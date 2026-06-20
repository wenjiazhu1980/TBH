import Testing
@testable import TBH

@Suite struct DamageResultTests {
    @Test func guaranteedCritIsFlagged() {
        let result = DamageCalculator.calculateResult(
            attackerATK: 100,
            defenderDEF: 0,
            critRate: 1.0,
            critDamage: 2.0
        )
        #expect(result.isCrit, "critRate=1 must always crit")
        // 100 * 2.0 = 200，±10% 波动
        #expect(result.amount >= 180 && result.amount <= 220, "Crit damage \(result.amount) out of range")
    }

    @Test func zeroCritRateNeverCrits() {
        let result = DamageCalculator.calculateResult(
            attackerATK: 100,
            defenderDEF: 0,
            critRate: 0,
            critDamage: 2.0
        )
        #expect(!result.isCrit, "critRate=0 must never crit")
        #expect(result.amount >= 90 && result.amount <= 110)
    }
}

@Suite struct SkillArtTests {
    @Test func namedSkillsResolveToCategoryIcons() {
        let allNamedSkills = HeroClass.allCases.flatMap { HeroSkills.named(for: $0) }
        let iconNames = allNamedSkills.map { GameArt.skillIconName(for: $0) }

        #expect(iconNames.count == 36)
        #expect(iconNames.allSatisfy { $0.hasPrefix("skill_") })
        #expect(Set(iconNames).count >= 8)

        let fireball = allNamedSkills.first { $0.id == "30101" }
        let iceOrb = allNamedSkills.first { $0.id == "30201" }
        let lightning = allNamedSkills.first { $0.id == "30301" }
        let heal = allNamedSkills.first { $0.id == "40101" }
        let resurrection = allNamedSkills.first { $0.id == "40601" }
        let chargeTrap = allNamedSkills.first { $0.id == "50401" }
        let quickLoader = allNamedSkills.first { $0.id == "50301" }

        #expect(fireball.map(GameArt.skillIconName(for:)) == "skill_0_2")
        #expect(iceOrb.map(GameArt.skillIconName(for:)) == "skill_2_1")
        #expect(lightning.map(GameArt.skillIconName(for:)) == "skill_2_2")
        #expect(heal.map(GameArt.skillIconName(for:)) == "skill_0_3")
        #expect(resurrection.map(GameArt.skillIconName(for:)) == "skill_0_3")
        #expect(chargeTrap.map(GameArt.skillIconName(for:)) == "skill_1_0")
        #expect(quickLoader.map(GameArt.skillIconName(for:)) == "skill_1_3")
    }

    @Test func battleHeroSpritesFitCompactBattleStrip() {
        let maximumBattleHeroHeight = BattleSceneMetrics.compactHeight * 0.72

        for heroClass in HeroClass.allCases {
            #expect(BattleHeroSpriteMetrics.mainSize(for: heroClass).height <= maximumBattleHeroHeight)
            #expect(BattleHeroSpriteMetrics.supportSize(for: heroClass).height <= maximumBattleHeroHeight)
        }
    }

    @Test func battleTabPrimaryHeroRemainsVisuallyDominant() {
        #expect(BattleHeroSpriteMetrics.mainScale > BattleHeroSpriteMetrics.supportScale)

        for heroClass in HeroClass.allCases {
            #expect(BattleHeroSpriteMetrics.mainSize(for: heroClass).width > BattleHeroSpriteMetrics.supportSize(for: heroClass).width)
            #expect(BattleHeroSpriteMetrics.mainSize(for: heroClass).height > BattleHeroSpriteMetrics.supportSize(for: heroClass).height)
        }
    }

    @Test func battleHeroSpritesResolveToDedicatedClassArtwork() {
        let battleSpriteNames = HeroClass.allCases.map(GameArt.battleHeroSpriteName(for:))

        #expect(battleSpriteNames.allSatisfy { $0.hasPrefix("battle_hero_") })
        #expect(Set(battleSpriteNames).count == HeroClass.allCases.count)
        #expect(HeroClass.allCases.allSatisfy {
            GameArt.heroSpriteName(for: $0) != GameArt.battleHeroSpriteName(for: $0)
        })
    }
}

@Suite struct SourceSkillCatalogTests {
    @Test func sourceSkillCatalogCoversCheckedRows() {
        let activationCounts = Dictionary(grouping: SourceSkillCatalog.all, by: \.activation)
            .mapValues(\.count)

        #expect(SourceSkillCatalog.all.count == 106)
        #expect(SourceSkillCatalog.all.count == SourceSkillCatalog.expectedSourceCount)
        #expect(Set(SourceSkillCatalog.all.map(\.id)).count == SourceSkillCatalog.all.count)
        #expect(activationCounts == [
            .baseAttack: 58,
            .baseAttackCount: 11,
            .continuous: 2,
            .cooldown: 35
        ])
        #expect(SourceSkillCatalog.damageTypes == ["Chaos", "Cold", "Fire", "Lightning", "Physical"])
        #expect(SourceSkillCatalog.deliveries.count == 8)
        #expect(SourceSkillCatalog.deliveries.contains(""))
        #expect(SourceSkillCatalog.deliveries.contains("Projectile, Summon"))
        #expect(SourceSkillCatalog.deliveries.contains("Trap"))
    }

    @Test func sourceSkillDamageReviewPreservesCheckedDistribution() {
        let damageCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillDamageReviewMetrics.rows.map {
                ($0.damageType, $0.sourceCount)
            }
        )

        #expect(SourceSkillDamageReviewMetrics.damageBucketCount == 5)
        #expect(SourceSkillDamageReviewMetrics.sourceCount == 106)
        #expect(SourceSkillDamageReviewMetrics.runtimeMappedCount == 46)
        #expect(SourceSkillDamageReviewMetrics.nonPhysicalRuntimeCount == 15)
        #expect(SourceSkillDamageReviewMetrics.chaosRuntimeCount == 1)
        #expect(SourceSkillDamageReviewMetrics.mostCommonDamageText == "Physical x77")
        #expect(damageCounts["Physical"] == 77)
        #expect(damageCounts["Fire"] == 12)
        #expect(damageCounts["Chaos"] == 8)
        #expect(SourceSkillDamageReviewMetrics.damageBoundaryText.contains("异常状态"))
        #expect(SourceSkillDamageReviewMetrics.visualBoundaryText.contains("VFX/SFX"))
    }

    @Test func sourceSkillActivationDamageReviewPreservesCheckedCrossTab() {
        let rowsByActivation = Dictionary(
            uniqueKeysWithValues: SourceSkillActivationDamageReviewMetrics.rows.map {
                ($0.activation, $0)
            }
        )
        let baseAttackCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttack]?.damageCells.map {
                ($0.damageType, $0)
            } ?? []
        )
        let cooldownCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.cooldown]?.damageCells.map {
                ($0.damageType, $0)
            } ?? []
        )

        #expect(SourceSkillActivationDamageReviewMetrics.rows.count == 4)
        #expect(SourceSkillActivationDamageReviewMetrics.pairCount == 14)
        #expect(SourceSkillActivationDamageReviewMetrics.runtimePairCount == 13)
        #expect(SourceSkillActivationDamageReviewMetrics.runtimeMappedCount == 46)
        #expect(SourceSkillActivationDamageReviewMetrics.baseAttackRuntimeText == "10/58")
        #expect(SourceSkillActivationDamageReviewMetrics.largestPendingPairText == "BASEATTACK/Physical 37")
        #expect(baseAttackCells["Physical"]?.sourceCount == 42)
        #expect(baseAttackCells["Physical"]?.runtimeCount == 5)
        #expect(baseAttackCells["Fire"]?.sourceCount == 8)
        #expect(baseAttackCells["Chaos"]?.runtimeCount == 1)
        #expect(cooldownCells["Chaos"]?.sourceCount == 3)
        #expect(cooldownCells["Chaos"]?.runtimeCount == 0)
        #expect(SourceSkillActivationDamageReviewMetrics.activationBoundaryText.contains("源表触发字段"))
        #expect(SourceSkillActivationDamageReviewMetrics.crossTabBoundaryText.contains("不推导技能归属"))
    }

    @Test func sourceSkillActivationDeliveryReviewPreservesCheckedCrossTab() {
        let rowsByActivation = Dictionary(
            uniqueKeysWithValues: SourceSkillActivationDeliveryReviewMetrics.rows.map {
                ($0.activation, $0)
            }
        )
        let baseAttackCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttack]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let baseAttackCountCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.baseAttackCount]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let cooldownCells = Dictionary(
            uniqueKeysWithValues: rowsByActivation[.cooldown]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )

        #expect(SourceSkillActivationDeliveryReviewMetrics.rows.count == 4)
        #expect(SourceSkillActivationDeliveryReviewMetrics.pairCount == 16)
        #expect(SourceSkillActivationDeliveryReviewMetrics.runtimePairCount == 15)
        #expect(SourceSkillActivationDeliveryReviewMetrics.runtimeMappedCount == 46)
        #expect(SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryRuntimeText == "11/71")
        #expect(SourceSkillActivationDeliveryReviewMetrics.baseAttackEmptyRuntimeText == "4/52")
        #expect(SourceSkillActivationDeliveryReviewMetrics.baseAttackCountEmptyRuntimeText == "0/2")
        #expect(SourceSkillActivationDeliveryReviewMetrics.largestPendingPairText == "BASEATTACK/空 delivery 48")
        #expect(baseAttackCells[""]?.sourceCount == 52)
        #expect(baseAttackCells[""]?.runtimeCount == 4)
        #expect(baseAttackCells["Melee"]?.runtimeCount == 3)
        #expect(baseAttackCells["Projectile"]?.runtimeCount == 3)
        #expect(baseAttackCountCells[""]?.sourceCount == 2)
        #expect(baseAttackCountCells[""]?.runtimeCount == 0)
        #expect(cooldownCells[""]?.sourceCount == 17)
        #expect(cooldownCells[""]?.runtimeCount == 7)
        #expect(SourceSkillActivationDeliveryReviewMetrics.crossTabBoundaryText.contains("完整触发时序"))
        #expect(SourceSkillActivationDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("attack-count"))
    }

    @Test func sourceSkillDamageDeliveryReviewPreservesCheckedCrossTab() {
        let rowsByDamage = Dictionary(
            uniqueKeysWithValues: SourceSkillDamageDeliveryReviewMetrics.rows.map {
                ($0.damageType, $0)
            }
        )
        let physicalCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Physical"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )
        let chaosCells = Dictionary(
            uniqueKeysWithValues: rowsByDamage["Chaos"]?.deliveryCells.map {
                ($0.delivery, $0)
            } ?? []
        )

        #expect(SourceSkillDamageDeliveryReviewMetrics.rows.count == 5)
        #expect(SourceSkillDamageDeliveryReviewMetrics.pairCount == 20)
        #expect(SourceSkillDamageDeliveryReviewMetrics.runtimePairCount == 20)
        #expect(SourceSkillDamageDeliveryReviewMetrics.runtimeMappedCount == 46)
        #expect(SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryRuntimeText == "11/71")
        #expect(SourceSkillDamageDeliveryReviewMetrics.physicalEmptyRuntimeText == "7/53")
        #expect(SourceSkillDamageDeliveryReviewMetrics.largestPendingPairText == "Physical/空 delivery 46")
        #expect(rowsByDamage["Physical"]?.sourceCount == 77)
        #expect(rowsByDamage["Physical"]?.runtimeCount == 31)
        #expect(rowsByDamage["Chaos"]?.runtimeCount == 1)
        #expect(physicalCells[""]?.sourceCount == 53)
        #expect(physicalCells[""]?.runtimeCount == 7)
        #expect(physicalCells["Projectile"]?.sourceCount == 6)
        #expect(chaosCells[""]?.sourceCount == 8)
        #expect(chaosCells[""]?.runtimeCount == 1)
        #expect(SourceSkillDamageDeliveryReviewMetrics.crossTabBoundaryText.contains("原版特效"))
        #expect(SourceSkillDamageDeliveryReviewMetrics.emptyDeliveryBoundaryText.contains("不推导无弹道"))
    }

    @Test func sourceSkillRangeReviewPreservesCheckedDistribution() {
        let rangeCounts = Dictionary(
            uniqueKeysWithValues: SourceSkillRangeReviewMetrics.rows.map {
                ($0.range, $0.sourceCount)
            }
        )

        #expect(SourceSkillRangeReviewMetrics.rangeBucketCount == 24)
        #expect(SourceSkillRangeReviewMetrics.sourceCount == 106)
        #expect(SourceSkillRangeReviewMetrics.runtimeMappedCount == 46)
        #expect(SourceSkillRangeReviewMetrics.minMaxRangeText == "120-1650")
        #expect(SourceSkillRangeReviewMetrics.mostCommonRangeText == "150 x16")
        #expect(rangeCounts[150] == 16)
        #expect(rangeCounts[800] == 12)
        #expect(rangeCounts[1100] == 11)
        #expect(SourceSkillRangeReviewMetrics.rangeBoundaryText.contains("不推导"))
        #expect(SourceSkillRangeReviewMetrics.runtimeBoundaryText.contains("不代表原版射程"))
    }

    @Test func pendingSourceSkillValueReadinessPreservesRuntimeBoundary() {
        #expect(PendingSourceSkillReviewMetrics.pendingValuedCandidateCount == 12)
        #expect(PendingSourceSkillReviewMetrics.pendingValuedEmptyDeliveryCount == 12)
        #expect(PendingSourceSkillReviewMetrics.pendingValuedUnnamedCount == 12)
        #expect(PendingSourceSkillReviewMetrics.highestPendingValueText == "209041=2300/r270; 309051=2300/r600")
        #expect(PendingSourceSkillReviewMetrics.highestPendingValueDetailPathText == "209041=/zh/skills/active/id-209041/; 309051=/zh/skills/active/id-309051/")
        #expect(PendingSourceSkillReviewMetrics.highestPendingValueDetailEvidenceText == "2 页 / Skill ID / 无说明 / 空 delivery")
        #expect(PendingSourceSkillReviewMetrics.pendingValueDetailLocalePageCount == 24)
        #expect(PendingSourceSkillReviewMetrics.pendingValueDetailSnapshotText == "24 中英页 / v1.00.13 / Skill ID / 无说明 / delivery — / 命中类型 —")
        #expect(PendingSourceSkillReviewMetrics.highestPendingValueLocalePageCount == 4)
        #expect(PendingSourceSkillReviewMetrics.highestPendingValueSnapshotText == "4 中英页 / v1.00.13 / Skill ID / 无说明 / delivery —")
        #expect(PendingSourceSkillReviewMetrics.pendingValueReadinessText == "12 value / 12 未命名 / 12 空形态")
        #expect(PendingSourceSkillReviewMetrics.sourceValueReadinessBoundaryText.contains("才可接入 runtime"))
        #expect(PendingSourceSkillReviewMetrics.highestValueDetailBoundaryText.contains("无本地化说明"))
        #expect(PendingSourceSkillReviewMetrics.sourcePageSnapshotBoundaryText.contains("不是第二独立来源"))
    }

    @Test func sourceSkillCatalogKeepsKnownRows() {
        #expect(SourceSkillCatalog.skill(id: "10001") == SourceSkill(
            id: "10001",
            name: "Skill 10001",
            activation: .baseAttack,
            damageType: "Physical",
            delivery: "Melee",
            range: 140
        ))
        #expect(SourceSkillCatalog.skill(id: "60301") == SourceSkill(
            id: "60301",
            name: "Commander’s Cry",
            activation: .cooldown,
            damageType: "Physical",
            delivery: "AOE",
            range: 150
        ))
        #expect(SourceSkillCatalog.skill(id: "309021") == SourceSkill(
            id: "309021",
            name: "Skill 309021",
            activation: .cooldown,
            damageType: "Chaos",
            delivery: "",
            range: 700,
            sourceValue: 800
        ))
        #expect(SourceSkillCatalog.skill(id: "309021")?.runtimeDamageElement == .chaos)
        #expect(SourceSkillCatalog.skill(id: "309021")?.runtimeDelivery == SkillDelivery.none)
        #expect(SourceSkillCatalog.skill(id: "309041")?.sourceValue == 1700)
        #expect(SourceSkillCatalog.skill(id: "309051")?.sourceValue == 2300)
        #expect(SourceSkillCatalog.skill(id: "109021")?.sourceValue == 1500)
        #expect(SourceSkillCatalog.skill(id: "209031")?.sourceValue == 1350)
        #expect(SourceSkillCatalog.skill(id: "209041")?.sourceValue == 2300)
        #expect(SourceSkillCatalog.skill(id: "309031")?.sourceValue == 1500)
        #expect(SourceSkillCatalog.skill(id: "10001")?.sourceValue == nil)
    }

    @Test func runtimeModeledSkillsAreSourceBacked() {
        #expect(SourceSkillCatalog.runtimeNamedHeroSkillIDs.count == 36)
        #expect(SourceSkillCatalog.runtimeHeroBaseAttackSkillIDs.count == 6)
        #expect(SourceSkillCatalog.runtimeHeroSkillIDs.count == 42)
        #expect(SourceSkillCatalog.runtimeMonsterAttackSkillIDs.count == 4)
        #expect(SourceSkillCatalog.runtimeModeledSkillIDs.count == 46)
        #expect(SourceSkillCatalog.runtimeModeledSkillIDs.allSatisfy {
            SourceSkillCatalog.skill(id: $0) != nil
        })
        #expect(SourceSkillCatalog.runtimeModeledSkills.count == 46)
        #expect(SourceSkillCatalog.runtimeHeroBaseAttackSkillIDs.allSatisfy {
            SourceSkillCatalog.skill(id: $0)?.activation == .baseAttack
        })
        #expect(SourceSkillCatalog.runtimeMonsterAttackSkillIDs.allSatisfy {
            SourceSkillCatalog.skill(id: $0)?.activation == .baseAttack
        })
        #expect(SourceSkillCatalog.skill(id: "999999") == nil)
    }

    @Test func sourceBaseAttackRowsResolveToRuntimeMetadata() {
        let expected: [(HeroClass, String, SkillDamageElement, SkillDelivery)] = [
            (.knight, "10001", .physical, .melee),
            (.ranger, "20001", .physical, .projectile),
            (.sorcerer, "30001", .fire, .projectile),
            (.priest, "40001", .physical, .melee),
            (.hunter, "50001", .physical, .projectile),
            (.slayer, "60001", .physical, .melee)
        ]

        for (heroClass, sourceID, damageElement, delivery) in expected {
            #expect(HeroSkills.baseAttackSourceSkill(for: heroClass)?.id == sourceID)
            #expect(HeroSkills.baseAttackDamageElement(for: heroClass) == damageElement)
            #expect(HeroSkills.baseAttackDelivery(for: heroClass) == delivery)
        }
    }

    @Test func stageElementalPriestsUseSourceAttackMetadata() {
        let expected: [(String, String, SkillDamageElement)] = [
            ("燃烧的地狱祭司", "301015", .fire),
            ("冰冻的地狱祭司", "301025", .cold),
            ("电流的地狱祭司", "301035", .lightning),
            ("混沌的地狱祭司", "301045", .chaos)
        ]

        for (name, sourceSkillID, damageElement) in expected {
            #expect(SourceSkillCatalog.sourceSkillID(forMonsterNamed: name) == sourceSkillID)

            var matchedMonster: Monster?
            stageSearch: for stage in StageDefinition.all {
                for difficulty in Difficulty.allCases {
                    let clearTarget = stage.clearTarget(for: difficulty)
                    for encounterIndex in 0..<clearTarget {
                        let monster = stage.spawnMonster(difficulty: difficulty, encounterIndex: encounterIndex)
                        if monster.name == name {
                            matchedMonster = monster
                            break stageSearch
                        }
                    }
                }
            }

            #expect(matchedMonster?.sourceSkillID == sourceSkillID)
            #expect(matchedMonster?.sourceSkill?.activation == .baseAttack)
            #expect(matchedMonster?.sourceDamageElement == damageElement)
        }

        let regularMonster = StageDefinition.stage(act: .forest, number: 1)
            .spawnMonster(difficulty: .normal)
        #expect(regularMonster.name == "哥布林盗贼")
        #expect(regularMonster.sourceSkillID == nil)
        #expect(regularMonster.sourceDamageElement == .none)
    }
}

