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
    var lastAttackTime: TimeInterval = 0
    var radius: CGFloat = 500
    var fireRate: TimeInterval = 2
    var damage: CGFloat = 2
    var isAOE: Bool = false

    init(color: UIColor, isAOE: Bool) {
        self.isAOE = isAOE
        super.init(color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attack(_ enemies: inout [Enemy], currentTime: TimeInterval, playerCoinCount: inout Int) {
        // Check if enough time has passed since the last attack
        if currentTime - lastAttackTime >= fireRate {
            // Find the closest enemy within the radius
            var closestEnemy: Enemy? = nil
            var closestDistance: CGFloat = CGFloat.infinity
            for enemy in enemies {
                let distanceFromSentry = enemy.distance(to: self.position)
                if distanceFromSentry <= radius && distanceFromSentry < closestDistance {
                    closestEnemy = enemy
                    closestDistance = distanceFromSentry
                }
            }
            
            // If an enemy is found within range, attack it
            if let closestEnemy = closestEnemy {
                animateSentryComponentAttack()
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
                    // TODO - update this in all attack methods
                    enemy.decreaseHealth(Int(damage))
                    
                    // Check if the enemy's hitpoints have reached zero
                    // TODO - move this into decreaseHealth and update all attack methods
                    if enemy.hitpoints <= 0 {
                        playerCoinCount += enemy.coinValue
                        // Handle enemy defeat
                        enemy.removeFromParent()
                        if let index = enemies.firstIndex(of: enemy) {
                            enemies.remove(at: index)
                        }
                    }
                }
                // Update last attack time for fire rate cooldown
                lastAttackTime = currentTime
            }
        }
    }

}

class SentryComponent: AttackComponent{
    init() {
        super.init(color: .purple, isAOE: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RocketComponent: AttackComponent{
    var aoeRadius: CGFloat = 100
    
    init() {
        super.init(color: .orange, isAOE: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
