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

    // TODO this will break once i try to add more components in the next ring
    func createBarrier() {
        let barrierSize = CGSize(width: (self.size.width + 500) * scaleFactor, height: (self.size.height + 500) * scaleFactor)
        let barrierRect = CGRect(origin: CGPoint(x: -barrierSize.width / 2, y: -barrierSize.height / 2), size: barrierSize)
        barrier = SKShapeNode(rect: barrierRect)
        barrier?.strokeColor = .black
        barrier?.lineWidth = 2.0
        barrier?.zPosition = self.zPosition

        if let barrier = barrier {
            self.addChild(barrier)
        }
    }
}
