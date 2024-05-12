import SpriteKit
import GameplayKit

extension Player {
    // Function to animate the player's attack with a white border
    func animatePlayerAttack() {
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
        
        // Perform the animation only on the player itself, excluding children
        for child in children {
            child.removeAllActions()
        }
    }
}
