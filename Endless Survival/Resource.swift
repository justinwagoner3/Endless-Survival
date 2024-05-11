import SpriteKit

class Resource: SKSpriteNode, Codable {
    var spawnBounds: CGSize
    var resourceCount: Int
    var collectionHarvestTime: TimeInterval
    var totalHarvestButtonHoldTime: TimeInterval = 0
    var colorData: Data // Store color data instead of UIColor directly


    enum CodingKeys: String, CodingKey {
        case spawnBounds
        case resourceCount
        case collectionHarvestTime
        case totalHarvestButtonHoldTime
        case curPosition
        case colorData // Add color data key

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spawnBounds, forKey: .spawnBounds)
        try container.encode(resourceCount, forKey: .resourceCount)
        try container.encode(collectionHarvestTime, forKey: .collectionHarvestTime)
        try container.encode(totalHarvestButtonHoldTime, forKey: .totalHarvestButtonHoldTime)
        try container.encode(self.position, forKey: .curPosition)
        try container.encode(colorData, forKey: .colorData) // Encode color data

    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        let resourceCount = try container.decode(Int.self, forKey: .resourceCount)
        let collectionHarvestTime = try container.decode(TimeInterval.self, forKey: .collectionHarvestTime)
        let totalHarvestButtonHoldTime = try container.decode(TimeInterval.self, forKey: .totalHarvestButtonHoldTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)
        let colorData = try container.decode(Data.self, forKey: .colorData) // Decode color data
        let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) ?? .clear // Convert color data back to UIColor

        self.init(color: color, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        self.totalHarvestButtonHoldTime = totalHarvestButtonHoldTime
        self.position = curPosition
    }

    init(color: UIColor, spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        self.colorData = try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) // Convert color to data
        self.spawnBounds = spawnBounds
        self.resourceCount = resourceCount
        self.collectionHarvestTime = collectionHarvestTime

        super.init(texture: nil, color: color, size: CGSize(width: 50, height: 50))

        self.zPosition = 2
        self.position = randomPosition()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func randomPosition() -> CGPoint {
        let randomX = CGFloat.random(in: 0...(spawnBounds.width - size.width))
        let randomY = CGFloat.random(in: 0...(spawnBounds.height - size.height))
        return CGPoint(x: randomX, y: randomY)
    }
}

class Wood: Resource {

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .brown, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional wood-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class Stone: Resource {
    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .gray, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional stone-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class Ore: Resource {
    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .black, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional ore-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
