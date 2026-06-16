#!/usr/bin/env bash
set -euo pipefail

hero_swift="${HERO_SWIFT:-Sources/Game/Character/Hero.swift}"
skills_swift="${SKILLS_SWIFT:-Sources/Game/Character/Skills.swift}"
rune_swift="${RUNE_SWIFT:-Sources/Game/Progress/RuneTree.swift}"
stage_swift="${STAGE_SWIFT:-Sources/Game/Progress/Stage.swift}"
difficulty_swift="${DIFFICULTY_SWIFT:-Sources/Game/Progress/Difficulty.swift}"
chapter_swift="${CHAPTER_SWIFT:-Sources/Game/Progress/Chapter.swift}"
item_swift="${ITEM_SWIFT:-Sources/Game/Inventory/Item.swift}"
inventory_swift="${INVENTORY_SWIFT:-Sources/Game/Inventory/Inventory.swift}"
loot_table_swift="${LOOT_TABLE_SWIFT:-Sources/Game/Inventory/LootTable.swift}"
game_loop_swift="${GAME_LOOP_SWIFT:-Sources/Game/Engine/GameLoop.swift}"
save_manager_swift="${SAVE_MANAGER_SWIFT:-Sources/Persistence/SaveManager.swift}"
battle_swift="${BATTLE_SWIFT:-Sources/Game/Combat/Battle.swift}"
monster_swift="${MONSTER_SWIFT:-Sources/Game/Combat/Monster.swift}"
battle_view_swift="${BATTLE_VIEW_SWIFT:-Sources/UI/Panels/BattleView.swift}"
inventory_view_swift="${INVENTORY_VIEW_SWIFT:-Sources/UI/Panels/InventoryView.swift}"
battle_scene_snapshot_swift="${BATTLE_SCENE_SNAPSHOT_SWIFT:-Sources/App/BattleSceneSnapshot.swift}"
self_test_swift="${SELF_TEST_SWIFT:-Sources/App/SelfTest.swift}"
battle_scene_audit_sh="${BATTLE_SCENE_AUDIT_SH:-scripts/audit-local-battle-scene.sh}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"
settings_swift="${SETTINGS_SWIFT:-Sources/UI/Panels/SettingsView.swift}"
source_gear_manifest="${SOURCE_GEAR_MANIFEST:-Sources/Resources/Extracted/source_gear_icons.tsv}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$hero_swift" "$skills_swift" "$rune_swift" "$stage_swift" "$difficulty_swift" "$chapter_swift" "$item_swift" "$inventory_swift" "$loot_table_swift" "$game_loop_swift" "$save_manager_swift" "$battle_swift" "$monster_swift" "$battle_view_swift" "$inventory_view_swift" "$battle_scene_snapshot_swift" "$self_test_swift" "$battle_scene_audit_sh" "$game_art_swift" "$settings_swift" "$source_gear_manifest" <<'PY'
import re
import sys
from collections import Counter
from pathlib import Path

hero_path = Path(sys.argv[1])
skills_path = Path(sys.argv[2])
rune_path = Path(sys.argv[3])
stage_path = Path(sys.argv[4])
difficulty_path = Path(sys.argv[5])
chapter_path = Path(sys.argv[6])
item_path = Path(sys.argv[7])
inventory_path = Path(sys.argv[8])
loot_table_path = Path(sys.argv[9])
game_loop_path = Path(sys.argv[10])
save_manager_path = Path(sys.argv[11])
battle_path = Path(sys.argv[12])
monster_path = Path(sys.argv[13])
battle_view_path = Path(sys.argv[14])
inventory_view_path = Path(sys.argv[15])
battle_scene_snapshot_path = Path(sys.argv[16])
self_test_path = Path(sys.argv[17])
battle_scene_audit_path = Path(sys.argv[18])
game_art_path = Path(sys.argv[19])
settings_path = Path(sys.argv[20])
source_gear_manifest_path = Path(sys.argv[21])

for path in [
    hero_path,
    skills_path,
    rune_path,
    stage_path,
    difficulty_path,
    chapter_path,
    item_path,
    inventory_path,
    loot_table_path,
    game_loop_path,
    save_manager_path,
    battle_path,
    monster_path,
    battle_view_path,
    inventory_view_path,
    battle_scene_snapshot_path,
    self_test_path,
    battle_scene_audit_path,
    game_art_path,
    settings_path,
    source_gear_manifest_path,
]:
    if not path.is_file():
        print(f"required source file does not exist: {path}", file=sys.stderr)
        sys.exit(2)

hero_source = hero_path.read_text(encoding="utf-8")
skills_source = skills_path.read_text(encoding="utf-8")
rune_source = rune_path.read_text(encoding="utf-8")
stage_source = stage_path.read_text(encoding="utf-8")
difficulty_source = difficulty_path.read_text(encoding="utf-8")
chapter_source = chapter_path.read_text(encoding="utf-8")
item_source = item_path.read_text(encoding="utf-8")
inventory_source = inventory_path.read_text(encoding="utf-8")
loot_table_source = loot_table_path.read_text(encoding="utf-8")
game_loop_source = game_loop_path.read_text(encoding="utf-8")
save_manager_source = save_manager_path.read_text(encoding="utf-8")
battle_source = battle_path.read_text(encoding="utf-8")
monster_source = monster_path.read_text(encoding="utf-8")
battle_view_source = battle_view_path.read_text(encoding="utf-8")
inventory_view_source = inventory_view_path.read_text(encoding="utf-8")
battle_scene_snapshot_source = battle_scene_snapshot_path.read_text(encoding="utf-8")
self_test_source = self_test_path.read_text(encoding="utf-8")
battle_scene_audit_source = battle_scene_audit_path.read_text(encoding="utf-8")
game_art_source = game_art_path.read_text(encoding="utf-8")
settings_source = settings_path.read_text(encoding="utf-8")
source_gear_manifest_lines = [
    line
    for line in source_gear_manifest_path.read_text(encoding="utf-8").splitlines()
    if line.strip()
]

ORIGINAL = {
    "hero_classes": 6,
    "active_skills": 106,
    "passive_skills": 108,
    "rune_nodes": 197,
    "rune_connections": 195,
    "rune_next_out_degree_distribution": {0: 79, 1: 63, 2: 35, 3: 18, 4: 2},
    "rune_previous_refs": 11,
    "rune_previous_reference_map": {
        "10": ["11001", "11002"],
        "11": ["13002"],
        "21": ["23", "24", "26", "27"],
        "101": ["1031"],
        "401": ["4031"],
        "1031": ["1071"],
        "13002": ["15001"],
    },
    "rune_max_level_distribution": {1: 62, 2: 1, 3: 43, 5: 89, 10: 2},
    "rune_icon_distribution": {
        "AdditionalExp": 2,
        "AdditionalExpActBoss": 3,
        "AdditionalExpNormalMonster": 2,
        "AdditionalExpStageBoss": 7,
        "AdditionalGold": 2,
        "AdditionalGoldActBoss": 3,
        "AdditionalGoldNormalMonster": 3,
        "AdditionalGoldStageBoss": 7,
        "AllHeroArmor": 3,
        "AllHeroArmorPercent": 2,
        "AllHeroAttackDamage": 4,
        "AllHeroAttackDamagePercent": 3,
        "AllHeroAttackSpeed": 3,
        "AllHeroMoveSpeed": 5,
        "CubeAlchemyGoldPercent": 4,
        "CubeExpPercent": 4,
        "DropChanceNormalChest": 15,
        "DropChanceStageBossChest": 14,
        "IncreaseExpAmount": 7,
        "IncreaseGoldAmount": 7,
        "MaxAmountActBossChest": 10,
        "MaxAmountNormalChest": 15,
        "MaxAmountStageBossChest": 13,
        "MaxInventorySlot": 26,
        "OfflineRewardExpPercent": 5,
        "OfflineRewardGoldPercent": 5,
        "OpenAllTypeChestAllAtOnce": 1,
        "OpenOneTypeChestAllAtOnce": 1,
        "ReduceAutoOpenActBossChestTime": 2,
        "ReduceAutoOpenNormalChestTime": 4,
        "ReduceAutoOpenStageBossChestTime": 4,
        "UnlockArrangeSlotCount": 2,
        "UnlockAutoOpenActBossChest": 1,
        "UnlockAutoOpenNormalChest": 1,
        "UnlockAutoOpenStageBossChest": 1,
        "UnlockOfflineReward": 1,
        "UnlockSkillSlotCount": 1,
        "UnlockStashPageCount": 3,
        "WaveCountReduction": 1,
    },
    "acts": 3,
    "stages": 30,
    "difficulty_stage_rows": 120,
    "difficulty_tiers": 4,
    "item_rarities": 10,
    "equipment_types": 20,
    "item_records": 5760,
    "material_rows": 115,
    "material_categories": 6,
    "stage_chests": 59,
    "synthesis_inputs": 9,
}

CURRENT_BASELINE = {
    "hero_classes": 6,
    "source_skill_catalog": 106,
    "source_skill_review_rows": 106,
    "active_skills": 36,
    "modeled_skill_level_tables": 36,
    "passive_skills": 108,
    "passive_runtime_stat_hooks": 30,
    "source_rune_nodes": 197,
    "source_rune_connections": 195,
    "source_rune_previous_refs": 11,
    "interactive_rune_nodes": 15,
    "runtime_rune_source_nodes": 15,
    "data_only_rune_source_nodes": 182,
    "source_rune_review_rows": 197,
    "runtime_rune_icon_families": 14,
    "unmodeled_only_rune_icon_families": 25,
    "rune_required_hero_level": 3,
    "rune_party_slot_verified_gold_total": 200000,
    "rune_direct_party_slot_3_gold": 200000,
    "rune_active_skill_slot_count": 2,
    "rune_inventory_slot_bonus": 10,
    "rune_offline_boost_percent": 10,
    "rune_unverified_cost_nodes": 13,
    "rune_approximate_cost_nodes": 1,
    "direct_inventory_expansion_slot_bonus": 10,
    "direct_inventory_expansion_base_gold_cost": 50000,
    "direct_inventory_expansion_first_gold_cost": 50000,
    "direct_inventory_expansion_second_gold_cost": 100000,
    "worse_equipment_handling_modes": 3,
    "acts": 3,
    "display_stages": 30,
    "runtime_stage_rows": 120,
    "source_stage_review_rows": 120,
    "difficulty_tiers": 4,
    "item_rarities": 10,
    "equipment_types": 20,
    "source_gear_type_rows": 20,
    "source_gear_entry_aggregate": 5760,
    "source_gear_level_progressions": 396,
    "source_material_rows": 115,
    "source_material_categories": 6,
    "source_stage_chest_rows": 59,
    "equip_slots": 10,
    "soul_stones": 4,
    "synthesis_inputs": 9,
    "player_status_badges": 16,
    "player_active_status_mappings": 14,
    "player_continuous_status_mappings": 2,
    "player_deployable_markers": 3,
    "battle_scene_render_width_px": 796,
    "battle_scene_render_height_px": 184,
    "battle_scene_local_platform_width_percent": 90,
    "battle_log_visible_entries": 8,
    "battle_log_panel_height": 122,
}

issues = []

