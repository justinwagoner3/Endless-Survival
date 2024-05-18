import SpriteKit

class Base: SKSpriteNode, Codable {
    var components: [BaseComponent] = []
    var barrier = BaseBarrier(size: CGSize(width: 400, height: 400), strokeColor: .black, lineWidth: 2.0)

    enum CodingKeys: String, CodingKey {
        case components
        case barrier
    }

    init() {
        super.init(texture: nil, color: .white, size: CGSize(width: 75, height: 75))
        self.zPosition = 2
        self.addChild(barrier)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(components, forKey: .components)
        try container.encode(barrier, forKey: .barrier)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        components = try container.decode([BaseComponent].self, forKey: .components)
        barrier = try container.decode(BaseBarrier.self, forKey: .barrier)
        super.init(texture: nil, color: .white, size: CGSize(width: 75, height: 75))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func positionComponents() {
        let offsets = [
            CGPoint(x: -75, y: 75),   // Position 1
            CGPoint(x: -75, y: 0),    // Position 2
            CGPoint(x: -75, y: -75),  // Position 3
            CGPoint(x: 0, y: -75),    // Position 4
            CGPoint(x: 75, y: 75),    // Position 5
            CGPoint(x: 75, y: 0),     // Position 6
            CGPoint(x: 75, y: -75),   // Position 7
            CGPoint(x: 0, y: 75)      // Position 8
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
