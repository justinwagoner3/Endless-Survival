import SpriteKit

class Base: SKSpriteNode, Codable {
    let baseLevel2ComponentSize: Int = 75
    let baseLevel2TotalSize: Int = 225

    var baseLevel: Int = 1
    var components: [BaseComponent] = []
    var barrier: BaseBarrier!

    enum CodingKeys: String, CodingKey {
        case components
        case barrier
        case baseLevel
    }

    init() {
        super.init(texture: nil, color: .white, size: CGSize(width: 75, height: 75))
        self.zPosition = 2
        self.barrier = BaseBarrier(size: CGSize(width: baseLevel2TotalSize + 100, height: baseLevel2TotalSize + 100), strokeColor: .black, lineWidth: 2.0)
        self.addChild(barrier)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(components, forKey: .components)
        try container.encode(barrier, forKey: .barrier)
        try container.encode(baseLevel, forKey: .baseLevel)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        components = try container.decode([BaseComponent].self, forKey: .components)
        barrier = try container.decode(BaseBarrier.self, forKey: .barrier)
        baseLevel = try container.decode(Int.self, forKey: .baseLevel)
        super.init(texture: nil, color: .white, size: CGSize(width: 75, height: 75))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func positionComponents() {
        let offsets = [
            CGPoint(x: -baseLevel2ComponentSize, y: baseLevel2ComponentSize),   // Position 1
            CGPoint(x: -baseLevel2ComponentSize, y: 0),    // Position 2
            CGPoint(x: -baseLevel2ComponentSize, y: -baseLevel2ComponentSize),  // Position 3
            CGPoint(x: 0, y: -baseLevel2ComponentSize),    // Position 4
            CGPoint(x: baseLevel2ComponentSize, y: baseLevel2ComponentSize),    // Position 5
            CGPoint(x: baseLevel2ComponentSize, y: 0),     // Position 6
            CGPoint(x: baseLevel2ComponentSize, y: -baseLevel2ComponentSize),   // Position 7
            CGPoint(x: 0, y: baseLevel2ComponentSize)      // Position 8
        ]

        for (index, component) in components.enumerated() {
            if index < offsets.count {
                let offset = offsets[index]
                component.position = CGPoint(x: self.position.x + offset.x, y: self.position.y + offset.y)
            }
        }
    }

    func addComponent(_ component: BaseComponent) {
        components.append(component)
        self.positionComponents()
    }
}
