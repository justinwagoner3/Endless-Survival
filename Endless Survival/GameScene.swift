//
//  GameScene.swift
//  Endless Survival
//
//  Created by justin.wagoner on 3/23/24.
//

import SpriteKit
import GameplayKit

// print func for logging
func mp<T>(_ name: String, _ value: T) {
    print("\(name): \(value)")
}

extension GameScene {
    // Function to animate the player's attack with a white border
    func animatePlayerAttack() {
        let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.1)
        let attackAnimation = SKAction.sequence([scaleUpAction, scaleDownAction])
        player.run(attackAnimation)
        
        // Create a white border sprite
        let whiteBorder = SKSpriteNode(color: .white, size: CGSize(width: player.size.width + 25, height: player.size.height + 25))
        whiteBorder.zPosition = player.zPosition - 1 // Place behind the player
        whiteBorder.position = player.position
        addChild(whiteBorder)
        
        // Fade out and remove the white border sprite
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        whiteBorder.run(sequence)
    }
}

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    // Joystick
    private var joystickOuterCircle: SKShapeNode!
    private var joystickInnerCircle: SKShapeNode!
    private var joystickRadius: CGFloat = 75.0 // Adjust as needed
    private var isJoystickActive = false
    private var speedMultiplier: CGFloat = 2 // Adjust as needed
    
    // Harvest button
    private var harvestCircle: SKShapeNode!

    // Player
    public var player: SKSpriteNode!
    
    // Base
    public var base: SKSpriteNode!

    // Camera
    private var cameraNode = SKCameraNode()

    // World
    private var worldSize = CGSize(width: 0, height: 0)
    private var scaleFactor: CGFloat = 1
    
    // Enemies
    private var enemies: [Enemy] = []
    private var selectedEnemy: Enemy? // Store the currently targeted enemy

    // Health
    private var playerTotalHealth: CGFloat = 100.0 // Total health value
    private var playerCurrentHealth: CGFloat = 100.0 // Current health value
    private var healthBarGray: SKSpriteNode!
    private var healthBarRed: SKSpriteNode!
    private var lastInjuryTime: TimeInterval?
    private var lastHealTime: TimeInterval = 0
    
    // Resources
    var resources: [Resource] = []
    private var resourceCounter: ResourceCounter!
    private var playerCoinCount: Int = 0
    private var playerWoodCount: Int = 0
    private var playerStoneCount: Int = 0
    private var playerOreCount: Int = 0
    private let resourceCollectionHarvestTime: TimeInterval = 1.0 // Adjust as needed
    private var lastResourceCollectionTime: TimeInterval = 0
    private var isHarvesting = false
    private var totalHarvestButtonHoldTime: TimeInterval = 0
    private var harvestButtonStartTime: TimeInterval = 0
    



    // tbd
    private let attackCooldown: TimeInterval = 2.0
    private var lastAttackTime: TimeInterval? // Stores the time of the last attack

    override func sceneDidLoad() {
        worldSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)

        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: worldSize)
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width/2, y: worldSize.height/2)
        background.zPosition = 0
        self.addChild(background)

        // Create player
        player = SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 25))
        player.position = background.position
        player.zPosition = 3;
        self.addChild(player)

        // Set up the camera
        self.camera = cameraNode;
        cameraNode.position = player.position
        addChild(cameraNode)

        // Calculate the position of the outer circle in screen coordinates
        let joystickOuterCircleScreenPosition = CGPoint(x: worldSize.width * 0.1 * scaleFactor, y: worldSize.height * 0.2 * scaleFactor)

        // Convert screen coordinates to world coordinates
        //let joystickOuterCircleRelativeToCameraPosition = self.convert(joystickOuterCircleScreenPosition, to: cameraNode)
        let joystickOuterCircleRelativeToCameraPosition = CGPoint(x: -819.2000122070312, y: -283.40283203125)

        // Create outer circle (grey) as child of camera
        joystickOuterCircle = SKShapeNode(circleOfRadius: joystickRadius)
        joystickOuterCircle.position = joystickOuterCircleRelativeToCameraPosition
        joystickOuterCircle.fillColor = .gray
        joystickOuterCircle.alpha = 0.5
        joystickOuterCircle.zPosition = 1
        cameraNode.addChild(joystickOuterCircle)

        // Create inner circle (black) as child of outer circle
        joystickInnerCircle = SKShapeNode(circleOfRadius: 20) // Adjust as needed
        joystickInnerCircle.position = CGPoint.zero
        joystickInnerCircle.fillColor = .black
        joystickInnerCircle.zPosition = 2
        joystickOuterCircle.addChild(joystickInnerCircle)
        
        // Create harvest circle as child of camera
        harvestCircle = SKShapeNode(circleOfRadius: 50)
        harvestCircle.position = CGPoint(x: -850, y: -150)
        harvestCircle.fillColor = .gray
        harvestCircle.alpha = 0.5
        harvestCircle.zPosition = 1
        harvestCircle.isHidden = true
        cameraNode.addChild(harvestCircle)

        // Create health bar nodes
        let healthBarSize = CGSize(width: 400, height: 20) // Adjust size as needed
        healthBarGray = SKSpriteNode(color: .gray, size: healthBarSize)
        healthBarGray.zPosition = 10 // Place on top of other nodes
        healthBarGray.position = CGPoint(x: -750, y: 400)
        cameraNode.addChild(healthBarGray)
        
        healthBarRed = SKSpriteNode(color: .red, size: healthBarSize)
        healthBarRed.zPosition = 11 // Place on top of gray bar
        healthBarRed.position = healthBarGray.position
        cameraNode.addChild(healthBarRed)
        
        updateHealthBar()
        
        // Create resource counter node
        resourceCounter = ResourceCounter()
        resourceCounter.zPosition = 10
        resourceCounter.position = CGPoint(x: -400, y: 400)
        cameraNode.addChild(resourceCounter)


        // Spawn enemies
        spawnEnemies(count: 10)
        
        // Spawn resources
        let coin = Coin(bounds:worldSize,resourceCount:1)
        addChild(coin)
        resources.append(coin)
        let wood = Wood(bounds:worldSize,resourceCount:10)
        addChild(wood)
        resources.append(wood)
        let stone = Stone(bounds:worldSize,resourceCount:10)
        addChild(stone)
        resources.append(stone)
        let ore = Ore(bounds:worldSize,resourceCount:10)
        addChild(ore)
        resources.append(ore)
        
        // Create a base
        base = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 100))
        base.position = CGPoint(x: background.position.x - 200, y: background.position.y)
        base.zPosition = 2;
        self.addChild(base)

        // logging initial state
        mp("worldSize",worldSize)
        mp("player.position",player.position)
        mp("cameraNode.position",cameraNode.position)
        mp("joystickOuterCircleScreenPosition",joystickOuterCircleScreenPosition)
        mp("joystickOuterCircleRelativeToCameraPosition",joystickOuterCircleRelativeToCameraPosition)
        mp("joystickOuterCircle.position",joystickOuterCircle.position)

    }

    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        // Check if touching the joystick
        let touchLocationInJoystickOuterCircle = touch.location(in: joystickOuterCircle) // Convert touch location to joystick outer circle's coordinate system
        
        // Check if the touch occurred inside the inner circle of the joystick
        if joystickInnerCircle.contains(touchLocationInJoystickOuterCircle) {
            isJoystickActive = true
        }
        
        // Check if touching the harvest button
        let touchLocationInHarvestCircle = touch.location(in: cameraNode) // Convert touch location to harvest circle's coordinate system
        
        // Check if the touch occurred inside the harvest circle
        if harvestCircle.contains(touchLocationInHarvestCircle) {
            isHarvesting = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isJoystickActive, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self) // Convert to scene's coordinate system
        let touchLocationInjoystickOuterCircle = convert(touchLocation, to: joystickOuterCircle) // Convert to outer circle's coordinate system

        // Calculate distance and angle from outer circle's center
        let dx = touchLocationInjoystickOuterCircle.x
        let dy = touchLocationInjoystickOuterCircle.y
        let distance = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
                
        // Limit inner circle's movement to the outer circle's bounds
        if distance <= joystickRadius {
            joystickInnerCircle.position = touchLocationInjoystickOuterCircle
        } else {
            joystickInnerCircle.position = CGPoint(x: cos(angle) * joystickRadius,
                                           y: sin(angle) * joystickRadius)
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isJoystickActive = false
        // Reset inner circle position to outer circle's center
        joystickInnerCircle.position = CGPoint.zero
        isHarvesting = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
        
    // Method to spawn multiple enemies
    private func spawnEnemies(count: Int) {
        for _ in 0..<count {
            let enemy = Enemy(movementSpeed: 1.5, hitpoints: 10, bounds: worldSize)
            enemy.gameScene = self // Pass reference to GameScene
            addChild(enemy)
            enemies.append(enemy)
        }
    }
    
    // Method to highlight the closest enemy within a radius
    private func highlightClosestEnemy(radius: CGFloat) {
        // Reset previously selected enemy
        if let selectedEnemy = selectedEnemy {
            // Unhighlight the previously selected enemy
            selectedEnemy.unhighlight()
        }
        
        // Find the closest enemy within the radius
        var closestEnemy: Enemy? = nil
        var closestDistance: CGFloat = CGFloat.infinity
        for enemy in enemies {
            let distance = enemy.distance(to: player.position)
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
    private func attackClosestEnemy() -> Bool {
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
            // If hitpoints are zero or less, remove the enemy from the scene and enemies array
            closestEnemy.removeFromParent()
            spawnCoins(at: closestEnemy.position)
            if let index = enemies.firstIndex(of: closestEnemy) {
                enemies.remove(at: index)
            }
            selectedEnemy = nil // Reset selectedEnemy as it's no longer valid
        }
        
        // Return true indicating a successful attack
        return true
    }
    
    // Update the size of the red health bar based on current health percentage
    private func updateHealthBar() {
        let healthPercentage = playerCurrentHealth / playerTotalHealth
        let newWidth = healthBarGray.size.width * healthPercentage
        healthBarRed.size.width = max(newWidth, 0) // Ensure width is non-negative
        
        // Set the anchor point of the health bar to the right
        healthBarRed.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Adjust the position of the health bar to align with the right edge of the gray bar
        healthBarRed.position.x = healthBarGray.position.x + healthBarGray.size.width / 2
    }

    // Method to decrease player's health
    public func decreaseHealth(amount: CGFloat) {
        playerCurrentHealth -= amount
        // Ensure current health doesn't go below 0
        playerCurrentHealth = max(playerCurrentHealth, 0)
        updateHealthBar()
        
        // Update last injury time
        lastInjuryTime = CACurrentMediaTime()
    }
    
    // Method to increase player's health
    private func increaseHealth(amount: CGFloat, currentTime: TimeInterval) {
        playerCurrentHealth += amount
        // Ensure current health doesn't exceed total health
        playerCurrentHealth = min(playerCurrentHealth, playerTotalHealth)
        updateHealthBar()
        
        // Update last heal time
        lastHealTime = currentTime
    }

    // Method to check if the player should receive passive healing
    private func shouldHealPlayer(_ currentTime: TimeInterval) -> Bool {
        // Quick return false if player health is full
        if(playerCurrentHealth == playerTotalHealth){
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
    
    // Update this method to show/hide the harvest circle based on the player's proximity to resources
    private func updateHarvestCircleVisibility() {
        // Check if there are any resources nearby
        var resourcesNearby = false
        for resource in resources {
            if player.frame.intersects(resource.frame) {
                resourcesNearby = true
                break
            }
        }
        // Show or hide the harvest circle accordingly
        harvestCircle.isHidden = !resourcesNearby
    }
    
    // Method to check for player-resource contact and collect resources
    private func checkAndCollectResources() {
        // Iterate through resources and check for player-resource contact
        for resource in resources {
            // Check if the player's bounding box intersects with the resource's bounding box
            if player.frame.intersects(resource.frame) {
                // Perform resource collection logic based on the resource type
                switch resource {
                case is Coin:
                    playerCoinCount += 1
                    resourceCounter.updateCoinCount(playerCoinCount)
                case is Wood:
                    // Check if the total hold time exceeds the required harvest time
                    if totalHarvestButtonHoldTime >= resourceCollectionHarvestTime {
                        playerWoodCount += 1
                        resourceCounter.updateWoodCount(playerWoodCount)
                    }
                case is Stone:
                    // Check if the total hold time exceeds the required harvest time
                    if totalHarvestButtonHoldTime >= resourceCollectionHarvestTime {
                        playerStoneCount += 1
                        resourceCounter.updateStoneCount(playerStoneCount)
                    }
                case is Ore:
                    // Check if the total hold time exceeds the required harvest time
                    if totalHarvestButtonHoldTime >= resourceCollectionHarvestTime {
                        playerOreCount += 1
                        resourceCounter.updateOreCount(playerOreCount)
                    }
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
                totalHarvestButtonHoldTime = 0
                                    
                // Exit the loop after collecting one resource
                return
            }
        }
    }
    
    private func updateHarvestTime(currentTime: TimeInterval){
        guard isHarvesting else {
            // Don't update time if not harvesting
            lastUpdateTime = currentTime
            return
        }
        
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastUpdateTime
        mp("deltaTime",deltaTime)
        
        // Increment the total hold time by the time since the last frame
        totalHarvestButtonHoldTime += deltaTime
        mp("totalHarvestButtonHoldTime",totalHarvestButtonHoldTime)
        
        // Update the last update time for the next frame
        lastUpdateTime = currentTime
    }
    
    // Method to spawn coins when a zombie dies
    func spawnCoins(at position: CGPoint) {
        let coin = Coin(bounds: worldSize, resourceCount: 1) // Create a new coin instance
        coin.position = position // Position the coin at the location where the zombie died
        addChild(coin) // Add the coin to the scene
        
        // Add the coin to the resources array
        resources.append(coin)
    }

    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // logging
        let oldPlayerPosition = player.position
        
        // Calculate movement vector
        let dx = joystickInnerCircle.position.x
        let dy = joystickInnerCircle.position.y
        
        // Calculate movement direction
        let angle = atan2(dy, dx)
                
        // Calculate movement vector
        let movementX = cos(angle) * speedMultiplier
        let movementY = sin(angle) * speedMultiplier
        
        // Move the player
        if isJoystickActive {
            // Keep the player within bounds of the world
            let potentialPlayerX = player.position.x + movementX
            let potentialPlayerY = player.position.y + movementY
            
            let clampedPlayerX = max(min(potentialPlayerX, worldSize.width - player.size.width / 2), player.size.width / 2)
            let clampedPlayerY = max(min(potentialPlayerY, worldSize.height - player.size.height / 2), player.size.height / 2)
            
            
            player.position = CGPoint(x: clampedPlayerX, y: clampedPlayerY)
        }
        
        // Update the camera position to follow the player
        cameraNode.position = player.position

        // don't log when standing still
        if(oldPlayerPosition != player.position){
            //mp("player.position",player.position)
            //mp("cameraNode.position",cameraNode.position)
        }
        
        // Highlight + Attack closest enemy with a cooldown
        highlightClosestEnemy(radius: 200)
        if !isHarvesting {
            if let lastAttackTime = lastAttackTime {
                let timeSinceLastAttack = currentTime - lastAttackTime
                if timeSinceLastAttack >= attackCooldown {
                    // Only reset the cooldown if the attack was successful
                    if attackClosestEnemy() {
                        self.lastAttackTime = currentTime
                    }
                }
            } else {
                lastAttackTime = currentTime
            }
        }
        
        // Loop through enemies to check if they can attack the player
        for enemy in enemies {
            enemy.checkAndAttackPlayer(playerPosition: player.position, currentTime: currentTime)
        }

        // Healing
        if shouldHealPlayer(currentTime) {
            //mp("Healing to ",playerCurrentHealth+1)
            increaseHealth(amount: 1,currentTime: currentTime)
        }
        
        // Resource Collection
        updateHarvestCircleVisibility()
        updateHarvestTime(currentTime: currentTime)
        checkAndCollectResources()

    }


}

class Enemy: SKSpriteNode {
    
    // Reference to the GameScene instance
    weak var gameScene: GameScene?

    // Enemy attributes
    var movementSpeed: CGFloat
    var hitpoints: Int
    var bounds: CGSize
    
    private let attackRadius: CGFloat = 50.0 // Adjust as needed
    private let attackCooldown: TimeInterval = 2 // Adjust as needed
    private var lastAttackTime: TimeInterval = 0

    // Initializer with default appearance
    init(movementSpeed: CGFloat, hitpoints: Int, bounds: CGSize) {
        self.movementSpeed = movementSpeed
        self.hitpoints = hitpoints
        self.bounds = bounds
        
        let size = CGSize(width: 25, height: 25)
        let color = UIColor.red
        super.init(texture: nil, color: color, size: size)
        
        self.zPosition = 3
        self.position = randomPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to generate random position within worldSize
    private func randomPosition() -> CGPoint {
        let randomX = CGFloat.random(in: 0...(bounds.width - size.width))
        let randomY = CGFloat.random(in: 0...(bounds.height - size.height))
        return CGPoint(x: randomX, y: randomY)
    }
    
    // Method to calculate distance between two points
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // Method to highlight the enemy
    func highlight() {
        // Add code to visually highlight the enemy, e.g., change color or add a glow effect
        self.colorBlendFactor = 0.5
        self.color = UIColor.white
    }
    
    // Method to remove highlighting from the enemy
    func unhighlight() {
        // Add code to remove the visual highlighting effect applied to the enemy
        self.colorBlendFactor = 0.0
        self.color = UIColor.red
    }
    
    // Additional methods/functions for enemy behavior
    // For example, you can add a method to handle enemy movement
    func moveTowards(_ targetPosition: CGPoint) {
        // Add movement logic here
    }
    
    // Method to check if the player is within attack range and initiate attack if cooldown is over
    func checkAndAttackPlayer(playerPosition: CGPoint, currentTime: TimeInterval) {
        // Calculate distance between enemy and player
        let distanceToPlayer = distance(to: playerPosition)
        
        // Check if player is within attack range and if enough time has passed since last attack
        if distanceToPlayer <= attackRadius && currentTime - lastAttackTime >= attackCooldown {
            // Initiate attack
            // You can implement attack animation or logic here
            print("Enemy is attacking!")
            animateEnemyAttack()
            
            gameScene?.decreaseHealth(amount: 10) // Call decreaseHealth method

            // Update last attack time
            lastAttackTime = currentTime
        }
    }
    
    
}

extension Enemy {
    // Function to animate the enemy's attack with a black border
    func animateEnemyAttack() {
        let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.1)
        let attackAnimation = SKAction.sequence([scaleUpAction, scaleDownAction])
        run(attackAnimation)
        
        // Access the player instance
        if let player = gameScene?.player {
            // Temporarily change player color to red
            player.color = .red
            // Revert player color to blue after 0.5 seconds
            let revertColorAction = SKAction.run {
                player.color = .blue
            }
            let colorChangeDuration = 0.1
            let waitAction = SKAction.wait(forDuration: colorChangeDuration)
            let revertColorSequence = SKAction.sequence([waitAction, revertColorAction])
            gameScene?.run(revertColorSequence)
        }
        
        // Create a black border sprite
        let blackBorder = SKSpriteNode(color: .black, size: CGSize(width: size.width + 25, height: size.height + 25))
        blackBorder.zPosition = zPosition - 1 // Place behind the enemy
        blackBorder.position = position
        parent?.addChild(blackBorder)
        
        // Fade out and remove the black border sprite
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        blackBorder.run(sequence)
    }
}

class Resource: SKSpriteNode {
    // Common properties and methods for all resources can go here
    var bounds: CGSize
    var resourceCount: Int

    init(color: UIColor, bounds: CGSize, resourceCount: Int) {
        self.bounds = bounds
        self.resourceCount = resourceCount

        super.init(texture: nil, color: color, size: CGSize(width: 50, height: 50))

        self.zPosition = 2 // Or adjust zPosition as needed
        self.position = randomPosition()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to generate random position within worldSize
    private func randomPosition() -> CGPoint {
        let randomX = CGFloat.random(in: 0...(bounds.width - size.width))
        let randomY = CGFloat.random(in: 0...(bounds.height - size.height))
        return CGPoint(x: randomX, y: randomY)
    }
}

class Coin: Resource {
    init(bounds: CGSize, resourceCount: Int) {
        super.init(color: .yellow, bounds: bounds, resourceCount: resourceCount)
        // Additional coin-specific customization can go here
        self.size = CGSize(width: 25, height: 25) // Set the size of the coin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Wood: Resource {
    init(bounds: CGSize, resourceCount: Int) {
        super.init(color: .brown, bounds: bounds, resourceCount: resourceCount)
        // Additional wood-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Stone: Resource {
    init(bounds: CGSize, resourceCount: Int) {
        super.init(color: .gray, bounds: bounds, resourceCount: resourceCount)
        // Additional stone-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Ore: Resource {
    init(bounds: CGSize, resourceCount: Int) {
        super.init(color: .black, bounds: bounds, resourceCount: resourceCount)
        // Additional ore-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ResourceCounter: SKNode {
    private var coinCountLabel: SKLabelNode!
    private var woodCountLabel: SKLabelNode!
    private var stoneCountLabel: SKLabelNode!
    private var oreCountLabel: SKLabelNode!

    override init() {
        super.init()

        // Create and configure labels for coins, wood, stone, and ore counts
        coinCountLabel = createLabel(text: "Coins: 0")
        coinCountLabel.position = CGPoint(x: 0, y: 0)
        addChild(coinCountLabel)
        
        woodCountLabel = createLabel(text: "Wood: 0")
        woodCountLabel.position = CGPoint(x: 0, y: -30)
        addChild(woodCountLabel)

        stoneCountLabel = createLabel(text: "Stone: 0")
        stoneCountLabel.position = CGPoint(x: 0, y: -60) // Adjust vertical position as needed
        addChild(stoneCountLabel)

        oreCountLabel = createLabel(text: "Ore: 0")
        oreCountLabel.position = CGPoint(x: 0, y: -90) // Adjust vertical position as needed
        addChild(oreCountLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Method to update ore count
    func updateCoinCount(_ count: Int) {
        coinCountLabel.text = "Coins: \(count)"
    }

    // Method to update wood count
    func updateWoodCount(_ count: Int) {
        woodCountLabel.text = "Wood: \(count)"
    }

    // Method to update stone count
    func updateStoneCount(_ count: Int) {
        stoneCountLabel.text = "Stone: \(count)"
    }

    // Method to update ore count
    func updateOreCount(_ count: Int) {
        oreCountLabel.text = "Ore: \(count)"
    }
    

    // Helper method to create and configure label nodes
    private func createLabel(text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "Arial"
        label.fontSize = 30
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        return label
    }
}
