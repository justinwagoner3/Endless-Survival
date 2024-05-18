import SpriteKit
import GameplayKit

//extension GameScene: PlayerDelegate {
//    func playerDidKillEnemy(at position: CGPoint) {
//    }
//}

extension GameScene: BaseInteractionDelegate {
    func addComponentToBase(_ component: BaseComponent) {
        base.addComponent(component)
        self.addChild(component)
        saveGameState()
    }
}
