import SpriteKit
import GameplayKit

extension Player {
    
    func updatePlayerState(isJoystickActive: Bool) {
        if isJoystickActive {
            if self.action(forKey: "idleAnimation") != nil {
                stopIdleAnimation()
            }
            if self.action(forKey: "walkAnimation") == nil {
                if let walkAnimation = walkAnimationAction{
                    self.run(walkAnimation, withKey: "walkAnimation")
                }
            }
        } else {
            if self.action(forKey: "walkAnimation") != nil {
                self.removeAction(forKey: "walkAnimation")
            }
            startIdleAnimation()
        }
    }
    // hurt
    func loadHurtTextures() {
        hurtTextures = [
            SKTexture(imageNamed: "player_hurt0"),
            SKTexture(imageNamed: "player_hurt1"),
            SKTexture(imageNamed: "player_hurt2"),
            SKTexture(imageNamed: "player_hurt3")
        ]
    }

    func setupHurtAnimation() {
        let animateHurt = SKAction.animate(with: hurtTextures, timePerFrame: 0.1, resize: false, restore: true)
        hurtAnimationAction = animateHurt
    }

    
    // walk
    func loadWalkTextures() {
        walkTextures = [
            SKTexture(imageNamed: "player_walk0"),
            SKTexture(imageNamed: "player_walk1"),
            SKTexture(imageNamed: "player_walk2"),
            SKTexture(imageNamed: "player_walk3"),
            SKTexture(imageNamed: "player_walk4"),
            SKTexture(imageNamed: "player_walk5"),
            SKTexture(imageNamed: "player_walk6"),
            SKTexture(imageNamed: "player_walk7")
        ]
    }

    func setupWalkAnimation() {
        let animateWalk = SKAction.animate(with: walkTextures, timePerFrame: 0.1, resize: false, restore: true)
        walkAnimationAction = SKAction.repeatForever(animateWalk)
    }

    
    // attack
    func loadAttackTextures() {
        attackTextures = [
            SKTexture(imageNamed: "player_attack_bow7"),
            SKTexture(imageNamed: "player_attack_bow8"),
            SKTexture(imageNamed: "player_attack_bow0"),
            SKTexture(imageNamed: "player_attack_bow1"),
            SKTexture(imageNamed: "player_attack_bow2"),
            SKTexture(imageNamed: "player_attack_bow3"),
            SKTexture(imageNamed: "player_attack_bow4"),
            SKTexture(imageNamed: "player_attack_bow5"),
            SKTexture(imageNamed: "player_attack_bow6")
        ]
    }
    
    func animatePlayerAttack() {
        // Calculate the time per frame based on the weapon's fire rate and the number of frames
        let timePerFrame = equippedWeapon.fireRate / CGFloat(attackTextures.count)
        
        // Create the animation action
        let attackAnimation = SKAction.animate(with: attackTextures, timePerFrame: timePerFrame, resize: false, restore: true)
        // Remove the removeFromParent to prevent the sprite from disappearing
        let attackSequence = SKAction.sequence([attackAnimation])

        // Run the attack animation
        self.run(attackSequence, withKey: "attacking")
    }


    // idle
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
            if let idleAction = idleAnimationAction {
                self.run(idleAction, withKey: "idleAnimation")
            }
        }
    }

    func stopIdleAnimation() {
        // Stop the idle animation
        self.removeAction(forKey: "idleAnimation")
    }
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
