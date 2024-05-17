import SpriteKit

class BaseComponent: SKSpriteNode{
    init(color: UIColor) {
        super.init(texture: nil, color: color, size: CGSize(width: 75, height: 75))

        self.zPosition = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ResourceComponent: BaseComponent{
    var resourceLevel: Int = 1
    private var accumulatedTime: TimeInterval = 0
    private let collectInterval: TimeInterval = 10.0
    private var lastCheckTime: TimeInterval = 0

    override init(color: UIColor) {
        super.init(color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func autoCollectResources(_ player: inout Player, _ currentTime: TimeInterval) {
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastCheckTime
        
        // Increment the total hold time by the time since the last frame
        accumulatedTime += deltaTime
        
        // Update the last update time for the next frame
        lastCheckTime = currentTime

        if(accumulatedTime >= collectInterval){
            switch self {
            case is WoodComponent:
                player.woodCount += resourceLevel
            case is StoneComponent:
                player.stoneCount += resourceLevel
            case is OreComponent:
                player.oreCount += resourceLevel
            default:
                break
            }
            accumulatedTime = 0
        }
    }
}

class WoodComponent: ResourceComponent{
    init() {
        super.init(color: .brown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StoneComponent: ResourceComponent{
    init() {
        super.init(color: .gray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OreComponent: ResourceComponent{
    init() {
        super.init(color: .black)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AttackComponent: BaseComponent{
    
}
