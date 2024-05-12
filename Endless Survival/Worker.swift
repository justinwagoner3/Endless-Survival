import SpriteKit

class Worker: SKSpriteNode{
    var movementLevel: Int = 1
}

class Harvester: Worker {
    var bagSpace: Int = 1
    var harvestLevel: Int = 1
    //var axe: Axe
    //var pikcaxe: Pickaxe
    
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
        let movementSpeed: CGFloat = 100.0 // Adjust this value based on your game's settings
        let duration = distance / (CGFloat(movementLevel) * movementSpeed)
        
        // Create the move action
        let moveAction = SKAction.move(to: resourceToMoveTo.position, duration: TimeInterval(duration))
        
        // Run the move action
        run(moveAction) {
            // Perform any actions after reaching the resource
            self.harvest(resource: resourceToMoveTo)
        }
    }

    
    func harvest(resource: Resource) {
        // Perform harvesting actions here
        print("Harvester is harvesting resource.")
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
