import SpriteKit
import GameplayKit

extension Enemy {
    // attack
    func loadAttackTextures() {
        attackTextures = [
            SKTexture(imageNamed: "enemy_attack0"),
            SKTexture(imageNamed: "enemy_attack1"),
            SKTexture(imageNamed: "enemy_attack2"),
            SKTexture(imageNamed: "enemy_attack3"),
            SKTexture(imageNamed: "enemy_attack4"),
            SKTexture(imageNamed: "enemy_attack5")
        ]
    }
    
    func animateEnemyAttack() {
        // Calculate the time per frame based on the weapon's fire rate and the number of frames
        //let timePerFrame = attackCooldown / CGFloat(attackTextures.count)
        
        // Create the animation action
        let attackAnimation = SKAction.animate(with: attackTextures, timePerFrame: 0.1, resize: false, restore: true)
        // Remove the removeFromParent to prevent the sprite from disappearing
        let attackSequence = SKAction.sequence([attackAnimation])

        // Run the attack animation
        self.run(attackSequence, withKey: "attacking")
    }

    
    // hurt
    func loadHurtTextures() {
        hurtTextures = [
            SKTexture(imageNamed: "enemy_hurt0"),
            SKTexture(imageNamed: "enemy_hurt1"),
            SKTexture(imageNamed: "enemy_hurt2"),
            SKTexture(imageNamed: "enemy_hurt3")
        ]
    }

    func setupHurtAnimation() {
        let animateHurt = SKAction.animate(with: hurtTextures, timePerFrame: 0.1, resize: false, restore: true)
        hurtAnimationAction = animateHurt
    }
    
    // death
    func loadDeathTextures() {
        deathTextures = [
            SKTexture(imageNamed: "enemy_death0"),
            SKTexture(imageNamed: "enemy_death1"),
            SKTexture(imageNamed: "enemy_death2"),
            SKTexture(imageNamed: "enemy_death3")
        ]
    }

    func setupDeathAnimation() {
        let animateDeath = SKAction.animate(with: deathTextures, timePerFrame: 0.1, resize: false, restore: true)
        deathAnimationAction = animateDeath
    }
    
}
