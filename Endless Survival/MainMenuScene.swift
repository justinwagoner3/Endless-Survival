import SpriteKit


class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Add a background color or image if desired
        self.backgroundColor = .white
        
        // Create "Start New" button
        let startNewButton = SKLabelNode(text: "Start New")
        startNewButton.fontSize = 24
        startNewButton.fontColor = .black
        startNewButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.7)
        startNewButton.name = "startNewButton" // Set a name for the button node
        self.addChild(startNewButton)
        
        // Create "Load" button
        let loadButton = SKLabelNode(text: "Load")
        loadButton.fontSize = 24
        loadButton.fontColor = .black
        loadButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.5)
        loadButton.name = "loadButton" // Set a name for the button node
        self.addChild(loadButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Check if the touch occurred on the "Start New" button
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "startNewButton" {
            print("New Game")
            switchToGameScene(newGame: true)
        }
        
        // Check if the touch occurred on the "Load" button
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "loadButton" {
            print("Load Game")
            switchToGameScene(newGame: false)
        }
    }
    
    private func switchToGameScene(newGame: Bool){
        print("switching to game scene")

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
        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .aspectFill
        if !newGame{
            scene.restoreGameState()
        }

        // Present the scene
        self.view?.presentScene(scene)

    }

}
