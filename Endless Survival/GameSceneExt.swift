import SpriteKit

// Enum for Rarity
enum Rarity: String, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    // Computed property to return associated color
    var color: UIColor {
        switch self {
        case .common:
            return UIColor.gray
        case .uncommon:
            return UIColor.green
        case .rare:
            return UIColor.blue
        case .epic:
            return UIColor.purple
        case .legendary:
            return UIColor.orange
        }
    }
}

extension GameScene{
    // TODO - hardcoded, but only a problem if i ever have multiple bases
    func showUpgradeOverlay(in view: SKView) {
        guard upgradeOverlay == nil else { return }

        // Calculate overlay size and position using safe area insets
        //let safeAreaInsets = view.safeAreaInsets
        let overlaySize = CGSize(width: 1600, height: 900)

        // Set up upgradeOverlay using overlaySize and overlayPosition
        upgradeOverlay = SKSpriteNode(color: .white, size: overlaySize)
        upgradeOverlay?.zPosition = 100
        //upgradeOverlay?.alpha = 0.97
        upgradeOverlay?.position = CGPoint(x: 824.0, y: 768.0)

        isGamePaused = true
        self.isPaused = true

        // Create the close button
        //let returnButton = SKSpriteNode(imageNamed: "closeButton")
        let returnButton = SKLabelNode(text: "X")
        returnButton.name = "returnButton"
        returnButton.fontSize = 60
        returnButton.fontColor = .black
        returnButton.position = CGPoint(x: -(overlaySize.width / 2) + 50, y: overlaySize.height / 2 - 50)
        returnButton.zPosition = self.zPosition + 1
        upgradeOverlay?.addChild(returnButton)

        // Create the tab buttons
        let tabNames = ["Player", "Base", "Drones", "Workers"]
        let tabButtonWidth = overlaySize.width / CGFloat(tabNames.count)
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 60
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(overlaySize.width / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: overlaySize.height / 2 - 75)
            tabButton.zPosition = self.zPosition + 1
            upgradeOverlay?.addChild(tabButton)
        }

        showPlayerSubTabs()

