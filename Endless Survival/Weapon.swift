import SpriteKit

class Weapon: Codable {
    var radius: CGFloat
    var fireRate: TimeInterval
    var damage: CGFloat
    var lastAttackTime: TimeInterval
    var isAOE: Bool
    var isEquipped: Bool
    var rarity: Rarity

    enum CodingKeys: String, CodingKey {
        case radius
        case fireRate
        case damage
        case lastAttackTime
        case isAOE
        case isEquipped
        case rarity
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(fireRate, forKey: .fireRate)
        try container.encode(damage, forKey: .damage)
        try container.encode(lastAttackTime, forKey: .lastAttackTime)
        try container.encode(isAOE, forKey: .isAOE)
        try container.encode(isEquipped, forKey: .isEquipped)
        try container.encode(rarity, forKey: .rarity)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let radius = try container.decode(CGFloat.self, forKey: .radius)
        let fireRate = try container.decode(TimeInterval.self, forKey: .fireRate)
        let damage = try container.decode(CGFloat.self, forKey: .damage)
        let lastAttackTime = try container.decode(TimeInterval.self, forKey: .lastAttackTime)
        let isAOE = try container.decode(Bool.self, forKey: .isAOE)
        let isEquipped = try container.decode(Bool.self, forKey: .isEquipped)
        let rarity = try container.decode(Rarity.self, forKey: .rarity)

        self.radius = radius
        self.fireRate = fireRate
        self.damage = damage
        self.lastAttackTime = lastAttackTime
        self.isAOE = isAOE
        self.isEquipped = isEquipped
        self.rarity = rarity
    }
    
    init(radius: CGFloat, fireRate: TimeInterval, damage: CGFloat, isAOE: Bool, isEquipped: Bool, rarity: Rarity) {
        self.radius = radius
        self.fireRate = fireRate
        self.damage = damage
        self.isAOE = isAOE
        self.lastAttackTime = 0
        self.isEquipped = isEquipped
        self.rarity = rarity
    }
}

class Bow: Weapon {
    init(isEquipped: Bool = false, rarity: Rarity = .common) {
        super.init(radius: 100, fireRate: 5, damage: 1, isAOE: false, isEquipped: isEquipped, rarity: rarity)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class Pistol: Weapon {
    init(isEquipped: Bool = false, rarity: Rarity = .common) {
        super.init(radius: 100, fireRate: 2, damage: 2, isAOE: false, isEquipped: isEquipped, rarity: rarity)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class AssaultRifle: Weapon {
    init(isEquipped: Bool = false, rarity: Rarity = .common) {
        super.init(radius: 150, fireRate: 1, damage: 1, isAOE: false, isEquipped: isEquipped, rarity: rarity)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class SniperRifle: Weapon {
    init(isEquipped: Bool = false, rarity: Rarity = .common) {
        super.init(radius: 500, fireRate: 3, damage: 10, isAOE: false, isEquipped: isEquipped, rarity: rarity)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class Rocket: Weapon {
    var aoeRadius: CGFloat = 100
    init(isEquipped: Bool = false, rarity: Rarity = .common) {
        super.init(radius: 500, fireRate: 3, damage: 0, isAOE: true, isEquipped: isEquipped, rarity: rarity)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
