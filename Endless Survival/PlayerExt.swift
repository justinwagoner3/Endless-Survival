import SpriteKit
import GameplayKit

extension Player {
    
    func updatePlayerState(isJoystickActive: Bool) {
        if isJoystickActive {
            // Player is moving
            stopIdleAnimation()
        } else {
            // Player is idle
            startIdleAnimation()
        }
    }

    func loadIdleTextures() {
        // Load textures for idle animation
        idleTextures = [
            SKTexture(imageNamed: "player_idle0"),
            SKTexture(imageNamed: "player_idle1"),
            SKTexture(imageNamed: "player_idle2"),
            SKTexture(imageNamed: "player_idle3"),
            SKTexture(imageNamed: "player_idle4"),
            SKTexture(imageNamed: "player_idle5")
        ]
    }
    
    func setupIdleAnimation() {
        // Create an animation action from textures
        let animateIdle = SKAction.animate(with: idleTextures, timePerFrame: 0.1, resize: false, restore: true)
        idleAnimationAction = SKAction.repeatForever(animateIdle)
    }

    func startIdleAnimation() {
        // Only start the idle animation if it is not already running
        if self.action(forKey: "idleAnimation") == nil {
            print("Starting idle animation")
            if let idleAction = idleAnimationAction {
                self.run(idleAction, withKey: "idleAnimation")
            }
        }
    }

    func stopIdleAnimation() {
        // Stop the idle animation
        self.removeAction(forKey: "idleAnimation")
    }

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
    
    func displayBagFullMessage() {
        let message = SKLabelNode(text: "Bag Full!")
        message.fontSize = 50
        message.fontColor = .red
        message.position = CGPoint(x: 0, y: self.size.height / 2 + 100) // Position slightly above the player
        message.zPosition = 100 // Ensure the message is above other elements
        
        self.addChild(message)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let wait = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])
        
        message.run(sequence)
    }

}
