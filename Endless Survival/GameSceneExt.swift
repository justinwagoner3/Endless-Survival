import SpriteKit

extension GameScene{
    // Upgrade
    // TODO - hardcoded, but only a problem if i ever have multiple bases
    func showUpgradeOverlay(in view: SKView) {
        guard upgradeOverlay == nil else { return }

        // Calculate overlay size and position using safe area insets
        //let safeAreaInsets = view.safeAreaInsets
        let overlaySize = CGSize(width: 1600, height: 900)

        // Set up upgradeOverlay using overlaySize and overlayPosition
        upgradeOverlay = SKSpriteNode(color: .white, size: overlaySize)
        upgradeOverlay?.zPosition = 100
        upgradeOverlay?.alpha = 0.97
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

        showPlayerUpgradeContent()

        addChild(upgradeOverlay!)
    }

    func hideUpgradeOverlay() {
        upgradeOverlay?.removeFromParent()
        upgradeOverlay = nil
        isGamePaused = false
        self.isPaused = false
    }

    func clearUpgradeContent() {
        upgradeOverlay?.childNode(withName: "contentNode")?.removeFromParent()
        upgradeOverlay?.childNode(withName: "subTabs")?.removeFromParent()
    }

    func showPlayerUpgradeContent() {
        clearUpgradeContent()
        
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

        let increaseMovementButton = SKLabelNode(text: "Increase Movement: \(LevelManager.shared.movementLevel)")
        increaseMovementButton.fontSize = 24
        increaseMovementButton.fontColor = .black
        increaseMovementButton.position = CGPoint(x: 0, y: -50)
        increaseMovementButton.name = "increaseMovementButton"
        contentNode.addChild(increaseMovementButton)

        upgradeOverlay?.addChild(contentNode)
    }

    func showBaseUpgradeContent() {
        clearUpgradeContent()

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

    func showDronesUpgradeContent() {
        clearUpgradeContent()

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

        let contentNode = SKNode()
        contentNode.name = "contentNode"

        let upgradeDroneButton = SKLabelNode(text: "Upgrade Drone")
        upgradeDroneButton.fontSize = 24
        upgradeDroneButton.fontColor = .black
        upgradeDroneButton.position = CGPoint(x: 0, y: -50)
        upgradeDroneButton.name = "upgradeDroneButton"
        contentNode.addChild(upgradeDroneButton)

        upgradeOverlay?.addChild(contentNode)
    }

    func showWorkersUpgradeContent() {
        clearUpgradeContent()

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

        let contentNode = SKNode()
        contentNode.name = "contentNode"

        let upgradeWorkerButton = SKLabelNode(text: "Add Worker")
        upgradeWorkerButton.fontSize = 24
        upgradeWorkerButton.fontColor = .black
        upgradeWorkerButton.position = CGPoint(x: 0, y: -50)
        upgradeWorkerButton.name = "addWorkerButton"
        contentNode.addChild(upgradeWorkerButton)

        upgradeOverlay?.addChild(contentNode)
    }

}