def enum_cases(source: str, enum_name: str) -> list[str]:
    match = re.search(rf'enum\s+{re.escape(enum_name)}\b[^\{{]*\{{(?P<body>.*?)(?:\n\}})', source, re.S)
    if not match:
        issues.append(f"missing enum {enum_name}")
        return []

    cases: list[str] = []
    for line in match.group("body").splitlines():
        if not line.startswith("    case "):
            continue
        stripped = line.strip()
        raw = stripped.removeprefix("case ").split("//", 1)[0].split("=", 1)[0]
        for case in raw.split(","):
            name = case.strip().split()[0] if case.strip() else ""
            if name:
                cases.append(name)
    return cases

def enum_switch_cases(source: str, enum_name: str) -> list[str]:
    cases = enum_cases(source, enum_name)
    return cases

def block_between(source: str, start_pattern: str, end_pattern: str) -> str:
    start = re.search(start_pattern, source, re.S)
    if not start:
        return ""
    end = re.search(end_pattern, source[start.end():], re.S)
    if not end:
        return source[start.end():]
    return source[start.end():start.end() + end.start()]

def tsv_lines(source: str, symbol_name: str) -> list[str]:
    match = re.search(rf'private\s+static\s+let\s+{re.escape(symbol_name)}\s*=\s*"""(?P<body>.*?)"""', source, re.S)
    if not match:
        issues.append(f"missing TSV block {symbol_name}")
        return []
    return [
        line.strip()
        for line in match.group("body").splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]

def ratio(count: int, total: int) -> str:
    if total <= 0:
        return "n/a"
    return f"{count}/{total} ({count / total:.1%})"

def status_for(count: int, original: int | None, expected_current: int | None = None) -> str:
    if expected_current is not None and count < expected_current:
        issues.append(f"regressed coverage: got {count}, expected at least {expected_current}")
        return "REGRESSION"
    if original is not None and count >= original:
        return "covered"
    return "gap"

def enum_block(source: str, enum_name: str) -> str:
    match = re.search(rf'enum\s+{re.escape(enum_name)}\b[^\{{]*\{{(?P<body>.*?)(?:\n\}})', source, re.S)
    if not match:
        issues.append(f"missing enum {enum_name}")
        return ""
    return match.group("body")

def swift_tuple_mappings(source: str, enum_name: str, mapping_name: str) -> list[tuple[str, str]]:
    body = enum_block(source, enum_name)
    if not body:
        return []
    match = re.search(
        rf'private\s+static\s+let\s+{re.escape(mapping_name)}\s*:[^\n=]+=\s*\[(?P<body>.*?)\n\s*\]',
        body,
        re.S,
    )
    if not match:
        issues.append(f"missing {enum_name}.{mapping_name}")
        return []
    return re.findall(r'\("([^"]+)",\s*\.(\w+)\)', match.group("body"))

def static_number(source: str, enum_name: str, symbol_name: str) -> float | None:
    body = enum_block(source, enum_name)
    if not body:
        return None
    match = re.search(
        rf'static\s+let\s+{re.escape(symbol_name)}(?:\s*:\s*[\w.<>]+)?\s*=\s*([0-9]+(?:\.[0-9]+)?)',
        body,
    )
    if not match:
        issues.append(f"missing {enum_name}.{symbol_name}")
        return None
    return float(match.group(1))

def swift_number(value: str) -> float:
    return float(value.replace("_", ""))

def global_static_number(source: str, symbol_name: str) -> float | None:
    match = re.search(
        rf'static\s+let\s+{re.escape(symbol_name)}(?:\s*:\s*[\w.<>]+)?\s*=\s*([0-9_]+(?:\.[0-9_]+)?)',
        source,
    )
    if not match:
        issues.append(f"missing static let {symbol_name}")
        return None
    return swift_number(match.group(1))

def switch_case_return_number(source: str, switch_name: str, case_name: str) -> float | None:
    block = block_between(source, rf"var\s+{re.escape(switch_name)}\s*:", r"\n\s*var\s+")
    if not block:
        issues.append(f"missing switch property {switch_name}")
        return None
    match = re.search(
        rf'case\s+[^:\n]*\.{re.escape(case_name)}[^:\n]*:\s*return\s+([0-9_]+(?:\.[0-9_]+)?)',
        block,
    )
    if not match:
        issues.append(f"missing {switch_name} return for {case_name}")
        return None
    return swift_number(match.group(1))

hero_classes = enum_cases(hero_source, "HeroClass")
difficulty_cases = enum_cases(difficulty_source, "Difficulty")
chapter_cases = enum_cases(chapter_source, "Chapter")
rarity_cases = enum_cases(item_source, "Rarity")
equipment_types = enum_cases(item_source, "EquipmentType")
soul_stones = enum_cases(stage_source, "SoulStoneKind")
rune_nodes = enum_cases(rune_source, "RuneTreeNode")

source_rune_rows = tsv_lines(rune_source, "sourceRuneTSV")
source_runes = []
for line in source_rune_rows:
    columns = line.split("\t")
    if len(columns) != 7:
        issues.append(f"malformed source rune row: {line}")
        continue
    try:
        max_level = int(columns[3])
    except ValueError:
        issues.append(f"malformed source rune max level: {line}")
        continue
    source_runes.append({
        "id": columns[0],
        "zh_name": columns[1],
        "en_name": columns[2],
        "max_level": max_level,
        "previous": [value.strip() for value in columns[4].split(",") if value.strip()],
        "next": [value.strip() for value in columns[5].split(",") if value.strip()],
        "icon": columns[6],
    })
source_rune_ids = [rune["id"] for rune in source_runes]
duplicate_source_rune_ids = sorted({rune_id for rune_id in source_rune_ids if source_rune_ids.count(rune_id) > 1})
if duplicate_source_rune_ids:
    issues.append(f"duplicate source rune ids: {', '.join(duplicate_source_rune_ids)}")
source_rune_connection_count = sum(len(rune["next"]) for rune in source_runes)
source_rune_next_out_degree_distribution = dict(sorted(Counter(len(rune["next"]) for rune in source_runes).items()))
if source_rune_next_out_degree_distribution != ORIGINAL["rune_next_out_degree_distribution"]:
    issues.append(
        "source rune next out-degree distribution mismatch: "
        f"{source_rune_next_out_degree_distribution} vs {ORIGINAL['rune_next_out_degree_distribution']}"
    )
source_rune_previous_reference_count = sum(len(rune["previous"]) for rune in source_runes)
source_rune_previous_reference_map = {
    rune["id"]: rune["previous"]
    for rune in source_runes
    if rune["previous"]
}
if source_rune_previous_reference_map != ORIGINAL["rune_previous_reference_map"]:
    issues.append(
        "source rune previous-reference map mismatch: "
        f"{source_rune_previous_reference_map} vs {ORIGINAL['rune_previous_reference_map']}"
    )
source_rune_max_level_distribution = dict(sorted(Counter(rune["max_level"] for rune in source_runes).items()))
if source_rune_max_level_distribution != ORIGINAL["rune_max_level_distribution"]:
    issues.append(
        "source rune max-level distribution mismatch: "
        f"{source_rune_max_level_distribution} vs {ORIGINAL['rune_max_level_distribution']}"
    )
source_rune_icon_distribution = dict(sorted(Counter(rune["icon"] for rune in source_runes).items()))
if source_rune_icon_distribution != ORIGINAL["rune_icon_distribution"]:
    issues.append(
        "source rune icon distribution mismatch: "
        f"{source_rune_icon_distribution} vs {ORIGINAL['rune_icon_distribution']}"
    )
source_rune_next_ids = [next_id for rune in source_runes for next_id in rune["next"]]
source_rune_previous_ids = [previous_id for rune in source_runes for previous_id in rune["previous"]]
dangling_source_rune_next_ids = sorted(set(source_rune_next_ids) - set(source_rune_ids))
if dangling_source_rune_next_ids:
    issues.append(f"dangling source rune next ids: {', '.join(dangling_source_rune_next_ids)}")
dangling_source_rune_previous_ids = sorted(set(source_rune_previous_ids) - set(source_rune_ids))
if dangling_source_rune_previous_ids:
    issues.append(f"dangling source rune previous ids: {', '.join(dangling_source_rune_previous_ids)}")
source_rune_icon_names = sorted({rune["icon"] for rune in source_runes})

source_rune_id_map = {rune["id"]: rune for rune in source_runes}
runtime_rune_source_ids = set(
    re.findall(r'return\s+"([^"]+)"', block_between(rune_source, r"var\s+sourceRuneID:\s*String\s*\{", r"\n\s*\}"))
)
runtime_rune_source_rows = [
    source_rune_id_map[source_id]
    for source_id in sorted(runtime_rune_source_ids)
    if source_id in source_rune_id_map
]
data_only_rune_source_rows = [
    rune
    for rune in source_runes
    if rune["id"] not in runtime_rune_source_ids
]
runtime_rune_icon_families = sorted({rune["icon"] for rune in runtime_rune_source_rows})
data_only_rune_icon_families = sorted({rune["icon"] for rune in data_only_rune_source_rows})
unmodeled_only_rune_icon_families = sorted(set(source_rune_icon_names) - set(runtime_rune_icon_families))
shared_modeled_data_only_rune_icon_families = sorted(set(runtime_rune_icon_families) & set(data_only_rune_icon_families))

missing_runtime_rune_source_ids = sorted(runtime_rune_source_ids - set(source_rune_id_map))
if missing_runtime_rune_source_ids:
    issues.append("runtime Rune Tree source IDs missing from source catalog: " + ",".join(missing_runtime_rune_source_ids))
if len(runtime_rune_source_rows) != CURRENT_BASELINE["runtime_rune_source_nodes"]:
    issues.append(
        "runtime Rune Tree source-node coverage drifted: "
        f"{len(runtime_rune_source_rows)} vs {CURRENT_BASELINE['runtime_rune_source_nodes']}"
    )
if len(data_only_rune_source_rows) != CURRENT_BASELINE["data_only_rune_source_nodes"]:
    issues.append(
        "data-only Rune Tree source-node coverage drifted: "
        f"{len(data_only_rune_source_rows)} vs {CURRENT_BASELINE['data_only_rune_source_nodes']}"
    )
if len(runtime_rune_icon_families) != CURRENT_BASELINE["runtime_rune_icon_families"]:
    issues.append(
        "runtime Rune Tree icon-family coverage drifted: "
        f"{len(runtime_rune_icon_families)} vs {CURRENT_BASELINE['runtime_rune_icon_families']}"
    )
if len(unmodeled_only_rune_icon_families) != CURRENT_BASELINE["unmodeled_only_rune_icon_families"]:
    issues.append(
        "unmodeled-only Rune Tree icon-family coverage drifted: "
        f"{len(unmodeled_only_rune_icon_families)} vs {CURRENT_BASELINE['unmodeled_only_rune_icon_families']}"
    )
if shared_modeled_data_only_rune_icon_families != [
    "MaxAmountActBossChest",
    "MaxAmountNormalChest",
    "MaxAmountStageBossChest",
    "MaxInventorySlot",
    "OfflineRewardExpPercent",
    "OfflineRewardGoldPercent",
]:
    issues.append(
        "unexpected shared modeled/data-only Rune Tree icon families: "
        + ",".join(shared_modeled_data_only_rune_icon_families)
    )

