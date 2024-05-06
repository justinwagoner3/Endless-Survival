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
        
    // Joystick
    private var joystick: Joystick!

    // Player
    public var player: Player!
    
    // Base
    public var base: SKSpriteNode!
    private var baseCircle: SKShapeNode!

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
    private var harvestCircle: SKShapeNode!

    public func startNewGame(completion: @escaping () -> Void) {
        print("startNewGame")
        // Clear saved game state
        clearSavedGameState {
            print("done clearing game state")
        }
        completion()
    }
    
    func loadGame() {
    }

    override func sceneDidLoad() {
        //super.sceneDidLoad()
                
        worldSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)

        // Create the background (solid green)
        let background = SKSpriteNode(color: SKColor.green, size: worldSize)
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width/2, y: worldSize.height/2)
        background.zPosition = 0
        addChild(background)

        // Create player
        player = Player(color: .blue, size: CGSize(width: 25, height: 25))
        player.position = background.position
        player.zPosition = 3;
        //player.delegate = self
        addChild(player)

        // Set up the camera
        self.camera = cameraNode;
        cameraNode.position = player.position
        addChild(cameraNode)

        // Joystick
        joystick = Joystick(radius: 75.0, position: CGPoint(x: -819.2000122070312, y: -283.40283203125), parent: cameraNode)

        // Create harvest circle as child of camera
        harvestCircle = SKShapeNode(circleOfRadius: 50)
        harvestCircle.position = CGPoint(x: -850, y: -150)
        harvestCircle.fillColor = .gray
        harvestCircle.alpha = 0.5
        harvestCircle.zPosition = 1
        harvestCircle.isHidden = true
        cameraNode.addChild(harvestCircle)

        // Create base circle as child of camera
        baseCircle = SKShapeNode(circleOfRadius: 50)
        baseCircle.position = CGPoint(x: -850, y: -150)
        baseCircle.fillColor = .gray
        baseCircle.alpha = 0.5
        baseCircle.zPosition = 1
        baseCircle.isHidden = true
        cameraNode.addChild(baseCircle)

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
        addChild(base)
        
        //mp("initial wood count: ",player.woodCount)
        
        // Restore game state if available
        // if MainMenuScene calls switchToGameScene(newGame: true), then do not call restoreGameState
        // but if MainMenuScene calls switchToGameScene(newGame: false), then do call restoreGameState
        //restoreGameState()
        //mp("after wood count: ",player.woodCount)

    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        saveGameState()
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
        joystick.handleTouch(touch)

        // Check if touching the harvest button
        let touchLocation = touch.location(in: cameraNode) // Convert touch location to harvest circle's coordinate system

        // Check if the touch occurred inside the harvest circle
        if (harvestCircle.contains(touchLocation) && !harvestCircle.isHidden) {
            player.isHarvesting = true
        }
        
        // Check if touch occured inside base circle
        if (baseCircle.contains(touchLocation) && !baseCircle.isHidden){
            switchToUpgradeScene()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard joystick.isActive, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self) // Convert to scene's coordinate system
        let touchLocationInjoystickOuterCircle = convert(touchLocation, to: joystick.outerCircle) // Convert to outer circle's coordinate system

        joystick.updatePosition(touchLocationInjoystickOuterCircle)
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.reset()
        player.isHarvesting = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    private func switchToUpgradeScene(){
        print("switching to upgrade scene")
        // Present the upgrade screen when the base circle is touched
        // Get the screen size
        let screenSize = UIScreen.main.bounds.size
        
        // Determine the aspect ratio
        let aspectRatio = screenSize.width / screenSize.height
        
        // Define the base size for your scene (you can adjust this as needed)
        let baseWidth: CGFloat = 2048.0
        //let baseHeight: CGFloat = 1536.0
        
        // Calculate the scaled size based on the aspect ratio
        let sceneSize = CGSize(width: baseWidth, height: baseWidth / aspectRatio)
        
        // Load the SKScene with the calculated size
        let scene = UpgradeScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        
        // Present the scene
        self.view?.presentScene(scene)

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
    
    // Update this method to show/hide the harvest circle based on the player's proximity to resources
    private func updateBaseCircleVisibility(){
        if player.frame.intersects(base.frame) {
            // Show or hide the harvest circle accordingly
            baseCircle.isHidden = false
        }
        else{
            baseCircle.isHidden = true
        }
    }

    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        // logging
        let oldPlayerPosition = player.position
        
        player.move(joystick.innerCircle, joystick.isActive, worldSize)
        
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
        if player.shouldHeal(currentTime, joystick.isActive) {
            player.increaseHealth(amount: 1,currentTime: currentTime)
        }
        updateHealthBar()
        
        // Resource Collection
        if let resource = updateHarvestCircleVisibility() {
            player.updateHarvestTime(currentTime: currentTime, resource)
            player.checkAndCollectResources(resource, &resources)
            resourceCounter.updateWoodCount(player.woodCount)
            resourceCounter.updateStoneCount(player.stoneCount)
            resourceCounter.updateOreCount(player.oreCount)
        }
        
        // Base
        updateBaseCircleVisibility()
    }
    
    // Method to save the game state
    func saveGameState() {
        let gameState = GameState(playerHealth: player.currentHealth,
                                  woodCount: player.woodCount,
                                  stoneCount: player.stoneCount,
                                  oreCount: player.oreCount)
        // Serialize and save the gameState (e.g., using UserDefaults)
        // Example:
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "gameState")
        }
    }

    // Method to restore the game state
    public func restoreGameState() {
        // Retrieve the saved gameState (e.g., from UserDefaults)
        // Example:
        if let savedData = UserDefaults.standard.data(forKey: "gameState"),
           let gameState = try? JSONDecoder().decode(GameState.self, from: savedData) {
            // Update the scene based on the restored gameState
            player.currentHealth = gameState.playerHealth
            player.woodCount = gameState.woodCount
            player.stoneCount = gameState.stoneCount
            player.oreCount = gameState.oreCount
            // Update other scene elements as needed
            updateHealthBar()
            resourceCounter.updateWoodCount(player.woodCount)
            resourceCounter.updateStoneCount(player.stoneCount)
            resourceCounter.updateOreCount(player.oreCount)
        }
    }
    
    func clearSavedGameState(completion: @escaping () -> Void) {
        UserDefaults.standard.removeObject(forKey: "gameState")
        // Call the completion handler once the clearing is finished
        completion()
    }

}

struct GameState: Codable {
    var playerHealth: CGFloat
    var woodCount: Int
    var stoneCount: Int
    var oreCount: Int
    // Add more properties as needed
}

