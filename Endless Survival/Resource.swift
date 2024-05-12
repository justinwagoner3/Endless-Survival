import SpriteKit

class Resource: SKSpriteNode, Codable {
    var spawnBounds: CGSize
    var resourceCount: Int
    var collectionHarvestTime: TimeInterval
    var totalHarvestButtonHoldTime: TimeInterval = 0


    enum CodingKeys: String, CodingKey {
        case spawnBounds
        case resourceCount
        case collectionHarvestTime
        case totalHarvestButtonHoldTime
        case curPosition
    }
    
    func encode(to encoder: Encoder) throws {
        print("Resource encode")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spawnBounds, forKey: .spawnBounds)
        try container.encode(resourceCount, forKey: .resourceCount)
        try container.encode(collectionHarvestTime, forKey: .collectionHarvestTime)
        try container.encode(totalHarvestButtonHoldTime, forKey: .totalHarvestButtonHoldTime)
        try container.encode(self.position, forKey: .curPosition)

    }

    required convenience init(from decoder: Decoder) throws {
        print("Resource decode")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        let resourceCount = try container.decode(Int.self, forKey: .resourceCount)
        let collectionHarvestTime = try container.decode(TimeInterval.self, forKey: .collectionHarvestTime)
        let totalHarvestButtonHoldTime = try container.decode(TimeInterval.self, forKey: .totalHarvestButtonHoldTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)

        self.init(color: .clear, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        self.totalHarvestButtonHoldTime = totalHarvestButtonHoldTime
        self.position = curPosition
    }

    init(color: UIColor, spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
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

    override func encode(to encoder: Encoder) throws {
        print("Wood encode")
        try super.encode(to: encoder)

    }

    required convenience init(from decoder: Decoder) throws {
        print("Wood decode")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        let resourceCount = try container.decode(Int.self, forKey: .resourceCount)
        let collectionHarvestTime = try container.decode(TimeInterval.self, forKey: .collectionHarvestTime)
        let totalHarvestButtonHoldTime = try container.decode(TimeInterval.self, forKey: .totalHarvestButtonHoldTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)

        self.init(spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        self.totalHarvestButtonHoldTime = totalHarvestButtonHoldTime
        self.position = curPosition
    }

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .brown, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional wood-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Stone: Resource {
    
    override func encode(to encoder: Encoder) throws {
        print("Stone encode")
        try super.encode(to: encoder)
    }

    required convenience init(from decoder: Decoder) throws {
        print("Stone decode")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        let resourceCount = try container.decode(Int.self, forKey: .resourceCount)
        let collectionHarvestTime = try container.decode(TimeInterval.self, forKey: .collectionHarvestTime)
        let totalHarvestButtonHoldTime = try container.decode(TimeInterval.self, forKey: .totalHarvestButtonHoldTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)

        self.init(spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        self.totalHarvestButtonHoldTime = totalHarvestButtonHoldTime
        self.position = curPosition
    }

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .gray, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional stone-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Ore: Resource {
    
    override func encode(to encoder: Encoder) throws {
        print("Ore encode")
        try super.encode(to: encoder)

    }

    required convenience init(from decoder: Decoder) throws {
        print("Ore decode")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        let resourceCount = try container.decode(Int.self, forKey: .resourceCount)
        let collectionHarvestTime = try container.decode(TimeInterval.self, forKey: .collectionHarvestTime)
        let totalHarvestButtonHoldTime = try container.decode(TimeInterval.self, forKey: .totalHarvestButtonHoldTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)

        self.init(spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        self.totalHarvestButtonHoldTime = totalHarvestButtonHoldTime
        self.position = curPosition
    }

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(color: .black, spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
        // Additional ore-specific customization can go here
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
