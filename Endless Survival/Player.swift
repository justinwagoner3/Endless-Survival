import SpriteKit
import GameplayKit

class Player : SKSpriteNode {
    
    // animation
    var idleTextures: [SKTexture] = []
    var idleAnimationAction: SKAction?
    var attackTextures: [SKTexture] = []

    // player
    var movementLevel: CGFloat = 5
    var totalHealth: CGFloat = 100.0
    var currentHealth: CGFloat = 100.0
    var coinCount: Int = 0
    var woodCount: Int = 0
    var stoneCount: Int = 0
    var oreCount: Int = 0
    var lastUpdateHarvestTime : TimeInterval = 0
    var isHarvesting = false
    var lastHealTime: TimeInterval = 0
    var lastInjuryTime: TimeInterval?
    var selectedEnemy: Enemy?
    // TODO these are not being saved in savegamestate, but should probably make player codable instead of doing what im doing
    var weapons: [Weapon] = [Pistol(isEquipped: true), AssaultRifle(), SniperRifle(), Rocket()]
    var equippedWeapon: Weapon = Pistol()
    var drones: [Drone] = []
    var tools: [Tool] = []
    var equippedPickaxe: Pickaxe = Pickaxe(rarity: .common, efficiency: 20)
    var equippedAxe: Axe = Axe(rarity: .common, efficiency: 20)
    var totalBagSpace: Int = 2
    var curBagCount: Int = 0
    var curBagWoodCount: Int = 0
    var curBagStoneCount: Int = 0
    var curBagOreCount: Int = 0
    var armors: [Armor] = []
    var equippedHeadArmor: HeadArmor?
    var equippedChestArmor: ChestArmor?
    var equippedLegArmor: LegArmor?

