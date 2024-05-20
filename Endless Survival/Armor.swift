import SpriteKit

class Armor {
    var rarity: Rarity
    var armor: CGFloat
    var isEquipped: Bool

    init(rarity: Rarity, armor: CGFloat, isEquipped: Bool = false) {
        self.rarity = rarity
        self.armor = armor
        self.isEquipped = isEquipped
    }

}

class HeadArmor {
    
}

class ChestArmor {
    
}

class LegArmor {
    
}
