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

    // Player
    public var player: SKSpriteNode!
    
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

        // Spawn enemies
        spawnEnemies(count: 10)
        
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
        //let touchLocation = touch.location(in: self) // Convert touch location to scene's coordinate system
        //print("Touched at position: \(touchLocation)")
        
        let touchLocationInJoystickOuterCircle = touch.location(in: joystickOuterCircle) // Convert touch location to joystick outer circle's coordinate system
        
        // Check if the touch occurred inside the inner circle of the joystick
        if joystickInnerCircle.contains(touchLocationInJoystickOuterCircle) {
            isJoystickActive = true
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
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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
        
        // Loop through enemies to check if they can attack the player
        for enemy in enemies {
            enemy.checkAndAttackPlayer(playerPosition: player.position, currentTime: currentTime)
        }

        // Healing
        if shouldHealPlayer(currentTime) {
            mp("Healing to ",playerCurrentHealth+1)
            increaseHealth(amount: 1,currentTime: currentTime)
        }

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
