import Foundation

/// 战斗结果
enum BattleResult {
    case victory(Rewards)
    case defeat

    struct Rewards {
        let xp: Int
        let gold: Int
        let lootItems: [Item]
        let encountersCleared: Int

        var lootItem: Item? { lootItems.first }

        init(xp: Int, gold: Int, lootItem: Item?, encountersCleared: Int = 1) {
            self.init(
                xp: xp,
                gold: gold,
                lootItems: lootItem.map { [$0] } ?? [],
                encountersCleared: encountersCleared
            )
        }

        init(xp: Int, gold: Int, lootItems: [Item], encountersCleared: Int) {
            self.xp = xp
            self.gold = gold
            self.lootItems = lootItems
            self.encountersCleared = max(1, encountersCleared)
        }
    }
}

enum BattleEvent {
    case heroAttack(isCrit: Bool)
    case heroSkill(skillName: String, isCrit: Bool)
    case supportAttack(isCrit: Bool)
    case supportSkill(heroClass: HeroClass, skillName: String, isCrit: Bool)
    case heroDamaged(isCrit: Bool)
    case battleWon(hasLoot: Bool)
    case battleLost
}

enum BattleEnemyColdStatus: String, Equatable {
    case chilled
    case frozen

    fileprivate var priority: Int {
        switch self {
        case .chilled:
            return 1
        case .frozen:
            return 2
        }
    }
}

struct BattleEnemyState: Identifiable, Equatable {
    let index: Int
    let monster: Monster
    var hp: Int
    var isDefeated: Bool
    var lodgedSkewerArrows: Int = 0
    var hasBleedingWound: Bool = false
    var coldStatus: BattleEnemyColdStatus?
    var coldStatusTimeRemaining: TimeInterval = 0
    var stunTimeRemaining: TimeInterval = 0

    var id: Int { index }
    var maxHP: Int { monster.hp }
    var isBleeding: Bool { lodgedSkewerArrows >= 3 || hasBleedingWound }
    var isStunned: Bool { stunTimeRemaining > 0 }

    @discardableResult
    mutating func applyBleedingWound() -> Bool {
        let wasBleeding = isBleeding
        hasBleedingWound = true
        return !wasBleeding
    }

    mutating func applyColdStatus(_ status: BattleEnemyColdStatus, duration: TimeInterval) {
        guard duration > 0 else { return }
        if let current = coldStatus, current.priority > status.priority {
            return
        }
        if coldStatus != status {
            coldStatus = status
            coldStatusTimeRemaining = duration
        } else {
            coldStatusTimeRemaining = max(coldStatusTimeRemaining, duration)
        }
    }

    mutating func tickColdStatus(deltaTime: TimeInterval) {
        guard coldStatus != nil else { return }
        coldStatusTimeRemaining = max(0, coldStatusTimeRemaining - max(0, deltaTime))
        if coldStatusTimeRemaining <= 0 {
            coldStatus = nil
        }
    }

    mutating func applyStun(duration: TimeInterval) {
        guard duration > 0 else { return }
        stunTimeRemaining = max(stunTimeRemaining, duration)
    }

    mutating func tickStun(deltaTime: TimeInterval) {
        guard stunTimeRemaining > 0 else { return }
        stunTimeRemaining = max(0, stunTimeRemaining - max(0, deltaTime))
    }

    static func == (lhs: BattleEnemyState, rhs: BattleEnemyState) -> Bool {
        lhs.index == rhs.index &&
            lhs.monster.id == rhs.monster.id &&
            lhs.hp == rhs.hp &&
            lhs.isDefeated == rhs.isDefeated &&
            lhs.lodgedSkewerArrows == rhs.lodgedSkewerArrows &&
            lhs.hasBleedingWound == rhs.hasBleedingWound &&
            lhs.coldStatus == rhs.coldStatus &&
            lhs.coldStatusTimeRemaining == rhs.coldStatusTimeRemaining &&
            lhs.stunTimeRemaining == rhs.stunTimeRemaining
    }
}

struct BattleSupportState: Identifiable, Equatable {
    let member: PartyMember
    let maxHP: Int
    var hp: Int
    var isDefeated: Bool

    var id: Int { member.slotIndex }
    var slotIndex: Int { member.slotIndex }
}

private struct ActiveBattleBuff: Identifiable, Equatable {
    let id: String
    let name: String
    var remainingDuration: TimeInterval?
    var remainingHeroAttacks: Int?
    let attackMultiplier: Double
    let attackSpeedMultiplier: Double
    let critRateMultiplier: Double
    let bonusAttackDamageMultiplier: Double
    let rangeDamagePerSecondMultiplier: Double
    let healPerHit: Int
    let healPerSecond: Int
    var damageAbsorbRemaining: Int?
    var trapChargesRemaining: Int?
    let trapDamageMultiplier: Double

    init(
        id: String,
        name: String,
        remainingDuration: TimeInterval?,
        remainingHeroAttacks: Int?,
        attackMultiplier: Double,
        attackSpeedMultiplier: Double,
        critRateMultiplier: Double,
        bonusAttackDamageMultiplier: Double,
        rangeDamagePerSecondMultiplier: Double,
        healPerHit: Int,
        healPerSecond: Int,
        damageAbsorbRemaining: Int?,
        trapChargesRemaining: Int? = nil,
        trapDamageMultiplier: Double = 0
    ) {
        self.id = id
        self.name = name
        self.remainingDuration = remainingDuration
        self.remainingHeroAttacks = remainingHeroAttacks
        self.attackMultiplier = attackMultiplier
        self.attackSpeedMultiplier = attackSpeedMultiplier
        self.critRateMultiplier = critRateMultiplier
        self.bonusAttackDamageMultiplier = bonusAttackDamageMultiplier
        self.rangeDamagePerSecondMultiplier = rangeDamagePerSecondMultiplier
        self.healPerHit = healPerHit
        self.healPerSecond = healPerSecond
        self.damageAbsorbRemaining = damageAbsorbRemaining
        self.trapChargesRemaining = trapChargesRemaining
        self.trapDamageMultiplier = trapDamageMultiplier
    }

    var isExpired: Bool {
        if let remainingDuration, remainingDuration <= 0 {
            return true
        }
        if let remainingHeroAttacks, remainingHeroAttacks <= 0 {
            return true
        }
        if let damageAbsorbRemaining, damageAbsorbRemaining <= 0 {
            return true
        }
        if let trapChargesRemaining, trapChargesRemaining <= 0 {
            return true
        }
        return false
    }
}

private struct ActiveSupportSkillBuff: Identifiable, Equatable {
    let id: String
    let name: String
    let supportSlotIndex: Int
    var remainingDuration: TimeInterval
    let rangeDamagePerSecondMultiplier: Double
    let focusedProjectileOnly: Bool
    let appliesColdSlow: Bool

    var isExpired: Bool {
        remainingDuration <= 0
    }
}

private enum GroundSlamRockScaffold {
    static let maxCharges = 3
    static let explosionSkillName = "大地强击岩石爆炸"
    static let explosionDamageMultiplier = 1.0
}

private enum BattlePartyTarget {
    case hero
    case support(Int)
}

private enum BattleAllyHealTarget {
    case hero
    case support(Int)
}

/// 战斗系统 — 回合制自动战斗
class Battle: ObservableObject {
    @Published var heroHP: Int
    @Published var monsterHP: Int
    @Published var log: [BattleLogEntry] = []
    @Published var isOver: Bool = false
    @Published var result: BattleResult?

    let hero: Hero
    let party: HeroParty
    let activeSkillSlotCount: Int
    let activeSkillLoadouts: ActiveSkillLoadouts
    @Published private(set) var monster: Monster
    @Published private(set) var enemyStates: [BattleEnemyState]
    @Published private(set) var supportStates: [BattleSupportState]
    @Published private(set) var groundSlamRockCharges: Int = 0
    var currentMonsterNumber: Int { min(max(currentMonsterIndex + 1, 1), monsterCount) }
    var monsterCount: Int { monsters.count }
    var waveMonsters: [Monster] { monsters }
    var primaryHeroClass: HeroClass { party.member(at: 0)?.heroClass ?? hero.heroClass }
    var activeEnemyState: BattleEnemyState? { enemyStates.first { !$0.isDefeated } ?? enemyStates.last }
    var aliveEnemyStates: [BattleEnemyState] { enemyStates.filter { !$0.isDefeated } }
    var aliveSupportStates: [BattleSupportState] { supportStates.filter { !$0.isDefeated } }
    var defeatedSupportStates: [BattleSupportState] { supportStates.filter(\.isDefeated) }
    var defeatedEnemyCount: Int { enemyStates.filter(\.isDefeated).count }
    var remainingWaveMonsters: [Monster] { aliveEnemyStates.map(\.monster) }
    var upcomingWaveMonsters: [Monster] {
        let focusedIndex = activeEnemyState?.index
        return aliveEnemyStates
            .filter { $0.index != focusedIndex }
            .map(\.monster)
    }
    var continuousSkillNames: [String] { partyContinuousSkills.map(\.name) }
    var continuousAttackMultiplier: Double {
        guard let blessing = partyContinuousSkills.first(where: { $0.id == "40201" }) else {
            return 1.0
        }
        return 1.0 + Double(blessing.levelOneValue) / 100.0
    }
    var continuousIncomingDamageMultiplier: Double {
        guard let blessing = partyContinuousSkills.first(where: { $0.id == "40501" }) else {
            return 1.0
        }
        let resistanceStandIn = Double(blessing.levelOneValue) / 100.0
        return max(0.1, 1.0 - resistanceStandIn)
    }
    var activeBuffNames: [String] { activeHeroBuffs.map(\.name) + activeSupportSkillBuffs.map(\.name) }
    var activeHeroAttackMultiplier: Double {
        activeHeroBuffs.reduce(1.0) { partial, buff in
            partial * buff.attackMultiplier
        }
    }
    var activeHeroAttackSpeedMultiplier: Double {
        activeHeroBuffs.reduce(1.0) { partial, buff in
            partial * buff.attackSpeedMultiplier
        }
    }
    var activeHeroCritRateMultiplier: Double {
        activeHeroBuffs.reduce(1.0) { partial, buff in
            partial * buff.critRateMultiplier
        }
    }
    var activeHeroDamageShieldRemaining: Int {
        activeHeroBuffs.compactMap(\.damageAbsorbRemaining).reduce(0, +)
    }
    var activeChargedTrapChargesRemaining: Int {
        activeHeroBuffs.compactMap(\.trapChargesRemaining).reduce(0, +)
    }
    private(set) var unyieldingWillWasUsed = false
    var onEvent: ((BattleEvent) -> Void)?
    var onUnyieldingWillUsed: (() -> Void)?

    private let monsters: [Monster]
    private var currentMonsterIndex = 0
    private var enemyCooldowns: [TimeInterval]
    private var accumulatedXP = 0
    private var accumulatedGold = 0
    private var accumulatedLoot: [Item] = []
    private var encountersCleared = 0
    private var heroCooldown: TimeInterval = 0
    private var skillCooldowns: [String: TimeInterval] = [:]
    private var nextCooldownSkillIndex = 0
    private var nextBaseAttackSkillIndex = 0
    private var nextAttackCountSkillIndex = 0
    private var nextEnemyTargetIndex = 0
    private var nextSupportCooldownSkillIndexes: [Int: Int] = [:]
    private var nextSupportAttackCountSkillIndexes: [Int: Int] = [:]
    private var heroBaseAttackCount = 0
    private var supportBaseAttackCounts: [Int: Int] = [:]
    private var activeHeroBuffs: [ActiveBattleBuff] = []
    private var activeSupportSkillBuffs: [ActiveSupportSkillBuff] = []
    private var unyieldingWillAvailable: Bool

