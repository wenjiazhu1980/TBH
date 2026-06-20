import Foundation

struct PartyMember: Codable, Identifiable, Equatable, Hashable {
    let slotIndex: Int
    var heroClass: HeroClass
    var isUnlocked: Bool

    var id: Int { slotIndex }

    var displayName: String {
        "位置 \(slotIndex + 1)"
    }

    var isPrimary: Bool {
        slotIndex == 0
    }

    func supportAttackPower(
        heroLevel: Int,
        allHeroAttackDamageBonus: Int = 0,
        allHeroAttackDamageMultiplier: Double = 1.0
    ) -> Int {
        guard isUnlocked, !isPrimary else { return 0 }
        let levelBonus = max(heroLevel - 1, 0) * 2
        let rawAttack = heroClass.baseStats.atk + levelBonus + max(0, allHeroAttackDamageBonus)
        return max(1, Int((Double(rawAttack) * max(0.1, allHeroAttackDamageMultiplier) * 0.35).rounded()))
    }

    func supportMaxHP(heroLevel: Int) -> Int {
        guard isUnlocked, !isPrimary else { return 0 }
        return max(1, heroClass.baseStats.hp + max(heroLevel - 1, 0) * 10)
    }

    func supportDefense(
        heroLevel: Int,
        allHeroArmorBonus: Int = 0,
        allHeroArmorMultiplier: Double = 1.0
    ) -> Int {
        guard isUnlocked, !isPrimary else { return 0 }
        let rawDefense = heroClass.baseStats.def + max(heroLevel - 1, 0) + max(0, allHeroArmorBonus)
        return max(0, Int(ceil(Double(rawDefense) * max(0.1, allHeroArmorMultiplier))))
    }

    func supportSpeed(allHeroMoveSpeedBonus: Int = 0) -> Int {
        guard isUnlocked, !isPrimary else { return 0 }
        return max(1, heroClass.baseStats.spd + max(0, allHeroMoveSpeedBonus))
    }
}

struct HeroParty: Codable, Equatable {
    static let maxSlots = 3

    var members: [PartyMember]

    init(primaryClass: HeroClass = .knight, unlockedSlotCount: Int = 1) {
        let supportClasses = Self.defaultSupportClasses(for: primaryClass)
        members = [
            PartyMember(slotIndex: 0, heroClass: primaryClass, isUnlocked: true),
            PartyMember(slotIndex: 1, heroClass: supportClasses[0], isUnlocked: false),
            PartyMember(slotIndex: 2, heroClass: supportClasses[1], isUnlocked: false)
        ]
        setUnlockedSlotCount(unlockedSlotCount)
    }

    var activeMembers: [PartyMember] {
        normalizedMembers.filter(\.isUnlocked)
    }

    var supportMembers: [PartyMember] {
        activeMembers.filter { !$0.isPrimary }
    }

    var activeCount: Int {
        activeMembers.count
    }

    func member(at slotIndex: Int) -> PartyMember? {
        normalizedMembers.first { $0.slotIndex == slotIndex }
    }

    func supportAttackPower(
        heroLevel: Int,
        allHeroAttackDamageBonus: Int = 0,
        allHeroAttackDamageMultiplier: Double = 1.0
    ) -> Int {
        supportMembers.reduce(0) { total, member in
            total + member.supportAttackPower(
                heroLevel: heroLevel,
                allHeroAttackDamageBonus: allHeroAttackDamageBonus,
                allHeroAttackDamageMultiplier: allHeroAttackDamageMultiplier
            )
        }
    }

    mutating func setPrimaryClass(_ heroClass: HeroClass) {
        setHeroClass(heroClass, atSlot: 0)
    }

    mutating func setHeroClass(_ heroClass: HeroClass, atSlot slotIndex: Int) {
        normalize()
        guard slotIndex >= 0, slotIndex < Self.maxSlots else { return }
        guard let index = members.firstIndex(where: { $0.slotIndex == slotIndex }) else { return }

        if let duplicateIndex = members.firstIndex(where: { $0.slotIndex != slotIndex && $0.heroClass == heroClass }) {
            members[duplicateIndex].heroClass = members[index].heroClass
        }

        members[index].heroClass = heroClass
        normalize()
    }

    mutating func setUnlockedSlotCount(_ count: Int) {
        normalize()
        let clampedCount = min(max(count, 1), Self.maxSlots)
        for index in members.indices {
            members[index].isUnlocked = members[index].slotIndex < clampedCount
        }
    }

    private var normalizedMembers: [PartyMember] {
        var copy = self
        copy.normalize()
        return copy.members
    }

    private mutating func normalize() {
        var bySlot: [Int: PartyMember] = [:]
        for member in members where member.slotIndex >= 0 && member.slotIndex < Self.maxSlots {
            bySlot[member.slotIndex] = member
        }

        let primaryClass = bySlot[0]?.heroClass ?? .knight
        let defaults = [primaryClass] + Self.defaultSupportClasses(for: primaryClass)
        members = (0..<Self.maxSlots).map { slot in
            bySlot[slot] ?? PartyMember(slotIndex: slot, heroClass: defaults[slot], isUnlocked: slot == 0)
        }

        var used: Set<HeroClass> = []
        for index in members.indices {
            if used.contains(members[index].heroClass),
               let replacement = HeroClass.allCases.first(where: { !used.contains($0) }) {
                members[index].heroClass = replacement
            }
            used.insert(members[index].heroClass)
        }
    }

    private static func defaultSupportClasses(for primaryClass: HeroClass) -> [HeroClass] {
        let starterOrder: [HeroClass] = [.knight, .priest, .ranger, .sorcerer, .hunter, .slayer]
        return starterOrder.filter { $0 != primaryClass }.prefix(2).map(\.self)
    }
}
