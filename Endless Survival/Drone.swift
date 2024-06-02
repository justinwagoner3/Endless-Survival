import SpriteKit

class Drone: SKSpriteNode {
    
    init(textureName: String) {
        super.init(texture: SKTexture(imageNamed: textureName), color: .clear, size: CGSize(width: 50, height: 50))
        
        self.zPosition = 3

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AssaultDrone: Drone {
    
    // animation
    var attackTextures: [SKTexture] = []

    // assault drone
    var radius: CGFloat
    var fireRate: TimeInterval
    var damageLevel: CGFloat
    var lastAttackTime: TimeInterval

    init() {
        self.radius = 100
        self.fireRate = 2
        self.damageLevel = 1
        self.lastAttackTime = 0
        
        super.init(textureName: "assault_drone_attack0")
        
        loadAttackTextures()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to attack enemies
    func attack(_ enemies: inout [Enemy], currentTime: TimeInterval, playerPosition: CGPoint, playerCoinCount: inout Int) {
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
                animateAttack()
                closestEnemy.decreaseHealth(Int(damageLevel), &enemies, playerCoinCount: &playerCoinCount)
                
                // Update last attack time for fire rate cooldown
                lastAttackTime = currentTime
            }
        }
    }
}

class HealDrone: Drone {
    var healAmount: CGFloat = 5.0
    var healInterval: TimeInterval = 10.0
    var remainingTime: TimeInterval = 10.0
    var lastCheckTime: TimeInterval = 0
    
    init() {
        super.init(textureName: "heal_drone")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func healPlayer(_ playerHealth: inout CGFloat, _ playerTotalHealth: CGFloat, _ currentTime: TimeInterval){
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastCheckTime
        
        // Increment the total hold time by the time since the last frame
        remainingTime -= deltaTime
        
        // Update the last update time for the next frame
        lastCheckTime = currentTime

        if(remainingTime <= 0 && playerHealth < playerTotalHealth){
            mp("healing player from ",playerHealth)
            mp("to ",playerHealth+healAmount)
            playerHealth += max(healAmount,playerTotalHealth)
            remainingTime = healInterval

        }
    }
}

class HarvestDrone: Drone {
    
}
