import SpriteKit

class UpgradeScene: SKScene, BaseInteractionDelegate {
    
    let increaseMovementButton = SKLabelNode(text: "")
    let addComponentButton = SKLabelNode(text: "")
    
    override func didMove(to view: SKView) {
        // Add a background color or image if desired
        self.backgroundColor = .white
        
        // Create a label for the return button
        let returnButton = SKLabelNode(text: "Return to Game")
        returnButton.fontSize = 24
        returnButton.fontColor = .black
        returnButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.6)
        returnButton.name = "returnButton" // Set a name for the button node
        self.addChild(returnButton)
        
        // Create a label for the increase movement button
        increaseMovementButton.fontSize = 24
        increaseMovementButton.fontColor = .black
        increaseMovementButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.4)
        increaseMovementButton.name = "increaseMovementButton" // Set a name for the button node
        self.addChild(increaseMovementButton)
        
        // Create a label for the add component button
        addComponentButton.text = "Add Component to Base"
        addComponentButton.fontSize = 24
        addComponentButton.fontColor = .black
        addComponentButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        addComponentButton.name = "addComponentButton" // Set a name for the button node
        self.addChild(addComponentButton)
        
        updateIncreaseMovementButtonText()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Check if the touch occurred on the return button
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "returnButton" {
            switchToGameScene()
        }
        
        // Check if the touch occurred on the increase movement button
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "increaseMovementButton" {
            // Call a method to increase the player's movement level
            increasePlayerMovementLevel()
        }
        
        // Check if the touch occurred on the add component button
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "addComponentButton" {
            print("Pressed button")
            // Call a method to add a component to the base
            addComponentToBase(WoodComponent())
        }
    }
    
    private func increasePlayerMovementLevel() {
        LevelManager.shared.movementLevel += 1.0
        UserDefaults.standard.set(LevelManager.shared.movementLevel, forKey: "movementLevel")
        updateIncreaseMovementButtonText()
    }

    private func updateIncreaseMovementButtonText() {
        increaseMovementButton.text = "Increase Movement: \(LevelManager.shared.movementLevel)"
    }
    
    func addComponentToBase(_ component: BaseComponent) {
        if let gameScene = self.view?.scene as? BaseInteractionDelegate {
            gameScene.addComponentToBase(component)
        }
    }

    private func switchToGameScene() {
        print("switching to game scene")

        // Get the screen size
        let screenSize = UIScreen.main.bounds.size
        
        // Determine the aspect ratio
        let aspectRatio = screenSize.width / screenSize.height
        
        // Define the base size for your scene (you can adjust this as needed)
        let baseWidth: CGFloat = 2048.0
        
        // Calculate the scaled size based on the aspect ratio
        let sceneSize = CGSize(width: baseWidth, height: baseWidth / aspectRatio)
        
        // Load the SKScene with the calculated size
        let gameScene = GameScene(size: sceneSize)
        gameScene.restoreGameState()
        gameScene.baseInteractionDelegate = self
        gameScene.scaleMode = .aspectFill
        
        // Present the scene
        self.view?.presentScene(gameScene)
    }
}
