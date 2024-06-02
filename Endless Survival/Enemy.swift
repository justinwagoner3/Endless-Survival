import SpriteKit

class Enemy: SKSpriteNode, Codable {
    
    // Reference to the GameScene instance
    weak var gameScene: GameScene?

    // animation
    var hurtTextures: [SKTexture] = []
    var hurtAnimationAction: SKAction?
    var deathTextures: [SKTexture] = []
    var deathAnimationAction: SKAction?

    // Enemy attributes
    var movementSpeed: CGFloat
    var hitpoints: Int
    var spawnBounds: CGSize

    var coinValue: Int = 1
    private var damage: CGFloat = 10.0
    private let attackRadius: CGFloat = 50.0
    private let attackCooldown: TimeInterval = 2
    private var lastAttackTime: TimeInterval = 0
    

    // Initializer with default appearance
    init(movementSpeed: CGFloat, hitpoints: Int, spawnBounds: CGSize) {
        self.movementSpeed = movementSpeed
        self.hitpoints = hitpoints
        self.spawnBounds = spawnBounds
        
        let size = CGSize(width: 50, height: 50)
        super.init(texture: SKTexture(imageNamed: "enemy_walk0"), color: .clear, size: size)
        
        self.zPosition = 3
        self.position = randomPosition()
        
        loadHurtTextures()
        setupHurtAnimation()
        loadDeathTextures()
        setupDeathAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to generate random position within worldSize
    private func randomPosition() -> CGPoint {
        let randomX = CGFloat.random(in: 0...(spawnBounds.width - size.width))
        let randomY = CGFloat.random(in: 0...(spawnBounds.height - size.height))
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
        //self.colorBlendFactor = 0.5
        //self.color = UIColor.white
    }
    
    // Method to remove highlighting from the enemy
    func unhighlight() {
        //self.colorBlendFactor = 0.0
        //self.color = UIColor.red
    }
    
    // Move Enemy
    func moveTowards(_ targetPosition: CGPoint) {
        // Add movement logic here
    }
    
    // Method to check if the player is within attack range and initiate attack if cooldown is over
    func checkAndAttackPlayer(playerPosition: CGPoint, currentTime: TimeInterval) -> CGFloat? {
        // Calculate distance between enemy and player
        let distanceToPlayer = distance(to: playerPosition)
        
        // Check if player is within attack range and if enough time has passed since last attack
        if distanceToPlayer <= attackRadius && currentTime - lastAttackTime >= attackCooldown {
            //print("Enemy is attacking!")
            animateEnemyAttack()

            lastAttackTime = currentTime
            
            return damage
        }
        
        return nil
    }
    
    func decreaseHealth(_ damage: Int, _ enemies: inout [Enemy], playerCoinCount: inout Int){
        if let hurtAnimation = hurtAnimationAction{
            self.run(hurtAnimation, withKey: "hurtAnimation")
        }
        hitpoints -= damage
        if hitpoints <= 0 {
            if let deathAnimation = deathAnimationAction{
                let sequence = SKAction.sequence([deathAnimation, SKAction.removeFromParent()])
                self.run(sequence, withKey: "deathAnimation")
            }
            playerCoinCount += coinValue
            // Handle enemy defeat
            if let index = enemies.firstIndex(of: self) {
                enemies.remove(at: index)
            }
        }

    }
    
    enum CodingKeys: String, CodingKey {
        case movementSpeed
        case hitpoints
        case spawnBounds
        case curPosition
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(movementSpeed, forKey: .movementSpeed)
        try container.encode(hitpoints, forKey: .hitpoints)
        try container.encode(spawnBounds, forKey: .spawnBounds)
        try container.encode(self.position, forKey: .curPosition)
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let movementSpeed = try container.decode(CGFloat.self, forKey: .movementSpeed)
        let hitpoints = try container.decode(Int.self, forKey: .hitpoints)
        let spawnBounds = try container.decode(CGSize.self, forKey: .spawnBounds)
        let curPosition = try container.decode(CGPoint.self, forKey: .curPosition)
        
        self.init(movementSpeed: movementSpeed, hitpoints: hitpoints, spawnBounds: spawnBounds)
        
        self.position = curPosition
    }
}
