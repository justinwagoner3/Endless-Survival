import SpriteKit

class Drone: SKSpriteNode, Codable {
    var radius: CGFloat
    var fireRate: TimeInterval
    var damage: CGFloat
    var lastAttackTime: TimeInterval

    enum CodingKeys: String, CodingKey {
        case radius
        case fireRate
        case damage
        case lastAttackTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(fireRate, forKey: .fireRate)
        try container.encode(damage, forKey: .damage)
        try container.encode(lastAttackTime, forKey: .lastAttackTime)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let radius = try container.decode(CGFloat.self, forKey: .radius)
        let fireRate = try container.decode(TimeInterval.self, forKey: .fireRate)
        let damage = try container.decode(CGFloat.self, forKey: .damage)
        let lastAttackTime = try container.decode(TimeInterval.self, forKey: .lastAttackTime)

        self.radius = radius
        self.fireRate = fireRate
        self.damage = damage
        self.lastAttackTime = lastAttackTime
        
        let size = CGSize(width: 25, height: 25)
        let color = UIColor.blue
        super.init(texture: nil, color: color, size: size)
        
        self.zPosition = 3

    }
    
    init(radius: CGFloat, fireRate: TimeInterval, damage: CGFloat) {
        self.radius = radius
        self.fireRate = fireRate
        self.damage = damage
        self.lastAttackTime = 0
        
        let size = CGSize(width: 25, height: 25)
        let color = UIColor.blue
        super.init(texture: nil, color: color, size: size)
        
        self.zPosition = 3

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssaultDrone: Drone {
    init() {
        super.init(radius: 100, fireRate: 2, damage: 2)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to attack enemies
    func attack(_ enemies: inout [Enemy], currentTime: TimeInterval, playerPosition: CGPoint, playerCointCount: inout Int) {
        // Check if enough time has passed since the last attack
        if currentTime - lastAttackTime >= fireRate {
            // Find the closest enemy within the radius
            var closestEnemy: Enemy? = nil
            for enemy in enemies {
                let distanceFromPlayer = enemy.distance(to: playerPosition)
                if distanceFromPlayer <= radius {
                    print("found closest enemy")
                    closestEnemy = enemy
                }
            }
            
            // If an enemy is found within range, attack it
            if let closestEnemy = closestEnemy {
                animateDroneAttack()
                // Perform attack logic
                closestEnemy.hitpoints -= Int(damage)
                
                // Check if the enemy's hitpoints have reached zero
                if closestEnemy.hitpoints <= 0 {
                    playerCointCount += closestEnemy.coinValue
                    // Handle enemy defeat
                    closestEnemy.removeFromParent()
                    if let index = enemies.firstIndex(of: closestEnemy) {
                        enemies.remove(at: index)
                    }
                }
                
                // Update last attack time for fire rate cooldown
                lastAttackTime = currentTime
            }
        }
    }

    
}
