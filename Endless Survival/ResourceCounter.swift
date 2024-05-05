import SpriteKit
import GameplayKit

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
