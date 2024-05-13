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
            
            mp("woodCount ",woodCount)
            mp("stoneCount ",stoneCount)
            mp("oreCount ",oreCount)
        }
    }
}

class Shooter: Worker{
    var attackLevel: Int = 1
    var weapon: Weapon = Pistol()
}

    extension CGPoint {
        func distance(to point: CGPoint) -> CGFloat {
            return hypot(point.x - self.x, point.y - self.y)
        }
    }
