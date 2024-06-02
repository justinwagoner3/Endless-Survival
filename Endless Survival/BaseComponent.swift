import SpriteKit

class BaseComponent: SKSpriteNode, Codable{
    // TODO - calculate the actual position based on the parent, used in attack
    // currently just using the base position as an easy fix
    //var globalPosition: CGPoint = .zero

    init(textureName: String) {
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: .clear, size: CGSize(width: 75, height: 75))
        self.zPosition = 2
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    func encode(to encoder: Encoder) throws {
        fatalError("encode(to:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ResourceComponent: BaseComponent{
    private let collectInterval: TimeInterval = 10.0

    var resourceLevel: Int
    private var remainingTime: TimeInterval = 10.0
    private var lastCheckTime: TimeInterval = 0

    init(textureName: String, resourceLevel: Int = 1) {
        self.resourceLevel = resourceLevel
        super.init(textureName: textureName)
    }
    
    enum CodingKeys: String, CodingKey {
        case resourceLevel
        case remainingTime
        case curPosition
    }
    
    override func encode(to encoder: Encoder) throws {
        mp("self.position at encode",self.position)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(resourceLevel, forKey: .resourceLevel)
        try container.encode(remainingTime, forKey: .remainingTime)
        try container.encode(self.position, forKey: .curPosition)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let resourceLevel = try container.decode(Int.self, forKey: .resourceLevel)
        let remainingTime = try container.decode(TimeInterval.self, forKey: .remainingTime)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)

        self.resourceLevel = resourceLevel
        self.remainingTime = remainingTime
        super.init(textureName: "")
        self.position = curPosition
        mp("self.position at decode",self.position)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func autoCollectResources(_ player: inout Player, _ currentTime: TimeInterval) {
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastCheckTime
        
        // Increment the total hold time by the time since the last frame
        remainingTime -= deltaTime
        
        // Update the last update time for the next frame
        lastCheckTime = currentTime

        if(remainingTime <= 0){
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
            remainingTime = collectInterval
        }
    }
}

class WoodComponent: ResourceComponent{
    init(resourceLevel: Int = 1) {
        super.init(textureName: "wood")
        self.resourceLevel = resourceLevel
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.texture = SKTexture(imageNamed: "wood")
    }
}

class StoneComponent: ResourceComponent{
    init(resourceLevel: Int = 1) {
        super.init(textureName: "stone")
        self.resourceLevel = resourceLevel
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.texture = SKTexture(imageNamed: "stone")
    }
}

class OreComponent: ResourceComponent{
    init(resourceLevel: Int = 1) {
        super.init(textureName: "ore")
        self.resourceLevel = resourceLevel
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.texture = SKTexture(imageNamed: "ore")
    }
}

class AttackComponent: BaseComponent{
    
    // animation
    var attackTextures: [SKTexture] = []
    var attackAnimationAction: SKAction?

    // attack component
    var lastAttackTime: TimeInterval = 0
    var radius: CGFloat = 500
    var fireRate: TimeInterval = 2
    var damage: CGFloat = 2
    var isAOE: Bool = false

    init(textureName: String, isAOE: Bool) {
        self.isAOE = isAOE
        super.init(textureName: textureName)
        loadAttackTextures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func attack(_ enemies: inout [Enemy], currentTime: TimeInterval, playerCoinCount: inout Int, animateEnemyAttack: Bool) -> Bool {
        // Check if enough time has passed since the last attack
        if currentTime - lastAttackTime >= fireRate {
            // Find the closest enemy within the radius
            var closestEnemy: Enemy? = nil
            var closestDistance: CGFloat = CGFloat.infinity
            for enemy in enemies {
                let distanceFromSentry = enemy.distance(to: parent!.position)
                if distanceFromSentry <= radius && distanceFromSentry < closestDistance {
                    closestEnemy = enemy
                    closestDistance = distanceFromSentry
                }
            }
            
            // If an enemy is found within range, attack it
            if let closestEnemy = closestEnemy {
                animateBowComponentAttack()
                var enemiesToAttack: [Enemy] = []
                
                // Add enemies to attack if isAOE
                if isAOE, let rocketComponent = self as? RocketComponent {
                    for enemy in enemies {
                        let distanceFromTargetEnemy = closestEnemy.distance(to: enemy.position)
                        if distanceFromTargetEnemy <= rocketComponent.aoeRadius {
                            enemiesToAttack.append(enemy)
                        }
                    }
                }
                else{
                    enemiesToAttack.append(closestEnemy)
                }
                // Perform attack logic
                for enemy in enemiesToAttack{
                    enemy.decreaseHealth(Int(damage), &enemies, playerCoinCount: &playerCoinCount, animate: animateEnemyAttack)
                }
                // Update last attack time for fire rate cooldown
                lastAttackTime = currentTime
                
                return true
            }
        }
        
        return false
    }

}

class BowComponent: AttackComponent{
    init() {
        super.init(textureName: "bowComponent0", isAOE: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class SentryComponent: AttackComponent{
    init() {
        super.init(textureName: "sentryComponent", isAOE: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class RocketComponent: AttackComponent{
    var aoeRadius: CGFloat = 100
    
    init() {
        super.init(textureName: "rocketLauncherComponent", isAOE: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