@Suite struct PassiveSkillCatalogTests {
    @Test func passiveSkillCatalogCoversCheckedSourceRows() {
        #expect(PassiveSkills.all.count == 108)
        #expect(Set(PassiveSkills.all.map(\.id)).count == PassiveSkills.all.count)
        #expect(HeroClass.allCases.allSatisfy { PassiveSkills.skills(for: $0).count == 18 })
        #expect(Set(PassiveSkills.all.map(\.valueType)) == Set(PassiveSkillValueType.allCases))
        #expect(Set(PassiveSkills.all.map(\.stat)).count == 30)
    }

    @Test func passiveSkillCatalogMapsCurrentSourceIcons() {
        let iconNames = PassiveSkills.all.compactMap { GameArt.passiveSkillIconName(for: $0) }
        let missingIconStats = Set(
            PassiveSkills.all
                .filter { GameArt.passiveSkillIconName(for: $0) == nil }
                .map(\.stat)
        )

        #expect(iconNames.count == 104)
        #expect(Set(iconNames).count == GameArt.passiveSkillIconNames.count)
        #expect(GameArt.passiveSkillIconNames.count == 27)
        #expect(iconNames.allSatisfy { $0.hasPrefix("source_passive_") })
        #expect(missingIconStats == ["IncreaseProjectileDamage", "SkillHealIncrease"])
        #expect(GameArt.passiveSkillIconName(forStat: "SkillDurationIncrease") == "source_passive_Duration")
        #expect(GameArt.passiveSkillIconName(forStat: "ElementalDodgeChance") == "source_passive_DodgeChance")
        #expect(GameArt.passiveSkillIconName(forStat: "IncreaseAreaOfEffectDamage") == "source_passive_AreaOfEffectDamage")
    }

    @Test func passiveSkillCatalogKeepsKnownSourceRows() {
        #expect(PassiveSkills.skill(id: "101001") == PassiveSkill(
            id: "101001",
            name: "Attack Damage Enhancement",
            stat: "AttackDamage",
            valueType: .flat,
            value: 1
        ))
        #expect(PassiveSkills.skill(id: "201011") == PassiveSkill(
            id: "201011",
            name: "Critical Chance Enhancement",
            stat: "CriticalChance",
            valueType: .additive,
            value: 200
        ))
        #expect(PassiveSkills.skill(id: "501021") == PassiveSkill(
            id: "501021",
            name: "Fire Damage Enhancement",
            stat: "FireDamagePercent",
            valueType: .flat,
            value: 150
        ))
        #expect(PassiveSkills.skill(id: "601072") == PassiveSkill(
            id: "601072",
            name: "Duration Enhancement",
            stat: "SkillDurationIncrease",
            valueType: .additive,
            value: 80
        ))
    }

    @Test func passiveSkillCatalogDerivesClassFromSourceIDPrefix() {
        #expect(PassiveSkills.skill(id: "501021")?.heroClass == .hunter)
        #expect(PassiveSkills.skill(id: "601072")?.heroClass == .slayer)
        #expect(PassiveSkills.skill(id: "999999") == nil)
        #expect(PassiveSkills.heroClass(for: "999999") == nil)
    }

    @Test func unlockedPassiveSkillsFeedCoreRuntimeStats() {
        let knight = Hero()
        knight.unlockedPassiveSkillIDs = [
            "101001",
            "101002",
            "101011",
            "101061",
            "101071",
            "201011"
        ]

        #expect(knight.maxHP == 145)
        #expect(knight.attack == 19)
        #expect(knight.defense == 55)
        #expect(knight.speed == 13)
        #expect(abs(knight.passiveRuntimeEffects.passiveDamageReduction - 0.20) < 0.0001)
        #expect(abs(knight.critRate - knight.baseStats.critRate) < 0.0001)

        func knightBaseAttackSummary(passiveIDs: Set<String> = [], seconds: Int = 120) -> (count: Int, totalDamage: Int) {
            let hero = Hero()
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "core-passive-base-attack-crit-suppression",
                name: "基础攻击测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))

            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkill("10601", for: .knight, slotIndex: 0)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "core-passive-base-attack-training",
                    name: "基础属性训练木桩",
                    hp: 100_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: .knight),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )

            for _ in 0..<(seconds * 10) {
                battle.update(deltaTime: 0.1)
            }

            let baseAttackLogs = battle.log.filter {
                $0.attacker == .hero && $0.kind == .damage && $0.skillName == nil
            }
            return (
                count: baseAttackLogs.count,
                totalDamage: baseAttackLogs.map(\.damage).reduce(0, +)
            )
        }

        let baselineBaseAttacks = knightBaseAttackSummary()
        let attackDamageBaseAttacks = knightBaseAttackSummary(passiveIDs: ["101001", "101072"])
        let attackSpeedBaseAttacks = knightBaseAttackSummary(passiveIDs: ["101061"])

        #expect(baselineBaseAttacks.count > 0)
        #expect(attackDamageBaseAttacks.totalDamage > baselineBaseAttacks.totalDamage)
        #expect(attackSpeedBaseAttacks.count > baselineBaseAttacks.count)

        func incomingMonsterDamageSummary(
            heroClass: HeroClass,
            passiveIDs: Set<String> = [],
            sourceSkillID: String? = nil,
            seconds: Int = 180
        ) -> (count: Int, totalDamage: Int) {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "defensive-passive-runtime-vitality",
                name: "防御被动测试生命护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusHP: 1_000_000),
                description: "测试用"
            ))
            _ = hero.heal(hero.maxHP)

            var loadouts = ActiveSkillLoadouts()
            switch heroClass {
            case .knight:
                loadouts.setSkill("10601", for: .knight, slotIndex: 0)
            case .priest:
                loadouts.setSkill("40601", for: .priest, slotIndex: 0)
            case .ranger, .sorcerer, .hunter, .slayer:
                break
            }

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "defensive-passive-runtime-attacker",
                    name: "防御被动训练攻击者",
                    hp: 100_000_000,
                    atk: 160,
                    def: 0,
                    spd: 20,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none",
                    sourceSkillID: sourceSkillID
                ),
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts,
                incomingDodgeRollProvider: { 1.0 },
                incomingBlockRollProvider: { 1.0 }
            )

            for _ in 0..<(seconds * 10) {
                battle.update(deltaTime: 0.1)
            }

            let monsterDamageLogs = battle.log.filter {
                $0.attacker == .monster && $0.kind == .damage && $0.damage > 0
            }
            return (
                count: monsterDamageLogs.count,
                totalDamage: monsterDamageLogs.map(\.damage).reduce(0, +)
            )
        }

        let baselineKnightIncoming = incomingMonsterDamageSummary(heroClass: .knight)
        let reducedKnightIncoming = incomingMonsterDamageSummary(heroClass: .knight, passiveIDs: ["101071"])
        let baselineKnightFireIncoming = incomingMonsterDamageSummary(heroClass: .knight, sourceSkillID: "301015")
        let resistedKnightFireIncoming = incomingMonsterDamageSummary(heroClass: .knight, passiveIDs: ["101062"], sourceSkillID: "301015")
        let baselinePriestIncoming = incomingMonsterDamageSummary(heroClass: .priest)
        let absorbedPriestIncoming = incomingMonsterDamageSummary(heroClass: .priest, passiveIDs: ["401012", "401032"])

        #expect(baselineKnightIncoming.count > 0)
        #expect(reducedKnightIncoming.count == baselineKnightIncoming.count)
        #expect(reducedKnightIncoming.totalDamage < baselineKnightIncoming.totalDamage)
        #expect(baselineKnightFireIncoming.count > 0)
        #expect(resistedKnightFireIncoming.count == baselineKnightFireIncoming.count)
        #expect(resistedKnightFireIncoming.totalDamage < baselineKnightFireIncoming.totalDamage)
        #expect(baselinePriestIncoming.count > 0)
        #expect(absorbedPriestIncoming.count == baselinePriestIncoming.count)
        #expect(absorbedPriestIncoming.totalDamage < baselinePriestIncoming.totalDamage)

        func firstMonsterIncomingLog(monsterCritRate: Double) -> BattleLogEntry? {
            let hero = Hero()
            hero.changeClass(to: .ranger)
            _ = hero.equipment.equip(Item(
                id: "monster-crit-runtime-vitality",
                name: "怪物暴击测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusHP: 1_000_000),
                description: "测试用"
            ))
            _ = hero.heal(hero.maxHP)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "monster-crit-runtime-attacker",
                    name: "怪物暴击训练攻击者",
                    hp: 100_000_000,
                    atk: 160,
                    def: 0,
                    spd: 20,
                    critRate: monsterCritRate,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: .ranger),
                incomingDodgeRollProvider: { 1.0 },
                incomingBlockRollProvider: { 1.0 }
            )
            battle.update(deltaTime: 1)
            return battle.log.first {
                $0.attacker == .monster && $0.kind == .damage && $0.damage > 0
            }
        }

        let guaranteedMonsterCrit = firstMonsterIncomingLog(monsterCritRate: 1.0)
        let zeroMonsterCrit = firstMonsterIncomingLog(monsterCritRate: 0)
        #expect(guaranteedMonsterCrit?.isCrit == true)
        #expect(zeroMonsterCrit?.isCrit == false)
        #expect((guaranteedMonsterCrit?.damage ?? 0) > (zeroMonsterCrit?.damage ?? Int.max))

        let blockEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101022", "101052"],
            heroClass: .knight
        )
        #expect(abs(blockEffects.passiveBlockChance - 0.006) < 0.0001)

        let elementalResistanceEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101062"],
            heroClass: .knight
        )
        #expect(abs(elementalResistanceEffects.passiveAllElementalResistance - 0.30) < 0.0001)

        let skillRangeEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101081"],
            heroClass: .knight
        )
        #expect(abs(skillRangeEffects.passiveSkillRangeExpansion - 0.30) < 0.0001)

        let areaEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101082"],
            heroClass: .knight
        )
        #expect(abs(areaEffects.passiveAreaOfEffect - 0.50) < 0.0001)

        let ranger = Hero()
        ranger.changeClass(to: .ranger)
        ranger.unlockedPassiveSkillIDs = ["201011", "201012"]

        #expect(abs(ranger.critRate - 0.06) < 0.0001)
        #expect(abs(ranger.critDamage - 2.8) < 0.0001)
    }

    @Test func unlockedSustainPassivesAggregateForBattleHooks() {
        let sustainEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["101012", "101021", "101051"],
            heroClass: .knight
        )

        #expect(sustainEffects.passiveHpRegenPerSec == 100)
        #expect(sustainEffects.passiveAddHpPerKill == 8)
        #expect(sustainEffects.passiveAddHpPerHit == 0)
    }

    @Test func unlockedDamageHealingCooldownAndDurationPassivesAggregateForBattleHooks() {
        let dodgeEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["201021", "201031", "201041", "201081"],
            heroClass: .ranger
        )
        #expect(abs(dodgeEffects.passiveDodgeChance - 0.006) < 0.0001)
        #expect(abs(dodgeEffects.passiveElementalDodgeChance - 0.003) < 0.0001)
        #expect(abs(dodgeEffects.passiveMaxDodgeChance - 0.001) < 0.0001)

        let sorcererEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["301002", "301021", "301022", "301031", "301041"],
            heroClass: .sorcerer
        )

        #expect(abs(sorcererEffects.passiveCooldownReduction - 0.30) < 0.0001)
        #expect(abs(sorcererEffects.passiveFireDamagePercent - 1.0) < 0.0001)
        #expect(abs(sorcererEffects.passiveColdDamagePercent - 1.0) < 0.0001)
        #expect(abs(sorcererEffects.passiveLightningDamagePercent - 1.0) < 0.0001)

        let castSpeedEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["301051", "301082"],
            heroClass: .sorcerer
        )
        #expect(abs(castSpeedEffects.passiveCastSpeed - 1.40) < 0.0001)

        let rangerEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["201022", "201052", "201061"],
            heroClass: .ranger
        )
        #expect(abs(rangerEffects.passiveIncreaseProjectileDamage - 1.5) < 0.0001)
        #expect(abs(rangerEffects.passiveHpLeech - 0.05) < 0.0001)
        #expect(abs(rangerEffects.passiveIncreaseAreaOfEffectDamage - 1.5) < 0.0001)

        let priestEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["401012", "401022", "401032", "401061"],
            heroClass: .priest
        )
        #expect(priestEffects.passiveDamageAbsorption == 10)
        #expect(abs(priestEffects.passiveSkillHealIncrease - 0.7) < 0.0001)
        #expect(abs(priestEffects.passiveCooldownReduction - 0.2) < 0.0001)

        let priestCastEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["401041", "401072"],
            heroClass: .priest
        )
        #expect(abs(priestCastEffects.passiveCastSpeed - 1.40) < 0.0001)

        let slayerEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["601051", "601072"],
            heroClass: .slayer
        )
        #expect(abs(slayerEffects.passiveIncreaseAreaOfEffectDamage - 1.5) < 0.0001)
        #expect(abs(slayerEffects.passiveSkillDurationIncrease - 0.8) < 0.0001)

        let movementEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["201042", "201082"],
            heroClass: .ranger
        )
        #expect(movementEffects.passiveMovementSpeed == 40)

        let movementHero = Hero()
        movementHero.changeClass(to: .ranger)
        movementHero.unlockedPassiveSkillIDs = ["201042", "201082"]
        #expect(movementHero.speed == 50)

        let slayerMovementEffects = PassiveSkillRuntimeEffects.make(
            unlockedSkillIDs: ["601062"],
            heroClass: .slayer
        )
        #expect(slayerMovementEffects.passiveMovementSpeed == 0)
        #expect(abs(slayerMovementEffects.passiveMovementSpeedMultiplier - 1.20) < 0.0001)

        let slayerMovementHero = Hero()
        slayerMovementHero.changeClass(to: .slayer)
        slayerMovementHero.unlockedPassiveSkillIDs = ["601062"]
        #expect(slayerMovementHero.speed == 9)
    }

    @Test func unlockedHpLeechPassiveHealsFromMainHeroDamage() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        hero.unlockedPassiveSkillIDs = ["201052"]
        _ = hero.equipment.equip(Item(
            id: "leech-bow",
            name: "吸血测试弓",
            rarity: .common,
            slot: .weapon,
            stats: ItemStats(bonusATK: 1_000),
            description: "",
            equipmentType: .bow
        ))
        hero.takeDamage(80)
        let woundedHP = hero.currentHP

        let battle = Battle(
            hero: hero,
            monster: Monster(
                id: "leech-dummy",
                name: "吸血测试目标",
                hp: 10_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .ranger),
            activeSkillSlotCount: 1
        )

        battle.update(deltaTime: 1)

        #expect(hero.currentHP > woundedHP)
        #expect(battle.heroHP == hero.currentHP)
        #expect(battle.log.contains {
            $0.attacker == .hero &&
                $0.skillName == "生命汲取" &&
                $0.kind == .heal &&
                $0.damage > 0
        })
    }

    @Test func unlockedSustainPassivesRecordVisibleLiveBattleHealing() {
        let regenHero = Hero()
        regenHero.unlockedPassiveSkillIDs = ["101012"]
        regenHero.takeDamage(80)
        var knightLoadouts = ActiveSkillLoadouts()
        knightLoadouts.setSkill("10601", for: .knight, slotIndex: 0)
        let regenBattle = Battle(
            hero: regenHero,
            monster: Monster(
                id: "passive-regen-dummy",
                name: "生命恢复测试目标",
                hp: 10_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: knightLoadouts
        )
        regenBattle.update(deltaTime: 0.2)

        #expect(regenBattle.heroHP == regenHero.currentHP)
        #expect(regenBattle.log.contains {
            $0.attacker == .hero &&
                $0.skillName == "生命恢复" &&
                $0.kind == .heal &&
                $0.damage > 0
        })

        let hitHealHero = Hero()
        hitHealHero.changeClass(to: .hunter)
        hitHealHero.unlockedPassiveSkillIDs = ["501072"]
        hitHealHero.takeDamage(20)
        var hunterLoadouts = ActiveSkillLoadouts()
        hunterLoadouts.setSkill("50301", for: .hunter, slotIndex: 0)
        let hitHealBattle = Battle(
            hero: hitHealHero,
            monster: Monster(
                id: "passive-hit-heal-dummy",
                name: "击中回复测试目标",
                hp: 10_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .hunter),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: hunterLoadouts
        )
        hitHealBattle.update(deltaTime: 1)

        #expect(hitHealBattle.heroHP == hitHealHero.currentHP)
        #expect(hitHealBattle.log.contains {
            $0.attacker == .hero &&
                $0.skillName == "击中回复" &&
                $0.kind == .heal &&
                $0.damage > 0
        })

        let killHealHero = Hero()
        killHealHero.unlockedPassiveSkillIDs = ["101021", "101051"]
        killHealHero.takeDamage(20)
        let killHealBattle = Battle(
            hero: killHealHero,
            monster: Monster(
                id: "passive-kill-heal-dummy",
                name: "击杀回复测试目标",
                hp: 1,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: knightLoadouts
        )
        killHealBattle.update(deltaTime: 1)

        #expect(killHealBattle.heroHP == killHealHero.currentHP)
        #expect(killHealBattle.log.contains {
            $0.attacker == .hero &&
                $0.skillName == "击杀回复" &&
                $0.kind == .heal &&
                $0.damage > 0
        })
    }

    @Test func unlockedDamageAbsorptionPassiveReducesIncomingDamageAfterPercentMitigation() {
        let damage = Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 1.0,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10
        )

        #expect(damage == 140)
    }

    @Test func unlockedAllElementalResistancePassiveReducesOnlyElementalIncomingDamage() {
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 1.0,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .fire
        ) == 110)
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 1.0,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .cold
        ) == 110)
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 1.0,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .lightning
        ) == 110)
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 1.0,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .physical
        ) == 140)
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 1.0,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .chaos
        ) == 140)
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 0.9,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .fire
        ) == 98)
        #expect(Battle.modifiedIncomingDamage(
            200,
            continuousIncomingDamageMultiplier: 0.9,
            passiveDamageReduction: 0.25,
            passiveDamageAbsorption: 10,
            passiveAllElementalResistance: 0.20,
            damageElement: .physical
        ) == 140)
    }

    @Test func monsterSourceElementFeedsIncomingResistanceAndLogMetadata() {
        func monsterHit(sourceSkillID: String) -> BattleLogEntry? {
            let hero = Hero()
            hero.unlockedPassiveSkillIDs = ["101062"]
            let monster = Monster(
                id: "source-\(sourceSkillID)",
                name: sourceSkillID == "301015" ? "燃烧的地狱祭司" : "混沌的地狱祭司",
                hp: 100_000,
                atk: 400,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none",
                sourceSkillID: sourceSkillID
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: .knight),
                activeSkillSlotCount: 1
            )

            battle.update(deltaTime: 0.01)
            return battle.log.last { $0.attacker == .monster }
        }

        let fireHit = monsterHit(sourceSkillID: "301015")
        let chaosHit = monsterHit(sourceSkillID: "301045")

        #expect(fireHit?.damageElement == .fire)
        #expect(chaosHit?.damageElement == .chaos)
        #expect(fireHit?.attackerName == "燃烧的地狱祭司")
        #expect(fireHit?.attackerDisplayName == "燃烧的地狱祭司")
        #expect(chaosHit?.attackerName == "混沌的地狱祭司")
        #expect((fireHit?.damage ?? 0) > 0)
        #expect((chaosHit?.damage ?? 0) > 0)
        #expect((fireHit?.damage ?? Int.max) < (chaosHit?.damage ?? 0))
    }

    @Test func unlockedDodgeChancePassiveCanAvoidIncomingAttacksBeforeDamageCalculation() {
        #expect(Battle.incomingAttackWasDodged(roll: 0.005, passiveDodgeChance: 0.006))
        #expect(!Battle.incomingAttackWasDodged(roll: 0.006, passiveDodgeChance: 0.006))
        #expect(Battle.incomingAttackWasDodged(roll: 0.79, passiveDodgeChance: 2.0))
        #expect(!Battle.incomingAttackWasDodged(roll: 0.81, passiveDodgeChance: 2.0))
        #expect(Battle.incomingAttackWasDodged(roll: 0.8005, passiveDodgeChance: 2.0, passiveMaxDodgeChance: 0.001))
        #expect(!Battle.incomingAttackWasDodged(roll: 0.8015, passiveDodgeChance: 2.0, passiveMaxDodgeChance: 0.001))
        #expect(Battle.incomingAttackWasDodged(
            roll: 0.008,
            passiveDodgeChance: 0.006,
            passiveElementalDodgeChance: 0.003,
            damageElement: .fire
        ))
        #expect(Battle.incomingAttackWasDodged(
            roll: 0.008,
            passiveDodgeChance: 0.006,
            passiveElementalDodgeChance: 0.003,
            damageElement: .cold
        ))
        #expect(Battle.incomingAttackWasDodged(
            roll: 0.008,
            passiveDodgeChance: 0.006,
            passiveElementalDodgeChance: 0.003,
            damageElement: .lightning
        ))
        #expect(!Battle.incomingAttackWasDodged(
            roll: 0.008,
            passiveDodgeChance: 0.006,
            passiveElementalDodgeChance: 0.003,
            damageElement: .physical
        ))
        #expect(!Battle.incomingAttackWasDodged(
            roll: 0.008,
            passiveDodgeChance: 0.006,
            passiveElementalDodgeChance: 0.003,
            damageElement: .chaos
        ))
    }

    @Test func unlockedCastSpeedPassiveShortensCooldownSkillInterval() {
        #expect(abs(Battle.modifiedSkillCooldown(
            baseCooldown: 10,
            passiveCooldownReduction: 0.20,
            passiveCastSpeed: 0
        ) - 8.0) < 0.0001)
        #expect(abs(Battle.modifiedSkillCooldown(
            baseCooldown: 10,
            passiveCooldownReduction: 0.20,
            passiveCastSpeed: 1.0
        ) - 4.0) < 0.0001)
        #expect(abs(Battle.modifiedSkillCooldown(
            baseCooldown: 10,
            passiveCooldownReduction: -0.20,
            passiveCastSpeed: -1.0
        ) - 10.0) < 0.0001)
        #expect(Battle.modifiedSkillCooldown(
            baseCooldown: 2,
            passiveCooldownReduction: 0.80,
            passiveCastSpeed: 2.0
        ) == 1)
    }

    @Test func cooldownReductionAndCastSpeedPassivesIncreaseFireballCastCount() {
        func fireballCastCount(passiveIDs: Set<String> = []) -> Int {
            let hero = Hero()
            hero.changeClass(to: .sorcerer)
            hero.unlockedPassiveSkillIDs = passiveIDs

            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["30101"], for: .sorcerer)

            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "cooldown-cast-speed-fireball-training",
                    name: "冷却施法训练木桩",
                    hp: 100_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                ),
                party: HeroParty(primaryClass: .sorcerer),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<12 {
                battle.update(deltaTime: 1)
            }
            return battle.log.filter { $0.skillName == "火球术" && $0.kind == .damage }.count
        }

        let baselineCastCount = fireballCastCount()
        let boostedCastCount = fireballCastCount(passiveIDs: ["301002", "301041", "301051"])

        #expect(baselineCastCount > 0)
        #expect(boostedCastCount > baselineCastCount)
    }

    @Test func unlockedBlockChancePassiveCanBlockIncomingAttacksBeforeDamageCalculation() {
        #expect(Battle.incomingAttackWasBlocked(roll: 0.005, passiveBlockChance: 0.006))
        #expect(!Battle.incomingAttackWasBlocked(roll: 0.006, passiveBlockChance: 0.006))
        #expect(Battle.incomingAttackWasBlocked(roll: 0.79, passiveBlockChance: 2.0))
        #expect(!Battle.incomingAttackWasBlocked(roll: 0.81, passiveBlockChance: 2.0))
    }

    @Test func unlockedDodgeAndBlockPassivesRecordVisibleLiveBattleAvoidanceLogs() {
        func avoidedMonsterAttack(
            heroClass: HeroClass,
            passiveIDs: Set<String>,
            dodgeRoll: Double,
            blockRoll: Double,
            sourceSkillID: String? = nil
        ) -> (heroHP: Int, entry: BattleLogEntry?) {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            hero.unlockedPassiveSkillIDs = passiveIDs
            let battle = Battle(
                hero: hero,
                monster: Monster(
                    id: "avoidance-runtime-attacker",
                    name: "规避测试攻击者",
                    hp: 100_000,
                    atk: 1_000,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none",
                    sourceSkillID: sourceSkillID
                ),
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                incomingDodgeRollProvider: { dodgeRoll },
                incomingBlockRollProvider: { blockRoll }
            )
            battle.update(deltaTime: 0.01)
            return (
                heroHP: battle.heroHP,
                entry: battle.log.last { $0.attacker == .monster }
            )
        }

        let dodgedAttack = avoidedMonsterAttack(
            heroClass: .ranger,
            passiveIDs: ["201021", "201031", "201041"],
            dodgeRoll: 0.008,
            blockRoll: 0.99,
            sourceSkillID: "301015"
        )
        let blockedAttack = avoidedMonsterAttack(
            heroClass: .knight,
            passiveIDs: ["101022", "101052"],
            dodgeRoll: 0.99,
            blockRoll: 0.005
        )

        #expect(dodgedAttack.heroHP == HeroClass.ranger.baseStats.hp)
        #expect(dodgedAttack.entry?.kind == .dodge)
        #expect(dodgedAttack.entry?.damage == 0)
        #expect(dodgedAttack.entry?.damageElement == .fire)
        #expect(dodgedAttack.entry?.attackerName == "规避测试攻击者")
        #expect(blockedAttack.heroHP == HeroClass.knight.baseStats.hp)
        #expect(blockedAttack.entry?.kind == .block)
        #expect(blockedAttack.entry?.damage == 0)
    }
}

