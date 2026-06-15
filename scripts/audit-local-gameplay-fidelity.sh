#!/usr/bin/env bash
set -euo pipefail

hero_swift="${HERO_SWIFT:-Sources/Game/Character/Hero.swift}"
skills_swift="${SKILLS_SWIFT:-Sources/Game/Character/Skills.swift}"
rune_swift="${RUNE_SWIFT:-Sources/Game/Progress/RuneTree.swift}"
stage_swift="${STAGE_SWIFT:-Sources/Game/Progress/Stage.swift}"
difficulty_swift="${DIFFICULTY_SWIFT:-Sources/Game/Progress/Difficulty.swift}"
chapter_swift="${CHAPTER_SWIFT:-Sources/Game/Progress/Chapter.swift}"
item_swift="${ITEM_SWIFT:-Sources/Game/Inventory/Item.swift}"
loot_table_swift="${LOOT_TABLE_SWIFT:-Sources/Game/Inventory/LootTable.swift}"
battle_view_swift="${BATTLE_VIEW_SWIFT:-Sources/UI/Panels/BattleView.swift}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$hero_swift" "$skills_swift" "$rune_swift" "$stage_swift" "$difficulty_swift" "$chapter_swift" "$item_swift" "$loot_table_swift" "$battle_view_swift" <<'PY'
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
loot_table_path = Path(sys.argv[8])
battle_view_path = Path(sys.argv[9])

for path in [hero_path, skills_path, rune_path, stage_path, difficulty_path, chapter_path, item_path, loot_table_path, battle_view_path]:
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
loot_table_source = loot_table_path.read_text(encoding="utf-8")
battle_view_source = battle_view_path.read_text(encoding="utf-8")

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
    "active_skills": 36,
    "modeled_skill_level_tables": 36,
    "passive_skills": 108,
    "source_rune_nodes": 197,
    "source_rune_connections": 195,
    "source_rune_previous_refs": 11,
    "interactive_rune_nodes": 9,
    "acts": 3,
    "display_stages": 30,
    "runtime_stage_rows": 120,
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
if not source_progression_runtime_selector:
    issues.append("SourceItemCatalog must expose runtime source gear progression selection")
if not loot_uses_source_progression_identity:
    issues.append("LootTable.makeItem must use checked source base gear progression name/id")
if not synthesis_preview_uses_source_progression:
    issues.append("SynthesisPreview must expose checked source base gear progression identity")

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
    ("runtime_active_skills", len(skills), ORIGINAL["active_skills"], CURRENT_BASELINE["active_skills"], "runtime-modeled named hero active skills"),
    ("active_skill_value_tables", len(skills_with_full_tables), len(skills), CURRENT_BASELINE["modeled_skill_level_tables"], "10-level value tables for modeled skills"),
    ("passive_skills", len(passive_skills), ORIGINAL["passive_skills"], CURRENT_BASELINE["passive_skills"], "checked passive skill catalog rows"),
    ("source_rune_nodes", len(source_runes), ORIGINAL["rune_nodes"], CURRENT_BASELINE["source_rune_nodes"], "checked Rune Tree source catalog rows"),
    ("source_rune_connections", source_rune_connection_count, ORIGINAL["rune_connections"], CURRENT_BASELINE["source_rune_connections"], "checked Rune Tree source next edges"),
    ("source_rune_next_out_degree_kinds", len(source_rune_next_out_degree_distribution), len(ORIGINAL["rune_next_out_degree_distribution"]), None, "checked Rune Tree Next out-degree distribution keys"),
    ("source_rune_previous_refs", source_rune_previous_reference_count, ORIGINAL["rune_previous_refs"], CURRENT_BASELINE["source_rune_previous_refs"], "checked Rune Tree source previous refs"),
    ("source_rune_previous_ref_nodes", len(source_rune_previous_reference_map), len(ORIGINAL["rune_previous_reference_map"]), None, "checked Rune Tree nodes with sparse Previous refs"),
    ("source_rune_max_level_kinds", len(source_rune_max_level_distribution), len(ORIGINAL["rune_max_level_distribution"]), None, "checked Rune Tree max-level distribution keys"),
    ("source_rune_icon_distribution", sum(source_rune_icon_distribution.values()), ORIGINAL["rune_nodes"], CURRENT_BASELINE["source_rune_nodes"], "checked Rune Tree icon-family distribution"),
    ("interactive_rune_nodes", len(rune_nodes), None, CURRENT_BASELINE["interactive_rune_nodes"], "runtime-unlockable Rune Tree nodes"),
    ("rune_dependency_edges", len(rune_dependency_edges), None, None, "modeled local prerequisites"),
    ("acts", len(chapter_cases), ORIGINAL["acts"], CURRENT_BASELINE["acts"], "Chapter enum"),
    ("display_stages", display_stage_count, ORIGINAL["stages"], CURRENT_BASELINE["display_stages"], "StageDefinition.all navigation skeleton"),
    ("runtime_stage_rows", len(set(stage_codes)), ORIGINAL["difficulty_stage_rows"], CURRENT_BASELINE["runtime_stage_rows"], "mined difficulty-stage data rows"),
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
]

print("source_files=" + ",".join(str(path) for path in [hero_path, skills_path, rune_path, stage_path, difficulty_path, chapter_path, item_path, loot_table_path, battle_view_path]))
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
print("passive_skills_by_class_prefix=" + ",".join(f"{prefix}:{count}" for prefix, count in passive_skills_by_class_prefix.items()))
print("source_rune_icon_count=" + str(len(source_rune_icon_names)))
print("source_rune_icons=" + ",".join(source_rune_icon_names))
print("source_rune_next_out_degree_distribution=" + ",".join(f"{degree}:{count}" for degree, count in source_rune_next_out_degree_distribution.items()))
print("source_rune_previous_ref_count=" + str(source_rune_previous_reference_count))
print("source_rune_previous_reference_map=" + ",".join(f"{node}:{'/'.join(previous)}" for node, previous in source_rune_previous_reference_map.items()))
print("source_rune_max_level_distribution=" + ",".join(f"{level}:{count}" for level, count in source_rune_max_level_distribution.items()))
print("source_rune_icon_distribution=" + ",".join(f"{icon}:{count}" for icon, count in source_rune_icon_distribution.items()))
print("rune_dependency_edges=" + ",".join(f"{source}->{target}" for source, target in rune_dependency_edges) if rune_dependency_edges else "rune_dependency_edges=none")
print("runtime_source_gear_progression_names=" + ("enabled" if source_progression_runtime_selector and loot_uses_source_progression_identity else "missing"))
print("synthesis_preview_source_progression=" + ("enabled" if synthesis_preview_uses_source_progression else "missing"))
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

if issues:
    print()
    for issue in issues:
        print(f"gameplay_fidelity_issue={issue}", file=sys.stderr)
    sys.exit(1)

print("local gameplay fidelity audit passed")
PY
