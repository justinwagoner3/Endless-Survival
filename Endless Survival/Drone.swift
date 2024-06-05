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
    func attack(_ enemies: inout [Enemy], currentTime: TimeInterval, playerPosition: CGPoint, playerCoinCount: inout Int, animateEnemyAttack: Bool) -> Bool {
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
                closestEnemy.decreaseHealth(Int(damageLevel), &enemies, playerCoinCount: &playerCoinCount, animate: animateEnemyAttack)
                
                // Update last attack time for fire rate cooldown
                lastAttackTime = currentTime
                
                return true
            }
        }
        
        return false
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
            playerHealth += max(healAmount,playerTotalHealth)
            remainingTime = healInterval

        }
    }
}

class HarvestDrone: Drone {
    var curResource: Resource?
    var resourceHarvestTime: TimeInterval = 0
    var lastUpdateHarvestTime: TimeInterval = 0
    var radius: CGFloat = 500
    
    init() {
        super.init(textureName: "harvest_drone")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func findResourceNearby(_ playerPosition: CGPoint, _ resources: [Resource]) -> Resource? {
        var closestDistance: CGFloat = .infinity
        var closestResource: Resource?
        for resource in resources {
            let distance = playerPosition.distance(to: resource.position)
            if distance <= radius && distance < closestDistance {
                closestDistance = distance
                closestResource = resource
            }
        }
        
        return closestResource
    }

    func updateHarvestTime(currentTime: TimeInterval, _ resource: inout Resource){
        // Calculate the time since the last frame
        let deltaTime = currentTime - lastUpdateHarvestTime
        
        // Increment the total hold time by the time since the last frame
        resource.totalHarvestButtonHoldTime += deltaTime
        
        // Update the last update time for the next frame
        lastUpdateHarvestTime = currentTime
    }

    // Method to check for player-resource contact and collect resources
    func checkAndCollectResources(_ resource: inout Resource, _ resources: inout [Resource], playerTotalBagSpace: Int, playerCurBagCount: inout Int, playerCurBagWoodCount: inout Int, playerCurBagStoneCount: inout Int, playerCurBagOreCount: inout Int) {
        if(playerCurBagCount < playerTotalBagSpace){
            // Check if the total hold time exceeds the required harvest time
            if resource.totalHarvestButtonHoldTime >= resource.collectionHarvestTime {
                // Perform resource collection logic based on the resource type
                switch resource {
                case is Wood:
                    playerCurBagWoodCount += 1
                case is Stone:
                    playerCurBagStoneCount += 1
                case is Ore:
                    playerCurBagOreCount += 1
                default:
                    break
                }
                playerCurBagCount += 1
                // Update resource count
                resource.resourceCount -= 1
                if(resource.resourceCount <= 0){
                    resource.removeFromParent()
                    if let index = resources.firstIndex(of: resource) {
                        resources.remove(at: index)
                    }
                }
                
                resource.totalHarvestButtonHoldTime = 0
            }
        } 
        else{
            displayBagFullMessage()
            resource.totalHarvestButtonHoldTime = 0
        }
    }
}