@Suite struct BattlePartyIdentityTests {
    @Test func battleInitializesPartyPrimaryFromCurrentHeroClass() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let staleParty = HeroParty(primaryClass: .knight, unlockedSlotCount: 3)
        let monster = Monster(
            id: "identity-check",
            name: "身份校验",
            hp: 100,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )

        let battle = Battle(hero: hero, monster: monster, party: staleParty)

        #expect(battle.primaryHeroClass == .hunter)
        #expect(battle.party.member(at: 0)?.heroClass == .hunter)
        #expect(battle.supportStates.allSatisfy { !$0.member.isPrimary })
        #expect(!battle.supportStates.contains { $0.member.heroClass == .hunter })
    }
}

@Suite struct PlayerBattleStatusBadgeTests {
    @Test func activeBuffNamesResolveToPlayerStatusBadges() {
        let badges = PlayerBattleStatusBadge.visible(
            activeBuffNames: [
                "神盾领域",
                "快速装填",
                "充能陷阱",
                "弩炮塔",
                "电击弩箭电流"
            ],
            shieldRemaining: 480,
            trapCharges: 1
        )

        #expect(badges == [.aegisField, .quickLoader, .chargedTrap, .crossbowTurret, .shockCurrent])
        #expect(PlayerBattleStatusBadge.aegisField.displayLabel(shieldRemaining: 480, trapCharges: 0) == "神盾 480")
        #expect(PlayerBattleStatusBadge.chargedTrap.displayLabel(shieldRemaining: 0, trapCharges: 1) == "陷阱 x1")
    }

    @Test func continuousPriestBlessingsResolveToPlayerStatusBadges() {
        let badges = PlayerBattleStatusBadge.visible(
            activeBuffNames: ["神盾领域"],
            continuousSkillNames: ["力量祝福", "守护祝福"],
            shieldRemaining: 480,
            trapCharges: 0
        )

        #expect(badges == [.mightBlessing, .wardingBlessing, .aegisField])
        #expect(PlayerBattleStatusBadge.mightBlessing.displayLabel(shieldRemaining: 0, trapCharges: 0) == "力量")
        #expect(PlayerBattleStatusBadge.wardingBlessing.displayLabel(shieldRemaining: 0, trapCharges: 0) == "守护")
    }

    @Test func depletedShieldAndSpentTrapAreHidden() {
        #expect(PlayerBattleStatusBadge.visible(
            activeBuffNames: ["神盾领域"],
            shieldRemaining: 0,
            trapCharges: 0
        ).isEmpty)
        #expect(PlayerBattleStatusBadge.visible(
            activeBuffNames: ["充能陷阱"],
            shieldRemaining: 0,
            trapCharges: 0
        ).isEmpty)
    }
}

@Suite struct PlayerBattleDeployableTests {
    @Test func activeSummonAndTrapBuffsResolveToSceneDeployables() {
        let deployables = PlayerBattleDeployable.visible(
            activeBuffNames: ["烈焰九头蛇", "充能陷阱", "弩炮塔"],
            trapCharges: 1
        )

        #expect(deployables == [.flameHydra, .chargedTrap, .crossbowTurret])
    }

    @Test func spentTrapIsNotRenderedAsDeployable() {
        #expect(PlayerBattleDeployable.visible(
            activeBuffNames: ["充能陷阱"],
            trapCharges: 0
        ).isEmpty)
    }
}

@Suite struct BattleFloatingDamageTextTests {
    @Test func criticalDamageTextUsesChineseBattleFeedback() {
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .monster, damage: 123, isCrit: true, attackerName: "骷髅弓手")
        ) == "暴击 123")
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .hero, damage: 456, isCrit: true, skillName: "爆炸弩箭")
        ) == "爆炸弩箭 暴击 456")
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .monster, damage: 123, isCrit: false)
        ) == "123")
    }

    @Test func utilityAndAvoidanceTextStaysExplicitInBattleLane() {
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .hero, damage: 25, isCrit: false, skillName: nil, kind: .heal)
        ) == "治疗 +25")
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神盾领域", kind: .buff)
        ) == "神盾领域")
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .dodge)
        ) == "闪避!")
        #expect(BattleFloatingDamageText.displayText(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .block)
        ) == "格挡!")
    }

    @Test func criticalHitsUseStrongerFloatingTextStyle() {
        let ordinaryStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 80, isCrit: false, damageElement: .physical)
        )
        let criticalStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 160, isCrit: true, damageElement: .physical)
        )

        #expect(ordinaryStyle.tone == .damage)
        #expect(criticalStyle.tone == .criticalDamage)
        #expect(criticalStyle.fontSize > ordinaryStyle.fontSize)
        #expect(criticalStyle.borderOpacity > ordinaryStyle.borderOpacity)
        #expect(criticalStyle.shadowRadius > ordinaryStyle.shadowRadius)
        #expect(criticalStyle.verticalOffset < ordinaryStyle.verticalOffset)
    }

    @Test func utilityAndAvoidanceRowsUseReadableFloatingTextStyle() {
        let ordinaryStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 80, isCrit: false, damageElement: .physical)
        )
        let dodgeStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .dodge)
        )
        let blockStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .block)
        )
        let healStyle = BattleFloatingDamageStyle.presentation(
            for: BattleLogEntry(attacker: .hero, damage: 25, isCrit: false, kind: .heal)
        )

        #expect(dodgeStyle.tone == .dodge)
        #expect(blockStyle.tone == .block)
        #expect(healStyle.tone == .heal)
        #expect(dodgeStyle.fontSize > ordinaryStyle.fontSize)
        #expect(blockStyle.fontSize > ordinaryStyle.fontSize)
        #expect(dodgeStyle.borderOpacity >= healStyle.borderOpacity)
        #expect(blockStyle.borderOpacity >= healStyle.borderOpacity)
    }
}

@Suite struct BattleLogActionTextTests {
    @Test func ordinaryBattleLogRowsUseDeterministicChineseActions() {
        #expect(BattleLogActionText.displayText(
            for: BattleLogEntry(attacker: .hero, damage: 88, isCrit: false)
        ) == "造成 88 伤害")
        #expect(BattleLogActionText.displayText(
            for: BattleLogEntry(attacker: .hero, damage: 25, isCrit: false, skillName: "治愈", kind: .heal)
        ) == "恢复 25 生命")
        #expect(BattleLogActionText.displayText(
            for: BattleLogEntry(attacker: .support(.priest), damage: 0, isCrit: false, skillName: "守护祝福", kind: .buff)
        ) == "触发增益")
    }

    @Test func incomingAvoidanceRowsReadFromThePlayerPerspective() {
        #expect(BattleLogActionText.displayText(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .dodge)
        ) == "攻击被闪避")
        #expect(BattleLogActionText.displayText(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, kind: .block)
        ) == "攻击被格挡")
        #expect(BattleLogActionText.displayText(
            for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, kind: .dodge)
        ) == "闪避了攻击")
        #expect(BattleLogActionText.criticalText(
            for: BattleLogEntry(attacker: .monster, damage: 30, isCrit: true)
        ) == "暴击!")
        #expect(BattleLogActionText.criticalText(
            for: BattleLogEntry(attacker: .monster, damage: 30, isCrit: false)
        ) == nil)
    }
}

@Suite struct BattleImpactCueTests {
    @Test func damagingSkillMetadataResolvesToImpactCues() {
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿透突刺")
        ) == .physicalSlash)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击")
        ) == .physicalSlash)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击冲击波")
        ) == .shockwaveImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "大地强击")
        ) == .earthquakeImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "火球术")
        ) == .fireBurst)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "爆炸弩箭")
        ) == .explosiveBoltImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "陨石打击")
        ) == .meteorImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(
                attacker: .hero,
                damage: 100,
                isCrit: false,
                damageElement: .cold,
                delivery: .projectile
            )
        ) == .coldBurst)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "寒霜弩箭")
        ) == .frostBoltImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "闪电术")
        ) == .lightningSpark)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭")
        ) == .shockBoltImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭电流")
        ) == .shockCurrentImpact)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(
                attacker: .hero,
                damage: 100,
                isCrit: false,
                damageElement: .chaos,
                delivery: .range
            )
        ) == .chaosBurst)
    }

    @Test func deliveryMetadataCanOverrideElementForSpecialCues() {
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(
                attacker: .hero,
                damage: 100,
                isCrit: false,
                skillName: "充能陷阱",
                damageElement: .physical,
                delivery: .trap
            )
        ) == .trapBurst)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "烈焰九头蛇")
        ) == .summonProjectile)
    }

    @Test func NonHeroDamageAndNonDamageEntriesDoNotRenderImpactCues() {
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
        ) == nil)
        #expect(BattleImpactCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "治愈", kind: .heal)
        ) == nil)
    }
}

