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

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    // Joystick
    private var joystickOuterCircle: SKShapeNode!
    private var joystickInnerCircle: SKShapeNode!
    private var joystickRadius: CGFloat = 75.0 // Adjust as needed
    private var isJoystickActive = false
    
    // Harvest button
    private var harvestCircle: SKShapeNode!

    // Player
    public var player: Player!
    
    // Base
    public var base: SKSpriteNode!

    // Camera
    private var cameraNode = SKCameraNode()

    // World
    private var worldSize = CGSize(width: 0, height: 0)
    private var scaleFactor: CGFloat = 1
    
    // Enemies
    private var enemies: [Enemy] = []

    // Health
    private var healthBarGray: SKSpriteNode!
    private var healthBarRed: SKSpriteNode!
    
    // Resources
    var resources: [Resource] = []
    private var resourceCounter: ResourceCounter!
    private let resourceCollectionHarvestTime: TimeInterval = 1.0 // Adjust as needed
    private var lastResourceCollectionTime: TimeInterval = 0
    private var totalHarvestButtonHoldTime: TimeInterval = 0
    
    
    override func sceneDidLoad() {
        worldSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)

        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: worldSize)
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width/2, y: worldSize.height/2)
        background.zPosition = 0
        self.addChild(background)

        // Create player
        player = Player(color: .blue, size: CGSize(width: 25, height: 25))
        player.position = background.position
        player.zPosition = 3;
        player.delegate = self
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
        let coin = Coin(bounds: worldSize, resourceCount: 1, collectionHarvestTime: 0.1)
        addChild(coin)
        resources.append(coin)
        let wood = Wood(bounds:worldSize,resourceCount:10, collectionHarvestTime: 1.0)
        addChild(wood)
        resources.append(wood)
        let stone = Stone(bounds:worldSize,resourceCount:10, collectionHarvestTime: 2.0)
        addChild(stone)
        resources.append(stone)
        let ore = Ore(bounds:worldSize,resourceCount:10, collectionHarvestTime: 3.0)
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
            player.isHarvesting = true
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
        player.isHarvesting = false
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
            
    // Update the size of the red health bar based on current health percentage
    private func updateHealthBar() {
        let healthPercentage = player.currentHealth / player.totalHealth
        let newWidth = healthBarGray.size.width * healthPercentage
        healthBarRed.size.width = max(newWidth, 0) // Ensure width is non-negative
        
        // Set the anchor point of the health bar to the right
        healthBarRed.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Adjust the position of the health bar to align with the right edge of the gray bar
        healthBarRed.position.x = healthBarGray.position.x + healthBarGray.size.width / 2
    }
        
    // Update this method to show/hide the harvest circle based on the player's proximity to resources
    private func updateHarvestCircleVisibility() -> Resource? {
        // Check if there are any resources nearby
        for resource in resources {
            if player.frame.intersects(resource.frame) {
                // Show or hide the harvest circle accordingly
                harvestCircle.isHidden = false
                return resource
            }
        }
        harvestCircle.isHidden = true
        return nil
    }

    // Method to check for player-resource contact and collect resources
    private func checkAndCollectResources() {
        // Iterate through resources and check for player-resource contact
        for resource in resources {
            // Check if the total hold time exceeds the required harvest time
            if totalHarvestButtonHoldTime >= resource.collectionHarvestTime {
                // Check if the player's bounding box intersects with the resource's bounding box
                if player.frame.intersects(resource.frame) {
                    // Perform resource collection logic based on the resource type
                    switch resource {
                    case is Wood:
                        player.woodCount += 1
                        resourceCounter.updateWoodCount(player.woodCount)
                    case is Stone:
                        player.stoneCount += 1
                        resourceCounter.updateStoneCount(player.stoneCount)
                    case is Ore:
                        player.oreCount += 1
                        resourceCounter.updateOreCount(player.oreCount)
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
    }
    
    private func updateHarvestTime(currentTime: TimeInterval){
        // Don't update time if not harvesting
        guard player.isHarvesting else {
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
        let coin = Coin(bounds: worldSize, resourceCount: 1, collectionHarvestTime: 0.1) // Create a new coin instance
        coin.position = position // Position the coin at the location where the zombie died
        addChild(coin) // Add the coin to the scene
        
        // Add the coin to the resources array
        resources.append(coin)
    }

    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // logging
        let oldPlayerPosition = player.position
        
        player.move(joystickInnerCircle, isJoystickActive, worldSize)
        
        // Update the camera position to follow the player
        cameraNode.position = player.position

        // don't log when standing still
        if(oldPlayerPosition != player.position){
            //mp("player.position",player.position)
            //mp("cameraNode.position",cameraNode.position)
        }
        
        // Highlight + Attack closest enemy with a cooldown
        player.highlightClosestEnemy(radius: 200, enemies)
        if !player.isHarvesting {
            if let lastAttackTime = player.lastAttackTime {
                let timeSinceLastAttack = currentTime - lastAttackTime
                if timeSinceLastAttack >= player.attackCooldown {
                    // Only reset the cooldown if the attack was successful
                    if player.attackClosestEnemy(&enemies) {
                        player.lastAttackTime = currentTime
                    }
                }
            } else {
                player.lastAttackTime = currentTime
            }
        }

        // Get attacked + heal
        for enemy in enemies {
            if let damage = enemy.checkAndAttackPlayer(playerPosition: player.position, currentTime: currentTime){
                player.decreaseHealth(amount: damage)
            }
        }
        if player.shouldHeal(currentTime, isJoystickActive) {
            player.increaseHealth(amount: 1,currentTime: currentTime)
        }
        updateHealthBar()
        
        // Resource Collection
        if updateHarvestCircleVisibility() != nil {
            updateHarvestTime(currentTime: currentTime)
            checkAndCollectResources()
        }
        player.checkAndCollectCoins(resources: &resources)
        resourceCounter.updateCoinCount(player.coinCount)

    }
}