        addChild(upgradeOverlay!)
    }

    func hideUpgradeOverlay() {
        upgradeOverlay?.removeFromParent()
        upgradeOverlay = nil
        isGamePaused = false
        self.isPaused = false
    }

    func clearSubTabs() {
        upgradeOverlay?.childNode(withName: "subTabs")?.removeFromParent()
    }
    
    func clearContent() {
        upgradeOverlay?.childNode(withName: "contentNode")?.removeFromParent()
    }

    func showPlayerSubTabs() {
        clearSubTabs()
        clearContent()
        
        let subTabs = SKNode()
        subTabs.name = "subTabs"
        
        // Create the tab buttons
        var tabNames = ["Stats", "Armor", "Tools", "4"]
        let tabButtonWidth = 1600 / CGFloat(tabNames.count)
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 150)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        tabNames = ["5", "6", "7", "8"]
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 200)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        
        upgradeOverlay?.addChild(subTabs)

        let contentNode = SKNode()
        contentNode.name = "contentNode"

        let increaseMovementButton = SKLabelNode(text: "Increase Movement: ")
        increaseMovementButton.fontSize = 24
        increaseMovementButton.fontColor = .black
        increaseMovementButton.position = CGPoint(x: 0, y: -50)
        increaseMovementButton.name = "increaseMovementButton"
        contentNode.addChild(increaseMovementButton)

        upgradeOverlay?.addChild(contentNode)
    }
    
    func showToolsContent() {
        clearContent()
        
        let contentNode = SKNode()
        contentNode.name = "contentNode"
        
        let columnCount = 3
        let columnWidth: CGFloat = 300
        let rowHeight: CGFloat = 50
        
        // Assuming player.tools is an array of Tool objects
        for (index, tool) in player.tools.enumerated() {
            let columnIndex = index % columnCount
            let rowIndex = index / columnCount
            
            let toolType = type(of: tool) == Pickaxe.self ? "Pickaxe" : "Axe"
            let equippedText = tool.isEquipped ? " (E)" : ""
            let toolLabel = SKLabelNode(text: "\(toolType) - Eff: \(tool.efficiency)\(equippedText)")
            toolLabel.fontSize = 24
            toolLabel.fontColor = tool.rarity.color
            toolLabel.position = CGPoint(x: CGFloat(columnIndex) * columnWidth - columnWidth,
                                         y: -CGFloat(rowIndex) * rowHeight + 100)
            toolLabel.name = "toolLabel\(index)"
            contentNode.addChild(toolLabel)
        }

        upgradeOverlay?.addChild(contentNode)
    }

    func showBaseSubTabs() {
        clearSubTabs()
        clearContent()

        let subTabs = SKNode()
        subTabs.name = "subTabs"
        
        // Create the tab buttons
        var tabNames = ["Components", "Barrier", "3", "4"]
        let tabButtonWidth = 1600 / CGFloat(tabNames.count)
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 150)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        tabNames = ["5", "6", "7", "8"]
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 200)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        
        upgradeOverlay?.addChild(subTabs)

        let contentNode = SKNode()
        contentNode.name = "contentNode"

        let addComponentButton = SKLabelNode(text: "Add Component to Base")
        addComponentButton.fontSize = 24
        addComponentButton.fontColor = .black
        addComponentButton.position = CGPoint(x: 0, y: -50)
        addComponentButton.name = "addComponentButton"
        contentNode.addChild(addComponentButton)

        upgradeOverlay?.addChild(contentNode)
    }

    func showDronesSubTabs() {
        clearSubTabs()
        clearContent()

        let subTabs = SKNode()
        subTabs.name = "subTabs"
        
        // Create the tab buttons
        var tabNames = ["Drone1", "Drone2", "Drone3", "4"]
        let tabButtonWidth = 1600 / CGFloat(tabNames.count)
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 150)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        tabNames = ["5", "6", "7", "8"]
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 200)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        
        upgradeOverlay?.addChild(subTabs)

        showDroneContent(for: 0)
    }
    
    func showDroneContent(for index: Int) {
        currentDroneSubTabIndex = index
        clearContent()

        let contentNode = SKNode()
        contentNode.name = "contentNode"
        
        if index < player.drones.count {
            //let drone = player.drones[index]

            let upgradeMovementButton = SKLabelNode(text: "Fix this")
            upgradeMovementButton.fontSize = 24
            upgradeMovementButton.fontColor = .black
            upgradeMovementButton.position = CGPoint(x: 0, y: -50)
            upgradeMovementButton.name = "fixThisButton"
            contentNode.addChild(upgradeMovementButton)
        } else {
            let createAssaultDroneButton = SKLabelNode(text: "Create Assault Drone")
            createAssaultDroneButton.fontSize = 24
            createAssaultDroneButton.fontColor = .black
            createAssaultDroneButton.position = CGPoint(x: 0, y: -50)
            createAssaultDroneButton.name = "createAssaultDroneButton"
            contentNode.addChild(createAssaultDroneButton)
            
            let createHealDroneButton = SKLabelNode(text: "Create Heal Drone")
            createHealDroneButton.fontSize = 24
            createHealDroneButton.fontColor = .black
            createHealDroneButton.position = CGPoint(x: 0, y: -100)
            createHealDroneButton.name = "createHealDroneButton"
            contentNode.addChild(createHealDroneButton)
            
            let createHarvestDroneButton = SKLabelNode(text: "Create Harvest Drone")
            createHarvestDroneButton.fontSize = 24
            createHarvestDroneButton.fontColor = .black
            createHarvestDroneButton.position = CGPoint(x: 0, y: -150)
            createHarvestDroneButton.name = "createHarvestDroneButton"
            contentNode.addChild(createHarvestDroneButton)
        }

        upgradeOverlay?.addChild(contentNode)
    }


    func showWorkersSubTabs() {
        clearSubTabs()
        clearContent()

        let subTabs = SKNode()
        subTabs.name = "subTabs"
        
        // Create the tab buttons
        var tabNames = ["Worker1", "Worker2", "Worker3", "Worker4"]
        let tabButtonWidth = 1600 / CGFloat(tabNames.count)
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 150)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        tabNames = ["Worker5", "Worker6", "Worker7", "Worker8"]
        for (index, name) in tabNames.enumerated() {
            let tabButton = SKLabelNode(text: name)
            tabButton.name = "\(name.lowercased())Tab"
            tabButton.fontSize = 40
            tabButton.fontColor = .black
            tabButton.position = CGPoint(x: -(1600 / 2) + (CGFloat(index) + 0.5) * tabButtonWidth, y: 900 / 2 - 200)
            tabButton.zPosition = self.zPosition + 1
            subTabs.addChild(tabButton)
        }
        
        upgradeOverlay?.addChild(subTabs)
        
        showWorkerContent(for: 0)
    }
    
    func showWorkerContent(for index: Int) {
        currentWorkerSubTabIndex = index
        clearContent()

        let contentNode = SKNode()
        contentNode.name = "contentNode"
        mp("workers.count",workers.count)
        
        if index < workers.count {
            let worker = workers[index]

            let upgradeMovementButton = SKLabelNode(text: "Upgrade Movement Level: \(worker.movementLevel)")
            upgradeMovementButton.fontSize = 24
            upgradeMovementButton.fontColor = .black
            upgradeMovementButton.position = CGPoint(x: 0, y: -50)
            upgradeMovementButton.name = "upgradeWorkerMovementButton"
            contentNode.addChild(upgradeMovementButton)
        } else {
            let createHarvesterButton = SKLabelNode(text: "Create Harvester Worker")
            createHarvesterButton.fontSize = 24
            createHarvesterButton.fontColor = .black
            createHarvesterButton.position = CGPoint(x: 0, y: -50)
            createHarvesterButton.name = "createHarvesterButton"
            contentNode.addChild(createHarvesterButton)
            
            let createShooterButton = SKLabelNode(text: "Create Shooter Worker")
            createShooterButton.fontSize = 24
            createShooterButton.fontColor = .black
            createShooterButton.position = CGPoint(x: 0, y: -100)
            createShooterButton.name = "createShooterButton"
            contentNode.addChild(createShooterButton)
        }

        upgradeOverlay?.addChild(contentNode)
    }
}
