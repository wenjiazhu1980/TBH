import Foundation

/// 技能定义（MVP 简化版）
struct Skill: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let cooldown: TimeInterval
    let damageMultiplier: Double
    let unlockLevel: Int
}

/// 战士技能
enum WarriorSkills {
    static let all: [Skill] = [
        Skill(id: "slash", name: "横斩", description: "对敌人造成1.5倍伤害", cooldown: 5, damageMultiplier: 1.5, unlockLevel: 1),
        Skill(id: "shield_bash", name: "盾击", description: "造成伤害并降低敌人攻击力", cooldown: 8, damageMultiplier: 1.2, unlockLevel: 5),
        Skill(id: "whirlwind", name: "旋风斩", description: "造成2倍伤害", cooldown: 12, damageMultiplier: 2.0, unlockLevel: 10),
        Skill(id: "berserk", name: "狂暴", description: "短时间内攻击力翻倍", cooldown: 20, damageMultiplier: 3.0, unlockLevel: 15)
    ]
}
