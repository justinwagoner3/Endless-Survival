import SpriteKit

class Enemy: SKSpriteNode, Codable {
    
    // Reference to the GameScene instance
    weak var gameScene: GameScene?

    // Enemy attributes
    var movementSpeed: CGFloat
    var hitpoints: Int
    var bounds: CGSize

    var coinValue: Int = 1
    private var damage: CGFloat = 10.0
    private var attackRadius: CGFloat = 50.0
    private var attackCooldown: TimeInterval = 2
    private var lastAttackTime: TimeInterval = 0

    // Initializer with default appearance
    init(movementSpeed: CGFloat, hitpoints: Int, bounds: CGSize) {
        self.movementSpeed = movementSpeed
        self.hitpoints = hitpoints
        self.bounds = bounds
        
        let size = CGSize(width: 25, height: 25)
        let color = UIColor.red
        super.init(texture: nil, color: color, size: size)
        
        self.zPosition = 3
        self.position = randomPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum CodingKeys: String, CodingKey {
        case movementSpeed
        case hitpoints
        case coinValue
        case damage
        case attackRadius
        case attackCooldown
        case lastAttackTime
        case bounds
        // Add more properties as needed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(movementSpeed, forKey: .movementSpeed)
        try container.encode(hitpoints, forKey: .hitpoints)
        try container.encode(coinValue, forKey: .coinValue)
        try container.encode(damage, forKey: .damage)
        try container.encode(attackRadius, forKey: .attackRadius)
        try container.encode(attackCooldown, forKey: .attackCooldown)
        try container.encode(lastAttackTime, forKey: .lastAttackTime)
        try container.encode(bounds, forKey: .bounds)
        // Encode other properties as needed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        movementSpeed = try container.decode(CGFloat.self, forKey: .movementSpeed)
        hitpoints = try container.decode(Int.self, forKey: .hitpoints)
        coinValue = try container.decode(Int.self, forKey: .coinValue)
        damage = try container.decode(CGFloat.self, forKey: .damage)
        attackRadius = try container.decode(CGFloat.self, forKey: .attackRadius)
        attackCooldown = try container.decode(TimeInterval.self, forKey: .attackCooldown)
        lastAttackTime = try container.decode(TimeInterval.self, forKey: .lastAttackTime)
        bounds = try container.decode(CGSize.self, forKey: .bounds)
        // Decode other properties as needed
        super.init(texture: nil, color: .clear, size: .zero)
    }

    // Method to generate random position within worldSize
    private func randomPosition() -> CGPoint {
        let randomX = CGFloat.random(in: 0...(bounds.width - size.width))
        let randomY = CGFloat.random(in: 0...(bounds.height - size.height))
        return CGPoint(x: randomX, y: randomY)
    }
    
    // Method to calculate distance between two points
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // Method to highlight the enemy
    func highlight() {
        // Add code to visually highlight the enemy, e.g., change color or add a glow effect
        self.colorBlendFactor = 0.5
        self.color = UIColor.white
    }
    
    // Method to remove highlighting from the enemy
    func unhighlight() {
        // Add code to remove the visual highlighting effect applied to the enemy
        self.colorBlendFactor = 0.0
        self.color = UIColor.red
    }
    
    // Additional methods/functions for enemy behavior
    // For example, you can add a method to handle enemy movement
    func moveTowards(_ targetPosition: CGPoint) {
        // Add movement logic here
    }
    
    // Method to check if the player is within attack range and initiate attack if cooldown is over
    func checkAndAttackPlayer(playerPosition: CGPoint, currentTime: TimeInterval) -> CGFloat? {
        // Calculate distance between enemy and player
        let distanceToPlayer = distance(to: playerPosition)
        
        // Check if player is within attack range and if enough time has passed since last attack
        if distanceToPlayer <= attackRadius && currentTime - lastAttackTime >= attackCooldown {
            // Initiate attack
            // You can implement attack animation or logic here
            print("Enemy is attacking!")
            animateEnemyAttack()

            // Update last attack time
            lastAttackTime = currentTime
            
            return damage
        }
        
        return nil
    }
}
