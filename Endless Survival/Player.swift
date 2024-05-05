import SpriteKit
import GameplayKit

class Player : SKSpriteNode {
    var totalHealth: CGFloat = 100.0
    var currentHealth: CGFloat = 100.0
    var coinCount: Int = 0
    var woodCount: Int = 0
    var stoneCount: Int = 0
    var oreCount: Int = 0
    var movementSpeed: CGFloat = 2 
    var isHarvesting = false
    let attackCooldown: TimeInterval = 2.0
    var lastHealTime: TimeInterval = 0
    var lastInjuryTime: TimeInterval?

    // Method to check if the player should receive passive healing
    func shouldHeal(_ currentTime: TimeInterval, isJoystickActive: Bool) -> Bool {
        // Quick return false if player health is full
        if(currentHealth == totalHealth){
            return false
        }

        guard let lastInjuryTime = lastInjuryTime else {
            // If the player has never been injured, no need to passive healing to start
            return false
        }
        
        
        // Calculate time since last injury
        let timeSinceInjury = currentTime - lastInjuryTime
        
        // Check if the player is not moving
        let isPlayerMoving = isJoystickActive

        // Check if the player has not been injured in the last 5 seconds and is not moving
        if timeSinceInjury >= 5 && !isPlayerMoving {
            // Check if enough time has passed since the last healing
            if currentTime - lastHealTime >= 1.0 {
                return true
            }
        }
        
        return false
    }

    
    // Method to increase player's health
    func increaseHealth(amount: CGFloat, currentTime: TimeInterval) {
        currentHealth += amount
        // Ensure current health doesn't exceed total health
        currentHealth = min(currentHealth, totalHealth)
        
        // Update last heal time
        lastHealTime = currentTime
    }

    
    // Method to check for player-coin contact and collect coins
    func checkAndCollectCoins(resources: inout [Resource]) {
        // Iterate through resources and check for player-resource contact
        for resource in resources {
            // Check if the player's bounding box intersects with the resource's bounding box
            if frame.intersects(resource.frame) {
                // make sure it's coin
                if resource is Coin {
                    coinCount += 1
                    // Update resource count
                    resource.resourceCount -= 1
                    if(resource.resourceCount <= 0){
                        resource.removeFromParent()
                        if let index = resources.firstIndex(of: resource) {
                            resources.remove(at: index)
                        }
                    }
                }
            }
        }
    }

}
