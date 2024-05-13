import SpriteKit

class Base: SKSpriteNode{
    init(){
        super.init(texture: nil, color: .white, size: CGSize(width: 100, height: 100))
        self.zPosition = 2;

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