    init() {
        let texture = SKTexture(imageNamed: "player_idle0")
        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))
        loadIdleTextures()
        setupIdleAnimation()
        loadAttackTextures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Movement
    func move(_ joystick: Joystick, _ isJoystickActive: Bool, _ worldSize: CGSize){
        // Calculate distance between inner joystick and center of outer circle
        let dx = joystick.innerCircle.position.x
        let dy = joystick.innerCircle.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Calculate movement direction
        let angle = atan2(dy, dx)
        
        // Calculate movement multiplier based on joystick position
        var joystickRatio: CGFloat = 0.0
        if distance > 0 {
            joystickRatio = min(distance / joystick.radius, 1.0)
        }
                
        // Calculate movement vector
        let movementX = cos(angle) * movementLevel * joystickRatio
        let movementY = sin(angle) * movementLevel * joystickRatio
        
        // Move the player
        if isJoystickActive {
            // Keep the player within bounds of the world
            let potentialPlayerX = position.x + movementX
            let potentialPlayerY = position.y + movementY
            
            let clampedPlayerX = max(min(potentialPlayerX, worldSize.width - size.width / 2), size.width / 2)
            let clampedPlayerY = max(min(potentialPlayerY, worldSize.height - size.height / 2), size.height / 2)
            
            position = CGPoint(x: clampedPlayerX, y: clampedPlayerY)
        }
    }

    // Method to highlight the closest enemy within a radius
    func highlightClosestEnemy(radius: CGFloat, _ enemies: [Enemy]) {
        // Unhighlight old selected enemy, if there is one
        if let selectedEnemy = selectedEnemy {
            selectedEnemy.unhighlight()
        }
        
        // Find the closest enemy within the radius
        var closestEnemy: Enemy? = nil
        var closestDistance: CGFloat = CGFloat.infinity
        for enemy in enemies {
            let distance = enemy.distance(to: position)
            if distance <= radius && distance < closestDistance {
                closestDistance = distance
                closestEnemy = enemy
            }
        }
        
        // Highlight the closest enemy
        if let closestEnemy = closestEnemy {
            closestEnemy.highlight()
            selectedEnemy = closestEnemy
        } else {
            selectedEnemy = nil
        }
    }
    
    // Method to attack the highlighted enemy
    func attackClosestEnemy(_ enemies: inout [Enemy], _ currentTime: TimeInterval) {
        // If no enemy is selected, return false
        guard let closestEnemy = selectedEnemy else {
            return
        }
        
        if !isHarvesting {
            let timeSinceLastAttack = currentTime - equippedWeapon.lastAttackTime
            if timeSinceLastAttack >= equippedWeapon.fireRate {
                equippedWeapon.lastAttackTime = currentTime
                
                //print("attacking")
                animatePlayerAttack()
                
                var enemiesToAttack: [Enemy] = []
                
                // Add enemies to attack if isAOE
                if equippedWeapon.isAOE, let rocket = equippedWeapon as? Rocket {
                    for enemy in enemies {
                        let distanceFromTargetEnemy = closestEnemy.distance(to: enemy.position)
                        if distanceFromTargetEnemy <= rocket.aoeRadius {
                            enemiesToAttack.append(enemy)
                        }
                    }
                }
                else{
                    enemiesToAttack.append(closestEnemy)
                }
                // Perform attack logic
                for enemy in enemiesToAttack{
                    // TODO - update this in all attack methods
                    enemy.decreaseHealth(Int(equippedWeapon.damage))
                    
                    // Check if the enemy's hitpoints have reached zero
                    // TODO - move this into decreaseHealth and update all attack methods
                    if enemy.hitpoints <= 0 {
                        coinCount += enemy.coinValue
                        // Handle enemy defeat
                        enemy.removeFromParent()
                        if let index = enemies.firstIndex(of: enemy) {
                            enemies.remove(at: index)
                        }
                        // won't be able to move this into decrease health though
                        selectedEnemy = nil
                    }
                }
            }
        }        
    }

    // Method to check if the player should receive passive healing
    func shouldHeal(_ currentTime: TimeInterval, _ isJoystickActive: Bool) -> Bool {
        // Quick return false if player health is full
        if(currentHealth == totalHealth){
            return false
        }

        guard let lastInjuryTime = lastInjuryTime else {
            // If the player has never been injured, no need to passive healing to start
            return false
        }
        
        
        // Calculate time since last injury
        let timeSinceInjury = currentTime - lastInjuryTime
        
        // Check if the player is not moving
        let isPlayerMoving = isJoystickActive

        // Check if the player has not been injured in the last 5 seconds and is not moving
        if timeSinceInjury >= 5 && !isPlayerMoving {
            // Check if enough time has passed since the last healing
            if currentTime - lastHealTime >= 1.0 {
                return true
            }
        }
        
        return false
    }

    // Method to increase player's health
    func increaseHealth(amount: CGFloat, currentTime: TimeInterval) {
        currentHealth += amount
        // Ensure current health doesn't exceed total health
        currentHealth = min(currentHealth, totalHealth)
        
        // Update last heal time
        lastHealTime = currentTime
    }
    
    // Method to decrease player's health
    public func decreaseHealth(amount: CGFloat) {
        currentHealth -= amount
        // Ensure current health doesn't go below 0
        currentHealth = max(currentHealth, 0)
        
        // Update last injury time
        lastInjuryTime = CACurrentMediaTime()
    }

    func updateHarvestTime(currentTime: TimeInterval, _ resource: inout Resource){
        // Don't update time if not harvesting
        guard isHarvesting else {
            lastUpdateHarvestTime = currentTime
            return
        }
        
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastUpdateHarvestTime
        
        // Increment the total hold time by the time since the last frame
        resource.totalHarvestButtonHoldTime += deltaTime
        
        // Update the last update time for the next frame
        lastUpdateHarvestTime = currentTime
    }

    // Method to check for player-resource contact and collect resources
    func checkAndCollectResources(_ resource: inout Resource, _ resources: inout [Resource]) {
        if curBagCount < totalBagSpace {
            // Check if the total hold time exceeds the required harvest time
            if resource.totalHarvestButtonHoldTime >= resource.collectionHarvestTime {
                // Perform resource collection logic based on the resource type
                switch resource {
                case is Wood:
                    curBagWoodCount += 1
                case is Stone:
                    curBagStoneCount += 1
                case is Ore:
                    curBagOreCount += 1
                default:
                    break
                }
                curBagCount += 1
                // Update resource count
                resource.resourceCount -= 1
                if(resource.resourceCount <= 0){
                    resource.removeFromParent()
                    if let index = resources.firstIndex(of: resource) {
                        resources.remove(at: index)
                    }
                }
                
                resource.totalHarvestButtonHoldTime = 0
                
                return
            }
        }
        else{
            displayBagFullMessage()
            resource.totalHarvestButtonHoldTime = 0
        }
    }
    
    //if player.frame.intersects(resource.frame) {

    func depositBag(baseFrame: CGRect){
        if(self.frame.intersects(baseFrame)){
            woodCount += curBagWoodCount
            stoneCount += curBagStoneCount
            oreCount += curBagOreCount
            curBagWoodCount = 0
            curBagStoneCount = 0
            curBagOreCount = 0
            curBagCount = 0
        }
    }
    
    func addDrone(_ drone: Drone) {
        // Check if the player can have more drones
        guard drones.count < 3 else {
            print("Maximum number of drones reached.")
            return
        }
        drones.append(drone)
        // Set initial positions for the drones
        setInitialDronePositions()
        addChild(drone) 
    }
    
    private func setInitialDronePositions() {
        // Define positions relative to the player for the drones
        let dronePositions: [(CGFloat, CGFloat)] = [(-50, 50), (50, 50), (0, -50)]
        // Loop through the drones and set their positions
        for (index, drone) in drones.enumerated() {
            guard index < dronePositions.count else {
                break // Exit loop if there are more drones than positions
            }
            let position = dronePositions[index]
            drone.position = CGPoint(x: position.0, y: position.1)
            print(drone.position)
        }
    }
    
    func updateDronePositions() {
        // Loop through the drones and update their positions
        for drone in drones {
            // Define circular path parameters
            let radius: CGFloat = 50 // adjust the radius as needed
            let angularSpeed: CGFloat = 0.03 // adjust the speed as needed
            let center = CGPoint(x: 0, y: 0) // center of the circular path, relative to the player
            
            // Calculate current angle of the drone relative to the center
            let currentAngle = atan2(drone.position.y - center.y, drone.position.x - center.x)
            
            // Calculate new angle by adding angular speed
            let newAngle = currentAngle + angularSpeed
            
            // Calculate new position using polar coordinates relative to the center
            let newX = center.x + radius * cos(newAngle)
            let newY = center.y + radius * sin(newAngle)
            
            // Update drone position relative to the player
            drone.position = CGPoint(x: newX, y: newY)
        }
    }
    
    func addTool(_ tool: Tool){
        tools.append(tool)
    }
    
    func equipPickaxe(_ pickaxe: Pickaxe){
        
    }
    
    func equipAxe(_ axe: Axe){
        
    }

    
}
