import SpriteKit

class Tool{
    var rarity: Rarity
    var efficiency: CGFloat
    var isEquipped: Bool

    init(rarity: Rarity, efficiency: CGFloat, isEquipped: Bool = false) {
        self.rarity = rarity
        self.efficiency = efficiency
        self.isEquipped = isEquipped
    }
}
    
class Pickaxe: Tool{

}

class Axe: Tool{

}
