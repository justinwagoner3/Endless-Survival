import SpriteKit

class PlayerManager {
    static let shared = PlayerManager() // Singleton instance
    
    var movementLevel: CGFloat = 1.0 // Default movement level
    
    private init() {} // Private initializer to prevent instantiation outside the class
}