rune_required_hero_level = int(global_static_number(rune_source, "requiredHeroLevel") or 0)
rune_inventory_slot_bonus = int(global_static_number(rune_source, "inventoryExpansionSlotBonus") or 0)
rune_party_slot2_gold = int(switch_case_return_number(rune_source, "goldCost", "partySlot2") or 0)
rune_party_slot3_gold = int(switch_case_return_number(rune_source, "goldCost", "partySlot3") or 0)
rune_party_slot_verified_gold_total = rune_party_slot2_gold + rune_party_slot3_gold

direct_slot_3_source = re.search(
    r'case\s+2:\s*\n\s*return\s+\[\.partySlot2,\s*\.partySlot3\]',
    rune_source,
) is not None
rune_direct_party_slot_3_gold = rune_party_slot_verified_gold_total if direct_slot_3_source else 0

rune_active_skill_slot_count_guard = (
    "var activeSkillSlotCount: Int" in rune_source
    and "1 + (isUnlocked(.activeSkillSlot2) ? 1 : 0)" in rune_source
)
rune_active_skill_slot_count = 2 if rune_active_skill_slot_count_guard else 0

rune_offline_boost_guard = (
    "isUnlocked(.offlineGoldBoost) ? 1.10 : 1.0" in rune_source
    and "isUnlocked(.offlineXPBoost) ? 1.10 : 1.0" in rune_source
)
rune_offline_boost_percent = 10 if rune_offline_boost_guard else 0

has_verified_gold_cost_body = block_between(rune_source, r"var\s+hasVerifiedGoldCost:\s*Bool\s*\{", r"\n\s*var\s+approximateGoldCost")
unverified_cost_cases_match = re.search(r'case\s+(?P<body>[^:]+):\s*\n\s*return\s+false', has_verified_gold_cost_body, re.S)
unverified_cost_nodes = (
    re.findall(r'\.(\w+)', unverified_cost_cases_match.group("body"))
    if unverified_cost_cases_match else []
)
rune_unverified_cost_nodes = len(unverified_cost_nodes)
approximate_cost_body = block_between(rune_source, r"var\s+approximateGoldCost:\s*Int\?\s*\{", r"\n\s*var\s+costText")
approximate_cost_nodes = re.findall(r'case\s+\.(\w+):\s*\n\s*return\s+[0-9_]+', approximate_cost_body)
rune_approximate_cost_nodes = len(approximate_cost_nodes)

if rune_required_hero_level != CURRENT_BASELINE["rune_required_hero_level"]:
    issues.append(
        "runtime Rune Tree hero-level gate drifted: "
        f"{rune_required_hero_level} vs {CURRENT_BASELINE['rune_required_hero_level']}"
    )
if rune_party_slot_verified_gold_total != CURRENT_BASELINE["rune_party_slot_verified_gold_total"]:
    issues.append(
        "verified Rune of Command party-slot gold total drifted: "
        f"{rune_party_slot_verified_gold_total} vs {CURRENT_BASELINE['rune_party_slot_verified_gold_total']}"
    )
if rune_direct_party_slot_3_gold != CURRENT_BASELINE["rune_direct_party_slot_3_gold"]:
    issues.append(
        "direct third-party-slot unlock cost drifted: "
        f"{rune_direct_party_slot_3_gold} vs {CURRENT_BASELINE['rune_direct_party_slot_3_gold']}"
    )
if rune_active_skill_slot_count != CURRENT_BASELINE["rune_active_skill_slot_count"]:
    issues.append(
        "runtime Rune of Awakening active skill slot count drifted: "
        f"{rune_active_skill_slot_count} vs {CURRENT_BASELINE['rune_active_skill_slot_count']}"
    )
if rune_inventory_slot_bonus != CURRENT_BASELINE["rune_inventory_slot_bonus"]:
    issues.append(
        "runtime Rune of Expansion inventory bonus drifted: "
        f"{rune_inventory_slot_bonus} vs {CURRENT_BASELINE['rune_inventory_slot_bonus']}"
    )
if rune_offline_boost_percent != CURRENT_BASELINE["rune_offline_boost_percent"]:
    issues.append(
        "runtime offline Rune boost percent drifted: "
        f"{rune_offline_boost_percent} vs {CURRENT_BASELINE['rune_offline_boost_percent']}"
    )
if rune_unverified_cost_nodes != CURRENT_BASELINE["rune_unverified_cost_nodes"]:
    issues.append(
        "runtime Rune nodes with unverified local cost count drifted: "
        f"{rune_unverified_cost_nodes} vs {CURRENT_BASELINE['rune_unverified_cost_nodes']}"
    )
if rune_approximate_cost_nodes != CURRENT_BASELINE["rune_approximate_cost_nodes"]:
    issues.append(
        "runtime Rune nodes with approximate cost count drifted: "
        f"{rune_approximate_cost_nodes} vs {CURRENT_BASELINE['rune_approximate_cost_nodes']}"
    )