@Suite struct BattleIncomingCueTests {
    @Test func monsterDamageResolvesToIncomingCues() {
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
        ) == .physical)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false, damageElement: .fire)
        ) == .fire)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false, damageElement: .cold)
        ) == .cold)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false, damageElement: .lightning)
        ) == .lightning)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false, damageElement: .chaos)
        ) == .chaos)
    }

    @Test func HeroZeroDamageAndNonDamageEntriesDoNotRenderIncomingCues() {
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "火球术")
        ) == nil)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .support(.ranger), damage: 100, isCrit: false)
        ) == nil)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 0, isCrit: false, damageElement: .fire)
        ) == nil)
        #expect(BattleIncomingCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false, kind: .heal)
        ) == nil)
    }
}

@Suite struct BattleTrajectoryCueTests {
    @Test func rangedDeliveryMetadataResolvesToTrajectoryCues() {
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(
                attacker: .hero,
                damage: 100,
                isCrit: false,
                damageElement: .physical,
                delivery: .projectile
            )
        ) == .projectile)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "快速射击")
        ) == .rapidVolley)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "散弹射击")
        ) == .trackingVolley)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "箭雨")
        ) == .arrowRain)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿透之箭")
        ) == .piercingArrow)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿刺射击")
        ) == .lodgedArrow)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "爆炸弩箭")
        ) == .explosiveBolt)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "寒霜弩箭")
        ) == .frostBolt)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭")
        ) == .shockBolt)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "电击弩箭电流")
        ) == .shockCurrentArc)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "暴风雪")
        ) == .rangeField)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "大地强击")
        ) == .groundRupture)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击冲击波")
        ) == .shockwaveRing)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "陨石打击")
        ) == .meteorFall)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "烈焰九头蛇")
        ) == .summonProjectile)
    }

    @Test func trapDeliveryResolvesToTrapArcTrajectory() {
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(
                attacker: .hero,
                damage: 100,
                isCrit: false,
                skillName: "充能陷阱",
                damageElement: .physical,
                delivery: .trap
            )
        ) == .trapArc)
    }

    @Test func movementMeleeSkillsResolveToDedicatedTrajectoryCues() {
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "盾牌冲锋")
        ) == .chargeDash)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "猛击跳跃")
        ) == .leapArc)
    }

    @Test func ordinaryMeleeDamageRendersShortArcWithoutMovementTrajectory() {
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "穿透突刺")
        ) == .meleeArc)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "粉碎强击")
        ) == .meleeArc)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "盾牌冲锋")
        ) == .chargeDash)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "猛击跳跃")
        ) == .leapArc)
    }

    @Test func monsterAndHealingEntriesDoNotRenderTrajectoryCues() {
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
        ) == nil)
        #expect(BattleTrajectoryCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "治愈", kind: .heal)
        ) == nil)
    }
}

@Suite struct BattleUtilityCueTests {
    @Test func healingAndBuffEntriesResolveToUtilityCues() {
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "治愈", kind: .heal)
        ) == .healPulse)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 300, isCrit: false, skillName: "圣域", kind: .heal)
        ) == .sanctuaryPulse)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 300, isCrit: false, skillName: "复活", kind: .heal)
        ) == .resurrectionRise)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 500, isCrit: false, skillName: "不屈意志", kind: .heal)
        ) == .resurrectionRise)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神盾领域", kind: .buff)
        ) == .shieldField)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "神圣之刃", kind: .buff)
        ) == .sacredBladeGlow)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 0, isCrit: false, skillName: "将军怒吼", kind: .buff)
        ) == .generalsCryRoar)
    }

    @Test func DamageAndMonsterEntriesDoNotRenderUtilityCues() {
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .hero, damage: 100, isCrit: false, skillName: "火球术")
        ) == nil)
        #expect(BattleUtilityCue.visible(
            for: BattleLogEntry(attacker: .monster, damage: 100, isCrit: false)
        ) == nil)
    }
}

@Suite struct PartyBattleTests {
    @Test func namedSkillsCarrySourceLevelValues() {
        let allNamedSkills = HeroClass.allCases.flatMap { HeroSkills.named(for: $0) }
        let piercingThrust = allNamedSkills.first { $0.id == "10101" }
        let shieldCharge = allNamedSkills.first { $0.id == "10201" }
        let retributionStrike = allNamedSkills.first { $0.id == "10301" }
        let aegisField = allNamedSkills.first { $0.id == "10401" }
        let unyieldingWill = allNamedSkills.first { $0.id == "10601" }
        let rapidFire = allNamedSkills.first { $0.id == "20101" }
        let scatterShot = allNamedSkills.first { $0.id == "20201" }
        let arrowRain = allNamedSkills.first { $0.id == "20301" }
        let swiftSurge = allNamedSkills.first { $0.id == "20401" }
        let piercingArrow = allNamedSkills.first { $0.id == "20501" }
        let skewerShot = allNamedSkills.first { $0.id == "20601" }
        let fireball = allNamedSkills.first { $0.id == "30101" }
        let iceOrb = allNamedSkills.first { $0.id == "30201" }
        let lightning = allNamedSkills.first { $0.id == "30301" }
        let flameHydra = allNamedSkills.first { $0.id == "30401" }
        let snowstorm = allNamedSkills.first { $0.id == "30501" }
        let meteorStrike = allNamedSkills.first { $0.id == "30601" }
        let explosiveBolt = allNamedSkills.first { $0.id == "50101" }
        let frostBolt = allNamedSkills.first { $0.id == "50201" }
        let chargedTrap = allNamedSkills.first { $0.id == "50401" }
        let crossbowTurret = allNamedSkills.first { $0.id == "50501" }
        let shockBolt = allNamedSkills.first { $0.id == "50601" }
        let heal = allNamedSkills.first { $0.id == "40101" }
        let blessingOfMight = allNamedSkills.first { $0.id == "40201" }
        let wrathOfHeaven = allNamedSkills.first { $0.id == "40301" }
        let sanctuary = allNamedSkills.first { $0.id == "40401" }
        let resurrection = allNamedSkills.first { $0.id == "40601" }
        let slamJump = allNamedSkills.first { $0.id == "60101" }
        let crushingBlow = allNamedSkills.first { $0.id == "60201" }
        let generalsRoar = allNamedSkills.first { $0.id == "60301" }
        let groundSlam = allNamedSkills.first { $0.id == "60401" }
        let axeSpin = allNamedSkills.first { $0.id == "60501" }
        let bloodlust = allNamedSkills.first { $0.id == "60601" }

        #expect(allNamedSkills.count == 36)
        #expect(allNamedSkills.allSatisfy { $0.levelValues.count == 10 })
        #expect(piercingThrust?.levelOneValue == 2_500)
        #expect(piercingThrust?.value(at: 10) == 4_300)
        #expect(piercingThrust?.damageMultiplier == 25.0)
        #expect(shieldCharge?.levelOneValue == 3_000)
        #expect(shieldCharge?.value(at: 10) == 5_700)
        #expect(shieldCharge?.damageMultiplier == 30.0)
        #expect(retributionStrike?.levelOneValue == 1_500)
        #expect(retributionStrike?.value(at: 10) == 3_300)
        #expect(retributionStrike?.damageMultiplier == 15.0)
        #expect(aegisField?.levelOneValue == 500)
        #expect(aegisField?.value(at: 10) == 1_850)
        #expect(unyieldingWill?.levelOneValue == 300)
        #expect(unyieldingWill?.value(at: 10) == 1_200)
        #expect(rapidFire?.levelOneValue == 1_320)
        #expect(rapidFire?.value(at: 10) == 2_400)
        #expect(rapidFire?.damageMultiplier == 13.2)
        #expect(scatterShot?.levelOneValue == 1_620)
        #expect(scatterShot?.value(at: 10) == 3_060)
        #expect(scatterShot?.damageMultiplier == 16.2)
        #expect(arrowRain?.levelOneValue == 2_150)
        #expect(arrowRain?.value(at: 10) == 4_490)
        #expect(arrowRain?.damageMultiplier == 21.5)
        #expect(swiftSurge?.levelOneValue == 500)
        #expect(swiftSurge?.value(at: 10) == 1_400)
        #expect(piercingArrow?.levelOneValue == 2_440)
        #expect(piercingArrow?.value(at: 10) == 3_880)
        #expect(piercingArrow?.damageMultiplier == 24.4)
        #expect(skewerShot?.levelOneValue == 1_000)
        #expect(skewerShot?.value(at: 10) == 3_700)
        #expect(skewerShot?.damageMultiplier == 10.0)
        #expect(fireball?.levelOneValue == 2_700)
        #expect(fireball?.value(at: 10) == 4_950)
        #expect(fireball?.damageMultiplier == 27.0)
        #expect(iceOrb?.levelOneValue == 1_500)
        #expect(iceOrb?.value(at: 10) == 2_580)
        #expect(iceOrb?.damageMultiplier == 15.0)
        #expect(lightning?.levelOneValue == 2_550)
        #expect(lightning?.value(at: 10) == 4_980)
        #expect(lightning?.damageMultiplier == 25.5)
        #expect(flameHydra?.levelOneValue == 2_300)
        #expect(flameHydra?.value(at: 10) == 3_650)
        #expect(flameHydra?.damageMultiplier == 23.0)
        #expect(snowstorm?.levelOneValue == 500)
        #expect(snowstorm?.value(at: 10) == 1_940)
        #expect(snowstorm?.damageMultiplier == 5.0)
        #expect(meteorStrike?.levelOneValue == 5_500)
        #expect(meteorStrike?.value(at: 10) == 9_550)
        #expect(meteorStrike?.damageMultiplier == 55.0)
        #expect(explosiveBolt?.levelOneValue == 4_840)
        #expect(explosiveBolt?.value(at: 10) == 9_430)
        #expect(explosiveBolt?.damageMultiplier == 48.4)
        #expect(frostBolt?.levelOneValue == 2_100)
        #expect(frostBolt?.value(at: 10) == 3_450)
        #expect(frostBolt?.damageMultiplier == 21.0)
        #expect(chargedTrap?.levelOneValue == 1_000)
        #expect(chargedTrap?.value(at: 10) == 5_500)
        #expect(crossbowTurret?.levelOneValue == 1_750)
        #expect(crossbowTurret?.value(at: 10) == 3_190)
        #expect(crossbowTurret?.damageMultiplier == 17.5)
        #expect(shockBolt?.levelOneValue == 2_700)
        #expect(shockBolt?.value(at: 10) == 4_500)
        #expect(shockBolt?.damageMultiplier == 27.0)
        #expect(heal?.levelOneValue == 100)
        #expect(blessingOfMight?.levelOneValue == 500)
        #expect(wrathOfHeaven?.levelOneValue == 4_300)
        #expect(wrathOfHeaven?.value(at: 10) == 7_900)
        #expect(sanctuary?.levelOneValue == 300)
        #expect(sanctuary?.value(at: 10) == 1_920)
        #expect(resurrection?.levelOneValue == 300)
        #expect(resurrection?.value(at: 10) == 750)
        #expect(slamJump?.levelOneValue == 3_100)
        #expect(slamJump?.value(at: 10) == 5_350)
        #expect(slamJump?.damageMultiplier == 31.0)
        #expect(crushingBlow?.damageMultiplier == 62.0)
        #expect(generalsRoar?.levelOneValue == 500)
        #expect(generalsRoar?.value(at: 10) == 950)
        #expect(groundSlam?.levelOneValue == 3_700)
        #expect(groundSlam?.value(at: 10) == 5_950)
        #expect(groundSlam?.damageMultiplier == 37.0)
        #expect(axeSpin?.levelOneValue == 1_000)
        #expect(axeSpin?.value(at: 10) == 1_720)
        #expect(axeSpin?.damageMultiplier == 10.0)
        #expect(bloodlust?.levelOneValue == 4_000)
        #expect(bloodlust?.value(at: 10) == 6_700)
        #expect(
            allNamedSkills
                .filter { $0.damageMultiplier > 0 }
                .allSatisfy { $0.damageElement != .none && $0.delivery != .none }
        )
        #expect(Set(allNamedSkills.map(\.damageElement)).isSuperset(of: [.physical, .fire, .cold, .lightning]))
        #expect(fireball?.damageElement == .fire)
        #expect(iceOrb?.damageElement == .cold)
        #expect(lightning?.damageElement == .lightning)
        #expect(explosiveBolt?.delivery == .projectileAOE)
        #expect(chargedTrap?.delivery == .trap)
        #expect(chargedTrap?.damageElement.isElemental == false)
        #expect(crossbowTurret?.delivery == .summonProjectile)
        #expect(resurrection?.delivery == .resurrection)
        #expect(HeroSkills.skill(forLogSkillName: "充能陷阱爆炸")?.id == "50401")
        #expect(HeroSkills.skill(forLogSkillName: "电击弩箭电流")?.id == "50601")

