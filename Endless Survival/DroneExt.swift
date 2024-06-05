import SpriteKit
import GameplayKit

extension AssaultDrone {
    // attack
    func loadAttackTextures() {
        attackTextures = [
            SKTexture(imageNamed: "assault_drone_attack0"),
            SKTexture(imageNamed: "assault_drone_attack1"),
            SKTexture(imageNamed: "assault_drone_attack2"),
            SKTexture(imageNamed: "assault_drone_attack3"),
            SKTexture(imageNamed: "assault_drone_attack4"),
            SKTexture(imageNamed: "assault_drone_attack5"),
            SKTexture(imageNamed: "assault_drone_attack6")
        ]
    }
    
    func animateAttack() {
        // Calculate the time per frame based on the weapon's fire rate and the number of frames
        let timePerFrame = fireRate / CGFloat(attackTextures.count)
        
        // Create the animation action
        let attackAnimation = SKAction.animate(with: attackTextures, timePerFrame: timePerFrame, resize: false, restore: true)
        // Remove the removeFromParent to prevent the sprite from disappearing
        let attackSequence = SKAction.sequence([attackAnimation])

        // Run the attack animation
        self.run(attackSequence, withKey: "attacking")
    }

}
