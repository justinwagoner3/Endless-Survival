import SpriteKit

class BaseBarrier: SKShapeNode, Codable {
    var totalBarrierHealth: Int = 100
    var currentBarrierHealth: Int = 100


    enum CodingKeys: String, CodingKey {
        case totalBarrierHealth
        case currentBarrierHealth
        case frame
        case strokeColor
        case lineWidth
    }

    init(size: CGSize, strokeColor: UIColor, lineWidth: CGFloat) {
        let rect = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)
        super.init()
        self.path = CGPath(rect: rect, transform: nil)
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.zPosition = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.totalBarrierHealth, forKey: .totalBarrierHealth)
        try container.encode(self.currentBarrierHealth, forKey: .currentBarrierHealth)
        try container.encode(self.frame, forKey: .frame)
        try container.encode(self.lineWidth, forKey: .lineWidth)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let totalBarrierHealth = try container.decode(Int.self, forKey: .totalBarrierHealth)
        let currentBarrierHealth = try container.decode(Int.self, forKey: .currentBarrierHealth)
        let frame = try container.decode(CGRect.self, forKey: .frame)
        let lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        super.init()
        self.totalBarrierHealth = totalBarrierHealth
        self.currentBarrierHealth = currentBarrierHealth
        self.path = CGPath(rect: frame, transform: nil)
        self.strokeColor = .black
        self.lineWidth = lineWidth
        self.zPosition = 2
    }
}
