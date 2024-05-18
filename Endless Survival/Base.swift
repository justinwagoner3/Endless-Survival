import SpriteKit

class Base: SKSpriteNode {
    var components: [BaseComponent] = []
    var barrier: SKShapeNode?
    var barrierHealth: Int = 100
    var scaleFactor: CGFloat

    init(_ scaleFactor: CGFloat) {
        self.scaleFactor = scaleFactor
        super.init(texture: nil, color: .white, size: CGSize(width: 150 * scaleFactor, height: 150 * scaleFactor))
        self.zPosition = 2
        self.createBarrier()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func positionComponents() {
        let offsets = [
            CGPoint(x: -150 * scaleFactor, y: 150 * scaleFactor),   // Position 1
            CGPoint(x: -150 * scaleFactor, y: 0),    // Position 2
            CGPoint(x: -150 * scaleFactor, y: -150 * scaleFactor),  // Position 3
            CGPoint(x: 0, y: -50 * scaleFactor),    // Position 4
            CGPoint(x: 150 * scaleFactor, y: 150 * scaleFactor),    // Position 5
            CGPoint(x: 150 * scaleFactor, y: 0),     // Position 6
            CGPoint(x: 150 * scaleFactor, y: -150 * scaleFactor),   // Position 7
            CGPoint(x: 0, y: 50 * scaleFactor)      // Position 8
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

    func createBarrier() {
        let fenceSize = CGSize(width: self.size.width + 160, height: self.size.height + 160)
        let fenceRect = CGRect(origin: CGPoint(x: -fenceSize.width / 2, y: -fenceSize.height / 2), size: fenceSize)
        barrier = SKShapeNode(rect: fenceRect)
        barrier?.strokeColor = .black
        barrier?.lineWidth = 2.0
        barrier?.zPosition = self.zPosition

        if let fence = barrier {
            self.addChild(fence)
        }
    }
}
