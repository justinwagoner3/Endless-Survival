import SpriteKit

class Worker: SKSpriteNode{
    var movementLevel: Int = 1
    let movementSpeed: CGFloat = 200.0 // Adjust this value based on your game's settings
}

class Harvester: Worker {
    var maxBagSpace: Int = 12
    var bagSpace: Int = 12
    var woodCount: Int = 0
    var stoneCount: Int = 0
    var oreCount: Int = 0
    var harvestLevel: Int = 1
    //var axe: Axe
    //var pikcaxe: Pickaxe
    var isOnResource: Bool = false
    var isOnBase: Bool = false
    var curResource: Resource?
    var resourceHarvestTime: TimeInterval = 0
    var lastUpdateHarvestTime: TimeInterval = 0

    func moveToResource(resources: [Resource]) {
        // Find the closest resource
        var closestDistance: CGFloat = .infinity
        var closestResource: Resource?
        for resource in resources {
            let distance = self.position.distance(to: resource.position)
            if distance < closestDistance {
                closestDistance = distance
                closestResource = resource
            }
        }
        
        guard let resourceToMoveTo = closestResource else {
            print("No resources found.")
            return
        }
        
        // Calculate the distance between the harvester and the resource
        let distance = sqrt(pow(resourceToMoveTo.position.x - self.position.x, 2) + pow(resourceToMoveTo.position.y - self.position.y, 2))
        
        // Calculate the duration based on the distance and the harvester's movement level
        let duration = distance / (CGFloat(movementLevel) * movementSpeed)
        
        // Create the move action
        let moveAction = SKAction.move(to: resourceToMoveTo.position, duration: TimeInterval(duration))
        
        // Run the move action
        run(moveAction) {
            self.curResource = resourceToMoveTo
            // Perform any actions after reaching the resource
            self.isOnResource = true
        }
    }
    
    func moveToBase(base: SKSpriteNode, player: inout Player){
        // Calculate the distance between the harvester and the resource
        let distance = sqrt(pow(base.position.x - self.position.x, 2) + pow(base.position.y - self.position.y, 2))
        
        // Calculate the duration based on the distance and the harvester's movement level
        let duration = distance / (CGFloat(movementLevel) * movementSpeed)
        
        // Create the move action
        let moveAction = SKAction.move(to: base.position, duration: TimeInterval(duration))
                
        // Run the move action
        run(moveAction) {
            self.isOnBase = true
        }
    }
    
    func depositBag(player: inout Player){
        print("deposit bag")
        player.woodCount += self.woodCount
        player.stoneCount += self.stoneCount
        player.oreCount += self.oreCount
        self.bagSpace = self.maxBagSpace
        self.woodCount = 0
        self.stoneCount = 0
        self.oreCount = 0
        self.isOnBase = false
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
    func checkAndCollectResources(_ resource: inout Resource, _ resources: inout [Resource]) {
        // Check if the total hold time exceeds the required harvest time
        if resource.totalHarvestButtonHoldTime >= resource.collectionHarvestTime {
            // Perform resource collection logic based on the resource type
            switch resource {
            case is Wood:
                woodCount += 1
            case is Stone:
                stoneCount += 1
            case is Ore:
                oreCount += 1
            default:
                break
            }
            bagSpace -= 1
            // Update resource count
            resource.resourceCount -= 1
            if(resource.resourceCount <= 0){
                resource.removeFromParent()
                if let index = resources.firstIndex(of: resource) {
                    resources.remove(at: index)
                }
                isOnResource = false
            }
            
            resource.totalHarvestButtonHoldTime = 0            
        }
    }
}

class Shooter: Worker{
    var attackLevel: Int = 1
    var weapon: Weapon = Pistol()
    var lastAttackTime: TimeInterval = 0
    
    // Method to make the shooter walk towards the closest enemy
    func walkTowardsEnemy(enemies: [Enemy]) {
        // Find the closest enemy
        var closestDistance: CGFloat = .infinity
        var closestEnemy: Enemy?
        for enemy in enemies {
            let distance = self.position.distance(to: enemy.position)
            if distance < closestDistance {
                closestDistance = distance
                closestEnemy = enemy
            }
        }

        guard let enemyToMoveTo = closestEnemy else {
            print("No enemies found.")
            return
        }

        // Calculate the distance between the shooter and the enemy
        let distance = sqrt(pow(enemyToMoveTo.position.x - self.position.x, 2) + pow(enemyToMoveTo.position.y - self.position.y, 2))

        // Calculate the duration based on the distance and the shooter's movement level
        let duration = distance / (CGFloat(movementLevel) * movementSpeed)

        // Create the move action
        let moveAction = SKAction.move(to: enemyToMoveTo.position, duration: TimeInterval(duration))

        // Run the move action
        run(moveAction)
    }

    // Method to make the shooter attack the enemy
    func attack(_ enemies: inout [Enemy], currentTime: TimeInterval, playerCointCount: inout Int) {
        // Check if enough time has passed since the last attack
        if currentTime - lastAttackTime >= weapon.fireRate {
            // Find the closest enemy within the radius
            var closestEnemy: Enemy? = nil
            for enemy in enemies {
                let distanceFromPlayer = enemy.distance(to: self.position)
                if distanceFromPlayer <= weapon.radius {
                    closestEnemy = enemy
                }
            }
            
            // If an enemy is found within range, attack it
            if let closestEnemy = closestEnemy {
                animateShooterAttack()
                // Perform attack logic
                closestEnemy.hitpoints -= Int(weapon.damage)
                
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

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(point.x - self.x, point.y - self.y)
    }
}
