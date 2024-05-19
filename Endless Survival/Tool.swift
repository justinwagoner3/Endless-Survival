import SpriteKit

// Enum for Rarity
enum Rarity: String {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    // Computed property to return associated color
    var color: UIColor {
        switch self {
        case .common:
            return UIColor.gray
        case .uncommon:
            return UIColor.green
        case .rare:
            return UIColor.blue
        case .epic:
            return UIColor.purple
        case .legendary:
            return UIColor.orange
        }
    }
}

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
