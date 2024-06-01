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
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spawnBounds, forKey: .spawnBounds)
        try container.encode(resourceCount, forKey: .resourceCount)
        try container.encode(collectionHarvestTime, forKey: .collectionHarvestTime)
        try container.encode(totalHarvestButtonHoldTime, forKey: .totalHarvestButtonHoldTime)
        try container.encode(self.position, forKey: .curPosition)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        resourceCount = try container.decode(Int.self, forKey: .resourceCount)
        collectionHarvestTime = try container.decode(TimeInterval.self, forKey: .collectionHarvestTime)
        totalHarvestButtonHoldTime = try container.decode(TimeInterval.self, forKey: .totalHarvestButtonHoldTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)

        super.init(texture: nil, color: .clear, size: CGSize(width: 100, height: 100))
        self.position = curPosition
        self.zPosition = 2
    }

    init(textureName: String, spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        self.spawnBounds = spawnBounds
        self.resourceCount = resourceCount
        self.collectionHarvestTime = collectionHarvestTime
        let texture = SKTexture(imageNamed: textureName)

        super.init(texture: texture, color: .clear, size: CGSize(width: 100, height: 100))
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
        try super.encode(to: encoder)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.texture = SKTexture(imageNamed: "wood")
    }

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(textureName: "wood", spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}

class Stone: Resource {
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(textureName: "stone", spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.texture = SKTexture(imageNamed: "stone")
    }
}

class Ore: Resource {
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    init(spawnBounds: CGSize, resourceCount: Int, collectionHarvestTime: TimeInterval) {
        super.init(textureName: "ore", spawnBounds: spawnBounds, resourceCount: resourceCount, collectionHarvestTime: collectionHarvestTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.texture = SKTexture(imageNamed: "ore")
    }
}
