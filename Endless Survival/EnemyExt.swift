import SpriteKit
import GameplayKit

extension Enemy {
    // Function to animate the enemy's attack with a black border
    func animateEnemyAttack() {
        let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.1)
        let attackAnimation = SKAction.sequence([scaleUpAction, scaleDownAction])
        run(attackAnimation)
        
        // Access the player instance
        if let player = gameScene?.player {
            // Temporarily change player color to red
            player.color = .red
            // Revert player color to blue after 0.5 seconds
            let revertColorAction = SKAction.run {
                player.color = .blue
            }
            let colorChangeDuration = 0.1
            let waitAction = SKAction.wait(forDuration: colorChangeDuration)
            let revertColorSequence = SKAction.sequence([waitAction, revertColorAction])
            gameScene?.run(revertColorSequence)
        }
        
        // Create a black border sprite
        let blackBorder = SKSpriteNode(color: .black, size: CGSize(width: size.width + 25, height: size.height + 25))
        blackBorder.zPosition = zPosition - 1 // Place behind the enemy
        blackBorder.position = position
        parent?.addChild(blackBorder)
        
        // Fade out and remove the black border sprite
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.2)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOutAction, removeAction])
        blackBorder.run(sequence)
    }
    
    func animateEnemyGotAttacked() {
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
