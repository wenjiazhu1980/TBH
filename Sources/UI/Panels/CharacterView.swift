import SwiftUI

/// 角色面板 — 显示英雄像素精灵
struct CharacterView: View {
    @ObservedObject var hero: Hero
    let party: HeroParty
    let activeSkillLoadouts: ActiveSkillLoadouts
    let activeSkillSlotCount: Int
    let onClassChange: (HeroClass) -> Void
    let onPartyMemberChange: (Int, HeroClass) -> Void
    let partySlotUnlockCost: (Int) -> Int?
    let canUnlockPartySlot: (Int) -> Bool
    let onPartySlotUnlock: (Int) -> Void
    let onActiveSkillChange: (HeroClass, Int, String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // 英雄立绘
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        // 像素英雄精灵
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.black.opacity(0.34),
                                            Color.accentColor.opacity(0.12)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 116, height: 132)

                            Ellipse()
                                .fill(Color.black.opacity(0.28))
                                .frame(width: 70, height: 12)
                                .offset(y: -8)

                            PixelSprite(
                                imageName: GameArt.heroSpriteName(for: hero.heroClass),
                                size: CGSize(width: 90, height: 118)
                            )
                            .padding(.bottom, 14)
                        }
                        Text(hero.name)
                            .font(.headline)
                        HStack {
                            Text("Lv.\(hero.level)")
                                .font(.caption)
                            Text(hero.heroClass.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)

                // 基础信息
                GroupBox("基础属性") {
                    VStack(alignment: .leading, spacing: 6) {
                        Picker(
                            "职业",
                            selection: Binding(
                                get: { hero.heroClass },
                                set: { onClassChange($0) }
                            )
                        ) {
                            ForEach(HeroClass.allCases, id: \.self) { heroClass in
                                Text(heroClass.rawValue).tag(heroClass)
                            }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)

                        StatRow(label: "等级", value: "\(hero.level)")
                        StatRow(label: "职业", value: hero.heroClass.rawValue)
                        StatRow(label: "定位", value: hero.heroClass.role)
                        StatRow(label: "梯度", value: hero.heroClass.grade)
                        StatRow(label: "经验", value: "\(hero.currentXP) / \(hero.xpForNextLevel())")
                        StatRow(label: "金币", value: "\(hero.gold) G")
                    }
                    .padding(.vertical, 4)
                }

                // 战斗属性
                GroupBox("战斗属性") {
                    VStack(alignment: .leading, spacing: 6) {
                        StatRow(label: "生命", value: "\(hero.maxHP)")
                        StatRow(label: "攻击", value: "\(hero.attack)")
                        StatRow(label: "防御", value: "\(hero.defense)")
                        StatRow(label: "速度", value: "\(hero.speed)")
                        StatRow(label: "暴击率", value: String(format: "%.1f%%", hero.critRate * 100))
                        StatRow(label: "暴击伤害", value: String(format: "%.0f%%", hero.critDamage * 100))
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("小队") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("上阵 \(party.activeCount)/\(HeroParty.maxSlots)")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            Spacer()
                            Text("支援攻击 +\(party.supportAttackPower(heroLevel: hero.level))")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                        }

                        ForEach(party.members) { member in
                            PartySlotRow(
                                member: member,
                                heroLevel: hero.level,
                                unlockCost: partySlotUnlockCost(member.slotIndex),
                                canUnlock: canUnlockPartySlot(member.slotIndex),
                                onUnlock: { onPartySlotUnlock(member.slotIndex) },
                                onClassChange: { onPartyMemberChange(member.slotIndex, $0) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("主动技能槽") {
                    ActiveSkillLoadoutEditor(
                        hero: hero,
                        activeSkillLoadouts: activeSkillLoadouts,
                        activeSkillSlotCount: activeSkillSlotCount,
                        onActiveSkillChange: onActiveSkillChange
                    )
                    .padding(.vertical, 4)
                }

                GroupBox("职业技能") {
                    VStack(alignment: .leading, spacing: 6) {
                        let equippedSkillIDs = Set(activeSkillLoadouts.activeSkills(
                            for: hero.heroClass,
                            heroLevel: hero.level,
                            slotCount: activeSkillSlotCount
                        ).map(\.id))
                        ForEach(HeroSkills.named(for: hero.heroClass)) { skill in
                            SkillRow(skill: skill, isEquipped: equippedSkillIDs.contains(skill.id))
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 装备栏
                GroupBox("装备") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(EquipSlot.allCases, id: \.self) { slot in
                            EquipmentRow(slot: slot, item: hero.equipment.item(in: slot))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}

private struct SkillRow: View {
    let skill: Skill
    let isEquipped: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            PixelSprite(
                imageName: GameArt.skillIconName(for: skill),
                size: CGSize(width: 24, height: 24)
            )
            .frame(width: 24, height: 24)
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(skill.name)
                        .font(.system(size: 10, weight: .semibold))
                    if isEquipped {
                        Text("已装备")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.accentColor)
                    }
                    Spacer()
                    Text(skill.id)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Text(skill.description)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct ActiveSkillLoadoutEditor: View {
    @ObservedObject var hero: Hero
    let activeSkillLoadouts: ActiveSkillLoadouts
    let activeSkillSlotCount: Int
    let onActiveSkillChange: (HeroClass, Int, String) -> Void

    private var availableSkills: [Skill] {
        HeroSkills.named(for: hero.heroClass)
            .filter { hero.level >= $0.unlockLevel }
    }

    private var activeSkills: [Skill] {
        activeSkillLoadouts.activeSkills(
            for: hero.heroClass,
            heroLevel: hero.level,
            slotCount: activeSkillSlotCount
        )
    }

    private var resolvedSlotCount: Int {
        min(max(activeSkillSlotCount, HeroSkills.defaultActiveSkillSlotCount), HeroSkills.maximumModeledActiveSkillSlots)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(resolvedSlotCount)/\(HeroSkills.maximumModeledActiveSkillSlots)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                Spacer()
                Text(hero.heroClass.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            if availableSkills.isEmpty {
                Text("—")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
            } else {
                ForEach(0..<resolvedSlotCount, id: \.self) { slotIndex in
                    ActiveSkillSlotPicker(
                        slotIndex: slotIndex,
                        selectedSkillID: selectedSkillID(at: slotIndex),
                        selectedSkillIDs: activeSkills.map(\.id),
                        availableSkills: availableSkills,
                        onSkillChange: { skillID in
                            onActiveSkillChange(hero.heroClass, slotIndex, skillID)
                        }
                    )
                }
            }
        }
    }

    private func selectedSkillID(at slotIndex: Int) -> String {
        if activeSkills.indices.contains(slotIndex) {
            return activeSkills[slotIndex].id
        }
        return availableSkills.first?.id ?? ""
    }
}

private struct ActiveSkillSlotPicker: View {
    let slotIndex: Int
    let selectedSkillID: String
    let selectedSkillIDs: [String]
    let availableSkills: [Skill]
    let onSkillChange: (String) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text("槽 \(slotIndex + 1)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 34, alignment: .leading)

            Picker("", selection: Binding(
                get: { selectedSkillID },
                set: { onSkillChange($0) }
            )) {
                ForEach(availableSkills) { skill in
                    HStack {
                        Text(skill.name)
                        Text(skill.id)
                            .foregroundColor(.secondary)
                    }
                    .tag(skill.id)
                    .disabled(selectedSkillIDs.contains(skill.id) && skill.id != selectedSkillID)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .controlSize(.mini)

            if let skill = availableSkills.first(where: { $0.id == selectedSkillID }) {
                PixelSprite(
                    imageName: GameArt.skillIconName(for: skill),
                    size: CGSize(width: 20, height: 20)
                )
                .frame(width: 20, height: 20)
            }
        }
    }
}

private struct PartySlotRow: View {
    let member: PartyMember
    let heroLevel: Int
    let unlockCost: Int?
    let canUnlock: Bool
    let onUnlock: () -> Void
    let onClassChange: (HeroClass) -> Void

    var body: some View {
        HStack(spacing: 8) {
            PixelSprite(
                imageName: GameArt.heroSpriteName(for: member.heroClass),
                size: CGSize(width: 30, height: 34)
            )
            .opacity(member.isUnlocked ? 1 : 0.35)
            .frame(width: 30, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(member.displayName)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    if !member.isUnlocked {
                        Text("锁定")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.orange)
                    } else if member.isPrimary {
                        Text("主位")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.accentColor)
                    } else {
                        Text("+\(member.supportAttackPower(heroLevel: heroLevel))")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                Text(member.heroClass.role)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if member.isUnlocked {
                Picker("", selection: Binding(
                    get: { member.heroClass },
                    set: { onClassChange($0) }
                )) {
                    ForEach(HeroClass.allCases, id: \.self) { heroClass in
                        Text(heroClass.rawValue).tag(heroClass)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .controlSize(.mini)
                .frame(width: 72)
            } else if let unlockCost {
                Button {
                    onUnlock()
                } label: {
                    Label("\(unlockCost.formatted())G", systemImage: "lock.open.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .disabled(!canUnlock)
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
    }
}

struct EquipmentRow: View {
    let slot: EquipSlot
    let item: Item?

    var body: some View {
        HStack(spacing: 8) {
            // 槽位图标
            if let item {
                PixelSprite(
                    imageName: GameArt.itemIconName(for: item),
                    size: CGSize(width: 24, height: 24)
                )
                .frame(width: 24, height: 24)
            } else {
                PixelSprite(
                    imageName: GameArt.itemIconName(for: slot),
                    size: CGSize(width: 22, height: 22)
                )
                .opacity(0.45)
                .frame(width: 24, height: 24)
            }

            Text(slot.rawValue)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .leading)

            if let item = item {
                Text(item.name)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: item.rarity.color))
            } else {
                Text("— 空 —")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            Spacer()
        }
    }
}
