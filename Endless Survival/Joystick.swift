import SpriteKit

class Joystick {
    var outerCircle: SKShapeNode
    var innerCircle: SKShapeNode
    private var radius: CGFloat
    var isActive = false
    
    var position: CGPoint {
        didSet {
            outerCircle.position = position
        }
    }
    
    var isActiveJoystick: Bool {
        return isActive
    }
    
    init(radius: CGFloat, position: CGPoint, parent: SKNode) {
        self.radius = radius
        self.position = position
        
        outerCircle = SKShapeNode(circleOfRadius: radius)
        outerCircle.position = position
        outerCircle.fillColor = .gray
        outerCircle.alpha = 0.5
        outerCircle.zPosition = 1
        
        innerCircle = SKShapeNode(circleOfRadius: 20)
        innerCircle.position = CGPoint.zero
        innerCircle.fillColor = .black
        innerCircle.zPosition = 2
        
        outerCircle.addChild(innerCircle)
        parent.addChild(outerCircle)
    }
    
    func handleTouch(_ touch: UITouch) {
        let touchLocation = touch.location(in: outerCircle)
        
        if innerCircle.contains(touchLocation) {
            isActive = true
        }
    }
    
    func updatePosition(_ touchLocation: CGPoint) {
        let dx = touchLocation.x
        let dy = touchLocation.y
        let distance = sqrt(dx * dx + dy * dy)
        let angle = atan2(dy, dx)
        
        if distance <= radius {
            innerCircle.position = touchLocation
        } else {
            innerCircle.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
        }
    }
    
    func reset() {
        isActive = false
        innerCircle.position = CGPoint.zero
    }
}
