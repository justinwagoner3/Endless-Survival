import SpriteKit

class Base: SKSpriteNode, Codable {
    let baseLevel2ComponentSize: Int = 75
    let baseLevel2TotalSize: Int = 225

    var baseLevel: Int = 1
    var components: [BaseComponent] = []
    var barrier: BaseBarrier!

    enum CodingKeys: String, CodingKey {
        case attackComponents
        case woodComponents
        case stoneComponents
        case oreComponents
        case barrier
        case baseLevel
        case curPosition
    }

    init() {
        super.init(texture: SKTexture(imageNamed: "base"), color: .clear, size: CGSize(width: 75, height: 75))
        self.zPosition = 2
        self.barrier = BaseBarrier(size: CGSize(width: baseLevel2TotalSize + 100, height: baseLevel2TotalSize + 100), strokeColor: .black, lineWidth: 2.0)
        self.addChild(barrier)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var woodComponents: [WoodComponent] = []
        var stoneComponents: [StoneComponent] = []
        var oreComponents: [OreComponent] = []
        // TODO implement specific logic for attack components like the resource ones
        var attackComponents: [AttackComponent] = []
        for component in components {
            if let woodComponent = component as? WoodComponent {
                woodComponents.append(woodComponent)
            }
            if let stoneComponent = component as? StoneComponent {
                stoneComponents.append(stoneComponent)
            }
            if let oreComponent = component as? OreComponent {
                oreComponents.append(oreComponent)
            }
            if let attackComponent = component as? AttackComponent {
                attackComponents.append(attackComponent)
            }
        }
        try container.encode(woodComponents, forKey: .woodComponents)
        try container.encode(stoneComponents, forKey: .stoneComponents)
        try container.encode(oreComponents, forKey: .oreComponents)
        try container.encode(attackComponents, forKey: .attackComponents)
        try container.encode(barrier, forKey: .barrier)
        try container.encode(baseLevel, forKey: .baseLevel)
        try container.encode(self.position, forKey: .curPosition)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let woodComponents = try container.decode([WoodComponent].self, forKey: .woodComponents)
        let stoneComponents = try container.decode([StoneComponent].self, forKey: .stoneComponents)
        let oreComponents = try container.decode([OreComponent].self, forKey: .oreComponents)
        let attackComponents = try container.decode([AttackComponent].self, forKey: .attackComponents)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)
        // components need to be children of Base so they are removed when base is removed
        components += woodComponents
        components += stoneComponents
        components += oreComponents
        components += attackComponents
        barrier = try container.decode(BaseBarrier.self, forKey: .barrier)
        baseLevel = try container.decode(Int.self, forKey: .baseLevel)
        super.init(texture: nil, color: .white, size: CGSize(width: 75, height: 75))
        self.zPosition = 2
        self.addChild(barrier)
        self.position = curPosition
        for component in components {
            self.addChild(component)
        }
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
            CGPoint(x: baseLevel2ComponentSize, y: -baseLevel2ComponentSize),    // Position 5
            CGPoint(x: baseLevel2ComponentSize, y: 0),     // Position 6
            CGPoint(x: baseLevel2ComponentSize, y: baseLevel2ComponentSize),   // Position 7
            CGPoint(x: 0, y: baseLevel2ComponentSize)      // Position 8
        ]

        for (index, component) in components.enumerated() {
            if index < offsets.count {
                let offset = offsets[index]
                component.position = CGPoint(x: offset.x, y: offset.y)
            }
        }
    }

    func addComponent(_ component: BaseComponent) {
        components.append(component)
        self.positionComponents()
        self.addChild(component)
    }
}
