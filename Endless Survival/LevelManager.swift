import SpriteKit

class LevelManager {
    static let shared = LevelManager() // Singleton instance
    
    var movementLevel: CGFloat = 1.0 // Default movement level
    
    private init() {} // Private initializer to prevent instantiation outside the class
}
