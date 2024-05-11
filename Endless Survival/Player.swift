import SpriteKit
import GameplayKit

class Player : SKSpriteNode, Codable {
    
    //weak var delegate: PlayerDelegate?

    var totalHealth: CGFloat = 100.0
    var currentHealth: CGFloat = 100.0
    var coinCount: Int = 0
    var woodCount: Int = 0
    var stoneCount: Int = 0
    var oreCount: Int = 0
    var lastUpdateHarvestTime : TimeInterval = 0
    var movementSpeed: CGFloat = 2
    var isHarvesting = false
    var attackCooldown: TimeInterval = 2.0
    var lastAttackTime: TimeInterval? // Stores the time of the last attack
    var lastHealTime: TimeInterval = 0
    var lastInjuryTime: TimeInterval?
    var selectedEnemy: Enemy?

    init(color: UIColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
    }

    enum CodingKeys: String, CodingKey {
        case totalHealth
        case currentHealth
        case coinCount
        case woodCount
        case stoneCount
        case oreCount
        case lastUpdateHarvestTime
        case movementSpeed
        case isHarvesting
        case attackCooldown
        case lastAttackTime
        case lastHealTime
        case lastInjuryTime
        case selectedEnemy
        // Add more properties as needed
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalHealth = try container.decode(CGFloat.self, forKey: .totalHealth)
        currentHealth = try container.decode(CGFloat.self, forKey: .currentHealth)
        coinCount = try container.decode(Int.self, forKey: .coinCount)
        woodCount = try container.decode(Int.self, forKey: .woodCount)
        stoneCount = try container.decode(Int.self, forKey: .stoneCount)
        oreCount = try container.decode(Int.self, forKey: .oreCount)
        lastUpdateHarvestTime = try container.decode(TimeInterval.self, forKey: .lastUpdateHarvestTime)
        movementSpeed = try container.decode(CGFloat.self, forKey: .movementSpeed)
        isHarvesting = try container.decode(Bool.self, forKey: .isHarvesting)
        attackCooldown = try container.decode(TimeInterval.self, forKey: .attackCooldown)
        lastAttackTime = try container.decode(TimeInterval.self, forKey: .lastAttackTime)
        lastHealTime = try container.decode(TimeInterval.self, forKey: .lastHealTime)
        lastInjuryTime = try container.decode(TimeInterval.self, forKey: .lastInjuryTime)
        selectedEnemy = try container.decode(Enemy.self, forKey: .selectedEnemy)
        // Decode other properties as needed

        // Call superclass initializer
        super.init(texture: nil, color: .clear, size: .zero)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalHealth, forKey: .totalHealth)
        try container.encode(currentHealth, forKey: .currentHealth)
        try container.encode(coinCount, forKey: .coinCount)
        try container.encode(woodCount, forKey: .woodCount)
        try container.encode(stoneCount, forKey: .stoneCount)
        try container.encode(oreCount, forKey: .oreCount)
        try container.encode(lastUpdateHarvestTime, forKey: .lastUpdateHarvestTime)
        try container.encode(movementSpeed, forKey: .movementSpeed)
        try container.encode(isHarvesting, forKey: .isHarvesting)
        try container.encode(attackCooldown, forKey: .attackCooldown)
        try container.encode(lastAttackTime, forKey: .lastAttackTime)
        try container.encode(lastHealTime, forKey: .lastHealTime)
        try container.encode(lastInjuryTime, forKey: .lastInjuryTime)
        try container.encode(selectedEnemy, forKey: .selectedEnemy)
        // Encode other properties as needed
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Movement
    func move(_ joystickInnerCircle: SKShapeNode, _ isJoystickActive: Bool, _ worldSize: CGSize){
        // Calculate movement vector
        let dx = joystickInnerCircle.position.x
        let dy = joystickInnerCircle.position.y
        
        // Calculate movement direction
        let angle = atan2(dy, dx)
                
        // Calculate movement vector
        let movementX = cos(angle) * movementSpeed
        let movementY = sin(angle) * movementSpeed
        
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
        // Reset previously selected enemy
        if let selectedEnemy = selectedEnemy {
            // Unhighlight the previously selected enemy
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
    func attackClosestEnemy(_ enemies: inout [Enemy]) -> Bool {
        guard let closestEnemy = selectedEnemy else {
            // If no enemy is selected, return false
            return false
        }
        print("attacking")
        // Animate the attack
        animatePlayerAttack()

        // Decrease the enemy's hitpoints
        closestEnemy.hitpoints -= 1
        
        // Check if the enemy's hitpoints have reached zero
        if closestEnemy.hitpoints <= 0 {
            //if let delegate = delegate {
            //    delegate.playerDidKillEnemy(at: position)
            //}
            coinCount += closestEnemy.coinValue
            // If hitpoints are zero or less, remove the enemy from the scene and enemies array
            closestEnemy.removeFromParent()
            if let index = enemies.firstIndex(of: closestEnemy) {
                enemies.remove(at: index)
            }
            selectedEnemy = nil // Reset player.selectedEnemy as it's no longer valid
        }
        
        // Return true indicating a successful attack
        return true
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

    func updateHarvestTime(currentTime: TimeInterval, _ resource: Resource){
        // Don't update time if not harvesting
        guard isHarvesting else {
            lastUpdateHarvestTime = currentTime
            return
        }
        
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastUpdateHarvestTime
        mp("deltaTime",deltaTime)
        
        // Increment the total hold time by the time since the last frame
        resource.totalHarvestButtonHoldTime += deltaTime
        mp("totalHarvestButtonHoldTime",resource.totalHarvestButtonHoldTime)
        
        // Update the last update time for the next frame
        lastUpdateHarvestTime = currentTime
    }

    // Method to check for player-resource contact and collect resources
    func checkAndCollectResources(_ resource: Resource, _ resources: inout [Resource]) {
        // Check if the total hold time exceeds the required harvest time
        if resource.totalHarvestButtonHoldTime >= resource.collectionHarvestTime {
            // Perform resource collection logic based on the resource type
            switch resource {
            case is Wood:
                woodCount += 1
            case is Stone:
                stoneCount += 1
            case is Ore:
                oreCount += 1
            default:
                break
            }
            // Update resource count
            resource.resourceCount -= 1
            if(resource.resourceCount <= 0){
                resource.removeFromParent()
                if let index = resources.firstIndex(of: resource) {
                    resources.remove(at: index)
                }
            }
            
            // Reset the total hold time
            resource.totalHarvestButtonHoldTime = 0
                                
            // Exit the loop after collecting one resource
            return
        }
    }    
}

//protocol PlayerDelegate: AnyObject {
//    func playerDidKillEnemy(at position: CGPoint)
//}
