import SpriteKit
import GameplayKit

class Resource: SKSpriteNode {
    // Common properties and methods for all resources can go here
    var bounds: CGSize
    var resourceCount: Int
    var collectionHarvestTime: TimeInterval
    
    var totalHarvestButtonHoldTime: TimeInterval = 0


    init(color: UIColor, bounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        self.bounds = bounds
        self.resourceCount = resourceCount
        self.collectionHarvestTime = collectionHarvestTime

        super.init(texture: nil, color: color, size: CGSize(width: 50, height: 50))

        self.zPosition = 2 // Or adjust zPosition as needed
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
}

class Coin: Resource {
    init(bounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .yellow, bounds: bounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional coin-specific customization can go here
        self.size = CGSize(width: 25, height: 25) // Set the size of the coin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Wood: Resource {

    init(bounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .brown, bounds: bounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional wood-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Stone: Resource {
    init(bounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .gray, bounds: bounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional stone-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Ore: Resource {
    init(bounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .black, bounds: bounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional ore-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
