import SpriteKit
import GameplayKit

extension BaseComponent {
    // Function to animate the player's attack with a white border
    func animateSentryComponentAttack() {
        let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.1)
        let attackAnimation = SKAction.sequence([scaleUpAction, scaleDownAction])
        run(attackAnimation)
        
        // Create a white border sprite
        let whiteBorder = SKSpriteNode(color: .white, size: CGSize(width: size.width + 25, height: size.height + 25))
        whiteBorder.zPosition = zPosition - 1 // Place behind the player
        whiteBorder.position = position
        parent?.addChild(whiteBorder)
                
        // Fade out and remove the white border sprite
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        whiteBorder.run(sequence)
    }
}

extension AttackComponent {
    // Bow component attack
    func loadAttackTextures() {
        attackTextures = [
            SKTexture(imageNamed: "bowComponent0"),
            SKTexture(imageNamed: "bowComponent1"),
            SKTexture(imageNamed: "bowComponent2"),
            SKTexture(imageNamed: "bowComponent3"),
            SKTexture(imageNamed: "bowComponent4"),
            SKTexture(imageNamed: "bowComponent5")
        ]
    }
    
    func animateBowComponentAttack() {
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