    convenience init(
        hero: Hero,
        monster: Monster,
        party: HeroParty? = nil,
        activeSkillSlotCount: Int = HeroSkills.maximumModeledActiveSkillSlots,
        activeSkillLoadouts: ActiveSkillLoadouts = ActiveSkillLoadouts()
    ) {
        self.init(
            hero: hero,
            monsters: [monster],
            party: party,
            activeSkillSlotCount: activeSkillSlotCount,
            activeSkillLoadouts: activeSkillLoadouts
        )
    }

    init(
        hero: Hero,
        monsters: [Monster],
        party: HeroParty? = nil,
        activeSkillSlotCount: Int = HeroSkills.maximumModeledActiveSkillSlots,
        activeSkillLoadouts: ActiveSkillLoadouts = ActiveSkillLoadouts(),
        unyieldingWillAvailable: Bool = true
    ) {
        let plannedMonsters = monsters.isEmpty ? [Monster.allMonsters[0]] : monsters
        var battleParty = party ?? HeroParty(primaryClass: hero.heroClass)
        battleParty.setPrimaryClass(hero.heroClass)
        self.hero = hero
        self.party = battleParty
        self.activeSkillSlotCount = min(
            max(activeSkillSlotCount, HeroSkills.defaultActiveSkillSlotCount),
            HeroSkills.maximumModeledActiveSkillSlots
        )
        self.activeSkillLoadouts = activeSkillLoadouts
        self.monsters = plannedMonsters
        self.monster = plannedMonsters[0]
        self.enemyStates = plannedMonsters.enumerated().map { index, monster in
            BattleEnemyState(index: index, monster: monster, hp: monster.hp, isDefeated: false)
        }
        self.supportStates = battleParty.supportMembers.map { member in
            let maxHP = member.supportMaxHP(heroLevel: hero.level)
            return BattleSupportState(member: member, maxHP: maxHP, hp: maxHP, isDefeated: false)
        }
        self.enemyCooldowns = Array(repeating: 0, count: plannedMonsters.count)
        self.heroHP = hero.currentHP
        self.monsterHP = plannedMonsters[0].hp
        self.unyieldingWillAvailable = unyieldingWillAvailable
    }

    /// 每 tick 调用
    func update(deltaTime: TimeInterval) {
        guard !isOver else { return }

        heroCooldown -= deltaTime
        for index in enemyCooldowns.indices {
            enemyCooldowns[index] -= deltaTime
        }
        tickEnemyStatusEffects(deltaTime: deltaTime)
        tickSkillCooldowns(deltaTime: deltaTime)
        tickActiveHeroBuffs(deltaTime: deltaTime)
        applyPassiveHpRegen(deltaTime: deltaTime)

        if applyCooldownHeroSkillIfReady() {
            if isOver { return }
        }

        if applyPartySupportSkillsIfReady() {
            if isOver { return }
        }

        // 英雄攻击
        if heroCooldown <= 0, let target = activeEnemyState {
            let hit = DamageCalculator.calculateResult(
                attackerATK: modifiedHeroAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            let defeated = damageFocusedEnemy(hit.amount, leechForHero: true)
            let logEntry = BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                damageElement: HeroSkills.baseAttackDamageElement(for: primaryHeroClass),
                delivery: HeroSkills.baseAttackDelivery(for: primaryHeroClass)
            )
            log.append(logEntry)
            onEvent?(.heroAttack(isCrit: hit.isCrit))
            heroCooldown = heroAttackInterval
            heroBaseAttackCount += 1
            applyHeroAttackDamageBuffEffects()
            if isOver { return }
            applyHeroOnHitBuffEffects()
            applyPassiveAddHpPerHit()
            consumeHeroAttackBuffCharges()

            if defeated {
                if completeFocusedEnemyIfNeeded() { return }
            }

            if applyTriggeredHeroSkillAfterAttack() {
                if isOver { return }
            }

            if applyPartySupportAttack() {
                if isOver { return }
            }
        }

        applyEnemyAttacks()
    }

    private func applyEnemyAttacks() {
        for index in enemyStates.indices {
            guard !isOver else { return }
            guard !enemyStates[index].isDefeated, enemyCooldowns[index] <= 0 else { continue }

            let attackingMonster = enemyStates[index].monster
            let attackElement = attackingMonster.sourceDamageElement
            let attackDelivery = attackingMonster.sourceDelivery
            let target = nextEnemyAttackTarget()
            if incomingAttackWasDodged(damageElement: attackElement) {
                log.append(BattleLogEntry(
                    attacker: .monster,
                    damage: 0,
                    isCrit: false,
                    damageElement: attackElement,
                    delivery: attackDelivery
                ))
                enemyCooldowns[index] = attackInterval(for: attackingMonster)
                continue
            }
            if incomingAttackWasBlocked() {
                log.append(BattleLogEntry(
                    attacker: .monster,
                    damage: 0,
                    isCrit: false,
                    damageElement: attackElement,
                    delivery: attackDelivery
                ))
                enemyCooldowns[index] = attackInterval(for: attackingMonster)
                continue
            }

            switch target {
            case .hero:
                let hit = DamageCalculator.calculateResult(
                    attackerATK: attackingMonster.atk,
                    defenderDEF: hero.defense,
                    critRate: attackingMonster.critRate,
                    critDamage: 1.5
                )
                let damage = absorbIncomingDamage(modifiedIncomingDamage(hit.amount, damageElement: attackElement))
                hero.takeDamage(damage)
                heroHP = hero.currentHP  // 单一事实来源：以英雄实际 HP 为准
                log.append(BattleLogEntry(
                    attacker: .monster,
                    damage: damage,
                    isCrit: hit.isCrit,
                    damageElement: attackElement,
                    delivery: attackDelivery
                ))
                onEvent?(.heroDamaged(isCrit: hit.isCrit))

            case .support(let supportIndex):
                guard supportStates.indices.contains(supportIndex) else { continue }
                let targetState = supportStates[supportIndex]
                let hit = DamageCalculator.calculateResult(
                    attackerATK: attackingMonster.atk,
                    defenderDEF: targetState.member.supportDefense(heroLevel: hero.level),
                    critRate: attackingMonster.critRate,
                    critDamage: 1.5
                )
                let damage = absorbIncomingDamage(modifiedIncomingDamage(hit.amount, damageElement: attackElement))
                _ = damageSupportMember(slotIndex: targetState.slotIndex, amount: damage)
                log.append(BattleLogEntry(
                    attacker: .monster,
                    damage: damage,
                    isCrit: hit.isCrit,
                    damageElement: attackElement,
                    delivery: attackDelivery
                ))
            }
            enemyCooldowns[index] = attackInterval(for: attackingMonster)

            if heroHP <= 0 {
                if applyUnyieldingWillIfAvailable() {
                    continue
                }
                endBattle(victory: false)
                return
            }
        }
    }

    private func nextEnemyAttackTarget() -> BattlePartyTarget {
        var candidates: [BattlePartyTarget] = [.hero]
        candidates.append(contentsOf: supportStates.indices.compactMap { index in
            supportStates[index].isDefeated ? nil : .support(index)
        })
        let target = candidates[nextEnemyTargetIndex % candidates.count]
        nextEnemyTargetIndex = (nextEnemyTargetIndex + 1) % candidates.count
        return target
    }

    @discardableResult
    func damageSupportMember(slotIndex: Int, amount: Int) -> Bool {
        guard let index = supportStates.firstIndex(where: { $0.slotIndex == slotIndex }),
              !supportStates[index].isDefeated else {
            return false
        }

        supportStates[index].hp = max(0, supportStates[index].hp - max(0, amount))
        if supportStates[index].hp <= 0 {
            supportStates[index].hp = 0
            supportStates[index].isDefeated = true
            return true
        }
        return false
    }

    @discardableResult
    private func healSupportMember(at index: Int, amount: Int) -> Int {
        guard supportStates.indices.contains(index), !supportStates[index].isDefeated else { return 0 }
        guard supportStates[index].hp < supportStates[index].maxHP else { return 0 }
        let oldHP = supportStates[index].hp
        supportStates[index].hp = min(supportStates[index].maxHP, supportStates[index].hp + max(0, amount))
        return supportStates[index].hp - oldHP
    }

    @discardableResult
    private func reviveSupportMember(at index: Int, withHP amount: Int) -> Int {
        guard supportStates.indices.contains(index), supportStates[index].isDefeated else { return 0 }
        let oldHP = supportStates[index].hp
        supportStates[index].hp = max(1, amount)
        supportStates[index].isDefeated = false
        return supportStates[index].hp - oldHP
    }

    private func endBattle(victory: Bool) {
        isOver = true
        if victory {
            result = .victory(BattleResult.Rewards(
                xp: accumulatedXP,
                gold: accumulatedGold,
                lootItems: accumulatedLoot,
                encountersCleared: encountersCleared
            ))
            onEvent?(.battleWon(hasLoot: !accumulatedLoot.isEmpty))
        } else {
            result = .defeat
            onEvent?(.battleLost)
        }
    }

    @discardableResult
    private func completeFocusedEnemyIfNeeded() -> Bool {
        guard let index = focusedEnemyArrayIndex, enemyStates[index].hp <= 0 else { return false }
        return completeEnemy(at: index)
    }

    @discardableResult
    private func completeEnemy(at index: Int) -> Bool {
        guard enemyStates.indices.contains(index), !enemyStates[index].isDefeated else { return false }

        var defeatedState = enemyStates[index]
        defeatedState.hp = 0
        defeatedState.isDefeated = true
        enemyStates[index] = defeatedState

        let defeatedMonster = defeatedState.monster
        currentMonsterIndex = defeatedState.index
        monster = defeatedMonster
        monsterHP = 0

        accumulatedXP += defeatedMonster.xpReward
        accumulatedGold += defeatedMonster.goldReward
        if let loot = LootTable.roll(for: defeatedMonster) {
            accumulatedLoot.append(loot)
        }
        encountersCleared += 1
        applyPassiveAddHpPerKill()

        guard enemyStates.contains(where: { !$0.isDefeated }) else {
            endBattle(victory: true)
            return true
        }

        refreshFocusedMonster()
        return false
    }

    @discardableResult
    private func damageFocusedEnemy(_ amount: Int, leechForHero: Bool = false) -> Bool {
        guard let index = focusedEnemyArrayIndex else { return false }
        return damageEnemy(at: index, amount: amount, leechForHero: leechForHero)
    }

    @discardableResult
    private func damageEnemy(at index: Int, amount: Int, leechForHero: Bool = false) -> Bool {
        guard enemyStates.indices.contains(index), !enemyStates[index].isDefeated else { return false }
        var updatedState = enemyStates[index]
        let hpBefore = updatedState.hp
        updatedState.hp = max(0, hpBefore - amount)
        let appliedDamage = max(0, hpBefore - updatedState.hp)
        enemyStates[index] = updatedState
        if focusedEnemyArrayIndex == index {
            currentMonsterIndex = updatedState.index
            monster = updatedState.monster
            monsterHP = updatedState.hp
        }
        if leechForHero {
            applyPassiveHpLeech(fromDamage: appliedDamage)
        }
        return updatedState.hp <= 0
    }

