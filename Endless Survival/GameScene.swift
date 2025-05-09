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
    
    // Upgrade Menu
    var upgradeOverlay: SKSpriteNode?
    var currentWorkerSubTabIndex: Int = 1
    var currentDroneSubTabIndex: Int = 1

    
    // Pause Button
    var isGamePaused: Bool = false
    private var pauseButton: SKSpriteNode!

    // Background
    private var background: SKSpriteNode!
    
    // Joystick
    private var joystick: Joystick!

    // Player
    public var player: Player!
    
    // Weapon
    public var weapon: Weapon!
    
    // Base
    public var base: Base!
    private var baseCircle: SKShapeNode!

    // Camera
    private var cameraNode = SKCameraNode()

    // World
    private let worldSizeScaleFactor: Int = 1
    private var worldSize = CGSize(width: 0, height: 0)
    
    // Enemies
    private var enemies: [Enemy] = []

    // Health
    private var healthBarGray: SKSpriteNode?
    private var healthBarRed: SKSpriteNode?
    
    // Resources
    var resources: [Resource] = []
    private var resourceCounter: ResourceCounter?
    private var harvestCircle: SKShapeNode!

    // Supply Drops
    var supplyDrops: [SupplyDrop] = []
    private var supplyDropCircle: SKShapeNode!

    // Workers
    var workers: [Worker] = []
    
    // Pause
    func togglePause() {
        isGamePaused.toggle()
        self.isPaused = isGamePaused
    }
    
    // Save/Load Game
    public func startNewGame() {
        print("startNewGame")
        // Clear saved game state
        clearSavedGameState()
        
        print("done clearing game state")
    }
    
    func loadGame() {
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
        // Set up world size
        worldSize = CGSize(width: 2048 * worldSizeScaleFactor, height: 1536 * worldSizeScaleFactor)
        
        // Create the background
        background = SKSpriteNode(color: SKColor.green, size: worldSize)
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = 0
        addChild(background)


        // Create Player + Tools
        player = Player()
        addChild(player)
        player.position = background.position
        // TODO - needed to increase this by a lot because player would appear behind base components; this is probably happening with workers and drones too
        player.zPosition = 10
        player.addTool(Axe(rarity: .common, efficiency: 20, isEquipped: true) )
        player.addTool(Axe(rarity: .uncommon, efficiency: 40))
        player.addTool(Axe(rarity: .rare, efficiency: 60))
        player.addTool(Axe(rarity: .epic, efficiency: 80))
        player.addTool(Axe(rarity: .legendary, efficiency: 100))
        player.addTool(Pickaxe(rarity: .common, efficiency: 20, isEquipped: true))
        player.addTool(Pickaxe(rarity: .uncommon, efficiency: 40))
        player.addTool(Pickaxe(rarity: .rare, efficiency: 60))
        player.addTool(Pickaxe(rarity: .epic, efficiency: 80))
        player.addTool(Pickaxe(rarity: .legendary, efficiency: 100))

        // Create a base
        base = Base()
        base.position = CGPoint(x: background.position.x - 200, y: background.position.y)
        addChild(base)
        
        // Add components to the base
        let woodComponent = WoodComponent()
        let stoneComponent = StoneComponent()
        let oreComponent = OreComponent()
        //let bowComponent = BowComponent()
        base.addComponent(woodComponent)
        base.addComponent(stoneComponent)
        base.addComponent(oreComponent)
        //base.addComponent(bowComponent)

        // Spawn resources
        let wood = Wood(spawnBounds: worldSize, resourceCount: 10, collectionHarvestTime: 1.0)
        addChild(wood)
        resources.append(wood)
        let stone = Stone(spawnBounds: worldSize, resourceCount: 10, collectionHarvestTime: 2.0)
        addChild(stone)
        resources.append(stone)
        let ore = Ore(spawnBounds: worldSize, resourceCount: 10, collectionHarvestTime: 3.0)
        addChild(ore)
        resources.append(ore)
        
        // Spawn resources
        let supplyDrop = SupplyDrop(spawnBounds: worldSize, tools: [Pickaxe(rarity: .legendary, efficiency: 99),Axe(rarity: .legendary, efficiency: 99)])
        addChild(supplyDrop)
        supplyDrops.append(supplyDrop)

        // Spawn enemies
        spawnEnemies(count: 20)


    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Set up the camera
        self.camera = cameraNode
        cameraNode.position = player.position
        addChild(cameraNode)
        let uiContainer = SKNode()
        cameraNode.addChild(uiContainer)

        // Create harvest circle as child of camera
        harvestCircle = SKShapeNode(circleOfRadius: 50)
        harvestCircle.position = CGPoint(x: -850, y: -150)
        harvestCircle.fillColor = .gray
        harvestCircle.alpha = 0.5
        harvestCircle.zPosition = 1
        harvestCircle.isHidden = true
        cameraNode.addChild(harvestCircle)
        
        // Create supplydrop circle as child of camera
        supplyDropCircle = SKShapeNode(circleOfRadius: 50)
        supplyDropCircle.position = CGPoint(x: -850, y: -150)
        supplyDropCircle.fillColor = .gray
        supplyDropCircle.alpha = 0.5
        supplyDropCircle.zPosition = 1
        supplyDropCircle.isHidden = true
        cameraNode.addChild(supplyDropCircle)

        // Create base circle as child of camera
        baseCircle = SKShapeNode(circleOfRadius: 50)
        baseCircle.position = CGPoint(x: -850, y: -150)
        baseCircle.fillColor = .gray
        baseCircle.alpha = 0.5
        baseCircle.zPosition = 1
        baseCircle.isHidden = true
        cameraNode.addChild(baseCircle)
        
        // UI Elements
        if let window = view.window {
            let safeAreaInsets = window.safeAreaInsets
            let adjustedWidth = size.width - safeAreaInsets.left - safeAreaInsets.right
            //let adjustedHeight = size.height - safeAreaInsets.top - safeAreaInsets.bottom
            
            // Calculate health bar size and position
            let healthBarSize = CGSize(width: adjustedWidth / 2, height: 20)
            let healthBarYPosition = size.height / 2 - safeAreaInsets.top - 40
            let healthBarXPosition = -size.width / 2 + safeAreaInsets.left + 20 + healthBarSize.width / 2

            // Create health bar nodes
            healthBarGray = SKSpriteNode(color: .gray, size: healthBarSize)
            if let healthBarGray = healthBarGray{
                healthBarGray.zPosition = 10
                healthBarGray.position = CGPoint(x: healthBarXPosition, y: healthBarYPosition)
                uiContainer.addChild(healthBarGray)
                healthBarRed = SKSpriteNode(color: .red, size: healthBarSize)
                if let healthBarRed = healthBarRed{
                    healthBarRed.zPosition = 11
                    healthBarRed.position = healthBarGray.position
                    uiContainer.addChild(healthBarRed)
                }
            }
            
            
            let joystickRadius: CGFloat = min(view.bounds.width, view.bounds.height) * 0.3 // Adjust the multiplier as needed
            let joystickPosition = CGPoint(x: -size.width / 2 + safeAreaInsets.left + joystickRadius * 1.2,
                                           y: -size.height / 2 + safeAreaInsets.bottom + joystickRadius * 1.2)
            joystick = Joystick(radius: joystickRadius, position: joystickPosition, parent: cameraNode)
            
            // Create pause button
            let pauseButtonSize = CGSize(width: 50, height: 50)
            pauseButton = SKSpriteNode(color: .yellow, size: pauseButtonSize)
            pauseButton.zPosition = 10
            let pauseButtonXPosition = size.width / 2 - safeAreaInsets.right - pauseButtonSize.width / 2 - 20
            let pauseButtonYPosition = size.height / 2 - safeAreaInsets.top - pauseButtonSize.height / 2 - 20
            pauseButton.position = CGPoint(x: pauseButtonXPosition, y: pauseButtonYPosition)
            uiContainer.addChild(pauseButton)

        }

        updateHealthBar()
        
        // Create resource counter node
        resourceCounter = ResourceCounter()
        if let resourceCounter = resourceCounter{
            resourceCounter.zPosition = 10
            resourceCounter.position = CGPoint(x: -400, y: 400)
            cameraNode.addChild(resourceCounter)
        }
                        
        // Example Worker setup (if needed)
        //let harvester = Harvester(color: .purple, size: CGSize(width: 25, height: 25))
        //harvester.position = CGPoint(x: background.position.x - 200, y: background.position.y)
        //harvester.zPosition = 3
        
        //let shooter = Shooter(color: .purple, size: CGSize(width: 25, height: 25))
        //shooter.position = CGPoint(x: background.position.x - 200, y: background.position.y)
        //shooter.zPosition = 3


        player.position = base.position
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
        let touchLocation = touch.location(in: cameraNode) // Convert touch location to camera's coordinate system
                
        if let upgradeOverlay = upgradeOverlay {
            let touchLocationInUpgradeOverlay = touch.location(in: upgradeOverlay) // Convert touch location to upgrade overlay's coordinate system
            
            if let node = upgradeOverlay.atPoint(touchLocationInUpgradeOverlay) as? SKLabelNode {
                print("Touched node: \(node.name ?? "Unknown")")
                switch node.name {
                case "returnButton":
                    print("Return button clicked")
                    hideUpgradeOverlay()
                // Player tab
                case "playerTab":
                    print("Player tab clicked")
                    showPlayerSubTabs()
                case "toolsTab":
                    print("toolsTab clicked")
                    showToolsContent()
                case "baseTab":
                    showBaseSubTabs()
                // Drone
                case "dronesTab":
                    print("Drones tab clicked")
                    showDronesSubTabs()
                case "drone1Tab":
                    print("Drone1tab clicked")
                    showDroneContent(for: 0)
                case "drone2Tab":
                    print("Drone2tab clicked")
                    showDroneContent(for: 1)
                case "drone3Tab":
                    print("Drone3tab clicked")
                    showDroneContent(for: 2)
                case "createAssaultDroneButton":
                    print("createAssaultDroneButton clicked")
                    player.addDrone(AssaultDrone())
                    showDroneContent(for: currentDroneSubTabIndex)
                case "createHealDroneButton":
                    print("createHealDroneButton clicked ")
                    player.addDrone(HealDrone())
                    showDroneContent(for: currentDroneSubTabIndex)
                case "createHarvestDroneButton":
                    print("createHarvestDroneButton clicked ")
                    player.addDrone(HarvestDrone())
                    showDroneContent(for: currentDroneSubTabIndex)
                // Workers
                case "workersTab":
                    print("workersTab clicked")
                    showWorkersSubTabs()
                case "worker1Tab":
                    print("Worker1Tab clicked")
                    showWorkerContent(for: 0)
                case "worker2Tab":
                    print("Worker2Tab clicked")
                    showWorkerContent(for: 1)
                case "worker3Tab":
                    print("Worker3Tab clicked")
                    showWorkerContent(for: 2)
                case "worker4Tab":
                    print("Worker4Tab clicked")
                    showWorkerContent(for: 3)
                case "worker5Tab":
                    print("Worker5Tab clicked")
                    showWorkerContent(for: 4)
                case "worker6Tab":
                    print("Worker6Tab clicked")
                    showWorkerContent(for: 5)
                case "worker7Tab":
                    print("Worker7Tab clicked")
                    showWorkerContent(for: 6)
                case "worker8Tab":
                    print("Worker8Tab clicked")
                    showWorkerContent(for: 7)
                case "createHarvesterButton":
                    print("createHarvesterButton clicked")
                    addWorker(Harvester())
                    showWorkerContent(for: currentWorkerSubTabIndex)
                case "createShooterButton":
                    print("createShooterButton clicked")
                    addWorker(Shooter())
                    showWorkerContent(for: currentWorkerSubTabIndex)
                case "upgradeWorkerMovementButton":
                    print("upgradeWorkerMovementButton clicked")
                    workers[currentWorkerSubTabIndex].movementLevel += 1
                    showWorkerContent(for: currentWorkerSubTabIndex)
                    
                default:
                    break
                }
            }
        }
        
        // Existing touch handling logic
        joystick.handleTouch(touch)
        
        // Check if the touch occurred inside the harvest circle
        if harvestCircle.contains(touchLocation) && !harvestCircle.isHidden {
            player.isHarvesting = true
        }
        
        // Check if the touch occurred inside the suppy drop circle
        if supplyDropCircle.contains(touchLocation) && !supplyDropCircle.isHidden {
            //player.isHarvesting = true
            collectSupplyDrop()
        }

        // Check if touch occurred inside base circle
        if baseCircle.contains(touchLocation) && !baseCircle.isHidden {
            if let view = self.view {
                showUpgradeOverlay(in: view)
            }
        }
        
        // Pause Button
        if pauseButton.contains(touchLocation) {
            togglePause()
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
            
    // Method to spawn multiple enemies
    private func spawnEnemies(count: Int) {
        for _ in 0..<count {
            let enemy = Enemy(movementSpeed: 1.5, hitpoints: 10, spawnBounds: worldSize)
            enemy.gameScene = self // Pass reference to GameScene
            addChild(enemy)
            enemies.append(enemy)
        }
    }
            
    // Update the size of the red health bar based on current health percentage
    private func updateHealthBar() {
        let healthPercentage = player.currentHealth / player.totalHealth
        if let healthBarGray = healthBarGray{
            if let healthBarRed = healthBarRed{
                let newWidth = healthBarGray.size.width * healthPercentage
                healthBarRed.size.width = max(newWidth, 0) // Ensure width is non-negative
                
                // Set the anchor point of the health bar to the right
                healthBarRed.anchorPoint = CGPoint(x: 1.0, y: 0.5)
                
                // Adjust the position of the health bar to align with the right edge of the gray bar
                healthBarRed.position.x = healthBarGray.position.x + healthBarGray.size.width / 2
            }
        }
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

    private func updateSupplyDropCircleVisibility() {
        supplyDropCircle.isHidden = true
        // Check if there are any resources nearby
        for supplyDrop in supplyDrops {
            if player.frame.intersects(supplyDrop.frame) {
                // Show or hide the harvest circle accordingly
                supplyDropCircle.isHidden = false
                return
            }
        }
    }
    
    private func collectSupplyDrop() {
        for supplyDrop in supplyDrops {
            if player.frame.intersects(supplyDrop.frame) {
                player.weapons += supplyDrop.weapons
                player.tools += supplyDrop.tools

                supplyDrop.removeFromParent()
                if let index = supplyDrops.firstIndex(of: supplyDrop) {
                    supplyDrops.remove(at: index)
                }
                return
            }
        }
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
    
    // Add Workers
    private func addWorker(_ worker: Worker){
        workers.append(worker)
        worker.position = CGPoint(x: background.position.x - 200, y: background.position.y)
        addChild(worker)
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }
        var animateEnemyAttack: Bool = true
        
        player.move(joystick, joystick.isActive, worldSize)
        
        // Update the camera position to follow the player
        cameraNode.position = player.position

        // Highlight + Attack closest enemy
        // TODO - move most of this logic into player class like i did for Drone class
        player.highlightClosestEnemy(radius: player.equippedWeapon.radius, enemies)
        if (player.attackClosestEnemy(&enemies, currentTime, animateEnemyAttack: animateEnemyAttack)){
            animateEnemyAttack = false
        }
        
        // Get attacked
        for enemy in enemies {
            if let damage = enemy.checkAndAttackPlayer(playerPosition: player.position, currentTime: currentTime){
                player.decreaseHealth(amount: damage)
            }
        }
        
        // Passive Healing
        if player.shouldHeal(currentTime, joystick.isActive) {
            player.increaseHealth(amount: 1,currentTime: currentTime)
        }
        
        // Resource Collection
        if var resource = updateHarvestCircleVisibility() {
            player.updateHarvestTime(currentTime: currentTime, &resource)
            player.checkAndCollectResources(&resource, &resources)
        }
        
        // Supply Drops - collected in touches began
        updateSupplyDropCircleVisibility()
        
        // Base Circle
        updateBaseCircleVisibility()
        
        // Move drones around player
        player.updateDronePositions()
        
        // AssaultDrones attack
        for drone in player.drones {
            if let assaultDrone = drone as? AssaultDrone {
                if(assaultDrone.attack(&enemies, currentTime: currentTime, playerPosition: player.position, playerCoinCount: &player.coinCount, animateEnemyAttack: animateEnemyAttack)){
                    animateEnemyAttack = false
                }
            }
            if let healDrone = drone as? HealDrone {
                healDrone.healPlayer(&player.currentHealth, player.totalHealth, currentTime)
            }
            if let harvestDrone = drone as? HarvestDrone {
                if var resource = harvestDrone.findResourceNearby(player.position, resources){
                    harvestDrone.updateHarvestTime(currentTime: currentTime, &resource)
                    harvestDrone.checkAndCollectResources(&resource, &resources, playerTotalBagSpace: player.totalBagSpace, playerCurBagCount: &player.curBagCount, playerCurBagWoodCount: &player.curBagWoodCount, playerCurBagStoneCount: &player.curBagStoneCount, playerCurBagOreCount: &player.curBagOreCount)
                }
            }
        }
        
        // Worker actions
        for worker in workers {
            if let harvester = worker as? Harvester {
                // Not on resource and has bag space: move to resource
                if(!harvester.isOnResource && harvester.bagSpace != 0){
                    harvester.moveToResource(resources: resources)
                }
                // On base: deposit
                else if(harvester.isOnBase){
                    harvester.depositBag(player: &player)
                }
                // Bag is full: return back to base
                else if(harvester.bagSpace == 0){
                    harvester.moveToBase(base: base, player: &player)
                    harvester.isOnResource = false
                }
                // On resource with space in bag: harvest
                else if(harvester.isOnResource && harvester.bagSpace != 0) {
                    if var resource = harvester.curResource{
                        harvester.updateHarvestTime(currentTime: currentTime, &resource)
                        harvester.checkAndCollectResources(&resource, &resources)
                    }
                }
                else{
                    print("worker doesn't know what to do")
                }
            }
            if let shooter = worker as? Shooter {
                shooter.walkTowardsEnemy(enemies: enemies)
                if(shooter.attack(&enemies, currentTime: currentTime, playerCoinCount: &player.coinCount, animateEnemyAttack: animateEnemyAttack)){
                    animateEnemyAttack = false
                }
            }
        }
        
        // Base actions
        for baseComponent in base.components {
            if let resourceComponent = baseComponent as? ResourceComponent {
                resourceComponent.autoCollectResources(&player, currentTime)
            }
            if let attackComponent = baseComponent as? AttackComponent {
                if(attackComponent.attack(&enemies, currentTime: currentTime, playerCoinCount: &player.coinCount, animateEnemyAttack: animateEnemyAttack)){
                    animateEnemyAttack = false
                }
            }
        }
        
        // Deposit Bag
        player.depositBag(baseFrame: base.frame)
        
        // Animation
        player.updatePlayerState(isJoystickActive: joystick.isActive)
        
        // UI Update
        resourceCounter?.updateCoinCount(player.coinCount)
        resourceCounter?.updateWoodCount(player.woodCount)
        resourceCounter?.updateStoneCount(player.stoneCount)
        resourceCounter?.updateOreCount(player.oreCount)
        resourceCounter?.updateBagCount(player.curBagCount)
        updateHealthBar()

    }
    
    // Method to save the game state
    // TODO - not currently saving anything about drones
    func saveGameState() {
        print("saveGameState")
        var wood: [Wood] = []
        var stone: [Stone] = []
        var ore: [Ore] = []
        for resource in resources{
            if resource is Wood{
                wood.append(resource as! Wood)
            }
            if resource is Stone{
                stone.append(resource as! Stone)
            }
            if resource is Ore{
                ore.append(resource as! Ore)
            }
        }
        let gameState = GameState(totalHealth: player.totalHealth,
                                  currentHealth: player.currentHealth,
                                  coinCount: player.coinCount,
                                  woodCount: player.woodCount,
                                  stoneCount: player.stoneCount,
                                  oreCount: player.oreCount,
                                  lastUpdateHarvestTime: player.lastUpdateHarvestTime,
                                  movementLevel: player.movementLevel,
                                  isHarvesting: player.isHarvesting,
                                  lastHealTime: player.lastHealTime,
                                  lastInjuryTime: player.lastInjuryTime ?? 0,
                                  enemies: enemies,
                                  wood: wood,
                                  stone: stone,
                                  ore: ore,
                                  base: base)
        // Serialize and save the gameState (e.g., using UserDefaults)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "gameState")
        }

    }

    // Method to restore the game state
    public func restoreGameState() {
        print("restoreGameState")
        if let savedData = UserDefaults.standard.data(forKey: "gameState"),
           let gameState = try? JSONDecoder().decode(GameState.self, from: savedData) {
            print("found saved data")
            // Restore the player
            player.totalHealth = gameState.totalHealth
            player.currentHealth = gameState.currentHealth
            player.coinCount = gameState.coinCount
            player.woodCount = gameState.woodCount
            player.stoneCount = gameState.stoneCount
            player.oreCount = gameState.oreCount
            player.lastUpdateHarvestTime = gameState.lastUpdateHarvestTime
            player.movementLevel = gameState.movementLevel
            player.isHarvesting = gameState.isHarvesting
            player.lastHealTime = gameState.lastHealTime
            player.lastInjuryTime = gameState.lastInjuryTime
            
            // Restore enemies
            for enemy in enemies{
                enemy.removeFromParent()
            }
            for enemy in gameState.enemies{
                addChild(enemy)
            }
            enemies = gameState.enemies
            
            // Restore resources
            for resource in resources{
                resource.removeFromParent()
            }
            
            resources = []
            for wood in gameState.wood{
                addChild(wood)
                resources.append(wood)
            }
            for stone in gameState.stone{
                addChild(stone)
                resources.append(stone)
            }
            for ore in gameState.ore{
                addChild(ore)
                resources.append(ore)
            }
            
            // Restore base
            base.removeFromParent()
            base = gameState.base
            
            addChild(base)
            
            // Update other scene elements as needed
            updateHealthBar()
            resourceCounter?.updateWoodCount(player.woodCount)
            resourceCounter?.updateStoneCount(player.stoneCount)
            resourceCounter?.updateOreCount(player.oreCount)
            resourceCounter?.updateCoinCount(player.coinCount)

        }
        else{
            print("something wrong with saved data. might not exist if player hit New Game, then never saved before trying to select Load")
        }
    }

    
    func clearSavedGameState() {
        print("clearSavedGameState")
        UserDefaults.standard.removeObject(forKey: "gameState")
        UserDefaults.standard.removeObject(forKey: "movementLevel")
    }

}

struct GameState: Codable {
    var totalHealth: CGFloat
    var currentHealth: CGFloat
    var coinCount: Int
    var woodCount: Int
    var stoneCount: Int
    var oreCount: Int
    var lastUpdateHarvestTime: TimeInterval
    var movementLevel: CGFloat
    var isHarvesting: Bool
    var lastHealTime: TimeInterval
    var lastInjuryTime: TimeInterval
    var enemies: [Enemy]
    var wood: [Wood]
    var stone: [Stone]
    var ore: [Ore]
    var base: Base
}
