import SpriteKit

class UpgradeScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Add a background color or image if desired
        self.backgroundColor = .white
        
        // Create a label for the button
        let returnButton = SKLabelNode(text: "Return to Game")
        returnButton.fontSize = 24
        returnButton.fontColor = .black
        returnButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        returnButton.name = "returnButton" // Set a name for the button node
        self.addChild(returnButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Check if the touch occurred on the return button
        if let node = self.atPoint(touchLocation) as? SKLabelNode, node.name == "returnButton" {
            print("switching to game scene")

            // Return to the GameScene
            if let gameScene = GameScene(fileNamed: "GameScene") {
                gameScene.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
        }
    }
}