direct_inventory_expansion_slot_bonus = int(global_static_number(inventory_source, "slotBonus") or 0)
direct_inventory_expansion_base_gold_cost = int(global_static_number(inventory_source, "baseGoldCost") or 0)
direct_inventory_expansion_first_gold_cost = direct_inventory_expansion_base_gold_cost
direct_inventory_expansion_second_gold_cost = direct_inventory_expansion_base_gold_cost * 2
direct_inventory_expansion_save_guard = (
    "purchasedInventoryExpansionCount" in game_loop_source
    and "purchasedInventoryExpansionCount" in save_manager_source
    and "InventoryExpansion.maxCapacity" in game_loop_source
    and "static func maxCapacity" in inventory_source
)
self_test_direct_inventory_expansion_guard = (
    "direct backpack expansion can be purchased repeatedly" in self_test_source
    and "save/load round trip derives inventory capacity from Rune Tree and purchased backpack expansions" in self_test_source
)
worse_equipment_handling_modes = len(enum_cases(inventory_source, "WorseEquipmentHandling"))
worse_equipment_runtime_guard = (
    "func setWorseEquipmentHandling" in game_loop_source
    and "private func handleWorseEquipmentLoot" in game_loop_source
    and "worseEquipmentHandling != .keep" in game_loop_source
    and "item.rarity.alchemyGoldValue" in game_loop_source
    and "guard !item.isBetterEquipment" in game_loop_source
)
worse_equipment_persistence_guard = (
    "worseEquipmentHandling" in save_manager_source
    and "worseEquipmentHandling" in game_loop_source
)
worse_equipment_ui_guard = (
    "WorseEquipmentHandling.allCases" in inventory_view_source
    and "onWorseEquipmentHandlingChange" in inventory_view_source
)
self_test_worse_equipment_guard = (
    "worse-equipment alchemy consumes weaker same-slot loot before it enters the backpack" in self_test_source
    and "worse-equipment discard removes weaker same-slot loot without granting gold" in self_test_source
)
auto_normal_chest_runtime_guard = (
    "var canAutoOpenNormalChests: Bool" in rune_source
    and "isUnlocked(.autoOpenNormalChests)" in rune_source
    and "func autoOpenEligibleChests" in game_loop_source
    and "openChest(family: .normalMonster)" in game_loop_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_normal_chest_self_test_guard = (
    "Rune of the Mainspring unlocks automatic Normal Monster chest opening in the engine" in self_test_source
    and "automatic Normal Monster chest opening consumes only source Normal Monster boxes" in self_test_source
)
auto_stage_boss_chest_runtime_guard = (
    "var canAutoOpenStageBossChests: Bool" in rune_source
    and "isUnlocked(.autoOpenStageBossChests)" in rune_source
    and "func autoOpenEligibleChests" in game_loop_source
    and "openChest(family: .stageBoss)" in game_loop_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_stage_boss_chest_self_test_guard = (
    "Rune of the Mainspring unlocks automatic Stage Boss chest opening in the engine" in self_test_source
    and "automatic Stage Boss chest opening consumes only source Stage Boss boxes" in self_test_source
)
auto_act_boss_chest_runtime_guard = (
    "var canAutoOpenActBossChests: Bool" in rune_source
    and "isUnlocked(.autoOpenActBossChests)" in rune_source
    and "func autoOpenEligibleChests" in game_loop_source
    and "openChest(family: .actBoss)" in game_loop_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_act_boss_chest_self_test_guard = (
    "Rune of the Mainspring unlocks automatic Act Boss chest opening in the engine" in self_test_source
    and "automatic Act Boss chest opening consumes only source Act Boss boxes" in self_test_source
)
chest_capacity_runtime_guard = (
    "case maxNormalChestStorage" in rune_source
    and "case maxStageBossChestStorage" in rune_source
    and "case maxActBossChestStorage" in rune_source
    and "var chestStorageLimits: ChestStorageLimits" in rune_source
    and "ChestStorageLimits.base.normalMonster + (isUnlocked(.maxNormalChestStorage)" in rune_source
    and "mutating func add(_ chest: LootChest, limits: ChestStorageLimits)" in stage_source
    and "progress.advance(by: rewards.encountersCleared, chestStorageLimits: runeTree.chestStorageLimits)" in game_loop_source
)
chest_capacity_self_test_guard = (
    "source-backed chest-capacity runes raise local box family caps by the conservative scaffold increment" in self_test_source
    and "base chest family storage keeps the newest source Normal Monster box within the local cap" in self_test_source
    and "Rune of Containment chest-capacity scaffold preserves an additional Normal Monster box" in self_test_source
)
new_game_plus_runtime_guard = (
    "progress.isAwaitingNewGamePlus" in game_loop_source
    and "func startNextPlaythrough" in game_loop_source
    and "currentBattle = nil" in game_loop_source
)
new_game_plus_ui_guard = (
    "CompletionSettlementView" in battle_view_source
    and "onStartNextPlaythrough" in battle_view_source
    and "开启" in battle_view_source
)
new_game_plus_self_test_guard = (
    "progress caps at torment 3-10 and opens the completion settlement" in self_test_source
    and "starting next playthrough resets campaign progression while preserving owned state" in self_test_source
    and "new game plus scales enemy stats and stage rewards" in self_test_source
    and "save/load round trip preserves playthrough settlement state" in self_test_source
)
ground_slam_rock_runtime_guard = (
    "GroundSlamRockScaffold" in battle_source
    and "groundSlamRockCharges" in battle_source
    and "triggerGroundSlamRockExplosionIfNeeded" in battle_source
    and "大地强击岩石爆炸" in battle_source
    and "isPhysicalAreaDamageSkill" in battle_source
)
ground_slam_rock_visual_guard = (
    "earthquakeRockExplosion" in battle_view_source
    and "rockBurst" in battle_view_source
    and "earthquakeRockExplosion" in battle_scene_snapshot_source
    and "damage_rock_explosion_pixels" in battle_scene_audit_source
)
ground_slam_rock_self_test_guard = (
    "Ground Slam rock explosion exposes a dedicated rock impact cue" in self_test_source
    and "Ground Slam rock explosion exposes a dedicated rock-burst trajectory cue" in self_test_source
    and "Ground Slam rock charges are consumed by later physical AOE and damage the live wave" in self_test_source
)
slayer_utility_visual_guard = (
    "generalsCryRoar" in battle_view_source
    and "bloodlustSurge" in battle_view_source
    and "generalsCryUtility" in battle_scene_snapshot_source
    and "bloodlustUtility" in battle_scene_snapshot_source
    and "utility_generals_cry_pixels" in battle_scene_audit_source
    and "utility_bloodlust_pixels" in battle_scene_audit_source
)
slayer_utility_self_test_guard = (
    "General's Cry exposes a dedicated roar utility cue" in self_test_source
    and "Bloodlust exposes a dedicated surge utility cue" in self_test_source
)
attack_speed_utility_visual_guard = (
    "swiftSurgeHaste" in battle_view_source
    and "quickLoaderHaste" in battle_view_source
    and "swiftSurgeUtility" in battle_scene_snapshot_source
    and "quickLoaderUtility" in battle_scene_snapshot_source
    and "utility_swift_surge_pixels" in battle_scene_audit_source
    and "utility_quick_loader_pixels" in battle_scene_audit_source
)
attack_speed_utility_self_test_guard = (
    "Swift Surge exposes a dedicated haste utility cue" in self_test_source
    and "Quick Loader exposes a dedicated reload-haste utility cue" in self_test_source
)

if direct_inventory_expansion_slot_bonus != CURRENT_BASELINE["direct_inventory_expansion_slot_bonus"]:
    issues.append(
        "direct inventory expansion slot bonus drifted: "
        f"{direct_inventory_expansion_slot_bonus} vs {CURRENT_BASELINE['direct_inventory_expansion_slot_bonus']}"
    )
if direct_inventory_expansion_base_gold_cost != CURRENT_BASELINE["direct_inventory_expansion_base_gold_cost"]:
    issues.append(
        "direct inventory expansion base gold cost drifted: "
        f"{direct_inventory_expansion_base_gold_cost} vs {CURRENT_BASELINE['direct_inventory_expansion_base_gold_cost']}"
    )
if not direct_inventory_expansion_save_guard:
    issues.append("direct inventory expansion must persist count and derive max capacity through InventoryExpansion")
if not self_test_direct_inventory_expansion_guard:
    issues.append("SelfTest must guard repeated direct backpack expansion and save/load capacity derivation")
if worse_equipment_handling_modes != CURRENT_BASELINE["worse_equipment_handling_modes"]:
    issues.append(
        "worse equipment handling mode count drifted: "
        f"{worse_equipment_handling_modes} vs {CURRENT_BASELINE['worse_equipment_handling_modes']}"
    )
if not worse_equipment_runtime_guard:
    issues.append("GameEngine must process worse equipment loot before backpack insertion")
if not worse_equipment_persistence_guard:
    issues.append("worse equipment handling setting must persist through SaveData")
if not worse_equipment_ui_guard:
    issues.append("UI must expose worse equipment handling mode selection")
if not self_test_worse_equipment_guard:
    issues.append("SelfTest must guard worse equipment alchemy and discard behavior")
if not auto_normal_chest_runtime_guard:
    issues.append("GameEngine must auto-open source Normal Monster boxes through the Rune of the Mainspring runtime node")
if not auto_normal_chest_self_test_guard:
    issues.append("SelfTest must guard automatic Normal Monster chest opening and Boss-box preservation")
if not auto_stage_boss_chest_runtime_guard:
    issues.append("GameEngine must auto-open source Stage Boss boxes through the Rune of the Mainspring runtime node")
if not auto_stage_boss_chest_self_test_guard:
    issues.append("SelfTest must guard automatic Stage Boss chest opening and Act Boss preservation")
if not auto_act_boss_chest_runtime_guard:
    issues.append("GameEngine must auto-open source Act Boss boxes through the Rune of the Mainspring runtime node")
if not auto_act_boss_chest_self_test_guard:
    issues.append("SelfTest must guard automatic Act Boss chest opening and lower-tier Boss-box preservation")
if not chest_capacity_runtime_guard:
    issues.append("chest capacity Rune runtime must apply source-backed per-family box storage limits")
if not chest_capacity_self_test_guard:
    issues.append("SelfTest must guard source-backed chest capacity Rune effects and base cap behavior")
if not new_game_plus_runtime_guard:
    issues.append("GameEngine must pause at completion settlement and expose next-playthrough start")
if not new_game_plus_ui_guard:
    issues.append("Battle UI must expose completion settlement and next-playthrough action")
if not new_game_plus_self_test_guard:
    issues.append("SelfTest must guard completion settlement, next playthrough scaling and persistence")
if not ground_slam_rock_runtime_guard:
    issues.append("Battle runtime must model Ground Slam rocks and later physical-AOE explosion consumption")
if not ground_slam_rock_visual_guard:
    issues.append("Battle UI and scene audit must expose Ground Slam rock explosion impact/trajectory cues")
if not ground_slam_rock_self_test_guard:
    issues.append("SelfTest must guard Ground Slam rock explosion cue mapping and runtime consumption")
if not slayer_utility_visual_guard:
    issues.append("Battle UI and scene audit must expose dedicated Slayer utility cues for General's Cry and Bloodlust")
if not slayer_utility_self_test_guard:
    issues.append("SelfTest must guard General's Cry and Bloodlust dedicated utility cue mapping")
if not attack_speed_utility_visual_guard:
    issues.append("Battle UI and scene audit must expose dedicated attack-speed utility cues for Swift Surge and Quick Loader")
if not attack_speed_utility_self_test_guard:
    issues.append("SelfTest must guard Swift Surge and Quick Loader dedicated utility cue mapping")

equip_slot_block = re.search(r'static\s+let\s+allCases:\s*\[EquipSlot\]\s*=\s*\[(?P<body>.*?)\]', item_source, re.S)
equip_slots = re.findall(r'\.(\w+)', equip_slot_block.group("body")) if equip_slot_block else []
if not equip_slots:
    issues.append("could not locate active EquipSlot.allCases list")

skill_calls = re.findall(r'Skill\s*\((?P<body>.*?)\)\s*(?:,|\])', skills_source, re.S)
skills = []
for body in skill_calls:
    id_match = re.search(r'id:\s*"([^"]+)"', body)
    name_match = re.search(r'name:\s*"([^"]+)"', body)
    activation_match = re.search(r'activation:\s*\.(\w+)', body)
    damage_element_match = re.search(r'damageElement:\s*\.(\w+)', body)
    delivery_match = re.search(r'delivery:\s*\.(\w+)', body)
    level_values_match = re.search(r'levelValues:\s*\[(.*?)\]', body, re.S)
    if not id_match or not name_match:
        continue
    level_values = []
    if level_values_match:
        level_values = [
            value.strip()
            for value in level_values_match.group(1).replace("\n", " ").split(",")
            if value.strip()
        ]
    skills.append({
        "id": id_match.group(1),
        "name": name_match.group(1),
        "activation": activation_match.group(1) if activation_match else "cooldown",
        "damage_element": damage_element_match.group(1) if damage_element_match else "none",
        "delivery": delivery_match.group(1) if delivery_match else "none",
        "level_value_count": len(level_values),
    })

skill_ids = [skill["id"] for skill in skills]
duplicate_skill_ids = sorted({skill_id for skill_id in skill_ids if skill_ids.count(skill_id) > 1})
if duplicate_skill_ids:
    issues.append(f"duplicate skill ids: {', '.join(duplicate_skill_ids)}")

skills_with_full_tables = [skill for skill in skills if skill["level_value_count"] == 10]
activation_types_used = sorted({skill["activation"] for skill in skills})
damage_elements_used = sorted({skill["damage_element"] for skill in skills})
deliveries_used = sorted({skill["delivery"] for skill in skills})
skills_by_class_prefix: dict[str, int] = {}
for skill_id in skill_ids:
    prefix = skill_id[:1]
    skills_by_class_prefix[prefix] = skills_by_class_prefix.get(prefix, 0) + 1

source_skill_rows = tsv_lines(skills_source, "sourceSkillTSV")
source_skills = []
for line in source_skill_rows:
    columns = line.split("\t")
    if len(columns) != 6:
        issues.append(f"malformed source skill row: {line}")
        continue
    source_skills.append({
        "id": columns[0],
        "name": columns[1],
        "activation": columns[2],
        "damage_type": columns[3],
        "delivery": columns[4],
        "range": columns[5],
    })
source_skill_ids = [skill["id"] for skill in source_skills]
duplicate_source_skill_ids = sorted({skill_id for skill_id in source_skill_ids if source_skill_ids.count(skill_id) > 1})
if duplicate_source_skill_ids:
    issues.append(f"duplicate source skill ids: {', '.join(duplicate_source_skill_ids)}")
missing_runtime_source_ids = sorted(set(skill_ids) - set(source_skill_ids))
if missing_runtime_source_ids:
    issues.append(f"runtime skill ids missing from source catalog: {', '.join(missing_runtime_source_ids)}")
source_skill_activations = sorted({skill["activation"] for skill in source_skills})
source_skill_damage_types = sorted({skill["damage_type"] for skill in source_skills})
source_skill_deliveries = sorted({skill["delivery"] for skill in source_skills})
source_skill_activation_counts = dict(sorted(Counter(skill["activation"] for skill in source_skills).items()))
source_skill_damage_counts = dict(sorted(Counter(skill["damage_type"] for skill in source_skills).items()))
source_skills_by_prefix = dict(sorted(Counter(skill_id[:1] for skill_id in source_skill_ids).items()))

passive_skill_rows = tsv_lines(skills_source, "passiveSkillTSV")
passive_skills = []
for line in passive_skill_rows:
    columns = line.split("\t")
    if len(columns) != 5:
        issues.append(f"malformed passive skill row: {line}")
        continue
    passive_skills.append({
        "id": columns[0],
        "name": columns[1],
        "stat": columns[2],
        "type": columns[3],
        "value": columns[4],
    })
passive_ids = [skill["id"] for skill in passive_skills]
duplicate_passive_ids = sorted({skill_id for skill_id in passive_ids if passive_ids.count(skill_id) > 1})
if duplicate_passive_ids:
    issues.append(f"duplicate passive skill ids: {', '.join(duplicate_passive_ids)}")
passive_types_used = sorted({skill["type"] for skill in passive_skills})
passive_stats_used = sorted({skill["stat"] for skill in passive_skills})
passive_skills_by_class_prefix = dict(sorted(Counter(skill_id[:1] for skill_id in passive_ids).items()))
passive_runtime_hook_markers = {
    "AddHpPerHit": "passiveAddHpPerHit",
    "AddHpPerKill": "passiveAddHpPerKill",
    "AllElementalResistance": "passiveAllElementalResistance",
    "AreaOfEffect": "passiveAreaOfEffect",
    "Armor": "passiveArmor",
    "AttackDamage": "passiveAttackDamage",
    "AttackSpeed": "passiveAttackSpeed",
    "BlockChance": "passiveBlockChance",
    "CastSpeed": "passiveCastSpeed",
    "ColdDamagePercent": "passiveColdDamagePercent",
    "CooldownReduction": "passiveCooldownReduction",
    "CriticalChance": "passiveCriticalChance",
    "CriticalDamage": "passiveCriticalDamage",
    "DamageAbsorption": "passiveDamageAbsorption",
    "DamageReduction": "passiveDamageReduction",
    "DodgeChance": "passiveDodgeChance",
    "ElementalDodgeChance": "passiveElementalDodgeChance",
    "FireDamagePercent": "passiveFireDamagePercent",
    "HpLeech": "passiveHpLeech",
    "HpRegenPerSec": "passiveHpRegenPerSec",
    "IncreaseAreaOfEffectDamage": "passiveIncreaseAreaOfEffectDamage",
    "IncreaseProjectileDamage": "passiveIncreaseProjectileDamage",
    "LightningDamagePercent": "passiveLightningDamagePercent",
    "MaxDodgeChance": "passiveMaxDodgeChance",
    "MaxHp": "passiveMaxHp",
    "MovementSpeed": "passiveMovementSpeed",
    "PhysicalDamagePercent": "passivePhysicalDamagePercent",
    "SkillDurationIncrease": "passiveSkillDurationIncrease",
    "SkillHealIncrease": "passiveSkillHealIncrease",
    "SkillRangeExpansion": "passiveSkillRangeExpansion",
}
missing_passive_runtime_marker_stats = sorted(set(passive_stats_used) - set(passive_runtime_hook_markers))
if missing_passive_runtime_marker_stats:
    issues.append(
        "passive runtime hook marker table is missing source stats: "
        + ",".join(missing_passive_runtime_marker_stats)
    )
passive_runtime_hooked_stats = sorted(
    stat
    for stat in passive_stats_used
    if passive_runtime_hook_markers.get(stat, "") in (hero_source + battle_source + skills_source + self_test_source)
)
passive_runtime_unhooked_stats = sorted(set(passive_stats_used) - set(passive_runtime_hooked_stats))

rune_dependency_edges = []
for cases, target in re.findall(r'case\s+([^:]+):\s+return\s+\.(\w+)', rune_source):
    for case in re.findall(r'\.(\w+)', cases):
        rune_dependency_edges.append((case, target))

stage_definitions_block = block_between(
    stage_source,
    r'static\s+let\s+all:\s*\[StageDefinition\]\s*=\s*\[',
    r'\n\s*\]\n\n\s*private\s+struct\s+ItemLevelThreshold',
)
display_stage_count = len(re.findall(r'StageDefinition\s*\(', stage_definitions_block))

stage_rows = tsv_lines(stage_source, "minedStageTSV")
stage_codes = [line.split()[0] for line in stage_rows if line.split()]
stage_composition_rows = tsv_lines(stage_source, "minedStageCompositionTSV")
composition_codes = [line.split()[0] for line in stage_composition_rows if line.split()]
composition_names: set[str] = set()
for line in stage_composition_rows:
    columns = line.split(maxsplit=1)
    if len(columns) != 2:
        continue
    for entry in columns[1].split("|"):
        parts = entry.split(":")
        if parts and parts[0]:
            composition_names.add(parts[0])

chest_catalog_entries = len(re.findall(r'ChestCatalogEntry\s*\(', stage_source))
chest_families = enum_cases(stage_source, "ChestFamily")
chest_catalog_ids = {
    value.replace("_", "")
    for value in re.findall(r'databaseID:\s*([0-9_]+)', stage_source)
}

soul_stone_material_id_block = block_between(
    stage_source,
    r'var\s+materialID:\s+Int\s*\{',
    r'\n\s*\}\n\n\s*var\s+rarity',
)
soul_stone_material_ids = [
    value.replace("_", "")
    for value in re.findall(r'return\s+([0-9_]+)', soul_stone_material_id_block)
]

synthesis_input_match = re.search(r'static\s+let\s+synthesisInputCount\s*=\s*(\d+)', item_source)
synthesis_inputs = int(synthesis_input_match.group(1)) if synthesis_input_match else 0
if synthesis_inputs == 0:
    issues.append("could not locate Rarity.synthesisInputCount")

exact_item_record_markers = re.findall(r'\bItemCatalogEntry\s*\(', item_source)
source_progression_runtime_selector = bool(re.search(
    r'static\s+func\s+progression\(for\s+equipmentType:\s*EquipmentType,\s*itemLevel:\s*Int\)\s*->\s*SourceGearLevelProgression\?',
    item_source,
))
loot_uses_source_progression_identity = "SourceItemCatalog.progression(for: type, itemLevel: itemLevel)" in loot_table_source and "来源装备" in loot_table_source
synthesis_preview_uses_source_progression = "outputSourceProgression" in item_source and "SourceItemCatalog.progression(for: $0, itemLevel: level)" in item_source
legacy_item_name_inference = (
    "inferredLegacyType" in item_source
    and "decodedDescription" in item_source
    and "旧项链" in self_test_source
    and "旧护腕" in self_test_source
    and "GameArt.itemIconName(for: item) == SourceItemCatalog.progression(" in self_test_source
)
source_gear_progression_icons = (
    "var iconName: String" in item_source
    and '"source_gear_\\(id)"' in item_source
    and "SourceItemCatalog.progression(" in game_art_source
    and "item.itemLevel" in game_art_source
    and "?.iconName ?? itemIconName(for: equipmentType)" in game_art_source
    and len(source_gear_manifest_lines) == 397
    and source_gear_manifest_lines[0] == "iconName\tslug\ttype\titemLevel\tsourceID\tname\tsourceURL\tsha256\tbytes"
)
support_sustained_skill_runtime = (
    "ActiveSupportSkillBuff" in battle_source
    and "activeSupportSkillBuffs" in battle_source
    and "applySupportOverTimeBuffEffects" in battle_source
    and "activateSupportSustainedDamageBuff" in battle_source
    and 'skill.id == "30401" || skill.id == "50501"' in battle_source
    and 'skill.id == "30501"' in battle_source
)
support_attack_count_skill_runtime = (
    "supportBaseAttackCounts" in battle_source
    and "nextSupportAttackCountSkillIndexes" in battle_source
    and "supportAttackCountSkills" in battle_source
    and "readyAttackCountSupportSkill" in battle_source
    and "applyTriggeredSupportSkillAfterAttack" in battle_source
    and "applySupportRapidProjectileSkill" in battle_source
    and "applySupportShockBoltSkill" in battle_source
    and 'skill.id == "20101"' in battle_source
    and 'skill.id == "50601"' in battle_source
)
source_base_attack_metadata = (
    "baseAttackSourceSkill(for heroClass: HeroClass)" in skills_source
    and "baseAttackDamageElement(for heroClass: HeroClass)" in skills_source
    and "baseAttackDelivery(for heroClass: HeroClass)" in skills_source
    and 'return "30001"' in skills_source
    and "HeroSkills.baseAttackDamageElement(for: primaryHeroClass)" in battle_source
    and "HeroSkills.baseAttackDelivery(for: primaryHeroClass)" in battle_source
    and "HeroSkills.baseAttackDamageElement(for: member.heroClass)" in battle_source
    and "HeroSkills.baseAttackDelivery(for: member.heroClass)" in battle_source
    and "source base attack rows resolve to runtime element and delivery metadata" in self_test_source
    and "source-backed Sorcerer base attacks expose fire projectile visual metadata" in self_test_source
)
source_chaos_damage_metadata = (
    "case chaos" in skills_source
    and 'case "chaos":' in skills_source
    and "SourceSkillCatalog.skill(id: \"309021\")?.runtimeDamageElement == .chaos" in self_test_source
    and "source chaos damage metadata exposes a chaos impact cue" in self_test_source
    and "case .chaosBurst" in battle_view_source
)
source_chaos_battle_scene_audit = (
    "case chaosBurst" in battle_scene_snapshot_source
    and "case .chaosBurst" in battle_scene_snapshot_source
    and "damageElement: .chaos" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture chaosBurst" in battle_scene_audit_source
    and "damage_chaos_pixels" in battle_scene_audit_source
    and "is_impact_chaos" in battle_scene_audit_source
)
source_monster_attack_metadata = (
    "let sourceSkillID: String?" in monster_source
    and "var sourceDamageElement: SkillDamageElement" in monster_source
    and 'case "燃烧的地狱祭司":' in stage_source
    and 'return "301015"' in stage_source
    and 'case "冰冻的地狱祭司":' in stage_source
    and 'return "301025"' in stage_source
    and 'case "电流的地狱祭司":' in stage_source
    and 'return "301035"' in stage_source
    and 'case "混沌的地狱祭司":' in stage_source
    and 'return "301045"' in stage_source
    and "let attackElement = attackingMonster.sourceDamageElement" in battle_source
    and "modifiedIncomingDamage(hit.amount, damageElement: attackElement)" in battle_source
    and "incomingAttackWasDodged(damageElement: attackElement)" in battle_source
    and "stage elemental hell priests resolve to checked source monster attack metadata" in self_test_source
    and "monster source attack elements feed battle log metadata and incoming elemental resistance" in self_test_source
)
source_monster_incoming_visual_audit = (
    "enum BattleIncomingCue" in battle_view_source
    and "BattleIncomingCueView" in battle_view_source
    and "BattleIncomingCue.visible(for: battle.log.last)" in battle_view_source
    and "source monster attack elements expose distinct incoming cues" in self_test_source
    and "case monsterFireIncoming" in battle_scene_snapshot_source
    and "case monsterColdIncoming" in battle_scene_snapshot_source
    and "case monsterLightningIncoming" in battle_scene_snapshot_source
    and "case monsterChaosIncoming" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture monsterFireIncoming" in battle_scene_audit_source
    and "--render-battle-scene-fixture monsterColdIncoming" in battle_scene_audit_source
    and "--render-battle-scene-fixture monsterLightningIncoming" in battle_scene_audit_source
    and "--render-battle-scene-fixture monsterChaosIncoming" in battle_scene_audit_source
    and "monster_fire_incoming_pixels" in battle_scene_audit_source
    and "monster_cold_incoming_pixels" in battle_scene_audit_source
    and "monster_lightning_incoming_pixels" in battle_scene_audit_source
    and "monster_chaos_incoming_pixels" in battle_scene_audit_source
)
source_skill_database_view = (
    "SourceSkillDatabaseView" in settings_source
    and "SourceSkillRow" in settings_source
    and "ForEach(SourceSkillCatalog.all)" in settings_source
    and "SourceSkillCatalog.runtimeModeledSkills.count" in settings_source
    and "SourceSkillCatalog.damageTypes.count" in settings_source
    and "SourceSkillCatalog.deliveries.count" in settings_source
    and "runtimeModeledSkillIDs.contains(sourceSkill.id)" in settings_source
    and "sourceSkill.activation.rawValue" in settings_source
    and "sourceSkill.damageType" in settings_source
    and "sourceSkill.delivery" in settings_source
    and "sourceSkill.range" in settings_source
)
source_rune_database_view = (
    "SourceRuneDatabaseView" in settings_source
    and "ForEach(SourceRuneCatalog.all)" in settings_source
    and "SourceRuneCatalog.runtimeModeledNodes.count" in settings_source
    and "SourceRuneCatalog.runtimeUnmodeledNodes.count" in settings_source
    and "runtimeModeledSourceIDs.contains(sourceNode.id)" in settings_source
    and "GameArt.sourceRuneIconName(for: sourceNode)" in settings_source
)
source_stage_database_view = (
    "SourceStageDatabaseView" in settings_source
    and "SourceStageRuntimeRow" in settings_source
    and "StageDefinition.all.count" in settings_source
    and "StageDefinition.runtimeDataCount" in settings_source
    and "Difficulty.allCases.count" in settings_source
    and "ForEach(Difficulty.allCases" in settings_source
    and "ForEach(StageDefinition.all)" in settings_source
    and "stage.runtimeData(for: difficulty)" in settings_source
    and "runtime.monsterComposition" in settings_source
    and "runtime.goldReward" in settings_source
    and "runtime.xpReward" in settings_source
)
if not source_progression_runtime_selector:
    issues.append("SourceItemCatalog must expose runtime source gear progression selection")
if not loot_uses_source_progression_identity:
    issues.append("LootTable.makeItem must use checked source base gear progression name/id")
if not synthesis_preview_uses_source_progression:
    issues.append("SynthesisPreview must expose checked source base gear progression identity")
if not legacy_item_name_inference:
    issues.append("legacy item decoding must infer concrete equipment types from old item names for source gear icons")
if not source_gear_progression_icons:
    issues.append("runtime equipment icons must use checked source_gear progression icons pinned by source_gear_icons.tsv")
if not support_sustained_skill_runtime:
    issues.append("Battle must keep support-member sustained summon/range skill state for Hydra/Snowstorm/Turret")
if not support_attack_count_skill_runtime:
    issues.append("Battle must keep support-member attack-count skill state for modeled BASEATTACK_COUNT skills")
if not source_base_attack_metadata:
    issues.append("Battle must apply source base attack element/delivery metadata to hero and support attack logs")
if not source_chaos_damage_metadata:
    issues.append("Runtime skill metadata must preserve checked source Chaos damage rows")
if not source_chaos_battle_scene_audit:
    issues.append("Local battle-scene audit must render and gate the checked source Chaos impact cue")
if not source_monster_attack_metadata:
    issues.append("Battle must apply checked source monster attack metadata for explicitly mapped elemental priests")
if not source_monster_incoming_visual_audit:
    issues.append("Local battle-scene audit must render and gate source-backed monster incoming cues")
if not source_skill_database_view:
    issues.append("Settings UI must expose the complete SourceSkillCatalog review table and runtime/data-only coverage")
if not source_rune_database_view:
    issues.append("Settings UI must expose the complete SourceRuneCatalog review table and runtime/data-only coverage")
if not source_stage_database_view:
    issues.append("Settings UI must expose the complete mined stage runtime source-data review table")

source_gear_rows = tsv_lines(item_source, "sourceGearTypeTSV")
source_gear_entries = []
source_gear_rarity_counts: Counter[str] = Counter()
source_gear_progression_ids: list[str] = []
for line in source_gear_rows:
    columns = line.split("\t")
    if len(columns) != 6:
        issues.append(f"malformed source gear row: {line}")
        continue
    try:
        gear_count = int(columns[2])
        level_step_count = int(columns[3])
    except ValueError:
        issues.append(f"malformed source gear counts: {line}")
        continue

    rarity_counts: Counter[str] = Counter()
    for pair in columns[4].split(","):
        parts = pair.split(":")
        if len(parts) != 2:
            issues.append(f"malformed source gear rarity count: {pair}")
            continue
        try:
            rarity_counts[parts[0]] += int(parts[1])
        except ValueError:
            issues.append(f"malformed source gear rarity number: {pair}")

    progressions = [entry for entry in columns[5].split("|") if entry]
    if len(progressions) != level_step_count:
        issues.append(f"source gear level-step count mismatch for {columns[1]}: {len(progressions)} vs {level_step_count}")
    if sum(rarity_counts.values()) != gear_count:
        issues.append(f"source gear rarity distribution mismatch for {columns[1]}: {sum(rarity_counts.values())} vs {gear_count}")

    for progression in progressions:
        parts = progression.split(":", 2)
        if len(parts) != 3:
            issues.append(f"malformed source gear progression: {progression}")
            continue
        source_gear_progression_ids.append(parts[1])

    source_gear_rarity_counts.update(rarity_counts)
    source_gear_entries.append({
        "slug": columns[0],
        "title": columns[1],
        "gear_count": gear_count,
        "level_step_count": level_step_count,
        "progressions": progressions,
    })

duplicate_source_gear_progression_ids = sorted({
    progression_id
    for progression_id in source_gear_progression_ids
    if source_gear_progression_ids.count(progression_id) > 1
})
if duplicate_source_gear_progression_ids:
    issues.append(f"duplicate source gear progression ids: {', '.join(duplicate_source_gear_progression_ids)}")

source_gear_entry_total = sum(entry["gear_count"] for entry in source_gear_entries)
source_gear_level_progression_total = sum(len(entry["progressions"]) for entry in source_gear_entries)
source_gear_rarity_total = sum(source_gear_rarity_counts.values())

source_material_rows = tsv_lines(item_source, "sourceMaterialTSV")
source_materials = []
source_material_ids: list[str] = []
source_material_category_counts: Counter[str] = Counter()
source_material_rarity_counts: Counter[str] = Counter()
for line in source_material_rows:
    columns = line.split("\t")
    if len(columns) != 4:
        issues.append(f"malformed source material row: {line}")
        continue
    source_materials.append({
        "name": columns[0],
        "rarity": columns[1],
        "category": columns[2],
        "id": columns[3],
    })
    source_material_ids.append(columns[3])
    source_material_rarity_counts[columns[1]] += 1
    source_material_category_counts[columns[2]] += 1

duplicate_source_material_ids = sorted({
    material_id
    for material_id in source_material_ids
    if source_material_ids.count(material_id) > 1
})
if duplicate_source_material_ids:
    issues.append(f"duplicate source material ids: {', '.join(duplicate_source_material_ids)}")

source_soul_stone_ids = sorted(
    material["id"]
    for material in source_materials
    if material["category"] == "Soul Stone"
)
if sorted(soul_stone_material_ids) != source_soul_stone_ids:
    issues.append(
        "runtime Soul Stone material ids do not match source materials: "
        f"{','.join(sorted(soul_stone_material_ids))} vs {','.join(source_soul_stone_ids)}"
    )

source_stage_chest_rows = tsv_lines(item_source, "sourceStageChestTSV")
source_stage_chests = []
source_stage_chest_ids: list[str] = []
source_stage_chest_rarity_counts: Counter[str] = Counter()
for line in source_stage_chest_rows:
    columns = line.split("\t")
    if len(columns) != 3:
        issues.append(f"malformed source stage chest row: {line}")
        continue
    source_stage_chests.append({
        "name": columns[0],
        "rarity": columns[1],
        "id": columns[2],
    })
    source_stage_chest_ids.append(columns[2])
    source_stage_chest_rarity_counts[columns[1]] += 1

duplicate_source_stage_chest_ids = sorted({
    chest_id
    for chest_id in source_stage_chest_ids
    if source_stage_chest_ids.count(chest_id) > 1
})
if duplicate_source_stage_chest_ids:
    issues.append(f"duplicate source stage chest ids: {', '.join(duplicate_source_stage_chest_ids)}")

missing_runtime_chest_ids = sorted(set(source_stage_chest_ids) - chest_catalog_ids)
extra_runtime_chest_ids = sorted(chest_catalog_ids - set(source_stage_chest_ids))
if missing_runtime_chest_ids:
    issues.append(f"source stage chest ids missing from runtime ChestCatalog: {', '.join(missing_runtime_chest_ids)}")
if extra_runtime_chest_ids:
    issues.append(f"runtime ChestCatalog ids missing from source stage chest catalog: {', '.join(extra_runtime_chest_ids)}")

player_status_badges = enum_cases(battle_view_source, "PlayerBattleStatusBadge")
player_status_active_mappings = swift_tuple_mappings(
    battle_view_source,
    "PlayerBattleStatusBadge",
    "skillNameMapping",
)
player_status_continuous_mappings = swift_tuple_mappings(
    battle_view_source,
    "PlayerBattleStatusBadge",
    "continuousSkillNameMapping",
)
player_deployable_markers = enum_cases(battle_view_source, "PlayerBattleDeployable")
player_deployable_mappings = swift_tuple_mappings(
    battle_view_source,
    "PlayerBattleDeployable",
    "skillNameMapping",
)

battle_scene_expected_width = static_number(battle_view_source, "BattleSceneMetrics", "expectedPopoverContentWidth")
battle_scene_compact_height = static_number(battle_view_source, "BattleSceneMetrics", "compactHeight")
battle_scene_ground_platform_ratio = static_number(battle_view_source, "BattleSceneMetrics", "groundPlatformWidthRatio")
battle_log_visible_entry_limit = static_number(battle_view_source, "BattleLogMetrics", "visibleEntryLimit")
battle_log_panel_height = static_number(battle_view_source, "BattleLogMetrics", "panelHeight")

battle_scene_render_width_px = int((battle_scene_expected_width or 0) * 2)
battle_scene_render_height_px = int((battle_scene_compact_height or 0) * 2)
battle_scene_local_platform_width_percent = int(round((battle_scene_ground_platform_ratio or 0) * 100))
battle_log_visible_entries = int(battle_log_visible_entry_limit or 0)
battle_log_panel_height_value = int(battle_log_panel_height or 0)

battle_scene_local_audit_guard = (
    "ground_platform_width_ratio = 0.90" in battle_scene_audit_source
    and "0.84 <= ground_width_to_image_ratio <= 0.96" in battle_scene_audit_source
    and "battle ground platform width no longer leaves only subtle side margins" in battle_scene_audit_source
    and "stage_pill_text_pixels" in battle_scene_audit_source
    and "stage_pill_dark_pixels" in battle_scene_audit_source
)
battle_scene_self_test_guard = (
    "BattleSceneMetrics.groundPlatformWidthRatio >= 0.86" in self_test_source
    and "BattleSceneMetrics.groundPlatformWidthRatio <= 0.94" in self_test_source
    and "battle scene keeps only subtle dark side margins around the ground platform" in self_test_source
)
battle_log_self_test_guard = (
    "BattleLogMetrics.visibleEntryLimit >= 8" in self_test_source
    and "BattleLogMetrics.panelHeight >= 116" in self_test_source
    and "battle tab reserves visible space for recent combat log entries" in self_test_source
)
if not battle_scene_local_audit_guard:
    issues.append("Local battle-scene audit must gate the current subtle-side-margin platform and stage pill")
if not battle_scene_self_test_guard:
    issues.append("SelfTest must guard the current subtle-side-margin battle scene geometry")
if not battle_log_self_test_guard:
    issues.append("SelfTest must guard visible battle log capacity and panel height")

player_status_badge_set = set(player_status_badges)
for skill_name, badge_name in player_status_active_mappings + player_status_continuous_mappings:
    if badge_name not in player_status_badge_set:
        issues.append(f"player status mapping for {skill_name} references missing badge {badge_name}")

runtime_continuous_skill_names = {
    skill["name"]
    for skill in skills
    if skill["activation"] == "continuous"
}
mapped_continuous_skill_names = {
    skill_name
    for skill_name, _ in player_status_continuous_mappings
}
missing_continuous_status_skills = sorted(runtime_continuous_skill_names - mapped_continuous_skill_names)
extra_continuous_status_skills = sorted(mapped_continuous_skill_names - runtime_continuous_skill_names)
if missing_continuous_status_skills:
    issues.append(
        "continuous runtime skills missing player status badges: "
        + ", ".join(missing_continuous_status_skills)
    )
if extra_continuous_status_skills:
    issues.append(
        "player continuous status badges reference non-continuous runtime skills: "
        + ", ".join(extra_continuous_status_skills)
    )

player_deployable_set = set(player_deployable_markers)
for skill_name, marker_name in player_deployable_mappings:
    if marker_name not in player_deployable_set:
        issues.append(f"player deployable mapping for {skill_name} references missing marker {marker_name}")

rows = [
    ("hero_classes", len(hero_classes), ORIGINAL["hero_classes"], CURRENT_BASELINE["hero_classes"], "modeled class enum"),
    ("source_skill_catalog_entries", len(source_skills), ORIGINAL["active_skills"], CURRENT_BASELINE["source_skill_catalog"], "checked active/base/monster source rows"),
    ("source_skill_review_rows", len(source_skills) if source_skill_database_view else 0, ORIGINAL["active_skills"], CURRENT_BASELINE["source_skill_review_rows"], "settings source skill review table rows"),
    ("runtime_active_skills", len(skills), ORIGINAL["active_skills"], CURRENT_BASELINE["active_skills"], "runtime-modeled named hero active skills"),
    ("active_skill_value_tables", len(skills_with_full_tables), len(skills), CURRENT_BASELINE["modeled_skill_level_tables"], "10-level value tables for modeled skills"),
    ("passive_skills", len(passive_skills), ORIGINAL["passive_skills"], CURRENT_BASELINE["passive_skills"], "checked passive skill catalog rows"),
    ("passive_runtime_stat_hooks", len(passive_runtime_hooked_stats), len(passive_stats_used), CURRENT_BASELINE["passive_runtime_stat_hooks"], "source passive stat kinds with explicit runtime hooks"),
    ("source_rune_nodes", len(source_runes), ORIGINAL["rune_nodes"], CURRENT_BASELINE["source_rune_nodes"], "checked Rune Tree source catalog rows"),
    ("source_rune_connections", source_rune_connection_count, ORIGINAL["rune_connections"], CURRENT_BASELINE["source_rune_connections"], "checked Rune Tree source next edges"),
    ("source_rune_next_out_degree_kinds", len(source_rune_next_out_degree_distribution), len(ORIGINAL["rune_next_out_degree_distribution"]), None, "checked Rune Tree Next out-degree distribution keys"),
    ("source_rune_previous_refs", source_rune_previous_reference_count, ORIGINAL["rune_previous_refs"], CURRENT_BASELINE["source_rune_previous_refs"], "checked Rune Tree source previous refs"),
    ("source_rune_previous_ref_nodes", len(source_rune_previous_reference_map), len(ORIGINAL["rune_previous_reference_map"]), None, "checked Rune Tree nodes with sparse Previous refs"),
    ("source_rune_max_level_kinds", len(source_rune_max_level_distribution), len(ORIGINAL["rune_max_level_distribution"]), None, "checked Rune Tree max-level distribution keys"),
    ("source_rune_icon_distribution", sum(source_rune_icon_distribution.values()), ORIGINAL["rune_nodes"], CURRENT_BASELINE["source_rune_nodes"], "checked Rune Tree icon-family distribution"),
    ("interactive_rune_nodes", len(rune_nodes), None, CURRENT_BASELINE["interactive_rune_nodes"], "runtime-unlockable Rune Tree nodes"),
    ("runtime_rune_source_nodes", len(runtime_rune_source_rows), ORIGINAL["rune_nodes"], CURRENT_BASELINE["runtime_rune_source_nodes"], "runtime-modeled source Rune Tree nodes"),
    ("data_only_rune_source_nodes", len(data_only_rune_source_rows), ORIGINAL["rune_nodes"], CURRENT_BASELINE["data_only_rune_source_nodes"], "source Rune Tree rows without runtime behavior"),
    ("source_rune_review_rows", len(source_runes) if source_rune_database_view else 0, ORIGINAL["rune_nodes"], CURRENT_BASELINE["source_rune_review_rows"], "settings source-data review table rows"),
    ("runtime_rune_icon_families", len(runtime_rune_icon_families), len(source_rune_icon_names), CURRENT_BASELINE["runtime_rune_icon_families"], "source Rune Tree icon families used by runtime nodes"),
    ("unmodeled_only_rune_icon_families", len(unmodeled_only_rune_icon_families), len(source_rune_icon_names), CURRENT_BASELINE["unmodeled_only_rune_icon_families"], "source Rune Tree icon families that remain data-only"),
    ("rune_dependency_edges", len(rune_dependency_edges), None, None, "modeled local prerequisites"),
    ("rune_required_hero_level", rune_required_hero_level, None, CURRENT_BASELINE["rune_required_hero_level"], "checked local Rune Tree level gate"),
    ("rune_party_slot_verified_gold_total", rune_party_slot_verified_gold_total, None, CURRENT_BASELINE["rune_party_slot_verified_gold_total"], "verified Rune of Command gold total for slots 2 and 3"),
    ("rune_direct_party_slot_3_gold", rune_direct_party_slot_3_gold, None, CURRENT_BASELINE["rune_direct_party_slot_3_gold"], "direct unlock path for party slots 2 and 3"),
    ("rune_active_skill_slot_count", rune_active_skill_slot_count, None, CURRENT_BASELINE["rune_active_skill_slot_count"], "Rune of Awakening active-skill slot scaffold"),
    ("rune_inventory_slot_bonus", rune_inventory_slot_bonus, None, CURRENT_BASELINE["rune_inventory_slot_bonus"], "first Rune of Expansion inventory-capacity scaffold"),
    ("rune_offline_boost_percent", rune_offline_boost_percent, None, CURRENT_BASELINE["rune_offline_boost_percent"], "first checked offline gold/XP boost percent"),
    ("rune_unverified_cost_nodes", rune_unverified_cost_nodes, None, CURRENT_BASELINE["rune_unverified_cost_nodes"], "runtime Rune nodes still marked cost-unverified"),
    ("rune_approximate_cost_nodes", rune_approximate_cost_nodes, None, CURRENT_BASELINE["rune_approximate_cost_nodes"], "runtime Rune nodes with approximate cost only"),
    ("direct_inventory_expansion_slot_bonus", direct_inventory_expansion_slot_bonus, None, CURRENT_BASELINE["direct_inventory_expansion_slot_bonus"], "repeatable direct backpack expansion slot bonus"),
    ("direct_inventory_expansion_base_gold_cost", direct_inventory_expansion_base_gold_cost, None, CURRENT_BASELINE["direct_inventory_expansion_base_gold_cost"], "repeatable direct backpack expansion base cost"),
    ("worse_equipment_handling_modes", worse_equipment_handling_modes, None, CURRENT_BASELINE["worse_equipment_handling_modes"], "keep/alchemy/discard weaker loot handling modes"),
    ("acts", len(chapter_cases), ORIGINAL["acts"], CURRENT_BASELINE["acts"], "Chapter enum"),
    ("display_stages", display_stage_count, ORIGINAL["stages"], CURRENT_BASELINE["display_stages"], "StageDefinition.all navigation skeleton"),
    ("runtime_stage_rows", len(set(stage_codes)), ORIGINAL["difficulty_stage_rows"], CURRENT_BASELINE["runtime_stage_rows"], "mined difficulty-stage data rows"),
    ("source_stage_review_rows", len(set(stage_codes)) if source_stage_database_view else 0, ORIGINAL["difficulty_stage_rows"], CURRENT_BASELINE["source_stage_review_rows"], "settings mined stage source-data review table rows"),
    ("stage_composition_rows", len(set(composition_codes)), ORIGINAL["difficulty_stage_rows"], None, "mined composition rows"),
    ("stage_composition_names", len(composition_names), None, 49, "unique names in mined composition rows"),
    ("difficulty_tiers", len(difficulty_cases), ORIGINAL["difficulty_tiers"], CURRENT_BASELINE["difficulty_tiers"], "Difficulty enum"),
    ("item_rarities", len(rarity_cases), ORIGINAL["item_rarities"], CURRENT_BASELINE["item_rarities"], "Rarity enum"),
    ("equipment_types", len(equipment_types), ORIGINAL["equipment_types"], CURRENT_BASELINE["equipment_types"], "EquipmentType enum"),
    ("active_equip_slots", len(equip_slots), None, CURRENT_BASELINE["equip_slots"], "EquipSlot.allCases"),
    ("source_gear_type_rows", len(source_gear_entries), ORIGINAL["equipment_types"], CURRENT_BASELINE["source_gear_type_rows"], "checked gear type pages"),
    ("source_gear_entry_aggregate", source_gear_entry_total, ORIGINAL["item_records"], CURRENT_BASELINE["source_gear_entry_aggregate"], "checked per-type aggregate gear counts"),
    ("source_gear_level_progressions", source_gear_level_progression_total, 396, CURRENT_BASELINE["source_gear_level_progressions"], "checked base item level IDs"),
    ("source_gear_rarity_distribution", source_gear_rarity_total, ORIGINAL["item_records"], CURRENT_BASELINE["source_gear_entry_aggregate"], "checked per-type rarity-count totals"),
    ("source_material_rows", len(source_materials), ORIGINAL["material_rows"], CURRENT_BASELINE["source_material_rows"], "checked material rows from item page"),
    ("source_material_categories", len(source_material_category_counts), ORIGINAL["material_categories"], CURRENT_BASELINE["source_material_categories"], "Decoration/Engraving/Inscription/Crafting/Offering/Soul Stone"),
    ("source_stage_chest_rows", len(source_stage_chests), ORIGINAL["stage_chests"], CURRENT_BASELINE["source_stage_chest_rows"], "checked stage chest rows from item page"),
    ("exact_item_records", len(exact_item_record_markers), ORIGINAL["item_records"], 0, "full per-rarity/per-affix item records still unavailable"),
    ("chest_catalog_entries", chest_catalog_entries, 59, None, "current chest-family catalog rows vs Wiki item rows"),
    ("chest_families", len(chest_families), 3, 3, "Normal/Stage Boss/Act Boss families"),
    ("soul_stone_kinds", len(soul_stones), 4, CURRENT_BASELINE["soul_stones"], "Soul Stone material kinds"),
    ("synthesis_input_count", synthesis_inputs, ORIGINAL["synthesis_inputs"], CURRENT_BASELINE["synthesis_inputs"], "checked same-rarity input count"),
    ("player_status_badges", len(player_status_badges), None, CURRENT_BASELINE["player_status_badges"], "compact player-side battle status badge cases"),
    ("player_active_status_mappings", len(player_status_active_mappings), None, CURRENT_BASELINE["player_active_status_mappings"], "active buff/summon/trap names visible in battle UI"),
    ("player_continuous_status_mappings", len(player_status_continuous_mappings), source_skill_activation_counts.get("CONTINUOUS", 0), CURRENT_BASELINE["player_continuous_status_mappings"], "source CONTINUOUS Priest blessings visible in battle UI"),
    ("player_deployable_markers", len(player_deployable_markers), None, CURRENT_BASELINE["player_deployable_markers"], "Hydra/trap/turret field markers"),
    ("battle_scene_render_width_px", battle_scene_render_width_px, None, CURRENT_BASELINE["battle_scene_render_width_px"], "deterministic battle scene render width"),
    ("battle_scene_render_height_px", battle_scene_render_height_px, None, CURRENT_BASELINE["battle_scene_render_height_px"], "deterministic battle scene render height"),
    ("battle_scene_local_platform_pct", battle_scene_local_platform_width_percent, None, CURRENT_BASELINE["battle_scene_local_platform_width_percent"], "local macOS subtle-side-margin platform ratio"),
    ("battle_log_visible_entries", battle_log_visible_entries, None, CURRENT_BASELINE["battle_log_visible_entries"], "recent combat log rows visible in battle tab"),
    ("battle_log_panel_height", battle_log_panel_height_value, None, CURRENT_BASELINE["battle_log_panel_height"], "reserved battle log panel height"),
]

print("source_files=" + ",".join(str(path) for path in [hero_path, skills_path, rune_path, stage_path, difficulty_path, chapter_path, item_path, inventory_path, loot_table_path, game_loop_path, save_manager_path, battle_path, monster_path, battle_view_path, inventory_view_path, settings_path]))
print("original_reference=Steam store and taskbarhero.org Wiki facts already recorded in docs/original-fidelity-review.md")
print()
print("area                         current       original      status      note")
print("---------------------------  ------------  ------------  ----------  ---------------------------------------------")
for name, count, original, expected_current, note in rows:
    status = status_for(count, original, expected_current)
    original_text = str(original) if original is not None else "n/a"
    current_text = str(count)
    if original is not None:
        current_text = ratio(count, original)
    print(f"{name:<27}  {current_text:<12}  {original_text:<12}  {status:<10}  {note}")

print()
print("source_skill_activations=" + ",".join(source_skill_activations))
print("source_skill_activation_counts=" + ",".join(f"{key}:{value}" for key, value in source_skill_activation_counts.items()))
print("source_skill_damage_types=" + ",".join(source_skill_damage_types))
print("source_skill_damage_counts=" + ",".join(f"{key}:{value}" for key, value in source_skill_damage_counts.items()))
print("source_skill_deliveries=" + ",".join(source_skill_deliveries))
print("source_skills_by_prefix=" + ",".join(f"{prefix}:{count}" for prefix, count in source_skills_by_prefix.items()))
print("runtime_skill_source_coverage=" + ratio(len(set(skill_ids) & set(source_skill_ids)), len(skill_ids)))
print("skill_activation_types=" + ",".join(activation_types_used))
print("skill_damage_elements=" + ",".join(damage_elements_used))
print("skill_deliveries=" + ",".join(deliveries_used))
print("skills_by_class_prefix=" + ",".join(f"{prefix}:{skills_by_class_prefix[prefix]}" for prefix in sorted(skills_by_class_prefix)))
print("passive_value_types=" + ",".join(passive_types_used))
print("passive_stat_count=" + str(len(passive_stats_used)))
print("passive_runtime_hooked_stats=" + (",".join(passive_runtime_hooked_stats) if passive_runtime_hooked_stats else "none"))
print("passive_runtime_unhooked_stats=" + ",".join(passive_runtime_unhooked_stats))
print("passive_skills_by_class_prefix=" + ",".join(f"{prefix}:{count}" for prefix, count in passive_skills_by_class_prefix.items()))
print("source_rune_icon_count=" + str(len(source_rune_icon_names)))
print("source_rune_icons=" + ",".join(source_rune_icon_names))
print("source_rune_next_out_degree_distribution=" + ",".join(f"{degree}:{count}" for degree, count in source_rune_next_out_degree_distribution.items()))
print("source_rune_previous_ref_count=" + str(source_rune_previous_reference_count))
print("source_rune_previous_reference_map=" + ",".join(f"{node}:{'/'.join(previous)}" for node, previous in source_rune_previous_reference_map.items()))
print("source_rune_max_level_distribution=" + ",".join(f"{level}:{count}" for level, count in source_rune_max_level_distribution.items()))
print("source_rune_icon_distribution=" + ",".join(f"{icon}:{count}" for icon, count in source_rune_icon_distribution.items()))
print("runtime_rune_source_node_coverage=" + ratio(len(runtime_rune_source_rows), len(source_runes)))
print("data_only_rune_source_nodes=" + str(len(data_only_rune_source_rows)))
print("runtime_rune_icon_family_coverage=" + ratio(len(runtime_rune_icon_families), len(source_rune_icon_names)))
print("unmodeled_only_rune_icon_families=" + str(len(unmodeled_only_rune_icon_families)))
print("shared_modeled_data_only_rune_icon_families=" + ",".join(shared_modeled_data_only_rune_icon_families))
print("rune_dependency_edges=" + ",".join(f"{source}->{target}" for source, target in rune_dependency_edges) if rune_dependency_edges else "rune_dependency_edges=none")
print("rune_required_hero_level=" + str(rune_required_hero_level))
print("rune_party_slot_verified_gold=slot2:" + str(rune_party_slot2_gold) + ",slot3:" + str(rune_party_slot3_gold))
print("rune_direct_party_slot_3_gold=" + str(rune_direct_party_slot_3_gold))
print("rune_active_skill_slot_count=" + str(rune_active_skill_slot_count))
print("rune_inventory_slot_bonus=" + str(rune_inventory_slot_bonus))
print("rune_offline_boost_percent=" + str(rune_offline_boost_percent))
print("rune_unverified_cost_nodes=" + ",".join(unverified_cost_nodes))
print("rune_approximate_cost_nodes=" + ",".join(approximate_cost_nodes))
print("direct_inventory_expansion_slot_bonus=" + str(direct_inventory_expansion_slot_bonus))
print("direct_inventory_expansion_base_gold_cost=" + str(direct_inventory_expansion_base_gold_cost))
print("direct_inventory_expansion_first_gold_cost=" + str(direct_inventory_expansion_first_gold_cost))
print("direct_inventory_expansion_second_gold_cost=" + str(direct_inventory_expansion_second_gold_cost))
print("direct_inventory_expansion_save_guard=" + ("enabled" if direct_inventory_expansion_save_guard else "missing"))
print("direct_inventory_expansion_self_test_guard=" + ("enabled" if self_test_direct_inventory_expansion_guard else "missing"))
print("worse_equipment_handling_modes=" + str(worse_equipment_handling_modes))
print("worse_equipment_runtime_guard=" + ("enabled" if worse_equipment_runtime_guard else "missing"))
print("worse_equipment_persistence_guard=" + ("enabled" if worse_equipment_persistence_guard else "missing"))
print("worse_equipment_ui_guard=" + ("enabled" if worse_equipment_ui_guard else "missing"))
print("worse_equipment_self_test_guard=" + ("enabled" if self_test_worse_equipment_guard else "missing"))
print("auto_normal_chest_runtime_guard=" + ("enabled" if auto_normal_chest_runtime_guard else "missing"))
print("auto_normal_chest_self_test_guard=" + ("enabled" if auto_normal_chest_self_test_guard else "missing"))
print("auto_stage_boss_chest_runtime_guard=" + ("enabled" if auto_stage_boss_chest_runtime_guard else "missing"))
print("auto_stage_boss_chest_self_test_guard=" + ("enabled" if auto_stage_boss_chest_self_test_guard else "missing"))
print("auto_act_boss_chest_runtime_guard=" + ("enabled" if auto_act_boss_chest_runtime_guard else "missing"))
print("auto_act_boss_chest_self_test_guard=" + ("enabled" if auto_act_boss_chest_self_test_guard else "missing"))
print("chest_capacity_runtime_guard=" + ("enabled" if chest_capacity_runtime_guard else "missing"))
print("chest_capacity_self_test_guard=" + ("enabled" if chest_capacity_self_test_guard else "missing"))
print("new_game_plus_runtime_guard=" + ("enabled" if new_game_plus_runtime_guard else "missing"))
print("new_game_plus_ui_guard=" + ("enabled" if new_game_plus_ui_guard else "missing"))
print("new_game_plus_self_test_guard=" + ("enabled" if new_game_plus_self_test_guard else "missing"))
print("ground_slam_rock_runtime_guard=" + ("enabled" if ground_slam_rock_runtime_guard else "missing"))
print("ground_slam_rock_visual_guard=" + ("enabled" if ground_slam_rock_visual_guard else "missing"))
print("ground_slam_rock_self_test_guard=" + ("enabled" if ground_slam_rock_self_test_guard else "missing"))
print("slayer_utility_visual_guard=" + ("enabled" if slayer_utility_visual_guard else "missing"))
print("slayer_utility_self_test_guard=" + ("enabled" if slayer_utility_self_test_guard else "missing"))
print("attack_speed_utility_visual_guard=" + ("enabled" if attack_speed_utility_visual_guard else "missing"))
print("attack_speed_utility_self_test_guard=" + ("enabled" if attack_speed_utility_self_test_guard else "missing"))
print("runtime_source_gear_progression_names=" + ("enabled" if source_progression_runtime_selector and loot_uses_source_progression_identity else "missing"))
print("source_gear_progression_icons=" + ("enabled" if source_gear_progression_icons else "missing"))
print("synthesis_preview_source_progression=" + ("enabled" if synthesis_preview_uses_source_progression else "missing"))
print("legacy_item_name_inference=" + ("enabled" if legacy_item_name_inference else "missing"))
print("support_sustained_skill_runtime=" + ("enabled" if support_sustained_skill_runtime else "missing"))
print("support_attack_count_skill_runtime=" + ("enabled" if support_attack_count_skill_runtime else "missing"))
print("source_base_attack_metadata=" + ("enabled" if source_base_attack_metadata else "missing"))
print("source_chaos_damage_metadata=" + ("enabled" if source_chaos_damage_metadata else "missing"))
print("source_chaos_battle_scene_audit=" + ("enabled" if source_chaos_battle_scene_audit else "missing"))
print("source_monster_attack_metadata=" + ("enabled" if source_monster_attack_metadata else "missing"))
print("source_monster_incoming_visual_audit=" + ("enabled" if source_monster_incoming_visual_audit else "missing"))
print("source_gear_rarity_counts=" + ",".join(f"{key}:{source_gear_rarity_counts[key]}" for key in sorted(source_gear_rarity_counts)))
print("source_material_category_counts=" + ",".join(f"{key}:{source_material_category_counts[key]}" for key in sorted(source_material_category_counts)))
print("source_material_rarity_counts=" + ",".join(f"{key}:{source_material_rarity_counts[key]}" for key in sorted(source_material_rarity_counts)))
print("source_stage_chest_rarity_counts=" + ",".join(f"{key}:{source_stage_chest_rarity_counts[key]}" for key in sorted(source_stage_chest_rarity_counts)))
print("source_soul_stone_ids=" + ",".join(source_soul_stone_ids))
print("stage_code_span=" + (f"{min(stage_codes)}..{max(stage_codes)}" if stage_codes else "none"))
print("composition_name_count=" + str(len(composition_names)))
print("player_status_badge_cases=" + ",".join(player_status_badges))
print("player_active_status_skill_names=" + ",".join(skill_name for skill_name, _ in player_status_active_mappings))
print("player_continuous_status_skill_names=" + ",".join(skill_name for skill_name, _ in player_status_continuous_mappings))
print("player_deployable_skill_names=" + ",".join(skill_name for skill_name, _ in player_deployable_mappings))
print("battle_scene_local_render_size=" + f"{battle_scene_render_width_px}x{battle_scene_render_height_px}")
print("battle_scene_local_platform_width_percent=" + str(battle_scene_local_platform_width_percent))
print("battle_scene_local_audit_guard=" + ("enabled" if battle_scene_local_audit_guard else "missing"))
print("battle_scene_self_test_guard=" + ("enabled" if battle_scene_self_test_guard else "missing"))
print("battle_log_visible_entries=" + str(battle_log_visible_entries))
print("battle_log_panel_height=" + str(battle_log_panel_height_value))
print("battle_log_self_test_guard=" + ("enabled" if battle_log_self_test_guard else "missing"))

if issues:
    print()
    for issue in issues:
        print(f"gameplay_fidelity_issue={issue}", file=sys.stderr)
    sys.exit(1)

print("local gameplay fidelity audit passed")
PY