        let fireDamageLog = BattleLogEntry(attacker: .hero, damage: 1, isCrit: false, skillName: "火球术")
        let coldDamageLog = BattleLogEntry(attacker: .hero, damage: 1, isCrit: false, skillName: "寒霜弩箭")
        let trapExplosionLog = BattleLogEntry(attacker: .hero, damage: 1, isCrit: false, skillName: "充能陷阱爆炸")
        #expect(fireDamageLog.damageElement == .fire)
        #expect(fireDamageLog.delivery == .rangeAOE)
        #expect(coldDamageLog.damageElement == .cold)
        #expect(coldDamageLog.delivery == .projectileAOE)
        #expect(trapExplosionLog.damageElement == .physical)
        #expect(trapExplosionLog.delivery == .trap)
    }

    @Test func mainHeroDamageSkillLogsCarrySourceElementAndDeliveryMetadata() {
        func skillLog(
            heroClass: HeroClass,
            skillID: String,
            skillName: String,
            updateCount: Int = 1
        ) -> BattleLogEntry? {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkill(skillID, for: heroClass, slotIndex: 0)
            let monster = Monster(
                id: "main-skill-metadata-\(skillID)",
                name: "主英雄技能元数据训练木桩",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<updateCount {
                battle.update(deltaTime: 10)
            }
            return battle.log.first {
                $0.attacker == .hero &&
                    $0.kind == .damage &&
                    $0.skillName == skillName
            }
        }

        let fireball = skillLog(heroClass: .sorcerer, skillID: "30101", skillName: "火球术")
        let frostBolt = skillLog(heroClass: .hunter, skillID: "50201", skillName: "寒霜弩箭")
        let rapidFire = skillLog(heroClass: .ranger, skillID: "20101", skillName: "快速射击", updateCount: 3)

        #expect(fireball?.damageElement == .fire)
        #expect(fireball?.delivery == .rangeAOE)
        #expect(frostBolt?.damageElement == .cold)
        #expect(frostBolt?.delivery == .projectileAOE)
        #expect(rapidFire?.damageElement == .physical)
        #expect(rapidFire?.delivery == .projectile)
    }

    @Test func supportMembersDealVisibleDamage() {
        let hero = Hero()
        let party = HeroParty(primaryClass: hero.heroClass, unlockedSlotCount: 3)
        let monster = Monster(
            id: "training",
            name: "训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: party)

        battle.update(deltaTime: 1)

        #expect(battle.log.contains { entry in
            if case .support = entry.attacker { return true }
            return false
        })
        #expect(battle.log.filter {
            if case .support = $0.attacker { return $0.skillName == nil }
            return false
        }.count >= 2)
        #expect(battle.log.contains { entry in
            entry.attacker == .support(.priest) && entry.skillName == "治愈"
        })
        #expect(battle.log.contains { entry in
            entry.attacker == .support(.ranger) && entry.skillName == "散弹射击" && entry.kind == .damage
        })
        #expect(battle.monsterHP < monster.hp)
    }

    @Test func sourceBaseAttackMetadataReachesBattleLogsAndVisualCues() {
        let sorcerer = Hero()
        sorcerer.changeClass(to: .sorcerer)
        let monster = Monster(
            id: "base-attack-metadata",
            name: "基础攻击元数据训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let sorcererBattle = Battle(
            hero: sorcerer,
            monster: monster,
            party: HeroParty(primaryClass: .sorcerer),
            activeSkillSlotCount: 1
        )

        sorcererBattle.update(deltaTime: 1)

        let sorcererBaseAttack = sorcererBattle.log.first {
            $0.attacker == .hero && $0.skillName == nil && $0.kind == .damage
        }
        #expect(sorcererBaseAttack?.damageElement == .fire)
        #expect(sorcererBaseAttack?.delivery == .projectile)
        #expect(BattleImpactCue.visible(for: sorcererBaseAttack) == .fireBurst)
        #expect(BattleTrajectoryCue.visible(for: sorcererBaseAttack) == .projectile)

        let knight = Hero()
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        let supportBattle = Battle(
            hero: knight,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1
        )

        supportBattle.update(deltaTime: 1)

        let rangerBaseAttack = supportBattle.log.first {
            $0.attacker == .support(.ranger) && $0.skillName == nil && $0.kind == .damage
        }
        #expect(rangerBaseAttack?.damageElement == .physical)
        #expect(rangerBaseAttack?.delivery == .projectile)
        #expect(BattleTrajectoryCue.visible(for: rangerBaseAttack) == .projectile)
    }

    @Test func supportAttackCountSkillsTriggerFromSupportAttacks() {
        let hero = Hero()
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["20101"], for: .ranger)
        let monster = Monster(
            id: "support-rapid-fire",
            name: "支援快速射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        let supportRapidFireTriggerEvery = max(
            1,
            HeroSkills.named(for: .ranger).first { $0.id == "20101" }?.triggerEvery ?? 3
        )
        while battle.log.filter({
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }).count < supportRapidFireTriggerEvery - 1 {
            battle.update(deltaTime: 1)
        }
        let rapidFireCountBeforeTrigger = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "快速射击" &&
                $0.kind == .damage
        }.count
        while battle.log.filter({
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }).count < supportRapidFireTriggerEvery {
            battle.update(deltaTime: 1)
        }
        let rapidFireCountAfterTrigger = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "快速射击" &&
                $0.kind == .damage
        }.count

        for _ in 0..<20 {
            battle.update(deltaTime: 1)
            if battle.log.filter({ $0.attacker == .support(.ranger) && $0.skillName == "快速射击" }).count >= 2 {
                break
            }
        }

        #expect(rapidFireCountBeforeTrigger == 0)
        #expect(rapidFireCountAfterTrigger > rapidFireCountBeforeTrigger)
        #expect(battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "快速射击" &&
                $0.kind == .damage
        }.count >= 2)
        #expect(!battle.log.contains {
            $0.attacker == .hero &&
                $0.skillName == "快速射击"
        })
    }

    @Test func supportScatterShotDealsSupportAttributedTrackingDamageAcrossLiveWave() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["20201"], for: .ranger)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-scatter-\(index)",
                name: "支援散弹射击训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: Hero(),
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)

        let supportScatterLogs = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "散弹射击" &&
                $0.kind == .damage
        }
        #expect(supportScatterLogs.count >= 3)
        #expect(supportScatterLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .projectile })
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(!battle.log.contains { $0.attacker == .hero && $0.skillName == "散弹射击" })
    }

    @Test func supportArrowRainDealsSupportAttributedRangeDamageAcrossLiveWave() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["20301"], for: .ranger)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-arrow-rain-\(index)",
                name: "支援箭雨训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: Hero(),
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)

        let supportArrowRainLogs = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "箭雨" &&
                $0.kind == .damage
        }
        #expect(supportArrowRainLogs.count >= 3)
        #expect(supportArrowRainLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .rangeAOE })
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(!battle.log.contains { $0.attacker == .hero && $0.skillName == "箭雨" })
    }

    @Test func supportPiercingArrowKeepsProjectileMetadataAcrossLiveWave() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["20501"], for: .ranger)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-piercing-arrow-\(index)",
                name: "支援穿透之箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: Hero(),
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        for _ in 0..<30 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: {
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "穿透之箭" &&
                    $0.kind == .damage
            }) {
                break
            }
        }

        let supportPiercingLogs = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "穿透之箭" &&
                $0.kind == .damage
        }
        #expect(supportPiercingLogs.count >= 3)
        #expect(supportPiercingLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .projectile })
        #expect(supportPiercingLogs.allSatisfy { BattleTrajectoryCue.visible(for: $0) == .piercingArrow })
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(!battle.log.contains { $0.attacker == .hero && $0.skillName == "穿透之箭" })
    }

    @Test func supportSkewerShotKeepsProjectileMetadataAndBleedingMarker() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["20601"], for: .ranger)
        let monster = Monster(
            id: "support-skewer-shot-training",
            name: "支援穿刺射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        for _ in 0..<40 {
            battle.update(deltaTime: 1)
            if battle.log.filter({
                $0.attacker == .support(.ranger) &&
                    $0.skillName == "穿刺射击" &&
                    $0.kind == .damage
            }).count >= 3 {
                break
            }
        }

        let supportSkewerLogs = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "穿刺射击" &&
                $0.kind == .damage
        }
        #expect(supportSkewerLogs.count >= 3)
        #expect(supportSkewerLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .projectile })
        #expect(supportSkewerLogs.allSatisfy { BattleTrajectoryCue.visible(for: $0) == .lodgedArrow })
        #expect(battle.enemyStates.first?.lodgedSkewerArrows == 3)
        #expect(battle.enemyStates.first?.isBleeding == true)
        #expect(battle.log.contains {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "穿刺射击出血" &&
                $0.kind == .buff
        })
        #expect(!battle.log.contains { $0.attacker == .hero && $0.skillName == "穿刺射击" })
    }

    @Test func supportMeteorStrikeDealsSupportAttributedRangeDamageAcrossLiveWave() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.sorcerer, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["30601"], for: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-meteor-\(index)",
                name: "支援陨石打击训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: Hero(),
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)

        let supportMeteorLogs = battle.log.filter {
            $0.attacker == .support(.sorcerer) &&
                $0.skillName == "陨石打击" &&
                $0.kind == .damage
        }
        #expect(supportMeteorLogs.count >= 3)
        #expect(supportMeteorLogs.allSatisfy { $0.damageElement == .fire && $0.delivery == .rangeAOE })
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(!battle.log.contains { $0.attacker == .hero && $0.skillName == "陨石打击" })
    }

    @Test func supportShockBoltKeepsSupportAttributedCurrentDamage() {
        let hero = Hero()
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.hunter, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["50601"], for: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-shock-bolt-\(index)",
                name: "支援电击弩箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        for _ in 0..<30 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "电击弩箭电流" &&
                    $0.kind == .damage
            }) {
                break
            }
        }

        #expect(battle.activeBuffNames.contains("电击弩箭电流"))
        #expect(PlayerBattleStatusBadge.visible(for: battle).contains(.shockCurrent))
        #expect(battle.log.contains {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "电击弩箭" &&
                $0.kind == .damage
        })
        #expect(battle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "电击弩箭电流" &&
                $0.kind == .damage
        }.count >= 3)
        #expect(battle.log
            .filter {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "电击弩箭电流" &&
                    $0.kind == .damage
            }
            .allSatisfy { $0.damageElement == .lightning && $0.delivery == .projectile }
        )
    }

    @Test func heroCooldownSkillExecutesInBattle() {
        let hero = Hero()
        let monster = Monster(
            id: "training-skill",
            name: "技能训练木桩",
            hp: 1_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        #expect(HeroSkills.activeLoadout(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10101"])
        #expect(HeroSkills.activeLoadout(for: .knight, heroLevel: 1, slotCount: 2).map(\.id) == ["10101", "10201"])
        #expect(HeroSkills.activeLoadout(
            for: .knight,
            heroLevel: 1,
            slotCount: 2,
            preferredSkillIDs: ["invalid", "10201", "10201"]
        ).map(\.id) == ["10201", "10101"])

        var selectedLoadouts = ActiveSkillLoadouts()
        selectedLoadouts.setSkill("10201", for: .knight, slotIndex: 0)
        #expect(selectedLoadouts.activeSkills(for: .knight, heroLevel: 1, slotCount: 1).map(\.id) == ["10201"])

        let oneSlotBattle = Battle(
            hero: Hero(),
            monster: monster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1
        )
        oneSlotBattle.update(deltaTime: 1)
        #expect(oneSlotBattle.activeSkillSlotCount == 1)
        #expect(!oneSlotBattle.log.contains { $0.skillName == "盾牌冲锋" })

        let selectedSlotBattle = Battle(
            hero: Hero(),
            monster: monster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: selectedLoadouts
        )
        selectedSlotBattle.update(deltaTime: 1)
        #expect(selectedSlotBattle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage })
        #expect(!selectedSlotBattle.log.contains { $0.skillName == "穿透突刺" })

        let twoSlotBattle = Battle(
            hero: Hero(),
            monster: monster,
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 2
        )
        twoSlotBattle.update(deltaTime: 1)
        #expect(twoSlotBattle.activeSkillSlotCount == 2)
        #expect(twoSlotBattle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage })

        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)

        #expect(battle.log.contains { $0.skillName == "盾牌冲锋" && $0.kind == .damage })
        #expect(battle.monsterHP < monster.hp)
    }

    @Test func shieldChargeKeepsMeleeCollisionFocusedOnCurrentTarget() {
        let hero = Hero()
        let monsters = (1...3).map { index in
            Monster(
                id: "shield-charge-\(index)",
                name: "盾牌冲锋训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)

        let shieldChargeLogs = battle.log.filter { $0.skillName == "盾牌冲锋" && $0.kind == .damage }
        #expect(shieldChargeLogs.count == 1)
        #expect(shieldChargeLogs.allSatisfy { $0.damageElement == .physical && $0.delivery == .melee })
        #expect((battle.enemyStates.first?.hp ?? 0) < (battle.enemyStates.first?.maxHP ?? 0))
        #expect(battle.enemyStates.dropFirst().allSatisfy { $0.hp == $0.maxHP })
    }

    @Test func piercingThrustDealsMeleeRangeDamageAcrossLiveWaveScaffold() {
        let hero = Hero()
        let monsters = (1...3).map { index in
            Monster(
                id: "piercing-thrust-\(index)",
                name: "穿透突刺训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .knight))

        for _ in 0..<5 {
            battle.update(deltaTime: 1)
            if battle.log.filter({ $0.skillName == "穿透突刺" && $0.kind == .damage }).count >= 3 {
                break
            }
        }

        #expect(battle.log.filter { $0.skillName == "穿透突刺" && $0.kind == .damage }.count >= 3)
    }

    @Test func heroAttackCountSkillExecutesAfterBaseAttacks() {
        let hero = Hero()
        let monster = Monster(
            id: "training-attack-count-skill",
            name: "攻击次数训练木桩",
            hp: 1_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .knight))

        for _ in 0..<5 {
            battle.update(deltaTime: 1)
        }

        #expect(battle.log.contains { $0.skillName == "穿透突刺" && $0.kind == .damage })
    }

    @Test func retributionStrikeMultiHitCountIncreasesAtLowHP() {
        let trainingMonster = Monster(
            id: "retribution-training",
            name: "报应打击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )

        let healthyHero = Hero()
        let healthyBattle = Battle(hero: healthyHero, monster: trainingMonster, party: HeroParty(primaryClass: .knight))
        for _ in 0..<14 {
            healthyBattle.update(deltaTime: 1)
            if healthyBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }
        let healthyHits = healthyBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count

        let woundedHero = Hero()
        let lowHP = max(1, woundedHero.maxHP / 13)
        woundedHero.takeDamage(max(0, woundedHero.currentHP - lowHP))
        let woundedBattle = Battle(hero: woundedHero, monster: trainingMonster, party: HeroParty(primaryClass: .knight))
        for _ in 0..<14 {
            woundedHero.takeDamage(max(0, woundedHero.currentHP - lowHP))
            woundedBattle.heroHP = woundedHero.currentHP
            woundedBattle.update(deltaTime: 1)
            if woundedBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }
        let woundedHits = woundedBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count

        #expect(healthyHits >= 2)
        #expect(woundedHits > healthyHits)
        #expect(woundedHits >= 5)
    }

    @Test func skillRangeExpansionExtendsFocusedMeleeSkillTargets() {
        func makeMonsters() -> [Monster] {
            (1...3).map { index in
                Monster(
                    id: "skill-range-\(index)",
                    name: "技能范围训练 \(index)",
                    hp: 1_000_000,
                    atk: 0,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            }
        }

        var loadout = ActiveSkillLoadouts()
        loadout.setSkills(["10301"], for: .knight)

        let baselineBattle = Battle(
            hero: Hero(),
            monsters: makeMonsters(),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadout
        )
        for _ in 0..<14 {
            baselineBattle.update(deltaTime: 1)
            if baselineBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }

        let expandedHero = Hero()
        expandedHero.unlockedPassiveSkillIDs = ["101081"]
        let expandedBattle = Battle(
            hero: expandedHero,
            monsters: makeMonsters(),
            party: HeroParty(primaryClass: .knight),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadout
        )
        for _ in 0..<14 {
            expandedBattle.update(deltaTime: 1)
            if expandedBattle.log.contains(where: { $0.skillName == "报应打击" && $0.kind == .damage }) {
                break
            }
        }

        #expect(baselineBattle.enemyStates.filter { $0.hp < $0.maxHP }.count == 1)
        #expect(expandedBattle.enemyStates.filter { $0.hp < $0.maxHP }.count >= 2)
        #expect(
            expandedBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count >
            baselineBattle.log.filter { $0.skillName == "报应打击" && $0.kind == .damage }.count
        )
    }

    @Test func aegisFieldAppliesDamageShield() {
        let hero = Hero()
        let monster = Monster(
            id: "aegis-training",
            name: "神盾领域训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)
        let hpBeforeAegisBlock = hero.currentHP
        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("神盾领域"))
        #expect(battle.activeHeroDamageShieldRemaining > 0)
        #expect(battle.activeHeroDamageShieldRemaining < 500)
        #expect(hero.currentHP == hpBeforeAegisBlock)
        #expect(battle.log.last { $0.attacker == .monster }?.damage == 0)
    }

    @Test func aegisFieldProtectsLivingSupportAllies() {
        let hero = Hero()
        let monster = Monster(
            id: "aegis-support-training",
            name: "神盾领域支援训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: HeroParty(primaryClass: .knight, unlockedSlotCount: 3)
        )

        battle.update(deltaTime: 1)
        let supportSlot = 1
        let supportHPBeforeBlock = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        battle.update(deltaTime: 1)
        let supportHPAfterBlock = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        #expect(battle.activeBuffNames.contains("神盾领域"))
        #expect(battle.activeHeroDamageShieldRemaining > 0)
        #expect(battle.activeHeroDamageShieldRemaining < 500)
        #expect(supportHPAfterBlock == supportHPBeforeBlock)
        #expect(battle.log.last { $0.attacker == .monster }?.damage == 0)
    }

    @Test func supportAegisFieldAppliesPartyDamageShield() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        var party = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        party.setHeroClass(.knight, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["10401"], for: .knight)
        let monster = Monster(
            id: "support-aegis-training",
            name: "支援神盾领域训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)
        let heroHPAfterFirstBlock = hero.currentHP
        let supportSlot = 1
        let supportHPBeforeBlock = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        battle.update(deltaTime: 1)
        let supportHPAfterBlock = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        #expect(battle.activeBuffNames.contains("神盾领域"))
        #expect(battle.log.contains {
            $0.attacker == .support(.knight) &&
                $0.skillName == "神盾领域" &&
                $0.kind == .buff
        })
        #expect(battle.activeHeroDamageShieldRemaining > 0)
        #expect(battle.activeHeroDamageShieldRemaining < 500)
        #expect(hero.currentHP == heroHPAfterFirstBlock)
        #expect(supportHPAfterBlock == supportHPBeforeBlock)
        #expect(battle.log.filter { $0.attacker == .monster }.suffix(2).allSatisfy { $0.damage == 0 })
    }

    @Test func sacredBladeAppliesAttackBuffAndOnHitHealing() {
        let hero = Hero()
        hero.takeDamage(60)
        let monster = Monster(
            id: "sacred-blade-training",
            name: "神圣之刃训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)
        let hpBeforeSacredBladeAttack = hero.currentHP
        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("神圣之刃"))
        #expect(battle.activeHeroAttackMultiplier == 1.5)
        #expect(battle.log.contains { $0.skillName == "神圣之刃" && $0.kind == .heal && $0.damage > 0 })
        #expect(hero.currentHP > hpBeforeSacredBladeAttack)
    }

    @Test func supportSacredBladeAppliesSupportAttackBuffAndOnHitHealing() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        var party = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        party.setHeroClass(.knight, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["10501"], for: .knight)
        let monster = Monster(
            id: "support-sacred-blade-training",
            name: "支援神圣之刃训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )
        let supportSlot = 1
        _ = battle.damageSupportMember(slotIndex: supportSlot, amount: 40)
        let supportHPBeforeSacredBladeAttack = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        battle.update(deltaTime: 1)

        let supportHPAfterSacredBladeAttack = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        #expect(battle.activeBuffNames.contains("神圣之刃"))
        #expect(battle.activeSupportAttackMultiplier(slotIndex: supportSlot) == 1.5)
        #expect(battle.log.contains {
            $0.attacker == .support(.knight) &&
                $0.skillName == "神圣之刃" &&
                $0.kind == .buff
        })
        #expect(supportHPAfterSacredBladeAttack > supportHPBeforeSacredBladeAttack)
        #expect(battle.log.contains {
            $0.attacker == .support(.knight) &&
                $0.skillName == "神圣之刃" &&
                $0.kind == .heal &&
            $0.damage > 0
        })
    }

    @Test func supportMembersAttackOnIndependentCooldowns() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        var party = HeroParty(primaryClass: .sorcerer, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        let monster = Monster(
            id: "support-independent-cooldown-training",
            name: "支援独立冷却训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1
        )

        for _ in 0..<9 {
            battle.update(deltaTime: GamePacing.combatSimulationStep)
        }

        let heroBaseAttacks = battle.log.filter {
            $0.attacker == .hero &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        let supportBaseAttacks = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count

        #expect(supportBaseAttacks > heroBaseAttacks)
    }

    @Test func supportQuickLoaderAppliesSupportAttackSpeedScaffold() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.hunter, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["10601"], for: .knight)
        loadouts.setSkills(["50301"], for: .hunter)
        let monster = Monster(
            id: "support-quick-loader-training",
            name: "支援快速装填训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )
        let supportSlot = 1

        battle.update(deltaTime: GamePacing.combatSimulationStep)

        let quickLoaderBaseAttacksAfterFirstTick = battle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        #expect(battle.activeBuffNames.contains("快速装填"))
        #expect(battle.activeSupportAttackSpeedMultiplier(slotIndex: supportSlot) == 1.5)
        #expect(battle.log.contains {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "快速装填" &&
                $0.kind == .buff
        })
        #expect(quickLoaderBaseAttacksAfterFirstTick == 1)

        for _ in 0..<16 {
            battle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let quickLoaderBaseAttacksAfterWindow = battle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count

        var baselineLoadouts = ActiveSkillLoadouts()
        baselineLoadouts.setSkills(["10601"], for: .knight)
        baselineLoadouts.setSkills(["50101"], for: .hunter)
        let baselineBattle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: baselineLoadouts
        )
        for _ in 0..<17 {
            baselineBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }
        let baselineBaseAttacks = baselineBattle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        #expect(baselineBaseAttacks > 0)
        #expect(quickLoaderBaseAttacksAfterWindow >= 3)
        #expect(quickLoaderBaseAttacksAfterWindow <= 17)
        #expect(battle.activeSupportAttackSpeedMultiplier(slotIndex: supportSlot) == 1.0)
        #expect(!battle.activeBuffNames.contains("快速装填"))
    }

    @Test func unyieldingWillRevivesOnceFromLethalMonsterDamage() {
        let hero = Hero()
        hero.takeDamage(hero.currentHP - 10)
        let monster = Monster(
            id: "unyielding-training",
            name: "不屈意志训练木桩",
            hp: 100_000,
            atk: 2_000,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)

        #expect(!battle.isOver)
        #expect(battle.unyieldingWillWasUsed)
        #expect(hero.currentHP == hero.maxHP * 3)
        #expect(battle.heroHP == hero.currentHP)
        #expect(battle.log.contains { $0.skillName == "不屈意志" && $0.kind == .heal })

        hero.takeDamage(hero.currentHP - 10)
        battle.heroHP = hero.currentHP
        battle.update(deltaTime: 1)

        #expect(battle.isOver)
    }

    @Test func supportUnyieldingWillRevivesThatSupportMemberOnceFromLethalMonsterDamage() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["10601"], for: .knight)
        let party = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        let monsters = [
            Monster(
                id: "support-unyielding-low",
                name: "不屈意志轻击木桩",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            ),
            Monster(
                id: "support-unyielding-heavy",
                name: "不屈意志重击木桩",
                hp: 100_000,
                atk: 10_000,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        ]
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillLoadouts: loadouts
        )
        let supportSlot = 1
        let supportMaxHP = battle.supportStates.first { $0.slotIndex == supportSlot }?.maxHP ?? 0

        battle.update(deltaTime: 1)

        let revivedSupport = battle.supportStates.first { $0.slotIndex == supportSlot }
        #expect(revivedSupport?.isDefeated == false)
        #expect(revivedSupport?.unyieldingWillWasUsed == true)
        #expect(revivedSupport?.hp == supportMaxHP * 3)
        #expect(battle.log.contains {
            $0.attacker == .support(.knight) &&
                $0.skillName == "不屈意志" &&
                $0.kind == .heal &&
                $0.damage == supportMaxHP * 3
        })

        battle.update(deltaTime: 1)

        let defeatedSupport = battle.supportStates.first { $0.slotIndex == supportSlot }
        #expect(defeatedSupport?.isDefeated == true)
        #expect(defeatedSupport?.unyieldingWillWasUsed == true)
        #expect(battle.log.filter {
            $0.attacker == .support(.knight) &&
                $0.skillName == "不屈意志" &&
                $0.kind == .heal
        }.count == 1)
    }

    @Test func swiftSurgeAppliesAttackSpeedBuff() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        let monster = Monster(
            id: "swift-surge-training",
            name: "迅捷觉醒训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["20401"], for: .ranger)
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: HeroParty(primaryClass: .ranger),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )
        let baselineHero = Hero()
        baselineHero.changeClass(to: .ranger)
        var baselineLoadouts = ActiveSkillLoadouts()
        baselineLoadouts.setSkills(["20101"], for: .ranger)
        let baselineBattle = Battle(
            hero: baselineHero,
            monster: monster,
            party: HeroParty(primaryClass: .ranger),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: baselineLoadouts
        )

        for _ in 0..<6 {
            battle.update(deltaTime: GamePacing.combatSimulationStep)
            baselineBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }

        let hastedBaseAttacks = battle.log.filter {
            $0.attacker == .hero &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        let baselineBaseAttacks = baselineBattle.log.filter {
            $0.attacker == .hero &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count

        #expect(battle.activeBuffNames.contains("迅捷觉醒"))
        #expect(battle.activeHeroAttackSpeedMultiplier == 6.0)
        #expect(hastedBaseAttacks == baselineBaseAttacks)
        #expect(hastedBaseAttacks <= 6)
    }

    @Test func supportSwiftSurgeAppliesSupportAttackSpeedBuff() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.ranger, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["10601"], for: .knight)
        loadouts.setSkills(["20401"], for: .ranger)
        let monster = Monster(
            id: "support-swift-surge-training",
            name: "支援迅捷觉醒训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )
        let supportSlot = 1

        var baselineLoadouts = ActiveSkillLoadouts()
        baselineLoadouts.setSkills(["10601"], for: .knight)
        baselineLoadouts.setSkills(["20101"], for: .ranger)
        let baselineBattle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: baselineLoadouts
        )

        for _ in 0..<6 {
            battle.update(deltaTime: GamePacing.combatSimulationStep)
            baselineBattle.update(deltaTime: GamePacing.combatSimulationStep)
        }

        let hastedBaseAttacks = battle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count
        let baselineBaseAttacks = baselineBattle.log.filter {
            $0.attacker == .support(.ranger) &&
                $0.skillName == nil &&
                $0.kind == .damage
        }.count

        #expect(battle.activeBuffNames.contains("迅捷觉醒"))
        #expect(battle.activeSupportAttackSpeedMultiplier(slotIndex: supportSlot) == 6.0)
        #expect(battle.log.contains {
            $0.attacker == .support(.ranger) &&
                $0.skillName == "迅捷觉醒" &&
                $0.kind == .buff
        })
        #expect(hastedBaseAttacks == baselineBaseAttacks)
        #expect(hastedBaseAttacks <= 6)
    }

    @Test func rapidFireDealsMultipleProjectileHitsAfterAttackCountTrigger() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        let monster = Monster(
            id: "rapid-fire-training",
            name: "快速射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .ranger))

        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)
        let hpBeforeRapidFire = battle.monsterHP
        battle.update(deltaTime: 1)

        #expect(battle.log.filter { $0.skillName == "快速射击" && $0.kind == .damage }.count >= 2)
        #expect(battle.monsterHP < hpBeforeRapidFire)
    }

    @Test func piercingArrowDealsProjectileDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        let monsters = (1...3).map { index in
            Monster(
                id: "piercing-arrow-\(index)",
                name: "穿透之箭训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .ranger))

        for _ in 0..<8 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "穿透之箭" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.filter { $0.skillName == "穿透之箭" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func skewerShotStacksLodgedArrowsAndBleeding() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        let monster = Monster(
            id: "skewer-shot-training",
            name: "穿刺射击训练木桩",
            hp: 1_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .ranger))

        for _ in 0..<30 {
            battle.update(deltaTime: 1)
            if battle.log.filter({ $0.skillName == "穿刺射击" && $0.kind == .damage }).count >= 3 {
                break
            }
        }
        let damageEntries = battle.log.filter { $0.skillName == "穿刺射击" && $0.kind == .damage }
        let normalizedDamages = damageEntries.map { entry in
            entry.isCrit ? Double(entry.damage) / hero.critDamage : Double(entry.damage)
        }

        #expect(battle.enemyStates.first?.lodgedSkewerArrows == 3)
        #expect(battle.enemyStates.first?.isBleeding == true)
        #expect(battle.log.contains { $0.skillName == "穿刺射击出血" && $0.kind == .buff })
        #expect(battle.enemyStates.first.map { EnemyStatusBadge.visible(for: $0) } == [.bleeding])
        if normalizedDamages.count >= 3 {
            #expect(normalizedDamages[1] > normalizedDamages[0])
            #expect(normalizedDamages[2] > normalizedDamages[1])
        } else {
            Issue.record("Skewer Shot should produce at least three damage logs")
        }
    }

    @Test func scatterShotDealsTrackingProjectileDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        let monsters = (1...3).map { index in
            Monster(
                id: "scatter-\(index)",
                name: "散弹射击训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .ranger))

        battle.update(deltaTime: 1)

        #expect(battle.log.filter { $0.skillName == "散弹射击" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func increaseProjectileDamagePassiveBoostsScatterShotDamage() {
        func makeHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .ranger)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "ranger-projectile-damage-crit-suppression",
                name: "投射物伤害测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))
            return hero
        }

        func firstScatterShotDamage(for hero: Hero) -> Int {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["20201"], for: .ranger)
            let monsters = (1...3).map { index in
                Monster(
                    id: "scatter-projectile-damage-\(index)",
                    name: "散弹射击投射物伤害训练 \(index)",
                    hp: 1_000_000,
                    atk: 1,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            }
            let battle = Battle(
                hero: hero,
                monsters: monsters,
                party: HeroParty(primaryClass: .ranger),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            battle.update(deltaTime: 1)
            return battle.log.first { $0.skillName == "散弹射击" && $0.kind == .damage }?.damage ?? 0
        }

        let baselineDamage = firstScatterShotDamage(for: makeHero())
        let boostedDamage = firstScatterShotDamage(for: makeHero(passiveIDs: ["201022"]))

        #expect(baselineDamage > 0)
        #expect(boostedDamage > baselineDamage)
    }

    @Test func arrowRainDealsRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        let monsters = (1...3).map { index in
            Monster(
                id: "arrow-rain-\(index)",
                name: "箭雨训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .ranger))

        battle.update(deltaTime: 1)
        let hpBeforeArrowRain = battle.enemyStates.map(\.hp)
        battle.update(deltaTime: 1)
        let hpAfterArrowRain = battle.enemyStates.map(\.hp)

        #expect(battle.log.filter { $0.skillName == "箭雨" && $0.kind == .damage }.count >= 3)
        #expect(zip(hpBeforeArrowRain, hpAfterArrowRain).allSatisfy { before, after in after < before })
    }

    @Test func fireballDealsRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "fireball-\(index)",
                name: "火球术训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .sorcerer))

        battle.update(deltaTime: 1)

        #expect(battle.log.filter { $0.skillName == "火球术" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func unlockedDamageTypePassivesIncreaseMatchingMainHeroSkillDamage() {
        func skillDamage(
            heroClass: HeroClass,
            skillID: String,
            skillName: String,
            unlockedPassiveSkillIDs: Set<String> = []
        ) -> Int {
            let hero = Hero()
            hero.changeClass(to: heroClass)
            hero.unlockedPassiveSkillIDs = unlockedPassiveSkillIDs
            _ = hero.equipment.equip(Item(
                id: "typed-damage-passive-crit-suppression-\(skillID)",
                name: "伤害类型测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))

            let monster = Monster(
                id: "typed-damage-passive-training-\(skillID)",
                name: "伤害类型训练木桩",
                hp: 100_000_000,
                atk: 0,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            var loadout = ActiveSkillLoadouts()
            loadout.setSkill(skillID, for: heroClass, slotIndex: 0)
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: heroClass),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadout
            )

            for _ in 0..<8 {
                battle.update(deltaTime: 1)
            }

            return battle.log
                .filter { $0.skillName == skillName && $0.kind == .damage }
                .map(\.damage)
                .reduce(0, +)
        }

        let baselineExplosiveBoltDamage = skillDamage(heroClass: .hunter, skillID: "50101", skillName: "爆炸弩箭")
        let boostedExplosiveBoltDamage = skillDamage(heroClass: .hunter, skillID: "50101", skillName: "爆炸弩箭", unlockedPassiveSkillIDs: ["501021"])
        let baselineFrostBoltDamage = skillDamage(heroClass: .hunter, skillID: "50201", skillName: "寒霜弩箭")
        let boostedFrostBoltDamage = skillDamage(heroClass: .hunter, skillID: "50201", skillName: "寒霜弩箭", unlockedPassiveSkillIDs: ["501022"])
        let baselineShockBoltDamage = skillDamage(heroClass: .hunter, skillID: "50601", skillName: "电击弩箭")
        let boostedShockBoltDamage = skillDamage(heroClass: .hunter, skillID: "50601", skillName: "电击弩箭", unlockedPassiveSkillIDs: ["501061"])
        let baselineSlamJumpDamage = skillDamage(heroClass: .slayer, skillID: "60101", skillName: "猛击跳跃")
        let boostedSlamJumpDamage = skillDamage(heroClass: .slayer, skillID: "60101", skillName: "猛击跳跃", unlockedPassiveSkillIDs: ["601021"])

        #expect(baselineExplosiveBoltDamage > 0)
        #expect(boostedExplosiveBoltDamage > baselineExplosiveBoltDamage)
        #expect(baselineFrostBoltDamage > 0)
        #expect(boostedFrostBoltDamage > baselineFrostBoltDamage)
        #expect(baselineShockBoltDamage > 0)
        #expect(boostedShockBoltDamage > baselineShockBoltDamage)
        #expect(baselineSlamJumpDamage > 0)
        #expect(boostedSlamJumpDamage > baselineSlamJumpDamage)
    }

    @Test func iceOrbDealsMultiHitRangeDamageAndSlowsLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "ice-orb-\(index)",
                name: "冰球术训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .sorcerer))

        battle.update(deltaTime: 1)
        let hpBeforeIceOrb = battle.enemyStates.map(\.hp)
        let monsterAttacksBeforeIceOrb = battle.log.filter { $0.attacker == .monster }.count
        battle.update(deltaTime: 1)
        let hpAfterIceOrb = battle.enemyStates.map(\.hp)

        #expect(battle.log.filter { $0.skillName == "冰球术" && $0.kind == .damage }.count >= 6)
        #expect(zip(hpBeforeIceOrb, hpAfterIceOrb).allSatisfy { before, after in after < before })
        #expect(battle.log.filter { $0.attacker == .monster }.count == monsterAttacksBeforeIceOrb)
        #expect(battle.enemyStates.allSatisfy {
            $0.coldStatus == .chilled &&
                EnemyStatusBadge.visible(for: $0).contains(.chilled)
        })
    }

    @Test func lightningDealsRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "lightning-\(index)",
                name: "闪电术训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .sorcerer))

        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)

        #expect(battle.log.filter { $0.skillName == "闪电术" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func flameHydraSummonsFocusedProjectileDamage() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "flame-hydra-\(index)",
                name: "烈焰九头蛇训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .sorcerer))

        for _ in 0..<4 {
            battle.update(deltaTime: 1)
        }
        let hpBeforeHydraTick = battle.enemyStates.map(\.hp)
        battle.update(deltaTime: 1)
        let hpAfterHydraTick = battle.enemyStates.map(\.hp)

        #expect(battle.activeBuffNames.contains("烈焰九头蛇"))
        #expect(battle.log.contains { $0.skillName == "烈焰九头蛇" && $0.kind == .damage })
        #expect(zip(hpBeforeHydraTick, hpAfterHydraTick).contains { before, after in after < before })
    }

    @Test func supportFlameHydraKeepsSupportAttributedSustainedDamage() {
        let hero = Hero()
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.sorcerer, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["30401"], for: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-flame-hydra-\(index)",
                name: "支援烈焰九头蛇训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)
        let hpBeforeHydraTick = battle.enemyStates.map(\.hp)
        battle.update(deltaTime: 1)
        let hpAfterHydraTick = battle.enemyStates.map(\.hp)

        #expect(battle.activeBuffNames.contains("烈焰九头蛇"))
        #expect(PlayerBattleStatusBadge.visible(for: battle).contains(.flameHydra))
        #expect(PlayerBattleDeployable.visible(for: battle).contains(.flameHydra))
        #expect(battle.log.contains {
            $0.attacker == .support(.sorcerer) &&
                $0.skillName == "烈焰九头蛇" &&
                $0.kind == .buff
        })
        #expect(battle.log.contains {
            $0.attacker == .support(.sorcerer) &&
                $0.skillName == "烈焰九头蛇" &&
                $0.kind == .damage
        })
        #expect(zip(hpBeforeHydraTick, hpAfterHydraTick).contains { before, after in after < before })
    }

    @Test func snowstormDealsDamageOverTimeAndCoolsLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "snowstorm-\(index)",
                name: "暴风雪训练 \(index)",
                hp: 1_000_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .sorcerer))

        for _ in 0..<5 {
            battle.update(deltaTime: 1)
        }
        let hpBeforeSnowstormTick = battle.enemyStates.map(\.hp)
        let monsterAttacksBeforeSnowstormTick = battle.log.filter { $0.attacker == .monster }.count
        battle.update(deltaTime: 1)
        let hpAfterSnowstormTick = battle.enemyStates.map(\.hp)

        #expect(battle.activeBuffNames.contains("暴风雪"))
        #expect(battle.log.filter { $0.skillName == "暴风雪" && $0.kind == .damage }.count >= 3)
        #expect(zip(hpBeforeSnowstormTick, hpAfterSnowstormTick).allSatisfy { before, after in after < before })
        #expect(battle.log.filter { $0.attacker == .monster }.count == monsterAttacksBeforeSnowstormTick)
        #expect(battle.enemyStates.allSatisfy {
            $0.coldStatus == .chilled &&
                EnemyStatusBadge.visible(for: $0).contains(.chilled)
        })
    }

    @Test func meteorStrikeDealsRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .sorcerer)
        let monsters = (1...3).map { index in
            Monster(
                id: "meteor-\(index)",
                name: "陨石打击训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .sorcerer))

        for _ in 0..<5 {
            battle.update(deltaTime: 1)
        }
        let hpBeforeMeteor = battle.enemyStates.map(\.hp)
        battle.update(deltaTime: 1)
        let hpAfterMeteor = battle.enemyStates.map(\.hp)

        #expect(battle.log.filter { $0.skillName == "陨石打击" && $0.kind == .damage }.count >= 3)
        #expect(zip(hpBeforeMeteor, hpAfterMeteor).allSatisfy { before, after in after < before })
    }

    @Test func sanctuaryAppliesOverTimeHealingBuff() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        let monster = Monster(
            id: "sanctuary-training",
            name: "圣域训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: HeroParty(primaryClass: .priest, unlockedSlotCount: 3)
        )

        for _ in 0..<8 {
            battle.update(deltaTime: 1)
            if battle.activeBuffNames.contains("圣域") { break }
        }
        hero.takeDamage(80)
        battle.heroHP = hero.currentHP
        let supportSlot = 1
        let supportMaxHP = battle.supportStates.first { $0.slotIndex == supportSlot }?.maxHP ?? 0
        _ = battle.damageSupportMember(slotIndex: supportSlot, amount: max(1, supportMaxHP / 2))
        let hpBeforeSanctuaryTick = hero.currentHP
        let supportHPBeforeSanctuaryTick = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        battle.update(deltaTime: 1)
        let supportHPAfterSanctuaryTick = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        #expect(battle.activeBuffNames.contains("圣域"))
        #expect(battle.log.contains { $0.skillName == "圣域" && $0.kind == .heal && $0.damage > 0 })
        #expect(hero.currentHP > hpBeforeSanctuaryTick)
        #expect(supportHPAfterSanctuaryTick > supportHPBeforeSanctuaryTick)
        #expect(battle.heroHP == hero.currentHP)
    }

    @Test func skillHealIncreasePassiveBoostsSanctuaryHealing() {
        func makeHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .priest)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "priest-skill-heal-test-armor",
                name: "治疗增强测试护甲",
                rarity: .common,
                slot: .armor,
                stats: ItemStats(bonusHP: 1_000),
                description: "测试用"
            ))
            _ = hero.heal(hero.maxHP)
            return hero
        }

        func firstSanctuaryHeal(for hero: Hero) -> Int {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["40401"], for: .priest)
            let monster = Monster(
                id: "skill-heal-sanctuary-training",
                name: "治疗增强圣域训练木桩",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: .priest),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<8 {
                battle.update(deltaTime: 1)
                if battle.activeBuffNames.contains("圣域") { break }
            }
            hero.takeDamage(800)
            battle.heroHP = hero.currentHP
            let logStart = battle.log.count
            battle.update(deltaTime: 1)
            return battle.log.dropFirst(logStart).first {
                $0.attacker == .hero &&
                    $0.skillName == "圣域" &&
                    $0.kind == .heal &&
                    $0.damage > 0
            }?.damage ?? 0
        }

        let baselineHeal = firstSanctuaryHeal(for: makeHero())
        let boostedHeal = firstSanctuaryHeal(for: makeHero(passiveIDs: ["401022"]))

        #expect(baselineHeal > 0)
        #expect(boostedHeal > baselineHeal)
    }

    @Test func supportSanctuaryAppliesOverTimeHealingField() {
        let hero = Hero()
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.priest, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["40401"], for: .priest)
        let monster = Monster(
            id: "support-sanctuary-training",
            name: "支援圣域训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        for _ in 0..<3 {
            battle.update(deltaTime: 1)
            if battle.activeBuffNames.contains("圣域") { break }
        }
        hero.takeDamage(80)
        battle.heroHP = hero.currentHP
        let supportSlot = 1
        let supportMaxHP = battle.supportStates.first { $0.slotIndex == supportSlot }?.maxHP ?? 0
        _ = battle.damageSupportMember(slotIndex: supportSlot, amount: max(1, supportMaxHP / 2))
        let hpBeforeSanctuaryTick = hero.currentHP
        let supportHPBeforeSanctuaryTick = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        battle.update(deltaTime: 1)
        let supportHPAfterSanctuaryTick = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        #expect(battle.activeBuffNames.contains("圣域"))
        #expect(battle.log.contains {
            $0.attacker == .support(.priest) &&
                $0.skillName == "圣域" &&
                $0.kind == .buff
        })
        #expect(battle.log.contains {
            $0.attacker == .support(.priest) &&
                $0.skillName == "圣域" &&
                $0.kind == .heal &&
                $0.damage > 0
        })
        #expect(hero.currentHP > hpBeforeSanctuaryTick)
        #expect(supportHPAfterSanctuaryTick > supportHPBeforeSanctuaryTick)
        #expect(battle.heroHP == hero.currentHP)
    }

    @Test func slayerAttackCountSkillExecutesAfterBaseAttacks() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        _ = hero.equipment.equip(Item(
            id: "slayer-attack-count-speed-boots",
            name: "杀手攻击次数测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let monster = Monster(
            id: "training-slayer-attack-count-skill",
            name: "杀手攻击次数训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .slayer))

        for _ in 0..<20 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "粉碎强击" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.contains { $0.skillName == "粉碎强击" && $0.kind == .damage })
    }

    @Test func slamJumpDealsMeleeRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        let monsters = (1...3).map { index in
            Monster(
                id: "slam-jump-\(index)",
                name: "猛击跳跃训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .slayer))

        for _ in 0..<8 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "猛击跳跃" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.filter { $0.skillName == "猛击跳跃" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func increaseAreaOfEffectDamagePassiveBoostsSlamJumpDamage() {
        func makeHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .slayer)
            hero.unlockedPassiveSkillIDs = passiveIDs
            _ = hero.equipment.equip(Item(
                id: "slayer-area-damage-crit-suppression",
                name: "范围伤害测试护符",
                rarity: .common,
                slot: .amulet,
                stats: ItemStats(bonusCritRate: -1.0),
                description: "测试用"
            ))
            return hero
        }

        func firstSlamJumpDamage(for hero: Hero) -> Int {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["60101"], for: .slayer)
            let monsters = (1...3).map { index in
                Monster(
                    id: "slam-jump-area-damage-\(index)",
                    name: "猛击跳跃范围伤害训练 \(index)",
                    hp: 1_000_000,
                    atk: 1,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            }
            let battle = Battle(
                hero: hero,
                monsters: monsters,
                party: HeroParty(primaryClass: .slayer),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            for _ in 0..<8 {
                battle.update(deltaTime: 1)
                if battle.log.contains(where: { $0.skillName == "猛击跳跃" && $0.kind == .damage }) {
                    break
                }
            }
            return battle.log.first { $0.skillName == "猛击跳跃" && $0.kind == .damage }?.damage ?? 0
        }

        let baselineDamage = firstSlamJumpDamage(for: makeHero())
        let boostedDamage = firstSlamJumpDamage(for: makeHero(passiveIDs: ["601051"]))

        #expect(baselineDamage > 0)
        #expect(boostedDamage > baselineDamage)
    }

    @Test func crushingBlowKillTriggersShockwaveDamage() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        _ = hero.equipment.equip(Item(
            id: "crushing-blow-speed-boots",
            name: "粉碎强击测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let monsters = [
            Monster(
                id: "crushing-blow-primary",
                name: "粉碎强击主目标",
                hp: 1_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none"
            ),
            Monster(
                id: "crushing-blow-near-1",
                name: "冲击波邻近目标 1",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none"
            ),
            Monster(
                id: "crushing-blow-near-2",
                name: "冲击波邻近目标 2",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 1,
                goldReward: 1,
                lootTableID: "none"
            )
        ]
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .slayer))

        for _ in 0..<6 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.contains { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage })
        #expect(battle.log.filter { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }.count >= 2)
        #expect(battle.log
            .filter { $0.skillName == "粉碎强击冲击波" && $0.kind == .damage }
            .allSatisfy { $0.damageElement == .physical && $0.delivery == .meleeAOE }
        )
        #expect(battle.enemyStates[0].isDefeated)
        #expect(battle.enemyStates.dropFirst().allSatisfy { !$0.isDefeated && $0.hp < $0.maxHP })
    }

    @Test func generalsRoarAppliesCritCoefficientAndStunsLiveEnemies() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        let monster = Monster(
            id: "generals-roar-training",
            name: "将军怒吼训练木桩",
            hp: 100_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .slayer))

        battle.update(deltaTime: 1)
        let monsterAttackCountBeforeRoar = battle.log.filter { $0.attacker == .monster }.count
        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("将军怒吼"))
        #expect(battle.activeHeroCritRateMultiplier == 6.0)
        #expect(battle.log.contains { $0.skillName == "将军怒吼" && $0.kind == .buff })
        #expect(battle.log.filter { $0.attacker == .monster }.count == monsterAttackCountBeforeRoar)
        #expect(battle.enemyStates.allSatisfy {
            $0.isStunned &&
                EnemyStatusBadge.visible(for: $0).contains(.stunned)
        })
    }

    @Test func supportGeneralsRoarAppliesPartyCritCoefficientAndStun() {
        let hero = Hero()
        hero.changeClass(to: .ranger)
        var party = HeroParty(primaryClass: .ranger, unlockedSlotCount: 2)
        party.setHeroClass(.slayer, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["60301"], for: .slayer)
        let monster = Monster(
            id: "support-generals-roar-training",
            name: "支援将军怒吼训练木桩",
            hp: 100_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("将军怒吼"))
        #expect(battle.activeHeroCritRateMultiplier == 6.0)
        #expect(battle.log.contains {
            $0.attacker == .support(.slayer) &&
                $0.skillName == "将军怒吼" &&
                $0.kind == .buff
        })
        #expect(battle.enemyStates.allSatisfy {
            $0.isStunned &&
                EnemyStatusBadge.visible(for: $0).contains(.stunned)
        })
    }

    @Test func groundSlamDealsRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        _ = hero.equipment.equip(Item(
            id: "ground-slam-speed-boots",
            name: "大地强击测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let monsters = (1...3).map { index in
            Monster(
                id: "ground-slam-\(index)",
                name: "大地强击训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .slayer))

        for _ in 0..<20 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "大地强击" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.filter { $0.skillName == "大地强击" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func groundSlamRockChargesExplodeAfterPhysicalAOE() {
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["60401", "60501"], for: .slayer)

        let hero = Hero()
        hero.changeClass(to: .slayer)
        _ = hero.equipment.equip(Item(
            id: "ground-slam-rock-speed-boots",
            name: "大地强击岩石测试靴",
            rarity: .common,
            slot: .boots,
            stats: ItemStats(bonusSPD: 100),
            description: "测试用"
        ))
        let monsters = (1...3).map { index in
            Monster(
                id: "ground-slam-rock-\(index)",
                name: "大地强击岩石训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: HeroParty(primaryClass: .slayer),
            activeSkillSlotCount: 2,
            activeSkillLoadouts: loadouts
        )

        var rockChargesWereArmed = false
        var maxRockCharges = 0
        var enemyHPAfterRockArm = battle.enemyStates.map(\.hp).reduce(0, +)
        for _ in 0..<80 {
            battle.update(deltaTime: 0.25)
            maxRockCharges = max(maxRockCharges, battle.groundSlamRockCharges)
            if !rockChargesWereArmed, battle.groundSlamRockCharges > 0 {
                rockChargesWereArmed = true
                enemyHPAfterRockArm = battle.enemyStates.map(\.hp).reduce(0, +)
            }
            if rockChargesWereArmed &&
                battle.log.contains(where: { $0.skillName == "大地强击岩石爆炸" && $0.kind == .damage }) {
                break
            }
        }
        let enemyHPAfterRockExplosion = battle.enemyStates.map(\.hp).reduce(0, +)

        #expect(rockChargesWereArmed)
        #expect(maxRockCharges == 3)
        #expect(battle.groundSlamRockCharges == 0)
        #expect(battle.log.contains { $0.skillName == "大地强击岩石" && $0.kind == .buff })
        #expect(battle.log.filter { $0.skillName == "大地强击岩石爆炸" && $0.kind == .damage }.count >= 3)
        #expect(enemyHPAfterRockExplosion < enemyHPAfterRockArm)
    }

    @Test func axeSpinDealsPerSecondRangeDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        let monsters = (1...3).map { index in
            Monster(
                id: "axe-spin-\(index)",
                name: "旋转斧训练 \(index)",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .slayer))

        for _ in 0..<5 {
            battle.update(deltaTime: 1)
            if battle.activeBuffNames.contains("旋转斧") {
                break
            }
        }
        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("旋转斧"))
        #expect(battle.log.filter { $0.skillName == "旋转斧" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(battle.enemyStates.allSatisfy { $0.isBleeding })
        #expect(battle.enemyStates.allSatisfy { EnemyStatusBadge.visible(for: $0).contains(.bleeding) })
        #expect(battle.log.filter { $0.skillName == "旋转斧出血" && $0.kind == .buff }.count >= 3)
    }

    @Test func bloodlustConsumesHalfHPAndAppliesAttackBuff() {
        let hero = Hero()
        hero.changeClass(to: .slayer)
        let monster = Monster(
            id: "bloodlust-training",
            name: "嗜血训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .slayer))
        var hpBeforeBloodlust = hero.currentHP

        for _ in 0..<8 {
            hpBeforeBloodlust = hero.currentHP
            battle.update(deltaTime: 1)
            if battle.activeBuffNames.contains("嗜血") { break }
        }

        #expect(battle.activeBuffNames.contains("嗜血"))
        #expect(battle.activeHeroAttackMultiplier == 41.0)
        #expect(hero.currentHP == hpBeforeBloodlust - hpBeforeBloodlust / 2)
        #expect(battle.heroHP == hero.currentHP)
    }

    @Test func supportBloodlustConsumesSupportHPAndAppliesSupportAttackBuff() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.slayer, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["60601"], for: .slayer)
        let monster = Monster(
            id: "support-bloodlust-training",
            name: "支援嗜血训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )
        let supportSlot = 1
        let hpBeforeBloodlust = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        battle.update(deltaTime: 1)

        let hpAfterBloodlust = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        #expect(battle.activeBuffNames.contains("嗜血"))
        #expect(battle.activeSupportAttackMultiplier(slotIndex: supportSlot) == 41.0)
        #expect(hpAfterBloodlust == hpBeforeBloodlust - hpBeforeBloodlust / 2)
        #expect(battle.log.contains {
            $0.attacker == .support(.slayer) &&
                $0.skillName == "嗜血" &&
                $0.kind == .buff &&
                $0.damage == hpBeforeBloodlust / 2
        })
    }

    @Test func skillDurationIncreasePassiveExtendsBloodlustDuration() {
        func makeHero(passiveIDs: Set<String> = []) -> Hero {
            let hero = Hero()
            hero.changeClass(to: .slayer)
            hero.unlockedPassiveSkillIDs = passiveIDs
            return hero
        }

        func bloodlustRemainingDuration(for hero: Hero) -> TimeInterval {
            var loadouts = ActiveSkillLoadouts()
            loadouts.setSkills(["60601"], for: .slayer)
            let monster = Monster(
                id: "skill-duration-bloodlust-training",
                name: "持续增强嗜血训练木桩",
                hp: 100_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
            let battle = Battle(
                hero: hero,
                monster: monster,
                party: HeroParty(primaryClass: .slayer),
                activeSkillSlotCount: 1,
                activeSkillLoadouts: loadouts
            )
            battle.update(deltaTime: 1)
            return battle.activeHeroBuffRemainingDuration(named: "嗜血") ?? 0
        }

        let baselineDuration = bloodlustRemainingDuration(for: makeHero())
        let boostedDuration = bloodlustRemainingDuration(for: makeHero(passiveIDs: ["601072"]))

        #expect(abs(baselineDuration - 18.0) < 0.0001)
        #expect(boostedDuration > baselineDuration)
        #expect(abs(boostedDuration - 32.4) < 0.0001)
    }

    @Test func quickLoaderAppliesAttackSpeedBuff() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let monster = Monster(
            id: "quick-loader-training",
            name: "装填训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .hunter))

        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("快速装填"))
        #expect(battle.activeHeroAttackSpeedMultiplier == 1.5)
    }

    @Test func explosiveBoltDealsFireExplosionDamageAcrossLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "explosive-bolt-\(index)",
                name: "爆炸弩箭训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .hunter))

        for _ in 0..<8 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "爆炸弩箭" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.filter { $0.skillName == "爆炸弩箭" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func frostBoltDealsColdExplosionDamageAndFreezesLiveWave() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "frost-bolt-\(index)",
                name: "寒霜弩箭训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .hunter))

        battle.update(deltaTime: 1)

        #expect(battle.log.filter { $0.skillName == "寒霜弩箭" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(battle.log.filter { $0.attacker == .monster }.isEmpty)
        #expect(battle.enemyStates.allSatisfy {
            $0.coldStatus == .frozen &&
                EnemyStatusBadge.visible(for: $0).contains(.frozen)
        })
    }

    @Test func supportFrostBoltDealsColdExplosionDamageAndFreezesLiveWave() {
        let hero = Hero()
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.hunter, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["50201"], for: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-frost-bolt-\(index)",
                name: "支援寒霜弩箭训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: hero,
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)

        #expect(battle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "寒霜弩箭" &&
                $0.kind == .damage
        }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(battle.log.filter { $0.attacker == .monster }.isEmpty)
        #expect(battle.enemyStates.allSatisfy {
            $0.coldStatus == .frozen &&
                EnemyStatusBadge.visible(for: $0).contains(.frozen)
        })
    }

    @Test func chargedTrapDetonatesAfterElementalDamage() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "charged-trap-\(index)",
                name: "充能陷阱训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .hunter))

        for _ in 0..<8 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.contains { $0.skillName == "充能陷阱" && $0.kind == .buff })
        #expect(battle.log.filter { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }.count >= 3)
        #expect(battle.log
            .filter { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }
            .allSatisfy { $0.damageElement == .physical && $0.delivery == .trap }
        )
        #expect(battle.activeChargedTrapChargesRemaining == 0)
    }

    @Test func chargedTrapTriggersOnlyFromActualElementalDamageLogs() {
        let physicalHero = Hero()
        physicalHero.changeClass(to: .hunter)
        var physicalLoadouts = ActiveSkillLoadouts()
        physicalLoadouts.setSkills(["50501"], for: .hunter)
        let physicalBattle = Battle(
            hero: physicalHero,
            monsters: [
                Monster(
                    id: "charged-trap-physical-log",
                    name: "充能陷阱物理日志木桩",
                    hp: 10_000_000,
                    atk: 1,
                    def: 0,
                    spd: 1,
                    critRate: 0,
                    xpReward: 0,
                    goldReward: 0,
                    lootTableID: "none"
                )
            ],
            party: HeroParty(primaryClass: .hunter),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: physicalLoadouts
        )
        physicalBattle.activateBattleStatusSnapshotBuffs()

        for _ in 0..<4 {
            physicalBattle.update(deltaTime: 2)
        }

        let physicalLogs = physicalBattle.log.filter { $0.skillName == "弩炮塔" && $0.kind == .damage }
        #expect(!physicalLogs.isEmpty)
        #expect(physicalLogs.allSatisfy {
            $0.damageElement == .physical &&
                $0.delivery == .summonProjectile &&
                $0.attacker.isHeroSide
        })
        #expect(!physicalBattle.log.contains { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage })
        #expect(physicalBattle.activeChargedTrapChargesRemaining == 1)

        let elementalHero = Hero()
        elementalHero.changeClass(to: .sorcerer)
        var elementalLoadouts = ActiveSkillLoadouts()
        elementalLoadouts.setSkills(["30501"], for: .sorcerer)
        let elementalMonsters = (1...3).map { index in
            Monster(
                id: "charged-trap-dot-\(index)",
                name: "充能陷阱持续伤害训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let elementalBattle = Battle(
            hero: elementalHero,
            monsters: elementalMonsters,
            party: HeroParty(primaryClass: .sorcerer),
            activeSkillSlotCount: 1,
            activeSkillLoadouts: elementalLoadouts
        )
        elementalBattle.activateBattleStatusSnapshotBuffs()

        for _ in 0..<6 {
            elementalBattle.update(deltaTime: 2)
            if elementalBattle.log.contains(where: { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }) {
                break
            }
        }

        let elementalLogs = elementalBattle.log.filter { $0.skillName == "暴风雪" && $0.kind == .damage }
        #expect(elementalLogs.count >= 3)
        #expect(elementalLogs.allSatisfy {
            $0.damageElement == .cold &&
                $0.attacker.isHeroSide
        })
        #expect(elementalBattle.log.filter { $0.skillName == "充能陷阱爆炸" && $0.kind == .damage }.count >= 3)
        #expect(elementalBattle.activeChargedTrapChargesRemaining == 0)
    }

    @Test func supportChargedTrapArmsVisibleTrapAndDetonatesFromSupportElementalDamage() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.hunter, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["10601"], for: .knight)
        loadouts.setSkills(["50401", "50101"], for: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-charged-trap-\(index)",
                name: "支援充能陷阱训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: Hero(),
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 2,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 2)

        #expect(battle.log.contains {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "充能陷阱" &&
                $0.kind == .buff
        })
        #expect(battle.activeChargedTrapChargesRemaining == 1)
        #expect(PlayerBattleDeployable.visible(for: battle).contains(.chargedTrap))

        for _ in 0..<8 {
            battle.update(deltaTime: 2)
            if battle.log.contains(where: {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "充能陷阱爆炸" &&
                    $0.kind == .damage
            }) {
                break
            }
        }

        #expect(battle.log.filter {
            $0.attacker == .support(.hunter) &&
                $0.skillName == "充能陷阱爆炸" &&
                $0.kind == .damage
        }.count >= 3)
        #expect(battle.log
            .filter {
                $0.attacker == .support(.hunter) &&
                    $0.skillName == "充能陷阱爆炸" &&
                    $0.kind == .damage
            }
            .allSatisfy { $0.damageElement == .physical && $0.delivery == .trap }
        )
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
        #expect(battle.activeChargedTrapChargesRemaining == 0)
    }

    @Test func crossbowTurretDeploysAndFiresOverTime() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let monster = Monster(
            id: "crossbow-turret-training",
            name: "弩炮塔训练木桩",
            hp: 10_000_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .hunter))

        for _ in 0..<10 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "弩炮塔" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.activeBuffNames.contains("弩炮塔"))
        #expect(battle.log.contains { $0.skillName == "弩炮塔" && $0.kind == .buff })
        #expect(battle.log.contains { $0.skillName == "弩炮塔" && $0.kind == .damage })
        #expect(battle.log
            .filter { $0.skillName == "弩炮塔" && $0.kind == .damage }
            .allSatisfy { $0.damageElement == .physical && $0.delivery == .summonProjectile }
        )
    }

    @Test func shockBoltLodgesAndEmitsLightningCurrent() {
        let hero = Hero()
        hero.changeClass(to: .hunter)
        let monsters = (1...3).map { index in
            Monster(
                id: "shock-bolt-\(index)",
                name: "电击弩箭训练 \(index)",
                hp: 10_000_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .hunter))

        for _ in 0..<20 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "电击弩箭电流" && $0.kind == .damage }) {
                break
            }
        }

        #expect(battle.log.contains { $0.skillName == "电击弩箭" && $0.kind == .damage })
        #expect(battle.activeBuffNames.contains("电击弩箭电流"))
        #expect(battle.log.filter { $0.skillName == "电击弩箭电流" && $0.kind == .damage }.count >= 3)
    }

    @Test func utilitySkillCanHealHero() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        hero.takeDamage(40)
        let woundedHP = hero.currentHP
        let monster = Monster(
            id: "training-heal",
            name: "治疗训练木桩",
            hp: 1_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .priest))

        battle.update(deltaTime: 1)

        #expect(battle.log.contains { $0.skillName == "治愈" && $0.kind == .heal })
        #expect(hero.currentHP > woundedHP)
        #expect(battle.heroHP == hero.currentHP)
    }

    @Test func healCanTargetWoundedLivingSupportAlly() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        let monster = Monster(
            id: "training-support-heal",
            name: "支援治疗训练木桩",
            hp: 1_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: HeroParty(primaryClass: .priest, unlockedSlotCount: 3)
        )
        let supportSlot = 1
        let supportMaxHP = battle.supportStates.first { $0.slotIndex == supportSlot }?.maxHP ?? 0
        _ = battle.damageSupportMember(slotIndex: supportSlot, amount: max(1, supportMaxHP / 2))
        let woundedSupportHP = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0

        battle.update(deltaTime: 1)

        let healedSupportHP = battle.supportStates.first { $0.slotIndex == supportSlot }?.hp ?? 0
        #expect(battle.log.contains { $0.skillName == "治愈" && $0.kind == .heal })
        #expect(healedSupportHP > woundedSupportHP)
    }

    @Test func resurrectionRevivesFallenSupportMemberWithSourceHPPercent() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        let monster = Monster(
            id: "resurrection-training",
            name: "复活训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(
            hero: hero,
            monster: monster,
            party: HeroParty(primaryClass: .priest, unlockedSlotCount: 3)
        )
        let targetSlot = 2
        let targetMaxHP = battle.supportStates.first { $0.slotIndex == targetSlot }?.maxHP ?? 0

        let defeated = battle.damageSupportMember(slotIndex: targetSlot, amount: targetMaxHP + 1)
        #expect(defeated)
        #expect(battle.supportStates.first { $0.slotIndex == targetSlot }?.isDefeated == true)

        for _ in 0..<6 {
            battle.update(deltaTime: 1)
            if battle.log.contains(where: { $0.skillName == "复活" && $0.kind == .heal }) {
                break
            }
        }

        let revivedState = battle.supportStates.first { $0.slotIndex == targetSlot }
        #expect(revivedState?.isDefeated == false)
        #expect(revivedState?.hp == targetMaxHP * 3)
        #expect(battle.log.contains { $0.skillName == "复活" && $0.kind == .heal && $0.damage == targetMaxHP * 3 })
    }

    @Test func supportPriestResurrectionRevivesAnotherFallenSupportMember() {
        let monster = Monster(
            id: "support-resurrection-training",
            name: "支援复活训练木桩",
            hp: 100_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 3)
        party.setHeroClass(.priest, atSlot: 1)
        party.setHeroClass(.ranger, atSlot: 2)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["40601"], for: .priest)
        let battle = Battle(
            hero: Hero(),
            monster: monster,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )
        let targetSlot = 2
        let targetMaxHP = battle.supportStates.first { $0.slotIndex == targetSlot }?.maxHP ?? 0

        let defeated = battle.damageSupportMember(slotIndex: targetSlot, amount: targetMaxHP + 1)
        #expect(defeated)

        battle.update(deltaTime: 1)

        let revivedState = battle.supportStates.first { $0.slotIndex == targetSlot }
        #expect(revivedState?.isDefeated == false)
        #expect(revivedState?.hp == targetMaxHP * 3)
        #expect(battle.log.contains {
            $0.attacker == .support(.priest) &&
                $0.skillName == "复活" &&
                $0.kind == .heal &&
                $0.damage == targetMaxHP * 3
        })
        #expect(!battle.log.contains { $0.attacker == .hero && $0.skillName == "复活" })
    }

    @Test func priestContinuousBlessingsModifyBattleAndBaseAttackSkillTriggers() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        let monster = Monster(
            id: "blessing-training",
            name: "祝福训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .priest))

        #expect(battle.continuousSkillNames == ["力量祝福", "守护祝福"])
        #expect(battle.continuousAttackMultiplier == 6.0)
        #expect(battle.continuousIncomingDamageMultiplier == 0.9)

        #expect(Battle.modifiedIncomingDamage(
            100,
            continuousIncomingDamageMultiplier: battle.continuousIncomingDamageMultiplier,
            passiveDamageReduction: 0,
            passiveDamageAbsorption: 0,
            damageElement: .fire
        ) == 90)
        #expect(Battle.modifiedIncomingDamage(
            100,
            continuousIncomingDamageMultiplier: battle.continuousIncomingDamageMultiplier,
            passiveDamageReduction: 0,
            passiveDamageAbsorption: 0,
            damageElement: .physical
        ) == 100)
    }

    @Test func supportPriestContinuousBlessingsModifyPartyBattleStatsWhenEquipped() {
        let hero = Hero()
        let party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        let monster = Monster(
            id: "support-blessing-training",
            name: "支援祝福训练木桩",
            hp: 10_000,
            atk: 100,
            def: 0,
            spd: 10,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )

        let oneSlotBattle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: HeroSkills.defaultActiveSkillSlotCount
        )
        #expect(oneSlotBattle.continuousSkillNames.isEmpty)
        #expect(oneSlotBattle.continuousAttackMultiplier == 1.0)
        #expect(oneSlotBattle.continuousIncomingDamageMultiplier == 1.0)

        let fullSupportLoadoutBattle = Battle(
            hero: hero,
            monster: monster,
            party: party,
            activeSkillSlotCount: HeroSkills.maximumModeledActiveSkillSlots
        )

        #expect(fullSupportLoadoutBattle.party.supportMembers.map(\.heroClass) == [.priest])
        #expect(fullSupportLoadoutBattle.continuousSkillNames == ["力量祝福", "守护祝福"])
        #expect(fullSupportLoadoutBattle.continuousAttackMultiplier == 6.0)
        #expect(fullSupportLoadoutBattle.continuousIncomingDamageMultiplier == 0.9)
        #expect(PlayerBattleStatusBadge.visible(for: fullSupportLoadoutBattle).contains(.mightBlessing))
        #expect(PlayerBattleStatusBadge.visible(for: fullSupportLoadoutBattle).contains(.wardingBlessing))
    }

    @Test func wrathOfHeavenAddsLightningDamageToLaterHeroAttacks() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        let monster = Monster(
            id: "wrath-buff-training",
            name: "天堂之怒训练木桩",
            hp: 10_000,
            atk: 1,
            def: 0,
            spd: 1,
            critRate: 0,
            xpReward: 0,
            goldReward: 0,
            lootTableID: "none"
        )
        let battle = Battle(hero: hero, monster: monster, party: HeroParty(primaryClass: .priest))

        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)
        let wrathDamageBeforeAttack = battle.log.filter { $0.skillName == "天堂之怒" && $0.kind == .damage }.count
        #expect(battle.activeBuffNames.contains("天堂之怒"))
        for _ in 0..<4 {
            if battle.log.filter({ $0.skillName == "天堂之怒" && $0.kind == .damage }).count > wrathDamageBeforeAttack {
                break
            }
            battle.update(deltaTime: 1)
        }
        #expect(battle.log.filter { $0.skillName == "天堂之怒" && $0.kind == .damage }.count > wrathDamageBeforeAttack)
    }

    @Test func wrathOfHeavenAddsRangeDamageToHeroAttacks() {
        let hero = Hero()
        hero.changeClass(to: .priest)
        let monsters = (1...3).map { index in
            Monster(
                id: "wrath-wave-\(index)",
                name: "天堂之怒范围训练 \(index)",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .priest))

        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)
        battle.update(deltaTime: 1)

        #expect(battle.activeBuffNames.contains("天堂之怒"))
        #expect(battle.log.filter { $0.skillName == "天堂之怒" && $0.kind == .damage }.count >= 3)
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func supportWrathOfHeavenAddsLightningRangeDamageToSupportAttacks() {
        var party = HeroParty(primaryClass: .knight, unlockedSlotCount: 2)
        party.setHeroClass(.priest, atSlot: 1)
        var loadouts = ActiveSkillLoadouts()
        loadouts.setSkills(["40301"], for: .priest)
        let monsters = (1...3).map { index in
            Monster(
                id: "support-wrath-wave-\(index)",
                name: "支援天堂之怒范围训练 \(index)",
                hp: 10_000,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(
            hero: Hero(),
            monsters: monsters,
            party: party,
            activeSkillSlotCount: 1,
            activeSkillLoadouts: loadouts
        )

        battle.update(deltaTime: 1)

        let buffIndex = battle.log.firstIndex {
            $0.attacker == .support(.priest) && $0.skillName == "天堂之怒" && $0.kind == .buff
        }
        let baseAttackIndex = battle.log.firstIndex {
            $0.attacker == .support(.priest) && $0.skillName == nil && $0.kind == .damage
        }
        let wrathDamageIndex = battle.log.firstIndex {
            $0.attacker == .support(.priest) && $0.skillName == "天堂之怒" && $0.kind == .damage
        }
        let wrathDamageLogs = battle.log.filter {
            $0.attacker == .support(.priest) && $0.skillName == "天堂之怒" && $0.kind == .damage
        }

        #expect(battle.activeBuffNames.contains("天堂之怒"))
        #expect(buffIndex != nil)
        #expect(baseAttackIndex != nil)
        #expect(wrathDamageIndex != nil)
        #expect(buffIndex! < baseAttackIndex!)
        #expect(baseAttackIndex! < wrathDamageIndex!)
        #expect(wrathDamageLogs.count >= 3)
        #expect(wrathDamageLogs.allSatisfy { $0.damageElement == .lightning && $0.delivery == .rangeAOE })
        #expect(battle.enemyStates.allSatisfy { $0.hp < $0.maxHP })
    }

    @Test func battleCanClearMultipleWaveEncounters() {
        let hero = Hero()
        let monsters = (1...3).map { index in
            Monster(
                id: "wave-\(index)",
                name: "波次训练 \(index)",
                hp: 1,
                atk: 1,
                def: 0,
                spd: 1,
                critRate: 0,
                xpReward: index * 10,
                goldReward: index * 5,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .knight))

        #expect(battle.waveMonsters.map(\.id) == ["wave-1", "wave-2", "wave-3"])
        #expect(battle.remainingWaveMonsters.map(\.id) == ["wave-1", "wave-2", "wave-3"])
        #expect(battle.upcomingWaveMonsters.map(\.id) == ["wave-2", "wave-3"])
        #expect(battle.enemyStates.count == 3)
        #expect(battle.enemyStates.allSatisfy { !$0.isDefeated && $0.hp == $0.maxHP })

        for _ in 0..<12 {
            battle.update(deltaTime: 1)
            if battle.isOver { break }
        }

        guard case .victory(let rewards) = battle.result else {
            Issue.record("Wave battle should finish with victory")
            return
        }
        #expect(rewards.encountersCleared == 3)
        #expect(rewards.xp == 60)
        #expect(rewards.gold == 30)
        #expect(battle.currentMonsterNumber == 3)
        #expect(battle.monsterCount == 3)
    }

    @Test func allAliveWaveEnemiesCanAttackInOneTick() {
        let hero = Hero()
        let monsters = (1...3).map { index in
            Monster(
                id: "group-\(index)",
                name: "群体训练 \(index)",
                hp: 10_000,
                atk: 12,
                def: 0,
                spd: 10,
                critRate: 0,
                xpReward: 0,
                goldReward: 0,
                lootTableID: "none"
            )
        }
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)

        #expect(battle.log.filter { $0.attacker == .monster }.count == 3)
        #expect(battle.heroHP < hero.maxHP)
    }

    @Test func defeatingOneEnemyKeepsRestOfWaveActive() {
        let hero = Hero()
        let monsters = [
            Monster(id: "split-1", name: "脆弱敌人", hp: 1, atk: 1, def: 0, spd: 1, critRate: 0, xpReward: 1, goldReward: 1, lootTableID: "none"),
            Monster(id: "split-2", name: "坚韧敌人 2", hp: 10_000, atk: 1, def: 0, spd: 1, critRate: 0, xpReward: 2, goldReward: 2, lootTableID: "none"),
            Monster(id: "split-3", name: "坚韧敌人 3", hp: 10_000, atk: 1, def: 0, spd: 1, critRate: 0, xpReward: 3, goldReward: 3, lootTableID: "none")
        ]
        let battle = Battle(hero: hero, monsters: monsters, party: HeroParty(primaryClass: .knight))

        battle.update(deltaTime: 1)

        #expect(battle.enemyStates[0].isDefeated)
        #expect(battle.remainingWaveMonsters.map(\.id) == ["split-2", "split-3"])
        #expect(battle.activeEnemyState?.monster.id == "split-2")
        #expect(!battle.isOver)
    }
}