    private func applyCrushingBlowShockwave(
        excluding defeatedIndex: Int?,
        attacker: BattleLogEntry.Battler = .hero,
        attackPower: Int? = nil,
        critRate: Double? = nil,
        critDamage: Double? = nil
    ) {
        guard !isOver else { return }

        let targetIndices = enemyStates.indices.filter { index in
            index != defeatedIndex && !enemyStates[index].isDefeated
        }
        guard !targetIndices.isEmpty else { return }

        let sourceAttack = attackPower ?? modifiedHeroAttack
        let sourceCritRate = critRate ?? modifiedHeroCritRate
        let sourceCritDamage = critDamage ?? hero.critDamage
        let shockwaveAttack = max(1, Int(Double(sourceAttack) * 3.5))
        var shockwaveDefeats: [Int] = []

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: shockwaveAttack,
                defenderDEF: target.monster.def,
                critRate: sourceCritRate,
                critDamage: sourceCritDamage
            )
            if damageEnemy(at: index, amount: hit.amount, leechForHero: attacker == .hero) {
                shockwaveDefeats.append(index)
            }
            log.append(BattleLogEntry(
                attacker: attacker,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: "粉碎强击冲击波",
                kind: .damage
            ))
        }

        for index in shockwaveDefeats {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
    }

    private var focusedEnemyArrayIndex: Int? {
        enemyStates.firstIndex { !$0.isDefeated }
    }

    private func refreshFocusedMonster() {
        guard let index = focusedEnemyArrayIndex else { return }
        currentMonsterIndex = enemyStates[index].index
        monster = enemyStates[index].monster
        monsterHP = enemyStates[index].hp
    }

    private func aliveEnemyIndices() -> [Int] {
        enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
    }

    private func focusedSkillTargetIndices(for skill: Skill) -> [Int] {
        let aliveIndices = aliveEnemyIndices()
        guard !aliveIndices.isEmpty else { return [] }

        let focusedIndex = focusedEnemyArrayIndex ?? aliveIndices[0]
        var targetIndices = [focusedIndex]

        guard skill.damageMultiplier > 0 else {
            return targetIndices
        }

        let extraTargetCount = passiveExtraTargetCount(for: skill)
        guard extraTargetCount > 0 else { return targetIndices }

        for index in aliveIndices where index != focusedIndex {
            targetIndices.append(index)
            if targetIndices.count >= 1 + extraTargetCount {
                break
            }
        }
        return targetIndices
    }

    private func passiveExtraTargetCount(for skill: Skill) -> Int {
        let effects = hero.passiveRuntimeEffects
        let expansion: Double

        if [.melee, .projectile, .range, .summonProjectile].contains(skill.delivery) {
            expansion = effects.passiveSkillRangeExpansion
        } else if [.meleeAOE, .projectileAOE, .rangeAOE, .trap].contains(skill.delivery) {
            expansion = effects.passiveAreaOfEffect
        } else {
            expansion = 0
        }

        return Int(floor(max(0, expansion) / 0.30 + 0.0001))
    }

    private func attackInterval(for monster: Monster) -> TimeInterval {
        1.0 / Double(max(1, monster.spd)) * 10
    }

    @discardableResult
    private func applyPartySupportAttack() -> Bool {
        let supportMembers = aliveSupportMembers
        guard !supportMembers.isEmpty else { return false }

        var applied = false
        for member in supportMembers {
            guard let target = activeEnemyState else { break }
            let hit = DamageCalculator.calculateResult(
                attackerATK: modifiedSupportAttack(for: member),
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            let defeated = damageFocusedEnemy(hit.amount)
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                damageElement: HeroSkills.baseAttackDamageElement(for: member.heroClass),
                delivery: HeroSkills.baseAttackDelivery(for: member.heroClass)
            ))
            onEvent?(.supportAttack(isCrit: hit.isCrit))
            applied = true
            supportBaseAttackCounts[member.slotIndex, default: 0] += 1

            if defeated, completeFocusedEnemyIfNeeded() {
                return true
            }

            if applyTriggeredSupportSkillAfterAttack(for: member) {
                applied = true
                if isOver { return true }
            }
        }
        return applied
    }

    private func tickSkillCooldowns(deltaTime: TimeInterval) {
        for skill in cooldownHeroSkills {
            tickSkillCooldown(key: heroSkillCooldownKey(skill), deltaTime: deltaTime)
        }
        for member in aliveSupportMembers {
            for skill in supportCooldownSkills(for: member) {
                tickSkillCooldown(key: supportSkillCooldownKey(skill, member: member), deltaTime: deltaTime)
            }
        }
    }

    private func tickSkillCooldown(key: String, deltaTime: TimeInterval) {
        let remaining = skillCooldowns[key] ?? 0
        skillCooldowns[key] = max(0, remaining - deltaTime)
    }

    private var activeHeroSkills: [Skill] {
        activeSkillLoadouts.activeSkills(
            for: hero.heroClass,
            heroLevel: hero.level,
            slotCount: activeSkillSlotCount
        )
    }

    private var cooldownHeroSkills: [Skill] {
        activeHeroSkills.filter(isAutomaticCooldownSkill)
    }

    private var attackCountHeroSkills: [Skill] {
        activeHeroSkills.filter { $0.activation == .baseAttackCount }
    }

    private var baseAttackHeroSkills: [Skill] {
        activeHeroSkills.filter { $0.activation == .baseAttack }
    }

    private var continuousHeroSkills: [Skill] {
        activeHeroSkills.filter { $0.activation == .continuous }
    }

    private var partyContinuousSkills: [Skill] {
        continuousHeroSkills + aliveSupportMembers.flatMap(supportContinuousSkills(for:))
    }

    private var aliveSupportMembers: [PartyMember] {
        aliveSupportStates.map(\.member)
    }

    private var unyieldingWillSkill: Skill? {
        activeHeroSkills.first { $0.id == "10601" }
    }

    private func isAutomaticCooldownSkill(_ skill: Skill) -> Bool {
        skill.activation == .cooldown && skill.id != "10601"
    }

    private var modifiedHeroAttack: Int {
        max(1, Int(ceil(Double(max(0, hero.attack)) * continuousAttackMultiplier * activeHeroAttackMultiplier)))
    }

    private var modifiedHeroCritRate: Double {
        min(max(0, hero.critRate * activeHeroCritRateMultiplier), 1.0)
    }

    private var modifiedSupportCritRate: Double {
        min(max(0, 0.03 * activeHeroCritRateMultiplier), 1.0)
    }

    private func modifiedSupportAttack(for member: PartyMember) -> Int {
        modifiedAttack(member.supportAttackPower(heroLevel: hero.level))
    }

    private func modifiedAttack(_ attack: Int) -> Int {
        max(1, Int(ceil(Double(max(0, attack)) * continuousAttackMultiplier)))
    }

    private func modifiedIncomingDamage(_ damage: Int, damageElement: SkillDamageElement = .none) -> Int {
        let passiveEffects = hero.passiveRuntimeEffects
        return Self.modifiedIncomingDamage(
            damage,
            continuousIncomingDamageMultiplier: continuousIncomingDamageMultiplier,
            passiveDamageReduction: passiveEffects.passiveDamageReduction,
            passiveDamageAbsorption: passiveEffects.passiveDamageAbsorption,
            passiveAllElementalResistance: passiveEffects.passiveAllElementalResistance,
            damageElement: damageElement
        )
    }

    static func modifiedIncomingDamage(
        _ damage: Int,
        continuousIncomingDamageMultiplier: Double,
        passiveDamageReduction: Double,
        passiveDamageAbsorption: Int,
        passiveAllElementalResistance: Double = 0,
        damageElement: SkillDamageElement = .none
    ) -> Int {
        let damageReduction = min(max(passiveDamageReduction, 0), 0.9)
        let elementalResistance = damageElement.isElemental ? min(max(passiveAllElementalResistance, 0), 0.9) : 0
        let scaledDamage = Int(
            Double(max(0, damage)) *
                continuousIncomingDamageMultiplier *
                (1.0 - damageReduction) *
                (1.0 - elementalResistance)
        )
        return max(1, scaledDamage - max(0, passiveDamageAbsorption))
    }

    private func incomingAttackWasDodged(damageElement: SkillDamageElement = .none) -> Bool {
        let passiveEffects = hero.passiveRuntimeEffects
        return Self.incomingAttackWasDodged(
            roll: Double.random(in: 0..<1),
            passiveDodgeChance: passiveEffects.passiveDodgeChance,
            passiveMaxDodgeChance: passiveEffects.passiveMaxDodgeChance,
            passiveElementalDodgeChance: passiveEffects.passiveElementalDodgeChance,
            damageElement: damageElement
        )
    }

    static func incomingAttackWasDodged(
        roll: Double,
        passiveDodgeChance: Double,
        passiveMaxDodgeChance: Double = 0,
        passiveElementalDodgeChance: Double = 0,
        damageElement: SkillDamageElement = .none
    ) -> Bool {
        let dodgeCap = min(0.95, 0.8 + max(0, passiveMaxDodgeChance))
        let elementalDodgeChance = damageElement.isElemental ? max(0, passiveElementalDodgeChance) : 0
        let dodgeChance = min(max(passiveDodgeChance, 0) + elementalDodgeChance, dodgeCap)
        guard dodgeChance > 0 else { return false }
        return min(max(roll, 0), 1) < dodgeChance
    }

    private func incomingAttackWasBlocked() -> Bool {
        Self.incomingAttackWasBlocked(
            roll: Double.random(in: 0..<1),
            passiveBlockChance: hero.passiveRuntimeEffects.passiveBlockChance
        )
    }

    static func incomingAttackWasBlocked(roll: Double, passiveBlockChance: Double) -> Bool {
        let blockChance = min(max(passiveBlockChance, 0), 0.8)
        guard blockChance > 0 else { return false }
        return min(max(roll, 0), 1) < blockChance
    }

    static func modifiedSkillCooldown(
        baseCooldown: TimeInterval,
        passiveCooldownReduction: Double,
        passiveCastSpeed: Double
    ) -> TimeInterval {
        let reduction = min(max(passiveCooldownReduction, 0), 0.8)
        let castSpeedMultiplier = 1.0 + max(0, passiveCastSpeed)
        return max(1, baseCooldown * (1.0 - reduction) / castSpeedMultiplier)
    }

    private func modifiedHeroSkillAttack(
        for skill: Skill,
        baseAttack: Int? = nil,
        multiplierOverride: Double? = nil
    ) -> Int {
        let attack = baseAttack ?? modifiedHeroAttack
        let multiplier = multiplierOverride ?? skill.damageMultiplier
        return max(1, Int(Double(max(0, attack)) * multiplier * passiveSkillDamageMultiplier(for: skill)))
    }

    private func passiveSkillDamageMultiplier(for skill: Skill) -> Double {
        let passiveEffects = hero.passiveRuntimeEffects
        var multiplier = 1.0

        switch skill.damageElement {
        case .physical:
            multiplier += passiveEffects.passivePhysicalDamagePercent
        case .fire:
            multiplier += passiveEffects.passiveFireDamagePercent
        case .cold:
            multiplier += passiveEffects.passiveColdDamagePercent
        case .lightning:
            multiplier += passiveEffects.passiveLightningDamagePercent
        case .none, .chaos:
            break
        }

        if [.projectile, .projectileAOE, .summonProjectile].contains(skill.delivery) {
            multiplier += passiveEffects.passiveIncreaseProjectileDamage
        }

        if [.meleeAOE, .rangeAOE, .projectileAOE, .trap].contains(skill.delivery) {
            multiplier += passiveEffects.passiveIncreaseAreaOfEffectDamage
        }

        return max(0.1, multiplier)
    }

    private func modifiedSkillCooldown(for skill: Skill) -> TimeInterval {
        let effects = hero.passiveRuntimeEffects
        return Self.modifiedSkillCooldown(
            baseCooldown: skill.cooldown,
            passiveCooldownReduction: effects.passiveCooldownReduction,
            passiveCastSpeed: effects.passiveCastSpeed
        )
    }

    private func modifiedSkillDuration(for skill: Skill) -> TimeInterval {
        max(1, skill.cooldown * (1.0 + max(0, hero.passiveRuntimeEffects.passiveSkillDurationIncrease)))
    }

    private func modifiedSkillHealing(_ amount: Int) -> Int {
        max(1, Int(Double(max(0, amount)) * (1.0 + max(0, hero.passiveRuntimeEffects.passiveSkillHealIncrease))))
    }

    private func applyPassiveHpRegen(deltaTime: TimeInterval) {
        let passiveHpRegenPerSec = hero.passiveRuntimeEffects.passiveHpRegenPerSec
        guard passiveHpRegenPerSec > 0, deltaTime > 0 else { return }
        let healed = hero.heal(Int(passiveHpRegenPerSec * deltaTime))
        if healed > 0 {
            heroHP = hero.currentHP
        }
    }

    private func applyPassiveAddHpPerHit() {
        let passiveAddHpPerHit = hero.passiveRuntimeEffects.passiveAddHpPerHit
        guard passiveAddHpPerHit > 0 else { return }
        let healed = hero.heal(passiveAddHpPerHit)
        if healed > 0 {
            heroHP = hero.currentHP
        }
    }

    private func applyPassiveHpLeech(fromDamage damage: Int) {
        let passiveHpLeech = hero.passiveRuntimeEffects.passiveHpLeech
        guard passiveHpLeech > 0, damage > 0 else { return }
        let healed = hero.heal(Int(Double(damage) * passiveHpLeech))
        if healed > 0 {
            heroHP = hero.currentHP
        }
    }

    private func applyPassiveAddHpPerKill() {
        let passiveAddHpPerKill = hero.passiveRuntimeEffects.passiveAddHpPerKill
        guard passiveAddHpPerKill > 0 else { return }
        let healed = hero.heal(passiveAddHpPerKill)
        if healed > 0 {
            heroHP = hero.currentHP
        }
    }

    private var heroAttackInterval: TimeInterval {
        let baseInterval = 1.0 / Double(max(1, hero.speed)) * 10
        return baseInterval / max(0.1, activeHeroAttackSpeedMultiplier)
    }

    private func readyCooldownHeroSkill() -> Skill? {
        let skills = cooldownHeroSkills
        guard !skills.isEmpty else { return nil }

        for offset in 0..<skills.count {
            let index = (nextCooldownSkillIndex + offset) % skills.count
            let skill = skills[index]
            guard (skillCooldowns[heroSkillCooldownKey(skill)] ?? 0) <= 0 else { continue }
            guard isHeroSkillUsableNow(skill) else { continue }
            nextCooldownSkillIndex = (index + 1) % skills.count
            return skill
        }
        return nil
    }

    private func readyAttackCountHeroSkill() -> Skill? {
        let skills = attackCountHeroSkills
        guard !skills.isEmpty else { return nil }

        for offset in 0..<skills.count {
            let index = (nextAttackCountSkillIndex + offset) % skills.count
            let skill = skills[index]
            let triggerEvery = max(1, skill.triggerEvery)
            guard heroBaseAttackCount % triggerEvery == 0 else { continue }
            nextAttackCountSkillIndex = (index + 1) % skills.count
            return skill
        }
        return nil
    }

    private func readyBaseAttackHeroSkill() -> Skill? {
        let skills = baseAttackHeroSkills
        guard !skills.isEmpty else { return nil }

        let index = nextBaseAttackSkillIndex % skills.count
        nextBaseAttackSkillIndex = (index + 1) % skills.count
        return skills[index]
    }

    private func isHeroSkillUsableNow(_ skill: Skill) -> Bool {
        if skill.id == "40601" {
            return supportStates.contains(where: \.isDefeated)
        }
        return true
    }

    @discardableResult
    private func applyCooldownHeroSkillIfReady() -> Bool {
        guard let skill = readyCooldownHeroSkill() else { return false }
        skillCooldowns[heroSkillCooldownKey(skill)] = modifiedSkillCooldown(for: skill)
        return applyHeroSkill(skill)
    }

    @discardableResult
    private func applyPartySupportSkillsIfReady() -> Bool {
        var applied = false
        for member in aliveSupportMembers {
            guard !isOver else { return applied }
            guard let skill = readySupportCooldownSkill(for: member) else { continue }
            skillCooldowns[supportSkillCooldownKey(skill, member: member)] = max(1, skill.cooldown)
            applied = applySupportSkill(skill, member: member) || applied
        }
        return applied
    }

    @discardableResult
    private func applyTriggeredHeroSkillAfterAttack() -> Bool {
        var applied = false
        if let baseAttackSkill = readyBaseAttackHeroSkill() {
            applied = applyHeroSkill(baseAttackSkill)
            if isOver { return applied }
        }
        guard let skill = readyAttackCountHeroSkill() else { return applied }
        return applyHeroSkill(skill) || applied
    }

    @discardableResult
    private func applyHeroSkill(_ skill: Skill) -> Bool {
        if skill.id == "10101" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "10201" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "10301" {
            return applyHeroRetributionStrikeSkill(skill)
        }

        if skill.id == "20101" {
            return applyHeroRapidProjectileSkill(skill)
        }

        if skill.id == "20201" {
            return applyHeroTrackingProjectileSkill(skill)
        }

        if skill.id == "20301" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "20501" {
            return applyHeroPiercingProjectileSkill(skill)
        }

        if skill.id == "20601" {
            return applyHeroSkewerShotSkill(skill)
        }

        if skill.id == "50101" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "50201" {
            return applyHeroFrostBoltSkill(skill)
        }

        if skill.id == "50401" {
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "50501" {
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "50601" {
            return applyHeroShockBoltSkill(skill)
        }

        if skill.id == "30101" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "30201" {
            return applyHeroIceOrbSkill(skill)
        }

        if skill.id == "30301" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "30401" {
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "30501" {
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "30601" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "40301" {
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "40601" {
            return applyHeroResurrectionSkill(skill)
        }

        if skill.id == "40101" {
            return applyHeroHealSkill(skill)
        }

        if skill.id == "60101" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.id == "60601" {
            let hpCost = hero.currentHP / 2
            hero.takeDamage(hpCost)
            heroHP = hero.currentHP
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hpCost,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "60301" {
            _ = activateHeroBuff(for: skill)
            stunAliveEnemies()
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "60501" {
            _ = activateHeroBuff(for: skill)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "60401" {
            return applyHeroRangeDamageSkill(skill)
        }

        if skill.damageMultiplier > 0 {
            guard let target = activeEnemyState else { return false }
            let hit = DamageCalculator.calculateResult(
                attackerATK: modifiedHeroSkillAttack(for: skill),
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            let defeated = damageFocusedEnemy(hit.amount, leechForHero: true)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))
            onEvent?(.heroSkill(skillName: skill.name, isCrit: hit.isCrit))
            if defeated {
                let defeatedIndex = focusedEnemyArrayIndex
                _ = completeFocusedEnemyIfNeeded()
                if skill.id == "60201" {
                    applyCrushingBlowShockwave(excluding: defeatedIndex)
                }
            }
            if !isOver {
                _ = triggerChargedTrapExplosionIfNeeded(after: skill)
            }
            return true
        }

        let healAmount = utilityHealAmount(for: skill)
        let activatedBuff = activateHeroBuff(for: skill)
        if healAmount > 0 {
            let healed = hero.heal(healAmount)
            heroHP = hero.currentHP
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: healed,
                isCrit: false,
                skillName: skill.name,
                kind: healed > 0 ? .heal : .buff
            ))
        } else if activatedBuff {
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
        } else {
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
        }
        onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
        return true
    }

    @discardableResult
    private func applyHeroRangeDamageSkill(_ skill: Skill) -> Bool {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty, skill.damageMultiplier > 0 else { return false }

        let skillAttack = modifiedHeroSkillAttack(for: skill)
        var defeatedIndices: [Int] = []
        var didCrit = false

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: skillAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            didCrit = didCrit || hit.isCrit
            if damageEnemy(at: index, amount: hit.amount, leechForHero: true) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))
        }

        onEvent?(.heroSkill(skillName: skill.name, isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }

        if !isOver {
            if skill.id == "60401" {
                armGroundSlamRocks(hitCount: targetIndices.count)
            } else if isPhysicalAreaDamageSkill(skill) {
                _ = triggerGroundSlamRockExplosionIfNeeded(
                    attacker: .hero,
                    attackPower: modifiedHeroAttack,
                    critRate: modifiedHeroCritRate,
                    critDamage: hero.critDamage
                )
            }
        }

        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applyHeroIceOrbSkill(_ skill: Skill) -> Bool {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty, skill.damageMultiplier > 0 else { return false }

        let hitCount = 2
        let hitAttack = modifiedHeroSkillAttack(for: skill, multiplierOverride: skill.damageMultiplier / Double(hitCount))
        var defeatedIndices: [Int] = []
        var didCrit = false

        for _ in 0..<hitCount {
            for index in targetIndices {
                guard !enemyStates[index].isDefeated, enemyStates[index].hp > 0 else { continue }
                let target = enemyStates[index]
                let hit = DamageCalculator.calculateResult(
                    attackerATK: hitAttack,
                    defenderDEF: target.monster.def,
                    critRate: modifiedHeroCritRate,
                    critDamage: hero.critDamage
                )
                didCrit = didCrit || hit.isCrit
                if damageEnemy(at: index, amount: hit.amount, leechForHero: true), !defeatedIndices.contains(index) {
                    defeatedIndices.append(index)
                }
                log.append(BattleLogEntry(
                    attacker: .hero,
                    damage: hit.amount,
                    isCrit: hit.isCrit,
                    skillName: skill.name,
                    kind: .damage
                ))
            }
        }

        slowAliveEnemies(at: targetIndices)
        onEvent?(.heroSkill(skillName: skill.name, isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applyHeroFrostBoltSkill(_ skill: Skill) -> Bool {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty, skill.damageMultiplier > 0 else { return false }

        let skillAttack = modifiedHeroSkillAttack(for: skill)
        var defeatedIndices: [Int] = []
        var didCrit = false

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: skillAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            didCrit = didCrit || hit.isCrit
            if damageEnemy(at: index, amount: hit.amount, leechForHero: true) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))
        }

        freezeAliveEnemies(at: targetIndices)
        onEvent?(.heroSkill(skillName: skill.name, isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applyHeroTrackingProjectileSkill(_ skill: Skill) -> Bool {
        return applyHeroRangeDamageSkill(skill)
    }

    @discardableResult
    private func applyHeroRetributionStrikeSkill(_ skill: Skill) -> Bool {
        guard skill.damageMultiplier > 0 else { return false }

        let strikeAttack = modifiedHeroSkillAttack(for: skill)
        let strikeCount = retributionStrikeHitCount()
        let targetIndices = focusedSkillTargetIndices(for: skill)
        var didApply = false
        var didCrit = false

        for _ in 0..<strikeCount {
            for targetIndex in targetIndices {
                guard enemyStates.indices.contains(targetIndex) else { continue }
                let target = enemyStates[targetIndex]
                guard !target.isDefeated, target.hp > 0 else { continue }

                let hit = DamageCalculator.calculateResult(
                    attackerATK: strikeAttack,
                    defenderDEF: target.monster.def,
                    critRate: modifiedHeroCritRate,
                    critDamage: hero.critDamage
                )
                didApply = true
                didCrit = didCrit || hit.isCrit
                let defeated = damageEnemy(at: targetIndex, amount: hit.amount, leechForHero: true)
                log.append(BattleLogEntry(
                    attacker: .hero,
                    damage: hit.amount,
                    isCrit: hit.isCrit,
                    skillName: skill.name,
                    kind: .damage
                ))

                if defeated {
                    _ = completeEnemy(at: targetIndex)
                    if isOver { break }
                }
            }
            if isOver { break }
        }

        guard didApply else { return false }
        onEvent?(.heroSkill(skillName: skill.name, isCrit: didCrit))
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    private func retributionStrikeHitCount() -> Int {
        let hpRatio = Double(max(hero.currentHP, 0)) / Double(max(hero.maxHP, 1))
        switch hpRatio {
        case ...0.25:
            return 5
        case ...0.5:
            return 4
        case ...0.75:
            return 3
        default:
            return 2
        }
    }

    @discardableResult
    private func applyHeroPiercingProjectileSkill(_ skill: Skill) -> Bool {
        return applyHeroRangeDamageSkill(skill)
    }

    @discardableResult
    private func applyHeroSkewerShotSkill(_ skill: Skill) -> Bool {
        guard let targetIndex = focusedEnemyArrayIndex, skill.levelOneValue > 0 else { return false }
        guard enemyStates.indices.contains(targetIndex), !enemyStates[targetIndex].isDefeated else { return false }

        enemyStates[targetIndex].lodgedSkewerArrows += 1
        let lodgedArrowCount = enemyStates[targetIndex].lodgedSkewerArrows
        let attackMultiplier = Double(skill.levelOneValue) / 100.0 * Double(lodgedArrowCount)
        let target = enemyStates[targetIndex]
        let hit = DamageCalculator.calculateResult(
            attackerATK: modifiedHeroSkillAttack(for: skill, multiplierOverride: attackMultiplier),
            defenderDEF: target.monster.def,
            critRate: modifiedHeroCritRate,
            critDamage: hero.critDamage
        )
        let defeated = damageEnemy(at: targetIndex, amount: hit.amount, leechForHero: true)
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: hit.amount,
            isCrit: hit.isCrit,
            skillName: skill.name,
            kind: .damage
        ))

        if defeated {
            _ = completeEnemy(at: targetIndex)
        } else if lodgedArrowCount == 3 {
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: "\(skill.name)出血",
                kind: .buff
            ))
        }

        onEvent?(.heroSkill(skillName: skill.name, isCrit: hit.isCrit))
        return true
    }

    @discardableResult
    private func applyHeroShockBoltSkill(_ skill: Skill) -> Bool {
        guard let lodgedTargetIndex = focusedEnemyArrayIndex, skill.levelOneValue > 0 else { return false }
        guard enemyStates.indices.contains(lodgedTargetIndex), !enemyStates[lodgedTargetIndex].isDefeated else { return false }

        let lightningAttack = modifiedHeroSkillAttack(for: skill, multiplierOverride: Double(skill.levelOneValue) / 100.0)
        let lodgedTarget = enemyStates[lodgedTargetIndex]
        let lodgedHit = DamageCalculator.calculateResult(
            attackerATK: lightningAttack,
            defenderDEF: lodgedTarget.monster.def,
            critRate: modifiedHeroCritRate,
            critDamage: hero.critDamage
        )
        let lodgedDefeated = damageEnemy(at: lodgedTargetIndex, amount: lodgedHit.amount, leechForHero: true)
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: lodgedHit.amount,
            isCrit: lodgedHit.isCrit,
            skillName: skill.name,
            kind: .damage
        ))

        if lodgedDefeated {
            _ = completeEnemy(at: lodgedTargetIndex)
            if isOver {
                onEvent?(.heroSkill(skillName: skill.name, isCrit: lodgedHit.isCrit))
                return true
            }
        }

        _ = activateHeroBuff(for: skill)
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: 0,
            isCrit: false,
            skillName: "\(skill.name)电流",
            kind: .buff
        ))

        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        onEvent?(.heroSkill(skillName: skill.name, isCrit: lodgedHit.isCrit))
        return true
    }

    @discardableResult
    private func applyHeroRapidProjectileSkill(_ skill: Skill) -> Bool {
        guard skill.damageMultiplier > 0 else { return false }

        let minimumSourceProvenProjectileCount = 2
        let projectileAttack = modifiedHeroSkillAttack(for: skill)
        var didApply = false
        var didCrit = false

        for _ in 0..<minimumSourceProvenProjectileCount {
            guard let targetIndex = focusedEnemyArrayIndex else { break }
            let target = enemyStates[targetIndex]
            guard !target.isDefeated, target.hp > 0 else { continue }

            let hit = DamageCalculator.calculateResult(
                attackerATK: projectileAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            didApply = true
            didCrit = didCrit || hit.isCrit
            let defeated = damageEnemy(at: targetIndex, amount: hit.amount, leechForHero: true)
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))

            if defeated {
                _ = completeEnemy(at: targetIndex)
                if isOver { break }
            }
        }

        guard didApply else { return false }
        onEvent?(.heroSkill(skillName: skill.name, isCrit: didCrit))
        return true
    }

    private func tickActiveHeroBuffs(deltaTime: TimeInterval) {
        applyHeroOverTimeBuffEffects(deltaTime: deltaTime)
        applySupportOverTimeBuffEffects(deltaTime: deltaTime)
        for index in activeHeroBuffs.indices {
            guard let duration = activeHeroBuffs[index].remainingDuration else { continue }
            activeHeroBuffs[index].remainingDuration = max(0, duration - deltaTime)
        }
        for index in activeSupportSkillBuffs.indices {
            activeSupportSkillBuffs[index].remainingDuration = max(
                0,
                activeSupportSkillBuffs[index].remainingDuration - max(0, deltaTime)
            )
        }
        removeExpiredHeroBuffs()
        removeExpiredSupportSkillBuffs()
    }

    private func consumeHeroAttackBuffCharges() {
        for index in activeHeroBuffs.indices {
            guard let attacks = activeHeroBuffs[index].remainingHeroAttacks else { continue }
            activeHeroBuffs[index].remainingHeroAttacks = max(0, attacks - 1)
        }
        removeExpiredHeroBuffs()
    }

    private func applyHeroOnHitBuffEffects() {
        for buff in activeHeroBuffs where buff.healPerHit > 0 {
            let healed = hero.heal(buff.healPerHit)
            heroHP = hero.currentHP
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: healed,
                isCrit: false,
                skillName: buff.name,
                kind: healed > 0 ? .heal : .buff
            ))
        }
    }

    private func applyHeroAttackDamageBuffEffects() {
        for buff in activeHeroBuffs where buff.bonusAttackDamageMultiplier > 0 {
            let targetIndices = enemyStates.indices.filter { index in
                !enemyStates[index].isDefeated && enemyStates[index].hp > 0
            }
            guard !targetIndices.isEmpty else { continue }

            let buffAttack = max(1, Int(Double(modifiedHeroAttack) * buff.bonusAttackDamageMultiplier))
            var defeatedIndices: [Int] = []
            for index in targetIndices {
                let target = enemyStates[index]
                let hit = DamageCalculator.calculateResult(
                    attackerATK: buffAttack,
                    defenderDEF: target.monster.def,
                    critRate: modifiedHeroCritRate,
                    critDamage: hero.critDamage
                )
                if damageEnemy(at: index, amount: hit.amount, leechForHero: true) {
                    defeatedIndices.append(index)
                }
                log.append(BattleLogEntry(
                    attacker: .hero,
                    damage: hit.amount,
                    isCrit: hit.isCrit,
                    skillName: buff.name,
                    kind: .damage
                ))
            }

            for index in defeatedIndices {
                guard !isOver else { break }
                _ = completeEnemy(at: index)
            }
        }
    }

    private func applyHeroOverTimeBuffEffects(deltaTime: TimeInterval) {
        guard deltaTime > 0 else { return }
        for buff in activeHeroBuffs where buff.rangeDamagePerSecondMultiplier > 0 {
            guard !isOver else { return }
            if buff.id == "30401" || buff.id == "50501" {
                applyFocusedProjectileDamageOverTime(from: buff, deltaTime: deltaTime)
            } else if buff.id == "30501" {
                let hitIndices = applyRangeDamageOverTime(from: buff, deltaTime: deltaTime)
                if !isOver {
                    slowAliveEnemies(at: hitIndices)
                }
            } else if buff.id == "60501" {
                let hitIndices = applyRangeDamageOverTime(from: buff, deltaTime: deltaTime)
                if !isOver {
                    markEnemiesBleeding(at: hitIndices, skillName: buff.name)
                }
                if !isOver {
                    _ = triggerGroundSlamRockExplosionIfNeeded(
                        attacker: .hero,
                        attackPower: modifiedHeroAttack,
                        critRate: modifiedHeroCritRate,
                        critDamage: hero.critDamage
                    )
                }
            } else {
                _ = applyRangeDamageOverTime(from: buff, deltaTime: deltaTime)
            }
        }
        for buff in activeHeroBuffs where buff.healPerSecond > 0 {
            let healAmount = max(1, Int(Double(buff.healPerSecond) * deltaTime))
            let healed = hero.heal(healAmount)
            if healed > 0 {
                heroHP = hero.currentHP
                log.append(BattleLogEntry(
                    attacker: .hero,
                    damage: healed,
                    isCrit: false,
                    skillName: buff.name,
                    kind: .heal
                ))
            }

            for index in supportStates.indices {
                let supportHealed = healSupportMember(at: index, amount: healAmount)
                guard supportHealed > 0 else { continue }
                log.append(BattleLogEntry(
                    attacker: .hero,
                    damage: supportHealed,
                    isCrit: false,
                    skillName: buff.name,
                    kind: .heal
                ))
            }
        }
    }

    private func applySupportOverTimeBuffEffects(deltaTime: TimeInterval) {
        guard deltaTime > 0 else { return }
        for buff in activeSupportSkillBuffs where buff.rangeDamagePerSecondMultiplier > 0 {
            guard !isOver else { return }
            guard let member = aliveSupportMembers.first(where: { $0.slotIndex == buff.supportSlotIndex }) else {
                continue
            }
            if buff.focusedProjectileOnly {
                applyFocusedSupportProjectileDamageOverTime(from: buff, member: member, deltaTime: deltaTime)
            } else {
                let hitIndices = applySupportRangeDamageOverTime(from: buff, member: member, deltaTime: deltaTime)
                if buff.appliesColdSlow, !isOver {
                    slowAliveEnemies(at: hitIndices)
                }
            }
        }
    }

    private func applyFocusedProjectileDamageOverTime(from buff: ActiveBattleBuff, deltaTime: TimeInterval) {
        guard let targetIndex = focusedEnemyArrayIndex else { return }
        let target = enemyStates[targetIndex]
        guard !target.isDefeated, target.hp > 0 else { return }

        let dotAttack = max(1, Int(Double(modifiedHeroAttack) * buff.rangeDamagePerSecondMultiplier * deltaTime))
        let hit = DamageCalculator.calculateResult(
            attackerATK: dotAttack,
            defenderDEF: target.monster.def,
            critRate: modifiedHeroCritRate,
            critDamage: hero.critDamage
        )
        let defeated = damageEnemy(at: targetIndex, amount: hit.amount, leechForHero: true)
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: hit.amount,
            isCrit: hit.isCrit,
            skillName: buff.name,
            kind: .damage
        ))

        if defeated {
            _ = completeEnemy(at: targetIndex)
        }
    }

    private func applyFocusedSupportProjectileDamageOverTime(
        from buff: ActiveSupportSkillBuff,
        member: PartyMember,
        deltaTime: TimeInterval
    ) {
        guard let targetIndex = focusedEnemyArrayIndex else { return }
        let target = enemyStates[targetIndex]
        guard !target.isDefeated, target.hp > 0 else { return }

        let dotAttack = max(
            1,
            Int(Double(modifiedSupportAttack(for: member)) * buff.rangeDamagePerSecondMultiplier * deltaTime)
        )
        let hit = DamageCalculator.calculateResult(
            attackerATK: dotAttack,
            defenderDEF: target.monster.def,
            critRate: modifiedSupportCritRate,
            critDamage: 1.5
        )
        let defeated = damageEnemy(at: targetIndex, amount: hit.amount, leechForHero: true)
        log.append(BattleLogEntry(
            attacker: .support(member.heroClass),
            damage: hit.amount,
            isCrit: hit.isCrit,
            skillName: buff.name,
            kind: .damage
        ))

        if defeated {
            _ = completeEnemy(at: targetIndex)
        }
    }

    @discardableResult
    private func applyRangeDamageOverTime(from buff: ActiveBattleBuff, deltaTime: TimeInterval) -> [Int] {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty else { return [] }

        let dotAttack = max(1, Int(Double(modifiedHeroAttack) * buff.rangeDamagePerSecondMultiplier * deltaTime))
        var defeatedIndices: [Int] = []
        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: dotAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            if damageEnemy(at: index, amount: hit.amount, leechForHero: true) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: buff.name,
                kind: .damage
            ))
        }

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        return targetIndices
    }

    @discardableResult
    private func applySupportRangeDamageOverTime(
        from buff: ActiveSupportSkillBuff,
        member: PartyMember,
        deltaTime: TimeInterval
    ) -> [Int] {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty else { return [] }

        let dotAttack = max(
            1,
            Int(Double(modifiedSupportAttack(for: member)) * buff.rangeDamagePerSecondMultiplier * deltaTime)
        )
        var defeatedIndices: [Int] = []
        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: dotAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            if damageEnemy(at: index, amount: hit.amount, leechForHero: true) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: buff.name,
                kind: .damage
            ))
        }

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        return targetIndices
    }

    private func markEnemiesBleeding(at indices: [Int], skillName: String) {
        for index in indices {
            guard enemyStates.indices.contains(index),
                  !enemyStates[index].isDefeated,
                  enemyStates[index].hp > 0 else {
                continue
            }
            guard enemyStates[index].applyBleedingWound() else { continue }
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: 0,
                isCrit: false,
                skillName: "\(skillName)出血",
                kind: .buff
            ))
        }
    }

    private func removeExpiredHeroBuffs() {
        activeHeroBuffs.removeAll(where: \.isExpired)
    }

    private func removeExpiredSupportSkillBuffs() {
        activeSupportSkillBuffs.removeAll(where: \.isExpired)
    }

    private func absorbIncomingDamage(_ damage: Int) -> Int {
        var remainingDamage = max(0, damage)
        guard remainingDamage > 0 else { return 0 }

        for index in activeHeroBuffs.indices {
            guard let shield = activeHeroBuffs[index].damageAbsorbRemaining, shield > 0 else { continue }
            let absorbed = min(shield, remainingDamage)
            activeHeroBuffs[index].damageAbsorbRemaining = shield - absorbed
            remainingDamage -= absorbed
            if remainingDamage <= 0 { break }
        }

        removeExpiredHeroBuffs()
        return remainingDamage
    }

    private func stunAliveEnemies() {
        for index in enemyStates.indices {
            guard !enemyStates[index].isDefeated else { continue }
            let stunDuration = max(1.0, attackInterval(for: enemyStates[index].monster))
            enemyCooldowns[index] = max(enemyCooldowns[index], stunDuration)
            enemyStates[index].applyStun(duration: stunDuration)
        }
    }

    private func slowAliveEnemies(at indices: [Int]) {
        for index in indices {
            guard enemyStates.indices.contains(index), !enemyStates[index].isDefeated else { continue }
            let slowDelay = attackInterval(for: enemyStates[index].monster) * 0.5
            enemyCooldowns[index] = max(enemyCooldowns[index], slowDelay)
            enemyStates[index].applyColdStatus(.chilled, duration: slowDelay)
        }
    }

    private func freezeAliveEnemies(at indices: [Int]) {
        for index in indices {
            guard enemyStates.indices.contains(index), !enemyStates[index].isDefeated else { continue }
            let freezeDelay = max(1.0, attackInterval(for: enemyStates[index].monster))
            enemyCooldowns[index] = max(enemyCooldowns[index], freezeDelay)
            enemyStates[index].applyColdStatus(.frozen, duration: freezeDelay)
        }
    }

    private func armGroundSlamRocks(hitCount: Int) {
        guard hitCount > 0 else { return }
        groundSlamRockCharges = min(
            GroundSlamRockScaffold.maxCharges,
            max(groundSlamRockCharges, hitCount)
        )
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: 0,
            isCrit: false,
            skillName: "大地强击岩石",
            kind: .buff
        ))
    }

    private func tickEnemyStatusEffects(deltaTime: TimeInterval) {
        guard deltaTime > 0 else { return }
        for index in enemyStates.indices {
            enemyStates[index].tickColdStatus(deltaTime: deltaTime)
            enemyStates[index].tickStun(deltaTime: deltaTime)
        }
    }

    @discardableResult
    private func applyUnyieldingWillIfAvailable() -> Bool {
        guard unyieldingWillAvailable, !unyieldingWillWasUsed, let skill = unyieldingWillSkill else {
            return false
        }

        let revivedHP = modifiedSkillHealing(max(1, Int(Double(hero.maxHP) * Double(skill.levelOneValue) / 100.0)))
        let restored = hero.revive(withHP: revivedHP)
        heroHP = hero.currentHP
        unyieldingWillWasUsed = true
        unyieldingWillAvailable = false
        onUnyieldingWillUsed?()
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: restored,
            isCrit: false,
            skillName: skill.name,
            kind: .heal
        ))
        onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
        return true
    }

    @discardableResult
    private func triggerChargedTrapExplosionIfNeeded(after skill: Skill) -> Bool {
        guard isElementalDamageSkill(skill) else { return false }
        guard let buffIndex = activeHeroBuffs.firstIndex(where: { buff in
            buff.id == "50401" && (buff.trapChargesRemaining ?? 0) > 0
        }) else { return false }

        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty else { return false }

        let buff = activeHeroBuffs[buffIndex]
        let trapAttack = max(1, Int(Double(modifiedHeroAttack) * max(1.0, buff.trapDamageMultiplier)))
        var defeatedIndices: [Int] = []
        var didCrit = false

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: trapAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedHeroCritRate,
                critDamage: hero.critDamage
            )
            didCrit = didCrit || hit.isCrit
            if damageEnemy(at: index, amount: hit.amount, leechForHero: true) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .hero,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: "\(buff.name)爆炸",
                kind: .damage
            ))
        }

        if let charges = activeHeroBuffs[buffIndex].trapChargesRemaining {
            activeHeroBuffs[buffIndex].trapChargesRemaining = max(0, charges - 1)
        }
        removeExpiredHeroBuffs()
        onEvent?(.heroSkill(skillName: "\(buff.name)爆炸", isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        return true
    }

    private func isElementalDamageSkill(_ skill: Skill) -> Bool {
        skill.damageElement.isElemental && skill.damageMultiplier > 0
    }

    private func isPhysicalAreaDamageSkill(_ skill: Skill) -> Bool {
        guard skill.damageElement == .physical, skill.damageMultiplier > 0 else { return false }
        switch skill.delivery {
        case .meleeAOE, .projectileAOE, .rangeAOE:
            return true
        case .melee, .projectile, .range, .summonProjectile, .trap, .buff, .heal, .resurrection, .none:
            return false
        }
    }

    @discardableResult
    private func triggerGroundSlamRockExplosionIfNeeded(
        attacker: BattleLogEntry.Battler,
        attackPower: Int,
        critRate: Double,
        critDamage: Double
    ) -> Bool {
        guard groundSlamRockCharges > 0 else { return false }
        let targetIndices = aliveEnemyIndices()
        guard !targetIndices.isEmpty else { return false }

        let explosionAttack = max(
            1,
            Int(Double(max(1, attackPower)) * GroundSlamRockScaffold.explosionDamageMultiplier)
        )
        groundSlamRockCharges = 0
        var defeatedIndices: [Int] = []
        var didCrit = false

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: explosionAttack,
                defenderDEF: target.monster.def,
                critRate: critRate,
                critDamage: critDamage
            )
            didCrit = didCrit || hit.isCrit
            if damageEnemy(at: index, amount: hit.amount, leechForHero: attacker == .hero) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: attacker,
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: GroundSlamRockScaffold.explosionSkillName,
                kind: .damage,
                damageElement: .physical,
                delivery: .meleeAOE
            ))
        }

        switch attacker {
        case .hero:
            onEvent?(.heroSkill(skillName: GroundSlamRockScaffold.explosionSkillName, isCrit: didCrit))
        case .support(let heroClass):
            onEvent?(.supportSkill(
                heroClass: heroClass,
                skillName: GroundSlamRockScaffold.explosionSkillName,
                isCrit: didCrit
            ))
        case .monster:
            break
        }

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        return true
    }

    @discardableResult
    private func activateHeroBuff(for skill: Skill) -> Bool {
        let buff: ActiveBattleBuff
        let modifiedDuration = modifiedSkillDuration(for: skill)
        switch skill.id {
        case "10401":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: max(1, skill.levelOneValue)
            )
        case "10501":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.5,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: modifiedSkillHealing(skill.levelOneValue),
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "40301":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill)),
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "30401":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill)),
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "30501":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill)),
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "20401":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0 + Double(skill.levelOneValue) / 100.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "40401":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: modifiedSkillHealing(skill.levelOneValue),
                damageAbsorbRemaining: nil
            )
        case "60301":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0 + Double(skill.levelOneValue) / 100.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "50301":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: nil,
                remainingHeroAttacks: max(1, skill.levelOneValue),
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.5,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "50401":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil,
                trapChargesRemaining: 1,
                trapDamageMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill))
            )
        case "50501":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill)),
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "50601":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: "\(skill.name)电流",
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill)),
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "60501":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0 * passiveSkillDamageMultiplier(for: skill)),
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        case "60601":
            buff = ActiveBattleBuff(
                id: skill.id,
                name: skill.name,
                remainingDuration: modifiedDuration,
                remainingHeroAttacks: nil,
                attackMultiplier: 1.0 + Double(skill.levelOneValue) / 100.0,
                attackSpeedMultiplier: 1.0,
                critRateMultiplier: 1.0,
                bonusAttackDamageMultiplier: 0,
                rangeDamagePerSecondMultiplier: 0,
                healPerHit: 0,
                healPerSecond: 0,
                damageAbsorbRemaining: nil
            )
        default:
            return false
        }

        if let index = activeHeroBuffs.firstIndex(where: { $0.id == buff.id }) {
            activeHeroBuffs[index] = buff
        } else {
            activeHeroBuffs.append(buff)
        }
        return true
    }

    @discardableResult
    private func applySupportSkill(_ skill: Skill, member: PartyMember) -> Bool {
        if skill.id == "10101" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "10301" {
            return applySupportRetributionStrikeSkill(skill, member: member)
        }

        if skill.id == "20101" {
            return applySupportRapidProjectileSkill(skill, member: member)
        }

        if skill.id == "20501" {
            return applySupportPiercingProjectileSkill(skill, member: member)
        }

        if skill.id == "20601" {
            return applySupportSkewerShotSkill(skill, member: member)
        }

        if skill.id == "50101" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "50601" {
            return applySupportShockBoltSkill(skill, member: member)
        }

        if skill.id == "60201" {
            return applySupportCrushingBlowSkill(skill, member: member)
        }

        if skill.id == "60401" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "30401" || skill.id == "50501" {
            _ = activateSupportSustainedDamageBuff(for: skill, member: member, focusedProjectileOnly: true)
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "30501" {
            _ = activateSupportSustainedDamageBuff(
                for: skill,
                member: member,
                focusedProjectileOnly: false,
                appliesColdSlow: true
            )
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
            onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: false))
            return true
        }

        if skill.id == "10201" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "20201" {
            return applySupportTrackingProjectileSkill(skill, member: member)
        }

        if skill.id == "20301" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "50201" {
            return applySupportFrostBoltSkill(skill, member: member)
        }

        if skill.id == "30101" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "30201" {
            return applySupportIceOrbSkill(skill, member: member)
        }

        if skill.id == "30301" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "30601" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.id == "40601" {
            return applySupportResurrectionSkill(skill, member: member)
        }

        if skill.id == "40101" {
            return applySupportHealSkill(skill, member: member)
        }

        if skill.id == "60101" {
            return applySupportRangeDamageSkill(skill, member: member)
        }

        if skill.damageMultiplier > 0 {
            guard let target = activeEnemyState else { return false }
            let hit = DamageCalculator.calculateResult(
                attackerATK: max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier)),
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            let defeated = damageFocusedEnemy(hit.amount)
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))
            onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: hit.isCrit))
            if defeated {
                _ = completeFocusedEnemyIfNeeded()
            }
            if !isOver {
                _ = triggerChargedTrapExplosionIfNeeded(after: skill)
            }
            return true
        }

        let healAmount = utilityHealAmount(for: skill)
        if healAmount > 0 {
            let healed = hero.heal(healAmount)
            heroHP = hero.currentHP
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: healed,
                isCrit: false,
                skillName: skill.name,
                kind: healed > 0 ? .heal : .buff
            ))
        } else {
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: 0,
                isCrit: false,
                skillName: skill.name,
                kind: .buff
            ))
        }
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: false))
        return true
    }

    @discardableResult
    private func activateSupportSustainedDamageBuff(
        for skill: Skill,
        member: PartyMember,
        focusedProjectileOnly: Bool,
        appliesColdSlow: Bool = false,
        displayName: String? = nil
    ) -> Bool {
        guard skill.levelOneValue > 0 else { return false }
        let buff = ActiveSupportSkillBuff(
            id: "support:\(member.slotIndex):\(skill.id)",
            name: displayName ?? skill.name,
            supportSlotIndex: member.slotIndex,
            remainingDuration: max(1, skill.cooldown),
            rangeDamagePerSecondMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0),
            focusedProjectileOnly: focusedProjectileOnly,
            appliesColdSlow: appliesColdSlow
        )

        if let index = activeSupportSkillBuffs.firstIndex(where: { $0.id == buff.id }) {
            activeSupportSkillBuffs[index] = buff
        } else {
            activeSupportSkillBuffs.append(buff)
        }
        return true
    }

    @discardableResult
    private func applyHeroHealSkill(_ skill: Skill) -> Bool {
        let applied = applyPartyHealSkill(skill, attacker: .hero, appliesHeroPassiveHealing: true)
        onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
        return applied
    }

    @discardableResult
    private func applySupportHealSkill(_ skill: Skill, member: PartyMember) -> Bool {
        let applied = applyPartyHealSkill(skill, attacker: .support(member.heroClass), appliesHeroPassiveHealing: false)
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: false))
        return applied
    }

    @discardableResult
    private func applyPartyHealSkill(
        _ skill: Skill,
        attacker: BattleLogEntry.Battler,
        appliesHeroPassiveHealing: Bool
    ) -> Bool {
        var healed = 0
        if let target = mostWoundedLivingAllyTarget() {
            let amount = healingAmount(
                for: target,
                skill: skill,
                appliesHeroPassiveHealing: appliesHeroPassiveHealing
            )
            switch target {
            case .hero:
                healed = hero.heal(amount)
                heroHP = hero.currentHP
            case .support(let index):
                healed = healSupportMember(at: index, amount: amount)
            }
        }

        log.append(BattleLogEntry(
            attacker: attacker,
            damage: healed,
            isCrit: false,
            skillName: skill.name,
            kind: healed > 0 ? .heal : .buff
        ))
        return true
    }

    private func mostWoundedLivingAllyTarget() -> BattleAllyHealTarget? {
        var candidates: [(target: BattleAllyHealTarget, missingRatio: Double, missingHP: Int)] = []

        if heroHP > 0, hero.currentHP < hero.maxHP {
            let missingHP = hero.maxHP - hero.currentHP
            candidates.append((
                target: .hero,
                missingRatio: Double(missingHP) / Double(max(hero.maxHP, 1)),
                missingHP: missingHP
            ))
        }

        for index in supportStates.indices {
            let state = supportStates[index]
            guard !state.isDefeated, state.hp < state.maxHP else { continue }
            let missingHP = state.maxHP - state.hp
            candidates.append((
                target: .support(index),
                missingRatio: Double(missingHP) / Double(max(state.maxHP, 1)),
                missingHP: missingHP
            ))
        }

        // Exact original target priority is not exposed by the checked pages.
        return candidates.max { lhs, rhs in
            if lhs.missingRatio == rhs.missingRatio {
                return lhs.missingHP < rhs.missingHP
            }
            return lhs.missingRatio < rhs.missingRatio
        }?.target
    }

    private func healingAmount(
        for target: BattleAllyHealTarget,
        skill: Skill,
        appliesHeroPassiveHealing: Bool
    ) -> Int {
        let maxHP: Int
        switch target {
        case .hero:
            maxHP = hero.maxHP
        case .support(let index):
            maxHP = supportStates.indices.contains(index) ? supportStates[index].maxHP : 0
        }
        let baseHealing = max(1, Int(Double(maxHP) * Double(skill.levelOneValue) / 100.0))
        return appliesHeroPassiveHealing ? modifiedSkillHealing(baseHealing) : baseHealing
    }

    @discardableResult
    private func applyHeroResurrectionSkill(_ skill: Skill) -> Bool {
        guard let targetIndex = firstDefeatedSupportIndex() else { return false }
        let revivedHP = resurrectionHP(for: supportStates[targetIndex], skill: skill, appliesHeroPassiveHealing: true)
        let restored = reviveSupportMember(at: targetIndex, withHP: revivedHP)
        log.append(BattleLogEntry(
            attacker: .hero,
            damage: restored,
            isCrit: false,
            skillName: skill.name,
            kind: .heal
        ))
        onEvent?(.heroSkill(skillName: skill.name, isCrit: false))
        return restored > 0
    }

    @discardableResult
    private func applySupportResurrectionSkill(_ skill: Skill, member: PartyMember) -> Bool {
        guard let targetIndex = firstDefeatedSupportIndex(excludingSlotIndex: member.slotIndex) else { return false }
        let revivedHP = resurrectionHP(for: supportStates[targetIndex], skill: skill, appliesHeroPassiveHealing: false)
        let restored = reviveSupportMember(at: targetIndex, withHP: revivedHP)
        log.append(BattleLogEntry(
            attacker: .support(member.heroClass),
            damage: restored,
            isCrit: false,
            skillName: skill.name,
            kind: .heal
        ))
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: false))
        return restored > 0
    }

    private func firstDefeatedSupportIndex(excludingSlotIndex excludedSlotIndex: Int? = nil) -> Int? {
        supportStates.firstIndex { state in
            state.isDefeated && state.slotIndex != excludedSlotIndex
        }
    }

    private func resurrectionHP(
        for state: BattleSupportState,
        skill: Skill,
        appliesHeroPassiveHealing: Bool
    ) -> Int {
        let baseHealing = max(1, Int(Double(state.maxHP) * Double(skill.levelOneValue) / 100.0))
        return appliesHeroPassiveHealing ? modifiedSkillHealing(baseHealing) : baseHealing
    }

    @discardableResult
    private func applySupportRetributionStrikeSkill(_ skill: Skill, member: PartyMember) -> Bool {
        guard skill.damageMultiplier > 0 else { return false }

        let strikeAttack = max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier))
        let strikeCount = supportRetributionStrikeHitCount(for: member)
        var didApply = false
        var didCrit = false

        for _ in 0..<strikeCount {
            guard let targetIndex = focusedEnemyArrayIndex else { break }
            let target = enemyStates[targetIndex]
            guard !target.isDefeated, target.hp > 0 else { continue }

            let hit = DamageCalculator.calculateResult(
                attackerATK: strikeAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            didApply = true
            didCrit = didCrit || hit.isCrit
            let defeated = damageEnemy(at: targetIndex, amount: hit.amount)
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))

            if defeated {
                _ = completeEnemy(at: targetIndex)
                if isOver { break }
            }
        }

        guard didApply else { return false }
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: didCrit))
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    private func supportRetributionStrikeHitCount(for member: PartyMember) -> Int {
        guard let supportState = supportStates.first(where: { $0.slotIndex == member.slotIndex }) else {
            return 2
        }
        let hpRatio = Double(max(supportState.hp, 0)) / Double(max(supportState.maxHP, 1))
        switch hpRatio {
        case ...0.25:
            return 5
        case ...0.5:
            return 4
        case ...0.75:
            return 3
        default:
            return 2
        }
    }

    @discardableResult
    private func applySupportRapidProjectileSkill(_ skill: Skill, member: PartyMember) -> Bool {
        guard skill.damageMultiplier > 0 else { return false }

        let minimumSourceProvenProjectileCount = 2
        let projectileAttack = max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier))
        var didApply = false
        var didCrit = false

        for _ in 0..<minimumSourceProvenProjectileCount {
            guard let targetIndex = focusedEnemyArrayIndex else { break }
            let target = enemyStates[targetIndex]
            guard !target.isDefeated, target.hp > 0 else { continue }

            let hit = DamageCalculator.calculateResult(
                attackerATK: projectileAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            didApply = true
            didCrit = didCrit || hit.isCrit
            let defeated = damageEnemy(at: targetIndex, amount: hit.amount)
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))

            if defeated {
                _ = completeEnemy(at: targetIndex)
                if isOver { break }
            }
        }

        guard didApply else { return false }
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: didCrit))
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applySupportPiercingProjectileSkill(_ skill: Skill, member: PartyMember) -> Bool {
        applySupportRangeDamageSkill(skill, member: member)
    }

    @discardableResult
    private func applySupportSkewerShotSkill(_ skill: Skill, member: PartyMember) -> Bool {
        guard let targetIndex = focusedEnemyArrayIndex, skill.levelOneValue > 0 else { return false }
        guard enemyStates.indices.contains(targetIndex), !enemyStates[targetIndex].isDefeated else { return false }

        enemyStates[targetIndex].lodgedSkewerArrows += 1
        let lodgedArrowCount = enemyStates[targetIndex].lodgedSkewerArrows
        let attackMultiplier = Double(skill.levelOneValue) / 100.0 * Double(lodgedArrowCount)
        let target = enemyStates[targetIndex]
        let hit = DamageCalculator.calculateResult(
            attackerATK: max(1, Int(Double(modifiedSupportAttack(for: member)) * attackMultiplier)),
            defenderDEF: target.monster.def,
            critRate: modifiedSupportCritRate,
            critDamage: 1.5
        )
        let defeated = damageEnemy(at: targetIndex, amount: hit.amount)
        log.append(BattleLogEntry(
            attacker: .support(member.heroClass),
            damage: hit.amount,
            isCrit: hit.isCrit,
            skillName: skill.name,
            kind: .damage
        ))

        if defeated {
            _ = completeEnemy(at: targetIndex)
        } else if lodgedArrowCount == 3 {
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: 0,
                isCrit: false,
                skillName: "\(skill.name)出血",
                kind: .buff
            ))
        }

        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: hit.isCrit))
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applySupportShockBoltSkill(_ skill: Skill, member: PartyMember) -> Bool {
        guard let lodgedTargetIndex = focusedEnemyArrayIndex, skill.levelOneValue > 0 else { return false }
        guard enemyStates.indices.contains(lodgedTargetIndex), !enemyStates[lodgedTargetIndex].isDefeated else { return false }

        let lightningAttack = max(1, Int(Double(modifiedSupportAttack(for: member)) * Double(skill.levelOneValue) / 100.0))
        let lodgedTarget = enemyStates[lodgedTargetIndex]
        let lodgedHit = DamageCalculator.calculateResult(
            attackerATK: lightningAttack,
            defenderDEF: lodgedTarget.monster.def,
            critRate: modifiedSupportCritRate,
            critDamage: 1.5
        )
        let lodgedDefeated = damageEnemy(at: lodgedTargetIndex, amount: lodgedHit.amount)
        log.append(BattleLogEntry(
            attacker: .support(member.heroClass),
            damage: lodgedHit.amount,
            isCrit: lodgedHit.isCrit,
            skillName: skill.name,
            kind: .damage
        ))

        if lodgedDefeated {
            _ = completeEnemy(at: lodgedTargetIndex)
            if isOver {
                onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: lodgedHit.isCrit))
                return true
            }
        }

        _ = activateSupportSustainedDamageBuff(
            for: skill,
            member: member,
            focusedProjectileOnly: false,
            displayName: "\(skill.name)电流"
        )
        log.append(BattleLogEntry(
            attacker: .support(member.heroClass),
            damage: 0,
            isCrit: false,
            skillName: "\(skill.name)电流",
            kind: .buff
        ))

        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: lodgedHit.isCrit))
        return true
    }

    @discardableResult
    private func applySupportCrushingBlowSkill(_ skill: Skill, member: PartyMember) -> Bool {
        guard skill.damageMultiplier > 0, let target = activeEnemyState else { return false }

        let hit = DamageCalculator.calculateResult(
            attackerATK: max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier)),
            defenderDEF: target.monster.def,
            critRate: modifiedSupportCritRate,
            critDamage: 1.5
        )
        let defeatedIndex = focusedEnemyArrayIndex
        let defeated = damageFocusedEnemy(hit.amount)
        log.append(BattleLogEntry(
            attacker: .support(member.heroClass),
            damage: hit.amount,
            isCrit: hit.isCrit,
            skillName: skill.name,
            kind: .damage
        ))
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: hit.isCrit))

        if defeated {
            _ = completeFocusedEnemyIfNeeded()
            if !isOver {
                applyCrushingBlowShockwave(
                    excluding: defeatedIndex,
                    attacker: .support(member.heroClass),
                    attackPower: modifiedSupportAttack(for: member),
                    critRate: modifiedSupportCritRate,
                    critDamage: 1.5
                )
            }
        }

        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applySupportRangeDamageSkill(_ skill: Skill, member: PartyMember) -> Bool {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty, skill.damageMultiplier > 0 else { return false }

        let skillAttack = max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier))
        var defeatedIndices: [Int] = []
        var didCrit = false

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: skillAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            didCrit = didCrit || hit.isCrit
            if damageEnemy(at: index, amount: hit.amount) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))
        }

        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }

        if !isOver {
            if skill.id == "60401" {
                armGroundSlamRocks(hitCount: targetIndices.count)
            } else if isPhysicalAreaDamageSkill(skill) {
                _ = triggerGroundSlamRockExplosionIfNeeded(
                    attacker: .support(member.heroClass),
                    attackPower: modifiedSupportAttack(for: member),
                    critRate: modifiedSupportCritRate,
                    critDamage: 1.5
                )
            }
        }

        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applySupportIceOrbSkill(_ skill: Skill, member: PartyMember) -> Bool {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty, skill.damageMultiplier > 0 else { return false }

        let hitCount = 2
        let hitAttack = max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier / Double(hitCount)))
        var defeatedIndices: [Int] = []
        var didCrit = false

        for _ in 0..<hitCount {
            for index in targetIndices {
                guard !enemyStates[index].isDefeated, enemyStates[index].hp > 0 else { continue }
                let target = enemyStates[index]
                let hit = DamageCalculator.calculateResult(
                    attackerATK: hitAttack,
                    defenderDEF: target.monster.def,
                    critRate: modifiedSupportCritRate,
                    critDamage: 1.5
                )
                didCrit = didCrit || hit.isCrit
                if damageEnemy(at: index, amount: hit.amount), !defeatedIndices.contains(index) {
                    defeatedIndices.append(index)
                }
                log.append(BattleLogEntry(
                    attacker: .support(member.heroClass),
                    damage: hit.amount,
                    isCrit: hit.isCrit,
                    skillName: skill.name,
                    kind: .damage
                ))
            }
        }

        slowAliveEnemies(at: targetIndices)
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applySupportFrostBoltSkill(_ skill: Skill, member: PartyMember) -> Bool {
        let targetIndices = enemyStates.indices.filter { index in
            !enemyStates[index].isDefeated && enemyStates[index].hp > 0
        }
        guard !targetIndices.isEmpty, skill.damageMultiplier > 0 else { return false }

        let skillAttack = max(1, Int(Double(modifiedSupportAttack(for: member)) * skill.damageMultiplier))
        var defeatedIndices: [Int] = []
        var didCrit = false

        for index in targetIndices {
            let target = enemyStates[index]
            let hit = DamageCalculator.calculateResult(
                attackerATK: skillAttack,
                defenderDEF: target.monster.def,
                critRate: modifiedSupportCritRate,
                critDamage: 1.5
            )
            didCrit = didCrit || hit.isCrit
            if damageEnemy(at: index, amount: hit.amount) {
                defeatedIndices.append(index)
            }
            log.append(BattleLogEntry(
                attacker: .support(member.heroClass),
                damage: hit.amount,
                isCrit: hit.isCrit,
                skillName: skill.name,
                kind: .damage
            ))
        }

        freezeAliveEnemies(at: targetIndices)
        onEvent?(.supportSkill(heroClass: member.heroClass, skillName: skill.name, isCrit: didCrit))

        for index in defeatedIndices {
            guard !isOver else { break }
            _ = completeEnemy(at: index)
        }
        if !isOver {
            _ = triggerChargedTrapExplosionIfNeeded(after: skill)
        }
        return true
    }

    @discardableResult
    private func applySupportTrackingProjectileSkill(_ skill: Skill, member: PartyMember) -> Bool {
        return applySupportRangeDamageSkill(skill, member: member)
    }

    private func utilityHealAmount(for skill: Skill) -> Int {
        guard skill.damageMultiplier == 0 else { return 0 }
        switch skill.id {
        default:
            return 0
        }
    }

    private func supportCooldownSkills(for member: PartyMember) -> [Skill] {
        supportActiveSkills(for: member)
            .filter { isAutomaticCooldownSkill($0) }
    }

    private func supportContinuousSkills(for member: PartyMember) -> [Skill] {
        supportActiveSkills(for: member)
            .filter { $0.activation == .continuous }
    }

    private func supportAttackCountSkills(for member: PartyMember) -> [Skill] {
        supportActiveSkills(for: member)
            .filter { $0.activation == .baseAttackCount }
    }

    private func supportActiveSkills(for member: PartyMember) -> [Skill] {
        activeSkillLoadouts.activeSkills(
            for: member.heroClass,
            heroLevel: hero.level,
            slotCount: activeSkillSlotCount
        )
    }

    private func readySupportCooldownSkill(for member: PartyMember) -> Skill? {
        let skills = supportCooldownSkills(for: member)
        guard !skills.isEmpty else { return nil }

        let startIndex = nextSupportCooldownSkillIndexes[member.slotIndex] ?? 0
        for offset in 0..<skills.count {
            let index = (startIndex + offset) % skills.count
            let skill = skills[index]
            guard (skillCooldowns[supportSkillCooldownKey(skill, member: member)] ?? 0) <= 0 else {
                continue
            }
            guard isSupportSkillUsableNow(skill, member: member) else { continue }
            nextSupportCooldownSkillIndexes[member.slotIndex] = (index + 1) % skills.count
            return skill
        }
        return nil
    }

    private func readyAttackCountSupportSkill(for member: PartyMember) -> Skill? {
        let skills = supportAttackCountSkills(for: member)
        guard !skills.isEmpty else { return nil }

        let supportAttackCount = supportBaseAttackCounts[member.slotIndex] ?? 0
        let startIndex = nextSupportAttackCountSkillIndexes[member.slotIndex] ?? 0
        for offset in 0..<skills.count {
            let index = (startIndex + offset) % skills.count
            let skill = skills[index]
            let triggerEvery = max(1, skill.triggerEvery)
            guard supportAttackCount > 0, supportAttackCount % triggerEvery == 0 else { continue }
            nextSupportAttackCountSkillIndexes[member.slotIndex] = (index + 1) % skills.count
            return skill
        }
        return nil
    }

    @discardableResult
    private func applyTriggeredSupportSkillAfterAttack(for member: PartyMember) -> Bool {
        guard let skill = readyAttackCountSupportSkill(for: member) else { return false }
        return applySupportSkill(skill, member: member)
    }

    private func isSupportSkillUsableNow(_ skill: Skill, member: PartyMember) -> Bool {
        if skill.id == "40601" {
            return supportStates.contains { $0.isDefeated && $0.slotIndex != member.slotIndex }
        }
        return true
    }

    private func heroSkillCooldownKey(_ skill: Skill) -> String {
        "hero:\(skill.id)"
    }

    private func supportSkillCooldownKey(_ skill: Skill, member: PartyMember) -> String {
        "support:\(member.slotIndex):\(skill.id)"
    }
}

