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


extension HarvestDrone {
    // TODO - there are 2x of these in Player and Drone
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