@Suite struct GameStatisticsTests {
    @Test func recordVictoryAccumulates() {
        var stats = GameStatistics()
        let rewards = BattleResult.Rewards(xp: 10, gold: 25, lootItem: nil)
        stats.recordVictory(
            rewards: rewards,
            lootStored: false,
            chapter: .dungeon,
            difficulty: .nightmare,
            stage: StageDefinition.stage(act: .dungeon, number: 3)
        )
        #expect(stats.monstersKilled == 1)
        #expect(stats.totalGoldEarned == 25)
        #expect(stats.highestChapter == Chapter.dungeon.rawValue)
        #expect(stats.highestDifficulty == Difficulty.nightmare.rawValue)
        #expect(stats.highestStageCode == "2-3")
        #expect(stats.itemsFound == 0, "No loot means no item count")
    }

    @Test func recordVictoryCountsOnlyStoredLoot() {
        var stats = GameStatistics()
        let item = Item(id: "i1", name: "测试", rarity: .common, slot: .weapon, stats: ItemStats(), description: "")
        let rewards = BattleResult.Rewards(xp: 1, gold: 1, lootItem: item)
        stats.recordVictory(rewards: rewards, lootStored: true, chapter: .forest, difficulty: .normal)
        #expect(stats.itemsFound == 1)
        // 背包满导致物品未入包 → 不计数
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .forest, difficulty: .normal)
        #expect(stats.itemsFound == 1, "Loot lost to a full inventory must not count")
    }

    @Test func recordVictoryCountsWaveEncountersAndStoredLoot() {
        var stats = GameStatistics()
        let first = Item(id: "i1", name: "测试", rarity: .common, slot: .weapon, stats: ItemStats(), description: "")
        let second = Item(id: "i2", name: "测试 2", rarity: .common, slot: .armor, stats: ItemStats(), description: "")
        let rewards = BattleResult.Rewards(xp: 3, gold: 7, lootItems: [first, second], encountersCleared: 3)

        stats.recordVictory(rewards: rewards, lootStoredCount: 2, chapter: .forest, difficulty: .normal)

        #expect(stats.monstersKilled == 3)
        #expect(stats.itemsFound == 2)
        #expect(stats.totalGoldEarned == 7)
    }

    @Test func highWaterMarksNeverDecrease() {
        var stats = GameStatistics()
        let rewards = BattleResult.Rewards(xp: 1, gold: 1, lootItem: nil)
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .volcano, difficulty: .torment, stage: StageDefinition.stage(act: .volcano, number: 10))
        stats.recordVictory(rewards: rewards, lootStored: false, chapter: .forest, difficulty: .normal, stage: StageDefinition.stage(act: .forest, number: 1))
        #expect(stats.highestChapter == Chapter.volcano.rawValue)
        #expect(stats.highestDifficulty == Difficulty.torment.rawValue)
        #expect(stats.highestStageCode == "3-10")
    }

    @Test func recordDefeatCountsDeath() {
        var stats = GameStatistics()
        stats.recordDefeat()
        #expect(stats.deaths == 1)
    }
}
