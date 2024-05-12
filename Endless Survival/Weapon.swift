import SpriteKit

class Weapon: Codable {
    var radius: CGFloat
    var fireRate: TimeInterval
    var damage: CGFloat
    var lastAttackTime: TimeInterval? // Stores the time of the last attack

    enum CodingKeys: String, CodingKey {
        case radius
        case fireRate
        case damage
        case lastAttackTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(fireRate, forKey: .fireRate)
        try container.encode(damage, forKey: .damage)
        try container.encode(lastAttackTime, forKey: .lastAttackTime)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let radius = try container.decode(CGFloat.self, forKey: .radius)
        let fireRate = try container.decode(TimeInterval.self, forKey: .fireRate)
        let damage = try container.decode(CGFloat.self, forKey: .damage)
        let lastAttackTime = try container.decode(CGFloat.self, forKey: .lastAttackTime)

        self.radius = radius
        self.fireRate = fireRate
        self.damage = damage
        self.lastAttackTime = lastAttackTime
    }
    
    init(radius: CGFloat, fireRate: TimeInterval, damage: CGFloat) {
        self.radius = radius
        self.fireRate = fireRate
        self.damage = damage
    }
}

class Pistol: Weapon {
    init() {
        super.init(radius: 100, fireRate: 2, damage: 2)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class AssaultRifle: Weapon {
    init() {
        super.init(radius: 150, fireRate: 1, damage: 1)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

class SniperRifle: Weapon {
    init() {
        super.init(radius: 500, fireRate: 3, damage: 10)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