extension Battle {
    func activateBattleSceneSnapshotDeployables() {
        let skills = HeroClass.allCases
            .flatMap { HeroSkills.named(for: $0) }
            .filter { ["30401", "50401", "50501"].contains($0.id) }

        for skill in skills {
            _ = activateHeroBuff(for: skill)
        }
    }

    func activateBattleStatusSnapshotBuffs() {
        let skills = HeroClass.allCases
            .flatMap { HeroSkills.named(for: $0) }
            .filter { ["10401", "50401"].contains($0.id) }

        for skill in skills {
            _ = activateHeroBuff(for: skill)
        }
    }

    func activateCrowdedBattleStatusSnapshotBuffs() {
        let crowdedStatusSkillIDs = Set([
            "10401",
            "10501",
            "20401",
            "30401",
            "30501",
            "40301",
            "40401",
            "50301",
            "50401",
            "50501",
            "50601",
            "60301",
            "60501",
            "60601"
        ])
        let skills = HeroClass.allCases
            .flatMap { HeroSkills.named(for: $0) }
            .filter { crowdedStatusSkillIDs.contains($0.id) }

        for skill in skills {
            _ = activateHeroBuff(for: skill)
        }
    }
}

struct BattleLogEntry: Identifiable {
    let id = UUID()
    let attacker: Battler
    let damage: Int
    let isCrit: Bool
    let skillName: String?
    let kind: Kind
    let damageElement: SkillDamageElement
    let delivery: SkillDelivery

    init(
        attacker: Battler,
        damage: Int,
        isCrit: Bool,
        skillName: String? = nil,
        kind: Kind = .damage,
        damageElement: SkillDamageElement = .none,
        delivery: SkillDelivery = .none
    ) {
        let inferredSkill = skillName.flatMap(HeroSkills.skill(forLogSkillName:))
        self.attacker = attacker
        self.damage = damage
        self.isCrit = isCrit
        self.skillName = skillName
        self.kind = kind
        self.damageElement = damageElement == .none ? (inferredSkill?.damageElement ?? .none) : damageElement
        self.delivery = delivery == .none ? (inferredSkill?.delivery ?? .none) : delivery
    }

    enum Battler: Equatable {
        case hero
        case support(HeroClass)
        case monster
    }

    enum Kind: Equatable {
        case damage
        case heal
        case buff
    }
}
