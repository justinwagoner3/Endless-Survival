import SpriteKit
import GameplayKit

extension GameScene: BaseInteractionDelegate {
    func addComponentToBase(_ component: BaseComponent) {
        base.addComponent(component)
        saveGameState()
    }
}
