import SpriteKit

class SupplyDrop: SKSpriteNode {
    
    var spawnBounds: CGSize
    var tools: [Tool]
    var weapons: [Weapon]

    init(spawnBounds: CGSize, tools: [Tool] = [], weapons: [Weapon] = []) {
        self.spawnBounds = spawnBounds
        self.tools = tools
        self.weapons = weapons

        super.init(texture: nil, color: .orange, size: CGSize(width: 50, height: 50))

        self.zPosition = 2
        self.position = randomPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func randomPosition() -> CGPoint {
        let randomX = CGFloat.random(in: 0...(spawnBounds.width - size.width))
        let randomY = CGFloat.random(in: 0...(spawnBounds.height - size.height))
        return CGPoint(x: randomX, y: randomY)
    }


}
