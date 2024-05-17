import SpriteKit

class Base: SKSpriteNode{
    var components: [BaseComponent] = []

    init(){
        super.init(texture: nil, color: .white, size: CGSize(width: 75, height: 75))
        self.zPosition = 2;

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
