import SpriteKit

class Drone: SKSpriteNode {
    
    init(color: UIColor) {
        super.init(texture: nil, color: color, size: CGSize(width: 25, height: 25))
        
        self.zPosition = 3

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssaultDrone: Drone {
    var radius: CGFloat
    var fireRate: TimeInterval
    var damageLevel: CGFloat
    var lastAttackTime: TimeInterval

    init() {
        self.radius = 100
        self.fireRate = 2
        self.damageLevel = 1
        self.lastAttackTime = 0
        
        super.init(color: .blue)
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
            var closestDistance: CGFloat = CGFloat.infinity
            for enemy in enemies {
                let distanceFromPlayer = enemy.distance(to: playerPosition)
                if distanceFromPlayer <= radius && distanceFromPlayer < closestDistance {
                    closestEnemy = enemy
                    closestDistance = distanceFromPlayer
                }
            }
            
            // If an enemy is found within range, attack it
            if let closestEnemy = closestEnemy {
                animateDroneAttack()
                // Perform attack logic
                closestEnemy.hitpoints -= Int(damageLevel)
                
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

class HealDrone: Drone {
    
}

class HarvestDrone: Drone {
    
}
