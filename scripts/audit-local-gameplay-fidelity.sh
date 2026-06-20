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
menu_bar_popover_swift="${MENU_BAR_POPOVER_SWIFT:-Sources/UI/MenuBar/MenuBarPopover.swift}"
inventory_view_swift="${INVENTORY_VIEW_SWIFT:-Sources/UI/Panels/InventoryView.swift}"
character_view_swift="${CHARACTER_VIEW_SWIFT:-Sources/UI/Panels/CharacterView.swift}"
battle_scene_snapshot_swift="${BATTLE_SCENE_SNAPSHOT_SWIFT:-Sources/App/BattleSceneSnapshot.swift}"
self_test_swift="${SELF_TEST_SWIFT:-Sources/App/SelfTest.swift}"
resource_self_test_swift="${RESOURCE_SELF_TEST_SWIFT:-Sources/App/ResourceSelfTest.swift}"
game_audio_swift="${GAME_AUDIO_SWIFT:-Sources/App/GameAudio.swift}"
sfx_manifest="${SFX_MANIFEST:-Sources/Resources/Extracted/sfx/sfx_manifest.tsv}"
battle_scene_audit_sh="${BATTLE_SCENE_AUDIT_SH:-scripts/audit-local-battle-scene.sh}"
steam_battle_scene_audit_sh="${STEAM_BATTLE_SCENE_AUDIT_SH:-scripts/audit-steam-battle-scene.sh}"
hero_sprite_audit_sh="${HERO_SPRITE_AUDIT_SH:-scripts/audit-local-hero-sprites.sh}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"
settings_swift="${SETTINGS_SWIFT:-Sources/UI/Panels/SettingsView.swift}"
source_gear_manifest="${SOURCE_GEAR_MANIFEST:-Sources/Resources/Extracted/source_gear_icons.tsv}"
combat_stats_tests_swift="${COMBAT_STATS_TESTS_SWIFT:-Tests/GameTests/CombatStatsTests.swift}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$hero_swift" "$skills_swift" "$rune_swift" "$stage_swift" "$difficulty_swift" "$chapter_swift" "$item_swift" "$inventory_swift" "$loot_table_swift" "$game_loop_swift" "$save_manager_swift" "$battle_swift" "$monster_swift" "$battle_view_swift" "$menu_bar_popover_swift" "$inventory_view_swift" "$character_view_swift" "$battle_scene_snapshot_swift" "$self_test_swift" "$resource_self_test_swift" "$game_audio_swift" "$sfx_manifest" "$battle_scene_audit_sh" "$steam_battle_scene_audit_sh" "$hero_sprite_audit_sh" "$game_art_swift" "$settings_swift" "$source_gear_manifest" "$combat_stats_tests_swift" <<'PY'
import re
import math
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
menu_bar_popover_path = Path(sys.argv[15])
inventory_view_path = Path(sys.argv[16])
character_view_path = Path(sys.argv[17])
battle_scene_snapshot_path = Path(sys.argv[18])
self_test_path = Path(sys.argv[19])
resource_self_test_path = Path(sys.argv[20])
game_audio_path = Path(sys.argv[21])
sfx_manifest_path = Path(sys.argv[22])
battle_scene_audit_path = Path(sys.argv[23])
steam_battle_scene_audit_path = Path(sys.argv[24])
hero_sprite_audit_path = Path(sys.argv[25])
game_art_path = Path(sys.argv[26])
settings_path = Path(sys.argv[27])
source_gear_manifest_path = Path(sys.argv[28])
combat_stats_tests_path = Path(sys.argv[29])

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
    menu_bar_popover_path,
    inventory_view_path,
    character_view_path,
    battle_scene_snapshot_path,
    self_test_path,
    resource_self_test_path,
    game_audio_path,
    sfx_manifest_path,
    battle_scene_audit_path,
    steam_battle_scene_audit_path,
    hero_sprite_audit_path,
    game_art_path,
    settings_path,
    source_gear_manifest_path,
    combat_stats_tests_path,
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
game_state_source = Path("Sources/Game/Engine/GameState.swift").read_text(encoding="utf-8")
game_pacing_source = Path("Sources/Game/Engine/GamePacing.swift").read_text(encoding="utf-8")
party_source = Path("Sources/Game/Character/Party.swift").read_text(encoding="utf-8")
save_manager_source = save_manager_path.read_text(encoding="utf-8")
battle_source = battle_path.read_text(encoding="utf-8")
monster_source = monster_path.read_text(encoding="utf-8")
battle_view_source = battle_view_path.read_text(encoding="utf-8")
menu_bar_popover_source = menu_bar_popover_path.read_text(encoding="utf-8")
inventory_view_source = inventory_view_path.read_text(encoding="utf-8")
character_view_source = character_view_path.read_text(encoding="utf-8")
battle_scene_snapshot_source = battle_scene_snapshot_path.read_text(encoding="utf-8")
self_test_source = self_test_path.read_text(encoding="utf-8")
resource_self_test_source = resource_self_test_path.read_text(encoding="utf-8")
game_audio_source = game_audio_path.read_text(encoding="utf-8")
battle_scene_audit_source = battle_scene_audit_path.read_text(encoding="utf-8")
steam_battle_scene_audit_source = steam_battle_scene_audit_path.read_text(encoding="utf-8")
hero_sprite_audit_source = hero_sprite_audit_path.read_text(encoding="utf-8")
game_art_source = game_art_path.read_text(encoding="utf-8")
settings_source = settings_path.read_text(encoding="utf-8")
combat_stats_tests_source = combat_stats_tests_path.read_text(encoding="utf-8")
source_gear_manifest_lines = [
    line
    for line in source_gear_manifest_path.read_text(encoding="utf-8").splitlines()
    if line.strip()
]
sfx_manifest_lines = [
    line
    for line in sfx_manifest_path.read_text(encoding="utf-8").splitlines()
    if line.strip()
]

def swift_call_blocks(source, callee):
    token = f"{callee}("
    search_index = 0
    while True:
        start_index = source.find(token, search_index)
        if start_index == -1:
            return

        depth = 0
        in_string = False
        is_escaped = False
        for index in range(start_index + len(callee), len(source)):
            character = source[index]
            if in_string:
                if is_escaped:
                    is_escaped = False
                elif character == "\\":
                    is_escaped = True
                elif character == "\"":
                    in_string = False
                continue

            if character == "\"":
                in_string = True
                continue
            if character == "(":
                depth += 1
                continue
            if character == ")":
                depth -= 1
                if depth == 0:
                    yield start_index, source[start_index:index + 1]
                    search_index = index + 1
                    break
        else:
            yield start_index, source[start_index:]
            return

def source_line_number(source, offset):
    return source.count("\n", 0, offset) + 1

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
    "monster_types_min": 50,
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
    "battle_hero_sprite_resources": 6,
    "battle_hero_source_sprite_resources": 6,
    "source_skill_catalog": 106,
    "source_skill_review_rows": 106,
    "active_skills": 36,
    "hero_base_attack_skills": 6,
    "runtime_hero_skill_source_rows": 42,
    "runtime_monster_attack_skills": 4,
    "runtime_modeled_source_skills": 46,
    "modeled_skill_level_tables": 36,
    "source_skill_damage_buckets": 5,
    "source_skill_physical_damage": 77,
    "source_skill_non_physical_damage_runtime": 15,
    "source_skill_chaos_damage_runtime": 1,
    "source_skill_most_common_damage_count": 77,
    "source_skill_activation_damage_pairs": 14,
    "source_skill_activation_damage_runtime_pairs": 13,
    "source_skill_baseattack_physical_pending": 37,
    "source_skill_cooldown_chaos_runtime": 0,
    "source_skill_cooldown_chaos_pending": 3,
    "source_skill_cooldown_chaos_value_rows": 3,
    "pending_source_skill_cooldown_chaos_page_rows": 3,
    "pending_source_skill_cooldown_chaos_locale_pages": 6,
    "pending_source_skill_cooldown_chaos_empty_delivery": 3,
    "pending_source_skill_cooldown_chaos_unnamed": 3,
    "source_skill_activation_delivery_pairs": 16,
    "source_skill_activation_delivery_runtime_pairs": 15,
    "source_skill_baseattack_empty_delivery_pending": 48,
    "source_skill_attackcount_empty_delivery_runtime": 0,
    "source_skill_damage_delivery_pairs": 20,
    "source_skill_damage_delivery_runtime_pairs": 20,
    "source_skill_empty_delivery_runtime": 11,
    "source_skill_physical_empty_delivery_pending": 46,
    "source_skill_chaos_empty_delivery_pending": 7,
    "source_skill_delivery_buckets": 8,
    "source_skill_empty_delivery": 71,
    "source_skill_non_empty_delivery_runtime": 35,
    "source_skill_most_common_delivery_count": 71,
    "source_skill_range_buckets": 24,
    "source_skill_min_range": 120,
    "source_skill_max_range": 1650,
    "source_skill_most_common_range_count": 16,
    "local_skill_runtime_coverage_source": 106,
    "local_skill_runtime_coverage_modeled": 46,
    "local_skill_runtime_coverage_pending": 60,
    "local_skill_runtime_coverage_rows": 4,
    "local_skill_runtime_coverage_hero_named": 36,
    "local_skill_runtime_coverage_hero_base": 6,
    "local_skill_runtime_coverage_monster": 4,
    "pending_source_skill_review_rows": 60,
    "pending_source_skill_empty_delivery": 60,
    "pending_source_skill_activation_buckets": 3,
    "pending_source_skill_damage_buckets": 4,
    "pending_source_skill_prefix_buckets": 3,
    "pending_source_skill_responsibility_buckets": 4,
    "pending_source_skill_six_digit_unnamed": 60,
    "pending_source_skill_damage_candidate_manifest": 60,
    "pending_source_skill_physical_damage_candidate_manifest": 46,
    "pending_source_skill_elemental_damage_candidate_manifest": 14,
    "pending_source_skill_fire_damage_candidate_manifest": 6,
    "pending_source_skill_cold_damage_candidate_manifest": 1,
    "pending_source_skill_chaos_damage_candidate_manifest": 7,
    "pending_source_skill_base_attack_candidates": 48,
    "pending_source_skill_base_attack_candidate_manifest": 48,
    "pending_source_skill_triggered_candidates": 12,
    "pending_source_skill_triggered_candidate_manifest": 12,
    "pending_source_skill_triggered_value_rows": 12,
    "pending_source_skill_valued_candidates": 15,
    "pending_source_skill_valued_empty_delivery": 15,
    "pending_source_skill_valued_unnamed": 15,
    "pending_source_skill_catalog_only": 45,
    "pending_source_skill_value_range_only": 15,
    "pending_source_skill_minimum_evidence": 0,
    "pending_source_skill_runtime_proof_rows": 7,
    "pending_source_skill_runtime_proof_coverage": 60,
    "pending_source_skill_runtime_proof_catalog": 60,
    "pending_source_skill_runtime_proof_value_range": 15,
    "pending_source_skill_runtime_proof_minimum_ready": 0,
    "pending_source_skill_runtime_proof_name_missing": 60,
    "pending_source_skill_runtime_proof_delivery_missing": 60,
    "pending_source_skill_runtime_proof_ownership_formula_missing": 60,
    "pending_source_skill_runtime_proof_animation_missing": 60,
    "pending_source_skill_runtime_proof_sfx_missing": 60,
    "pending_source_skill_runtime_gates": 7,
    "pending_source_skill_evidence_queues": 3,
    "pending_source_skill_evidence_queue_coverage": 60,
    "pending_source_skill_activation_damage_queues": 7,
    "pending_source_skill_activation_damage_queue_coverage": 60,
    "pending_source_skill_activation_damage_value_coverage": 15,
    "pending_source_skill_activation_damage_empty_delivery": 60,
    "pending_source_skill_range_evidence_queues": 13,
    "pending_source_skill_range_evidence_queue_coverage": 60,
    "pending_source_skill_range_evidence_value_coverage": 15,
    "pending_source_skill_range_evidence_empty_delivery": 60,
    "pending_source_skill_prefix_evidence_queues": 3,
    "pending_source_skill_prefix_evidence_queue_coverage": 60,
    "pending_source_skill_prefix_evidence_value_coverage": 15,
    "pending_source_skill_prefix_evidence_empty_delivery": 60,
    "pending_source_skill_value_evidence_queues": 8,
    "pending_source_skill_value_evidence_queue_coverage": 15,
    "pending_source_skill_value_evidence_empty_delivery": 15,
    "pending_source_skill_visual_priority_queues": 4,
    "pending_source_skill_visual_priority_entries": 22,
    "pending_source_skill_visual_priority_elemental": 14,
    "pending_source_skill_visual_priority_cooldown_chaos": 3,
    "pending_source_skill_visual_priority_unmapped_monster": 3,
    "pending_source_skill_visual_priority_highest_value": 2,
    "pending_source_skill_visual_priority_unique": 16,
    "pending_source_skill_visual_priority_overlap": 6,
    "pending_source_skill_visual_priority_unqueued": 44,
    "pending_source_skill_visual_review_total_queues": 6,
    "pending_source_skill_visual_review_total_coverage": 60,
    "pending_source_skill_visual_priority_unqueued_queues": 2,
    "pending_source_skill_visual_priority_unqueued_queue_coverage": 44,
    "pending_source_skill_visual_priority_unqueued_value": 8,
    "pending_source_skill_visual_priority_unqueued_empty_delivery": 44,
    "pending_source_skill_visual_priority_unqueued_activation_buckets": 3,
    "pending_source_skill_visual_priority_unqueued_damage_buckets": 1,
    "pending_source_skill_visual_priority_unqueued_range_buckets": 12,
    "pending_source_skill_value_range_queue": 15,
    "pending_source_skill_nonphysical_baseattack_queue": 9,
    "pending_source_skill_physical_baseattack_queue": 36,
    "pending_source_skill_value_evidence_rows": 15,
    "pending_source_skill_base_attack_evidence_rows": 45,
    "pending_source_skill_nonphysical_baseattack_evidence_rows": 9,
    "pending_source_skill_physical_baseattack_evidence_rows": 36,
    "pending_source_skill_unmapped_monster_candidates": 3,
    "pending_source_skill_unmapped_monster_candidate_empty_delivery": 3,
    "pending_source_skill_value_detail_pages": 15,
    "pending_source_skill_value_detail_locale_pages": 30,
    "pending_source_skill_highest_detail_pages": 2,
    "pending_source_skill_highest_detail_locale_pages": 4,
    "pending_source_skill_checked_monster_attacks": 4,
    "pending_source_skill_range_buckets": 13,
    "pending_source_skill_most_common_range": 150,
    "pending_source_skill_most_common_range_count": 10,
    "modeled_active_skill_value_review_rows": 36,
    "runtime_tick_interval_tenths": 10,
    "combat_simulation_step_centiseconds": 100,
    "combat_delta_multiplier_percent": 100,
    "runtime_xp_multiplier_percent": 35,
    "stage_level_buffer": 2,
    "minimum_attack_interval_tenths": 10,
    "minimum_hasted_attack_interval_centiseconds": 100,
    "passive_skills": 108,
    "passive_runtime_stat_hooks": 30,
    "source_rune_nodes": 197,
    "source_rune_connections": 195,
    "source_rune_previous_refs": 11,
    "interactive_rune_nodes": 197,
    "runtime_rune_source_nodes": 197,
    "data_only_rune_source_nodes": 0,
    "source_rune_review_rows": 197,
    "runtime_rune_icon_families": 39,
    "unmodeled_only_rune_icon_families": 0,
    "rune_required_hero_level": 3,
    "rune_party_slot_verified_gold_total": 200000,
    "rune_direct_party_slot_3_gold": 200000,
    "rune_active_skill_slot_count": 2,
    "rune_all_hero_attack_damage_bonus": 4,
    "rune_all_hero_attack_damage_percent_boost_percent": 30,
    "rune_all_hero_armor_bonus": 3,
    "rune_all_hero_armor_percent_boost_percent": 20,
    "rune_all_hero_move_speed_bonus": 5,
    "rune_all_hero_attack_speed_boost_percent": 30,
    "rune_combat_reward_runtime_nodes": 43,
    "rune_combat_reward_boost_percent": 160,
    "rune_cube_reward_runtime_nodes": 8,
    "rune_cube_reward_boost_percent": 40,
    "rune_inventory_expansion_runtime_nodes": 26,
    "rune_inventory_slot_bonus": 10,
    "rune_stash_page_runtime_nodes": 3,
    "rune_stash_page_slot_bonus": 20,
    "rune_stage_clear_target_reduction": 1,
    "rune_offline_boost_percent": 10,
    "rune_dependency_edges": 38,
    "rune_unverified_cost_nodes": 195,
    "rune_approximate_cost_nodes": 1,
    "local_rune_cost_review_rows": 197,
    "local_rune_cost_review_verified": 2,
    "local_rune_cost_review_approximate": 1,
    "local_rune_cost_review_approximate_source": 1,
    "local_rune_cost_review_approximate_evidence_rows": 1,
    "local_rune_cost_review_approximate_evidence_coverage": 1,
    "local_rune_cost_review_pending": 194,
    "local_rune_cost_review_pending_groups": 37,
    "local_rune_cost_review_pending_branches": 7,
    "local_rune_cost_review_evidence_gates": 6,
    "local_rune_cost_review_evidence_queues": 7,
    "local_rune_cost_review_evidence_queue_coverage": 194,
    "local_rune_cost_review_evidence_queue_group_coverage": 37,
    "local_rune_cost_review_branch_evidence_rows": 37,
    "local_rune_cost_review_branch_evidence_coverage": 194,
    "local_rune_cost_review_branch_evidence_group_coverage": 37,
    "local_rune_cost_review_max_level_evidence_queues": 5,
    "local_rune_cost_review_max_level_evidence_coverage": 194,
    "local_rune_cost_review_max_level_evidence_icon_buckets": 62,
    "source_rune_evidence_review_rows": 9,
    "source_rune_evidence_independent_sources": 6,
    "source_rune_evidence_verified_cost_rows": 2,
    "source_rune_evidence_candidate_cost_rows": 13,
    "source_rune_evidence_candidate_cost_gold_total": 383790000,
    "source_rune_tbh_city_candidate_cost_table_rows": 197,
    "source_rune_tbh_city_candidate_cost_table_gold_total": 10040515050,
    "source_rune_candidate_cost_queues": 4,
    "source_rune_candidate_cost_queue_coverage": 13,
    "source_rune_candidate_cost_queue_gold_total": 383790000,
    "source_rune_evidence_timer_rows": 1,
    "source_audio_sfx_evidence_rows": 6,
    "source_audio_sfx_event_gate_rows": 7,
    "source_audio_sfx_local_events": 11,
    "source_audio_sfx_local_resources": 11,
    "source_audio_sfx_original_isolated": 0,
    "source_audio_sfx_steam_duration_seconds": 47,
    "source_audio_sfx_steam_sample_rate_hz": 48000,
    "source_battle_animation_evidence_rows": 7,
    "source_battle_animation_motion_sample_rows": 4,
    "source_battle_animation_action_frame_gate_rows": 8,
    "source_battle_animation_official_width": 776,
    "source_battle_animation_official_height": 180,
    "source_battle_animation_official_fps": 30,
    "source_battle_animation_official_duration_ms": 6133,
    "source_battle_animation_official_frames": 184,
    "source_battle_animation_official_motion_sample_ms": 267,
    "source_battle_animation_official_motion_pixels": 26623,
    "source_battle_animation_official_platform_motion_pixels": 11920,
    "source_battle_animation_official_non_platform_motion_pixels": 14703,
    "source_battle_animation_official_motion_percent_x10000": 1906,
    "source_battle_animation_local_render_width_px": 1232,
    "source_battle_animation_local_render_height_px": 600,
    "source_battle_animation_local_battle_tab_width_px": 1280,
    "source_battle_animation_local_battle_tab_height_px": 1200,
    "source_battle_animation_local_ratio_x100": 205,
    "source_battle_animation_local_popover_width_pt": 640,
    "source_battle_animation_local_popover_height_pt": 600,
    "source_battle_animation_local_content_height_pt": 488,
    "source_battle_animation_local_battle_scene_height_pt": 300,
    "source_battle_animation_local_bottom_tab_height_pt": 46,
    "source_battle_animation_exact_action_frames": 0,
    "rune_auto_open_normal_base_cooldown_seconds": 300,
    "rune_auto_open_stage_boss_base_cooldown_seconds": 600,
    "rune_auto_open_act_boss_base_cooldown_seconds": 60,
    "rune_auto_open_normal_reduction_seconds": 39,
    "rune_auto_open_stage_boss_reduction_seconds": 75,
    "rune_auto_open_act_boss_reduction_seconds": 6,
    "direct_inventory_expansion_slot_bonus": 10,
    "direct_inventory_expansion_base_gold_cost": 50000,
    "direct_inventory_expansion_first_gold_cost": 50000,
    "direct_inventory_expansion_second_gold_cost": 100000,
    "worse_equipment_handling_modes": 3,
    "acts": 3,
    "display_stages": 30,
    "runtime_stage_rows": 120,
    "source_stage_review_rows": 120,
    "source_monster_database_rows": 61,
    "source_monster_database_unique_ids": 61,
    "source_monster_database_unique_names": 52,
    "source_monster_database_stage_coverage": 49,
    "source_monster_database_unmapped_stage_rows": 3,
    "source_monster_source_only_sprites": 3,
    "source_monster_source_only_sprite_preview_rows": 3,
    "source_monster_source_only_proof_rows": 3,
    "source_monster_source_only_proof_coverage": 3,
    "source_monster_source_stage_evidence_rows": 3,
    "source_monster_source_stage_appearance_confirmed": 2,
    "source_monster_source_stage_appearance_absent": 1,
    "source_monster_source_stage_appearance_rows_total": 14,
    "source_monster_source_stage_crosscheck_pages": 4,
    "source_monster_source_page_field_rows": 3,
    "source_monster_source_page_field_sprite_paths": 3,
    "source_monster_source_page_field_move_known": 3,
    "source_monster_source_page_field_damage_known": 1,
    "source_monster_source_page_field_range_known": 1,
    "source_monster_source_page_field_unknown_damage_range": 2,
    "source_monster_source_only_stage_proof_missing": 3,
    "source_monster_source_only_runtime_blocked": 3,
    "source_monster_source_only_skill_ownership_unproven": 3,
    "source_monster_source_only_animation_frame_missing": 3,
    "source_monster_source_only_sfx_missing": 3,
    "source_monster_unmapped_evidence_gates": 5,
    "source_monster_unmapped_evidence_queues": 3,
    "source_monster_unmapped_evidence_queue_coverage": 3,
    "source_monster_unmapped_candidate_skills": 3,
    "source_monster_database_missing_best_farm": 1,
    "source_monster_runtime_attack_coverage": 49,
    "source_monster_runtime_speed_coverage": 49,
    "source_monster_source_cooldown_min_tenths": 6,
    "source_monster_source_cooldown_max_tenths": 25,
    "source_monster_loop_cooldown_min_tenths": 10,
    "source_monster_loop_cooldown_max_tenths": 30,
    "source_monster_art_review_rows": 49,
    "source_monster_steam_minimum": 50,
    "source_monster_source_roster_steam_gap": 0,
    "source_monster_unchecked_roster_gap_minimum": 0,
    "source_monster_art_evidence_gates": 5,
    "source_monster_art_evidence_queues": 4,
    "source_monster_art_evidence_queue_coverage": 49,
    "source_monster_art_evidence_queue_roster_gap": 0,
    "source_monster_art_evidence_queue_source_roster_gap": 3,
    "source_monster_attack_review_rows": 4,
    "source_monster_attack_evidence_gates": 5,
    "difficulty_tiers": 4,
    "item_rarities": 10,
    "equipment_types": 20,
    "source_gear_type_rows": 20,
    "source_gear_entry_aggregate": 5760,
    "source_gear_level_progressions": 396,
    "exact_item_record_gap_review_rows": 4,
    "exact_item_record_gap_review_type_rows": 20,
    "exact_item_record_gap_evidence_gates": 5,
    "exact_item_record_gap_category_queues": 4,
    "exact_item_record_gap_rarity_queues": 10,
    "exact_item_record_gap_category_rarity_queues": 40,
    "exact_item_record_gap_progression_queues": 396,
    "exact_item_record_gap_type_queues": 20,
    "exact_item_record_gap_largest_type_queues": 16,
    "exact_item_record_gap_queue_coverage": 5760,
    "exact_item_record_gap_rarity_queue_coverage": 5760,
    "exact_item_record_gap_category_rarity_queue_coverage": 5760,
    "exact_item_record_gap_progression_queue_coverage": 396,
    "exact_item_record_gap_largest_type_queue_coverage": 4672,
    "exact_item_record_gap_review_aggregate": 5760,
    "exact_item_record_gap_review_progressions": 396,
    "exact_item_record_gap_review_missing": 5760,
    "original_fidelity_hard_gap_rows": 7,
    "source_material_rows": 115,
    "source_material_categories": 6,
    "source_stage_chest_rows": 59,
    "source_crafting_rule_review_rows": 10,
    "equip_slots": 10,
    "soul_stones": 4,
    "synthesis_inputs": 9,
    "player_status_badges": 16,
    "player_active_status_mappings": 14,
    "player_continuous_status_mappings": 2,
    "player_deployable_markers": 3,
    "support_formula_review_rows": 4,
    "support_formula_attack_scalar_percent": 35,
    "menu_bar_popover_default_width": 640,
    "menu_bar_popover_default_height": 600,
    "menu_bar_content_min_height": 488,
    "battle_scene_render_width_px": 1232,
    "battle_scene_render_height_px": 600,
    "battle_tab_layout_render_width_px": 1280,
    "battle_tab_layout_render_height_px": 1200,
    "inventory_panel_render_width_px": 1232,
    "inventory_panel_render_height_px": 1440,
    "character_panel_render_width_px": 1232,
    "character_panel_render_height_px": 976,
    "chest_panel_render_width_px": 1232,
    "chest_panel_render_height_px": 720,
    "original_fidelity_panel_render_width_px": 1232,
    "original_fidelity_panel_render_height_px": 1200,
    "rune_evidence_panel_render_width_px": 1232,
    "rune_evidence_panel_render_height_px": 1240,
    "skill_evidence_panel_render_width_px": 1232,
    "skill_evidence_panel_render_height_px": 1440,
    "passive_evidence_panel_render_width_px": 1232,
    "passive_evidence_panel_render_height_px": 1440,
    "battle_scene_configured_ratio_x100": 205,
    "battle_scene_local_platform_width_percent": 90,
    "battle_log_visible_entries": 50,
    "battle_log_panel_height": 168,
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

def nested_enum_cases(source: str, enum_name: str) -> list[str]:
    match = re.search(
        rf'enum\s+{re.escape(enum_name)}\b[^\{{]*\{{(?P<body>.*?)(?:\n\s{{4}}\}})',
        source,
        re.S,
    )
    if not match:
        issues.append(f"missing nested enum {enum_name}")
        return []

    cases: list[str] = []
    for line in match.group("body").splitlines():
        stripped = line.strip()
        if not stripped.startswith("case "):
            continue
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

LOCAL_GUARDED_METRICS = {
    "menu_bar_popover_default_width",
    "menu_bar_popover_default_height",
    "menu_bar_content_min_height",
    "battle_scene_render_width_px",
    "battle_scene_render_height_px",
    "battle_tab_layout_render_width_px",
    "battle_tab_layout_render_height_px",
    "inventory_panel_render_width_px",
    "inventory_panel_render_height_px",
    "character_panel_render_width_px",
    "character_panel_render_height_px",
    "chest_panel_render_width_px",
    "chest_panel_render_height_px",
    "original_fidelity_panel_render_width_px",
    "original_fidelity_panel_render_height_px",
    "rune_evidence_panel_render_width_px",
    "rune_evidence_panel_render_height_px",
    "skill_evidence_panel_render_width_px",
    "skill_evidence_panel_render_height_px",
    "passive_evidence_panel_render_width_px",
    "passive_evidence_panel_render_height_px",
    "battle_scene_configured_ratio_x100",
    "battle_scene_local_platform_pct",
    "battle_log_visible_entries",
    "battle_log_hero_highlight_entries",
    "battle_log_panel_height",
    "runtime_tick_interval_tenths",
    "combat_simulation_step_centiseconds",
    "combat_delta_multiplier_percent",
    "runtime_xp_multiplier_percent",
    "runtime_stage_level_buffer",
    "runtime_min_attack_interval_tenths",
    "runtime_min_hasted_attack_interval_centiseconds",
    "support_formula_review_rows",
    "support_formula_attack_scalar_percent",
    "source_rune_evidence_review_rows",
    "source_rune_evidence_independent_sources",
    "source_rune_evidence_verified_cost_rows",
    "source_rune_evidence_candidate_cost_rows",
    "source_rune_evidence_candidate_cost_gold_total",
    "source_rune_tbh_city_candidate_cost_table_rows",
    "source_rune_tbh_city_candidate_cost_table_gold_total",
    "source_rune_candidate_cost_queues",
    "source_rune_candidate_cost_queue_coverage",
    "source_rune_candidate_cost_queue_gold_total",
    "source_rune_evidence_timer_rows",
    "source_audio_sfx_evidence_rows",
    "source_audio_sfx_event_gate_rows",
    "source_audio_sfx_local_events",
    "source_audio_sfx_local_resources",
    "source_audio_sfx_original_isolated",
    "source_audio_sfx_steam_duration_seconds",
    "source_audio_sfx_steam_sample_rate_hz",
    "source_battle_animation_evidence_rows",
    "source_battle_animation_motion_sample_rows",
    "source_battle_animation_action_frame_gate_rows",
    "source_battle_animation_official_width",
    "source_battle_animation_official_height",
    "source_battle_animation_official_fps",
    "source_battle_animation_official_duration_ms",
    "source_battle_animation_official_frames",
    "source_battle_animation_official_motion_sample_ms",
    "source_battle_animation_official_motion_pixels",
    "source_battle_animation_official_platform_motion_pixels",
    "source_battle_animation_official_non_platform_motion_pixels",
    "source_battle_animation_official_motion_percent_x10000",
    "source_battle_animation_local_render_width_px",
    "source_battle_animation_local_render_height_px",
    "source_battle_animation_local_battle_tab_width_px",
    "source_battle_animation_local_battle_tab_height_px",
    "source_battle_animation_local_ratio_x100",
    "source_battle_animation_local_popover_width_pt",
    "source_battle_animation_local_popover_height_pt",
    "source_battle_animation_local_content_height_pt",
    "source_battle_animation_local_battle_scene_height_pt",
    "source_battle_animation_local_bottom_tab_height_pt",
    "source_battle_animation_exact_action_frames",
    "source_skill_damage_buckets",
    "source_skill_physical_damage",
    "source_skill_non_physical_damage_runtime",
    "source_skill_chaos_damage_runtime",
    "source_skill_most_common_damage_count",
    "source_skill_activation_damage_pairs",
    "source_skill_activation_damage_runtime_pairs",
    "source_skill_cooldown_chaos_value_rows",
    "pending_source_skill_cooldown_chaos_page_rows",
    "pending_source_skill_cooldown_chaos_locale_pages",
    "pending_source_skill_cooldown_chaos_empty_delivery",
    "pending_source_skill_cooldown_chaos_unnamed",
    "source_skill_activation_delivery_pairs",
    "source_skill_activation_delivery_runtime_pairs",
    "source_skill_damage_delivery_pairs",
    "source_skill_damage_delivery_runtime_pairs",
    "source_skill_empty_delivery_runtime",
    "source_skill_delivery_buckets",
    "source_skill_empty_delivery",
    "source_skill_non_empty_delivery_runtime",
    "source_skill_most_common_delivery_count",
    "source_skill_range_buckets",
    "source_skill_min_range",
    "source_skill_max_range",
    "source_skill_most_common_range_count",
    "local_skill_runtime_coverage_source",
    "local_skill_runtime_coverage_modeled",
    "local_skill_runtime_coverage_rows",
    "local_skill_runtime_coverage_hero_named",
    "local_skill_runtime_coverage_hero_base",
    "local_skill_runtime_coverage_monster",
    "pending_source_skill_runtime_proof_rows",
    "pending_source_skill_runtime_proof_coverage",
    "pending_source_skill_runtime_proof_catalog",
    "pending_source_skill_runtime_proof_value_range",
    "pending_source_skill_activation_buckets",
    "pending_source_skill_damage_buckets",
    "pending_source_skill_prefix_buckets",
    "pending_source_skill_responsibility_buckets",
    "pending_source_skill_damage_candidate_manifest",
    "pending_source_skill_physical_damage_candidate_manifest",
    "pending_source_skill_elemental_damage_candidate_manifest",
    "pending_source_skill_fire_damage_candidate_manifest",
    "pending_source_skill_cold_damage_candidate_manifest",
    "pending_source_skill_chaos_damage_candidate_manifest",
    "pending_source_skill_base_attack_candidate_manifest",
    "pending_source_skill_triggered_candidate_manifest",
    "pending_source_skill_triggered_value_rows",
    "pending_source_skill_runtime_gates",
    "pending_source_skill_evidence_queues",
    "pending_source_skill_evidence_queue_coverage",
    "pending_source_skill_activation_damage_queues",
    "pending_source_skill_activation_damage_queue_coverage",
    "pending_source_skill_activation_damage_value_coverage",
    "pending_source_skill_range_evidence_queues",
    "pending_source_skill_range_evidence_queue_coverage",
    "pending_source_skill_range_evidence_value_coverage",
    "pending_source_skill_prefix_evidence_queues",
    "pending_source_skill_prefix_evidence_queue_coverage",
    "pending_source_skill_prefix_evidence_value_coverage",
    "pending_source_skill_value_evidence_queues",
    "pending_source_skill_value_evidence_queue_coverage",
    "pending_source_skill_visual_priority_queues",
    "pending_source_skill_visual_priority_entries",
    "pending_source_skill_visual_priority_elemental",
    "pending_source_skill_visual_priority_cooldown_chaos",
    "pending_source_skill_visual_priority_unmapped_monster",
    "pending_source_skill_visual_priority_highest_value",
    "pending_source_skill_visual_priority_unique",
    "pending_source_skill_visual_priority_overlap",
    "pending_source_skill_visual_priority_unqueued",
    "pending_source_skill_visual_review_total_queues",
    "pending_source_skill_visual_review_total_coverage",
    "pending_source_skill_visual_priority_unqueued_queues",
    "pending_source_skill_visual_priority_unqueued_queue_coverage",
    "pending_source_skill_visual_priority_unqueued_value",
    "pending_source_skill_visual_priority_unqueued_activation_buckets",
    "pending_source_skill_visual_priority_unqueued_damage_buckets",
    "pending_source_skill_visual_priority_unqueued_range_buckets",
    "pending_source_skill_value_range_queue",
    "pending_source_skill_nonphysical_baseattack_queue",
    "pending_source_skill_physical_baseattack_queue",
    "pending_source_skill_value_evidence_rows",
    "pending_source_skill_base_attack_evidence_rows",
    "pending_source_skill_nonphysical_baseattack_evidence_rows",
    "pending_source_skill_physical_baseattack_evidence_rows",
    "pending_source_skill_unmapped_monster_candidates",
    "pending_source_skill_checked_monster_attacks",
    "pending_source_skill_range_buckets",
    "pending_source_skill_most_common_range",
    "pending_source_skill_most_common_range_count",
    "interactive_rune_nodes",
    "rune_dependency_edges",
    "rune_required_hero_level",
    "rune_party_slot_verified_gold_total",
    "rune_direct_party_slot_3_gold",
    "rune_active_skill_slot_count",
    "rune_all_hero_attack_damage_bonus",
    "rune_all_hero_attack_damage_percent_boost_percent",
    "rune_all_hero_armor_bonus",
    "rune_all_hero_armor_percent_boost_percent",
    "rune_all_hero_move_speed_bonus",
    "rune_all_hero_attack_speed_boost_percent",
    "rune_combat_reward_runtime_nodes",
    "rune_combat_reward_boost_percent",
    "rune_cube_reward_runtime_nodes",
    "rune_cube_reward_boost_percent",
    "rune_inventory_expansion_runtime_nodes",
    "rune_inventory_slot_bonus",
    "rune_stash_page_runtime_nodes",
    "rune_stash_page_slot_bonus",
    "rune_stage_clear_target_reduction",
    "rune_offline_boost_percent",
    "local_rune_cost_review_rows",
    "local_rune_cost_review_verified",
    "local_rune_cost_review_approximate",
    "local_rune_cost_review_approximate_evidence_rows",
    "local_rune_cost_review_approximate_evidence_coverage",
    "local_rune_cost_review_pending_groups",
    "local_rune_cost_review_pending_branches",
    "local_rune_cost_review_evidence_gates",
    "local_rune_cost_review_evidence_queues",
    "local_rune_cost_review_evidence_queue_coverage",
    "local_rune_cost_review_evidence_queue_group_coverage",
    "local_rune_cost_review_branch_evidence_rows",
    "local_rune_cost_review_branch_evidence_coverage",
    "local_rune_cost_review_branch_evidence_group_coverage",
    "local_rune_cost_review_max_level_evidence_queues",
    "local_rune_cost_review_max_level_evidence_coverage",
    "local_rune_cost_review_max_level_evidence_icon_buckets",
    "stage_composition_names",
    "source_monster_database_rows",
    "source_monster_database_unique_ids",
    "source_monster_database_unique_names",
    "source_monster_database_stage_coverage",
    "source_monster_source_only_sprites",
    "source_monster_source_only_sprite_preview_rows",
    "source_monster_source_only_proof_rows",
    "source_monster_source_only_proof_coverage",
    "source_monster_source_stage_evidence_rows",
    "source_monster_source_stage_appearance_confirmed",
    "source_monster_source_stage_appearance_absent",
    "source_monster_source_stage_appearance_rows_total",
    "source_monster_source_stage_crosscheck_pages",
    "source_monster_source_page_field_rows",
    "source_monster_source_page_field_sprite_paths",
    "source_monster_source_page_field_move_known",
    "source_monster_source_page_field_damage_known",
    "source_monster_source_page_field_range_known",
    "source_monster_source_page_field_unknown_damage_range",
    "source_monster_unmapped_evidence_gates",
    "source_monster_unmapped_evidence_queues",
    "source_monster_unmapped_evidence_queue_coverage",
    "source_monster_unmapped_candidate_skills",
    "source_monster_runtime_attack_coverage",
    "source_monster_runtime_speed_coverage",
    "source_monster_art_review_rows",
    "source_monster_art_evidence_gates",
    "source_monster_art_evidence_queues",
    "source_monster_art_evidence_queue_coverage",
    "source_monster_attack_evidence_gates",
    "active_equip_slots",
    "exact_item_record_gap_review_rows",
    "exact_item_record_gap_review_type_rows",
    "exact_item_record_gap_evidence_gates",
    "exact_item_record_gap_category_queues",
    "exact_item_record_gap_rarity_queues",
    "exact_item_record_gap_category_rarity_queues",
    "exact_item_record_gap_progression_queues",
    "exact_item_record_gap_type_queues",
    "exact_item_record_gap_largest_type_queues",
    "exact_item_record_gap_queue_coverage",
    "exact_item_record_gap_rarity_queue_coverage",
    "exact_item_record_gap_category_rarity_queue_coverage",
    "exact_item_record_gap_progression_queue_coverage",
    "exact_item_record_gap_largest_type_queue_coverage",
    "exact_item_record_gap_review_aggregate",
    "exact_item_record_gap_review_progressions",
    "original_fidelity_hard_gap_rows",
    "player_status_badges",
    "player_active_status_mappings",
    "player_deployable_markers",
    "rune_auto_open_normal_base_cooldown_seconds",
    "rune_auto_open_stage_boss_base_cooldown_seconds",
    "rune_auto_open_act_boss_base_cooldown_seconds",
    "rune_auto_open_normal_reduction_seconds",
    "rune_auto_open_stage_boss_reduction_seconds",
    "rune_auto_open_act_boss_reduction_seconds",
    "source_monster_source_cooldown_min_tenths",
    "source_monster_source_cooldown_max_tenths",
    "source_monster_loop_cooldown_min_tenths",
    "source_monster_loop_cooldown_max_tenths",
    "direct_inventory_expansion_slot_bonus",
    "direct_inventory_expansion_base_gold_cost",
    "worse_equipment_handling_modes",
}

SOURCE_ABSENT_METRICS = {
    "source_monster_database_missing_best_farm",
}

def row_status(name: str, count: int, original: int | None, expected_current: int | None = None) -> str:
    status = status_for(count, original, expected_current)
    if (
        status == "gap"
        and name in SOURCE_ABSENT_METRICS
        and original is None
        and expected_current is not None
        and count == expected_current
    ):
        return "source_absent"
    if (
        status == "gap"
        and name in LOCAL_GUARDED_METRICS
        and original is None
        and expected_current is not None
        and count >= expected_current
    ):
        return "guarded"
    return status

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

def global_static_dictionary_value_sum(source: str, symbol_name: str) -> float:
    match = re.search(
        rf'static\s+let\s+{re.escape(symbol_name)}(?:\s*:\s*[^\n=]+)?\s*=\s*\[(?P<body>.*?)\n\s*\]',
        source,
        re.S,
    )
    if not match:
        issues.append(f"missing static dictionary {symbol_name}")
        return 0
    return sum(swift_number(value) for value in re.findall(r':\s*([0-9_]+(?:\.[0-9_]+)?)\s*,?', match.group("body")))

def static_cgsize(source: str, symbol_name: str) -> tuple[int, int]:
    match = re.search(
        rf'static\s+let\s+{re.escape(symbol_name)}\s*=\s*CGSize\s*\(\s*width:\s*([0-9_]+(?:\.[0-9_]+)?)\s*,\s*height:\s*([0-9_]+(?:\.[0-9_]+)?)\s*\)',
        source,
    )
    if not match:
        issues.append(f"missing CGSize static let {symbol_name}")
        return (0, 0)
    return (int(swift_number(match.group(1))), int(swift_number(match.group(2))))

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

damage_log_blocks = [
    (source_line_number(battle_source, start), block)
    for start, block in swift_call_blocks(battle_source, "BattleLogEntry")
    if "kind: .damage" in block
]
damage_log_metadata_missing_lines = [
    line_number
    for line_number, block in damage_log_blocks
    if "damageElement:" not in block or "delivery:" not in block
]
battle_damage_log_metadata_static_guard = (
    len(damage_log_blocks) > 0
    and not damage_log_metadata_missing_lines
)
snapshot_damage_log_blocks = [
    (source_line_number(battle_scene_snapshot_source, start), block)
    for start, block in swift_call_blocks(battle_scene_snapshot_source, "BattleLogEntry")
    if "kind: .damage" in block
]
snapshot_damage_log_metadata_missing_lines = [
    line_number
    for line_number, block in snapshot_damage_log_blocks
    if "damageElement:" not in block or "delivery:" not in block
]
battle_scene_snapshot_damage_metadata_static_guard = (
    len(snapshot_damage_log_blocks) > 0
    and not snapshot_damage_log_metadata_missing_lines
)
battle_scene_snapshot_fixture_cases = nested_enum_cases(battle_scene_snapshot_source, "Fixture")
battle_scene_audit_fixture_arguments = [
    positional or inline
    for positional, inline in re.findall(
        r"--render-battle-scene-fixture\s+([A-Za-z0-9_]+)|--render-battle-scene-fixture=([A-Za-z0-9_]+)",
        battle_scene_audit_source,
    )
]
battle_scene_audit_missing_fixtures = sorted(
    set(battle_scene_snapshot_fixture_cases) - set(battle_scene_audit_fixture_arguments)
)
battle_scene_audit_unknown_fixtures = sorted(
    set(battle_scene_audit_fixture_arguments) - set(battle_scene_snapshot_fixture_cases)
)
battle_scene_snapshot_fixture_audit_guard = (
    len(battle_scene_snapshot_fixture_cases) > 0
    and not battle_scene_audit_missing_fixtures
    and not battle_scene_audit_unknown_fixtures
)
battle_scene_snapshot_fixture_cli_guard = (
    "enum Fixture: String, CaseIterable" in battle_scene_snapshot_source
    and "case missingFixtureValue" in battle_scene_snapshot_source
    and "case invalidFixture(String)" in battle_scene_snapshot_source
    and "unknown battle scene fixture" in battle_scene_snapshot_source
    and "valid fixtures:" in battle_scene_snapshot_source
    and "try fixture(arguments: arguments)" in battle_scene_snapshot_source
    and "battle scene snapshot self-test categorizes every render fixture" in self_test_source
)
battle_scene_snapshot_hero_class_cli_guard = (
    "case missingHeroClassValue" in battle_scene_snapshot_source
    and "case invalidHeroClass(String)" in battle_scene_snapshot_source
    and "unknown battle scene hero class" in battle_scene_snapshot_source
    and "valid hero classes:" in battle_scene_snapshot_source
    and "try heroClass(arguments: arguments)" in battle_scene_snapshot_source
    and "guard !normalized.isEmpty else { return nil }" in battle_scene_snapshot_source
    and "battle scene snapshot CLI resolves every hero class case name and Chinese display name" in self_test_source
    and "battle scene snapshot CLI rejects missing hero-class values" in self_test_source
    and "battle scene snapshot CLI rejects invalid hero-class values" in self_test_source
)
battle_scene_audit_time_arguments = re.findall(
    r"--render-battle-scene-time(?:\s+|=)([A-Za-z0-9_.$\"-]+)",
    battle_scene_audit_source,
)
battle_scene_snapshot_time_cli_guard = (
    "case missingBackdropTimeValue" in battle_scene_snapshot_source
    and "case invalidBackdropTime(String)" in battle_scene_snapshot_source
    and "invalid battle scene time" in battle_scene_snapshot_source
    and "expected a finite non-negative second value" in battle_scene_snapshot_source
    and "try fixedBackdropTime(arguments: arguments)" in battle_scene_snapshot_source
    and "parsed.isFinite, parsed >= 0" in battle_scene_snapshot_source
    and "battle scene snapshot CLI resolves deterministic fixed animation times" in self_test_source
    and "battle scene snapshot CLI rejects missing fixed animation time values" in self_test_source
    and "battle scene snapshot CLI rejects non-numeric fixed animation times" in self_test_source
    and "battle scene snapshot CLI rejects negative fixed animation times" in self_test_source
    and "motion_sample_time_seconds=\"0.267\"" in battle_scene_audit_source
    and "render_battle_scene_snapshot_one \"$motion_screenshot_path\" --render-battle-scene-time \"$motion_sample_time_seconds\"" in battle_scene_audit_source
    and "TBH_MOTION_SAMPLE_TIME_SECONDS" in battle_scene_audit_source
    and "local_motion_sample_time_seconds" in battle_scene_audit_source
    and "render_battle_scene_snapshot_one \"$screenshot_path\" --render-battle-scene-time 0" in battle_scene_audit_source
    and len(battle_scene_audit_time_arguments) >= len(battle_scene_snapshot_fixture_cases) - 1
)

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
source_rune_id_body = block_between(rune_source, r"var\s+sourceRuneID:\s*String\s*\{", r"\n\s*\}")
runtime_node_source_id_map = {}
for match in re.finditer(r'case\s+([^:]+):\s*return\s+"([^"]+)"', source_rune_id_body):
    for node_name in re.findall(r'\.(\w+)', match.group(1)):
        runtime_node_source_id_map[node_name] = match.group(2)
runtime_rune_source_ids = set(runtime_node_source_id_map.values())
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
if shared_modeled_data_only_rune_icon_families:
    issues.append(
        "unexpected shared modeled/data-only Rune Tree icon families: "
        + ",".join(shared_modeled_data_only_rune_icon_families)
    )

rune_required_hero_level = int(global_static_number(rune_source, "requiredHeroLevel") or 0)
rune_inventory_slot_bonus = int(global_static_number(rune_source, "inventoryExpansionSlotBonus") or 0)
rune_stash_page_slot_bonus = int(global_static_number(rune_source, "stashPageSlotBonus") or 0)
rune_stage_clear_target_reduction = int(global_static_number(rune_source, "stageClearTargetReductionBonus") or 0)
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
rune_all_hero_attack_damage_bonus = int(global_static_number(rune_source, "allHeroAttackDamageBonus") or 0)
rune_all_hero_attack_damage_guard = (
    'case .allHeroAttackDamage1: return "1"' in rune_source
    and 'case .allHeroAttackDamage4: return "4031"' in rune_source
    and 'case .allHeroAttackDamage2: return "411"' in rune_source
    and 'case .allHeroAttackDamage3: return "4081"' in rune_source
    and "allHeroAttackDamageUnlockedCount" in rune_source
    and "var allHeroAttackDamage: Int" in rune_source
    and "hero.runeAttackDamageBonus = runeTree.allHeroAttackDamage" in game_loop_source
    and "allHeroAttackDamageBonus: runeTree.allHeroAttackDamage" in game_loop_source
    and "allHeroAttackDamageBonus: Int" in battle_source
    and "member.supportAttackPower(" in battle_source
    and "fourth Rune of War refreshes main, support and active battle attack scaffolds" in self_test_source
    and "second Rune of War refreshes main, support and active battle attack scaffolds" in self_test_source
    and "third Rune of War refreshes main, support and active battle attack scaffolds" in self_test_source
)
rune_all_hero_attack_damage_bonus = rune_all_hero_attack_damage_bonus * 4 if rune_all_hero_attack_damage_guard else 0
rune_all_hero_attack_damage_percent_boost_percent = 10 if (
    'case .allHeroAttackDamagePercent1: return "405"' in rune_source
    and "case .allHeroAttackDamagePercent1: return .allHeroMoveSpeed4" in rune_source
    and 'case .allHeroAttackDamagePercent2: return "408"' in rune_source
    and 'case .allHeroAttackDamagePercent3: return "413"' in rune_source
    and "static let allHeroAttackDamageMultiplierBonus = 0.10" in rune_source
    and "allHeroAttackDamagePercentUnlockedCount" in rune_source
    and "var allHeroAttackDamageMultiplier: Double" in rune_source
    and "hero.runeAttackDamageMultiplier = runeTree.allHeroAttackDamageMultiplier" in game_loop_source
    and "allHeroAttackDamageMultiplier: runeTree.allHeroAttackDamageMultiplier" in game_loop_source
    and "let allHeroAttackDamageMultiplier: Double" in battle_source
    and "allHeroAttackDamageMultiplier: allHeroAttackDamageMultiplier" in battle_source
    and "runeAttackDamageMultiplier" in hero_source
    and "Rune of War percent scaffold refreshes main, support and active battle attack multipliers" in self_test_source
    and "Rune of War percent attack scaffold stays locked behind the checked fourth Rune of the Gale source edge" in self_test_source
    and "second Rune of War percent scaffold refreshes main, support and active battle attack multipliers" in self_test_source
    and "third Rune of War percent refreshes main, support and active battle attack multipliers" in self_test_source
) else 0
rune_all_hero_attack_damage_percent_boost_percent *= 3
rune_all_hero_armor_bonus = int(global_static_number(rune_source, "allHeroArmorBonus") or 0)
rune_all_hero_armor_guard = (
    'case .allHeroArmor1: return "401"' in rune_source
    and 'case .allHeroArmor2: return "410"' in rune_source
    and 'case .allHeroArmor3: return "403"' in rune_source
    and "allHeroArmorUnlockedCount" in rune_source
    and "var allHeroArmor: Int" in rune_source
    and "hero.runeArmorBonus = runeTree.allHeroArmor" in game_loop_source
    and "allHeroArmorBonus: runeTree.allHeroArmor" in game_loop_source
    and "allHeroArmorBonus: Int" in battle_source
    and "supportDefense(" in battle_source
    and "allHeroArmorBonus: allHeroArmorBonus" in battle_source
    and "second Rune of the Shield refreshes main, support and active battle armor scaffolds" in self_test_source
    and "third Rune of the Shield refreshes main, support and active battle armor scaffolds" in self_test_source
)
rune_all_hero_armor_bonus = rune_all_hero_armor_bonus * 3 if rune_all_hero_armor_guard else 0
rune_all_hero_armor_percent_boost_percent = 10 if (
    'case .allHeroArmorPercent1: return "407"' in rune_source
    and "case .allHeroArmorPercent1: return .allHeroMoveSpeed5" in rune_source
    and 'case .allHeroArmorPercent2: return "412"' in rune_source
    and "allHeroArmorPercentUnlockedCount" in rune_source
    and "static let allHeroArmorMultiplierBonus = 0.10" in rune_source
    and "var allHeroArmorMultiplier: Double" in rune_source
    and "hero.runeArmorMultiplier = runeTree.allHeroArmorMultiplier" in game_loop_source
    and "allHeroArmorMultiplier: runeTree.allHeroArmorMultiplier" in game_loop_source
    and "let allHeroArmorMultiplier: Double" in battle_source
    and "allHeroArmorMultiplier: allHeroArmorMultiplier" in battle_source
    and "runeArmorMultiplier" in hero_source
    and "Rune of the Shield percent scaffold refreshes main, support and active battle armor multipliers" in self_test_source
    and "second Rune of the Shield percent refreshes main, support and active battle armor multipliers" in self_test_source
) else 0
rune_all_hero_armor_percent_boost_percent *= 2
rune_all_hero_move_speed_bonus = int(global_static_number(rune_source, "allHeroMoveSpeedBonus") or 0)
rune_all_hero_move_speed_guard = (
    'case .allHeroMoveSpeed1: return "402"' in rune_source
    and 'case .allHeroMoveSpeed2: return "4082"' in rune_source
    and 'case .allHeroMoveSpeed3: return "4101"' in rune_source
    and 'case .allHeroMoveSpeed4: return "404"' in rune_source
    and 'case .allHeroMoveSpeed5: return "406"' in rune_source
    and "allHeroMoveSpeedUnlockedCount" in rune_source
    and "var allHeroMoveSpeed: Int" in rune_source
    and "hero.runeMoveSpeedBonus = runeTree.allHeroMoveSpeed" in game_loop_source
    and "runeMoveSpeedBonus" in hero_source
    and "supportSpeed(allHeroMoveSpeedBonus:" in self_test_source
    and "second Rune of the Gale refreshes main and support move-speed scaffolds" in self_test_source
    and "third Rune of the Gale refreshes main and support move-speed scaffolds" in self_test_source
    and "fourth Rune of the Gale refreshes main and support move-speed scaffolds" in self_test_source
    and "fifth Rune of the Gale refreshes main and support move-speed scaffolds" in self_test_source
)
rune_all_hero_move_speed_bonus = rune_all_hero_move_speed_bonus * 5 if rune_all_hero_move_speed_guard else 0
rune_all_hero_attack_speed_guard = (
    'case .allHeroAttackSpeed1: return "4061"' in rune_source
    and "case .allHeroAttackSpeed1: return .allHeroMoveSpeed5" in rune_source
    and 'case .allHeroAttackSpeed2: return "409"' in rune_source
    and 'case .allHeroAttackSpeed3: return "414"' in rune_source
    and "static let allHeroAttackSpeedMultiplierBonus = 0.10" in rune_source
    and "allHeroAttackSpeedUnlockedCount" in rune_source
    and "var allHeroAttackSpeedMultiplier: Double" in rune_source
    and "allHeroAttackSpeedMultiplier: runeTree.allHeroAttackSpeedMultiplier" in game_loop_source
    and "allHeroAttackSpeedMultiplier: Double" in battle_source
    and "activeHeroAttackSpeedMultiplier * allHeroAttackSpeedMultiplier" in battle_source
    and "second Rune of Frenzy refreshes the active battle attack-speed scaffold" in self_test_source
    and "third Rune of Frenzy refreshes the active battle attack-speed scaffold" in self_test_source
)
rune_all_hero_attack_speed_boost_percent = 30 if rune_all_hero_attack_speed_guard else 0
rune_combat_reward_runtime_nodes = sum(
    1 for rune in runtime_rune_source_rows
    if rune["icon"] in (
        "IncreaseGoldAmount",
        "IncreaseExpAmount",
        "AdditionalGold",
        "AdditionalGoldNormalMonster",
        "AdditionalGoldStageBoss",
        "AdditionalGoldActBoss",
        "AdditionalExp",
        "AdditionalExpNormalMonster",
        "AdditionalExpStageBoss",
        "AdditionalExpActBoss",
    )
)
rune_combat_reward_boost_guard = (
    "static let combatRewardMultiplierBonus = 0.10" in rune_source
    and "static let combatGoldBoostNodes: [RuneTreeNode]" in rune_source
    and "static let combatXPBoostNodes: [RuneTreeNode]" in rune_source
    and "static let additionalGoldBoostNodes: [RuneTreeNode]" in rune_source
    and "static let additionalGoldNormalMonsterNodes: [RuneTreeNode]" in rune_source
    and "static let additionalGoldStageBossNodes: [RuneTreeNode]" in rune_source
    and "static let additionalGoldActBossNodes: [RuneTreeNode]" in rune_source
    and "static let additionalXPBoostNodes: [RuneTreeNode]" in rune_source
    and "static let additionalXPNormalMonsterNodes: [RuneTreeNode]" in rune_source
    and "static let additionalXPStageBossNodes: [RuneTreeNode]" in rune_source
    and "static let additionalXPActBossNodes: [RuneTreeNode]" in rune_source
    and "combatGoldBoostUnlockedCount" in rune_source
    and "combatXPBoostUnlockedCount" in rune_source
    and "additionalGoldStageBossUnlockedCount" in rune_source
    and "additionalXPStageBossUnlockedCount" in rune_source
    and "var combatGoldMultiplier: Double" in rune_source
    and "var combatXPMultiplier: Double" in rune_source
    and "func combatGoldMultiplier(for encounterKind: CombatRewardEncounterKind) -> Double" in rune_source
    and "func combatXPMultiplier(for encounterKind: CombatRewardEncounterKind) -> Double" in rune_source
    and "Double(combatGoldBoostUnlockedCount) * Self.combatRewardMultiplierBonus" in rune_source
    and "Double(combatXPBoostUnlockedCount) * Self.combatRewardMultiplierBonus" in rune_source
    and "combatRewardEncounterKind" in game_loop_source
    and "runeTree.combatGoldMultiplier(for: encounterKind)" in game_loop_source
    and "runeTree.combatXPMultiplier(for: encounterKind)" in game_loop_source
    and "adjustedVictoryRewards" in game_loop_source
)
rune_combat_reward_boost_percent = 160 if rune_combat_reward_boost_guard else 0
rune_cube_reward_runtime_nodes = sum(
    1 for rune in runtime_rune_source_rows
    if rune["icon"] in ("CubeExpPercent", "CubeAlchemyGoldPercent")
)
rune_cube_reward_boost_guard = (
    "static let cubeRewardMultiplierBonus = 0.10" in rune_source
    and "static let cubeXPBoostNodes: [RuneTreeNode]" in rune_source
    and "static let alchemyGoldBoostNodes: [RuneTreeNode]" in rune_source
    and "cubeXPBoostUnlockedCount" in rune_source
    and "alchemyGoldBoostUnlockedCount" in rune_source
    and "var cubeExperienceMultiplier: Double" in rune_source
    and "var alchemyGoldMultiplier: Double" in rune_source
    and "Double(cubeXPBoostUnlockedCount) * Self.cubeRewardMultiplierBonus" in rune_source
    and "Double(alchemyGoldBoostUnlockedCount) * Self.cubeRewardMultiplierBonus" in rune_source
    and "cubeProgress.infuse(item, multiplier: runeTree.cubeExperienceMultiplier)" in game_loop_source
    and "private func alchemyGold(for item: Item) -> Int" in game_loop_source
    and "runeTree.alchemyGoldMultiplier" in game_loop_source
    and "mutating func infuse(_ item: Item, multiplier: Double = 1.0)" in Path("Sources/Game/Progress/CubeProgress.swift").read_text(encoding="utf-8")
)
rune_cube_reward_boost_percent = 40 if rune_cube_reward_boost_guard else 0
rune_inventory_expansion_runtime_nodes = sum(
    1 for rune in runtime_rune_source_rows
    if rune["icon"] == "MaxInventorySlot"
)
rune_stash_page_runtime_nodes = sum(
    1 for rune in runtime_rune_source_rows
    if rune["icon"] == "UnlockStashPageCount"
)

rune_offline_boost_guard = (
    "static let offlineGoldBoostNodes: [RuneTreeNode]" in rune_source
    and "static let offlineXPBoostNodes: [RuneTreeNode]" in rune_source
    and "offlineGoldBoostUnlockedCount" in rune_source
    and "offlineXPBoostUnlockedCount" in rune_source
    and "Double(offlineGoldBoostUnlockedCount) * 0.10" in rune_source
    and "Double(offlineXPBoostUnlockedCount) * 0.10" in rune_source
    and "offlineGoldMultiplier: runeTree.offlineGoldMultiplier" in game_loop_source
    and "offlineXPMultiplier: runeTree.offlineXPMultiplier" in game_loop_source
)
rune_offline_boost_percent = 10 if rune_offline_boost_guard else 0

has_verified_gold_cost_body = block_between(rune_source, r"var\s+hasVerifiedGoldCost:\s*Bool\s*\{", r"\n\s*var\s+approximateGoldCost")
unverified_cost_cases_match = re.search(r'case\s+(?P<body>[^:]+):\s*\n\s*return\s+false', has_verified_gold_cost_body, re.S)
if unverified_cost_cases_match:
    unverified_cost_nodes = re.findall(r'\.(\w+)', unverified_cost_cases_match.group("body"))
elif "self == .partySlot2 || self == .partySlot3" in has_verified_gold_cost_body:
    unverified_cost_nodes = [
        node for node in rune_nodes
        if node not in ("partySlot2", "partySlot3")
    ]
else:
    unverified_cost_nodes = []
rune_unverified_cost_nodes = len(unverified_cost_nodes)
approximate_cost_body = block_between(rune_source, r"var\s+approximateGoldCost:\s*Int\?\s*\{", r"\n\s*var\s+costText")
approximate_cost_nodes = re.findall(r'case\s+\.(\w+):\s*\n\s*return\s+[0-9_]+', approximate_cost_body)
rune_approximate_cost_nodes = len(approximate_cost_nodes)
approximate_cost_source_body = block_between(rune_source, r"var\s+approximateGoldCostSourceText:\s*String\?\s*\{", r"\n\s*var\s+costText")
approximate_cost_source_nodes = re.findall(
    r'case\s+\.(\w+):\s*\n\s*return\s+"官方符文分支：2nd Active Skill Slot \(~50,000g\)"',
    approximate_cost_source_body
)
rune_approximate_cost_source_nodes = len(approximate_cost_source_nodes)
rune_pending_cost_nodes = rune_unverified_cost_nodes - rune_approximate_cost_nodes
approximate_cost_node_set = set(approximate_cost_nodes)
rune_pending_cost_icon_counts: Counter[str] = Counter()
rune_pending_cost_max_level_counts: Counter[int] = Counter()
rune_pending_cost_max_level_icon_sets: dict[int, set[str]] = {}
for node in unverified_cost_nodes:
    if (
        node not in approximate_cost_node_set
        and node in runtime_node_source_id_map
        and runtime_node_source_id_map[node] in source_rune_id_map
    ):
        source_rune = source_rune_id_map[runtime_node_source_id_map[node]]
        rune_pending_cost_icon_counts[source_rune["icon"]] += 1
        rune_pending_cost_max_level_counts[source_rune["max_level"]] += 1
        rune_pending_cost_max_level_icon_sets.setdefault(source_rune["max_level"], set()).add(source_rune["icon"])
rune_pending_cost_icon_groups = sorted(rune_pending_cost_icon_counts)
rune_pending_cost_icon_group_count = len(rune_pending_cost_icon_groups)
rune_pending_cost_max_level_summary_text = ",".join(
    f"{max_level}:{rune_pending_cost_max_level_counts[max_level]}"
    for max_level in sorted(rune_pending_cost_max_level_counts)
)
rune_pending_cost_max_level_queue_count = len(rune_pending_cost_max_level_counts)
rune_pending_cost_max_level_queue_coverage = sum(rune_pending_cost_max_level_counts.values())
rune_pending_cost_max_level_icon_bucket_total = sum(
    len(icon_names)
    for icon_names in rune_pending_cost_max_level_icon_sets.values()
)
rune_pending_cost_branch_icon_sets = {
    "chest": [
        "DropChanceNormalChest",
        "DropChanceStageBossChest",
        "MaxAmountActBossChest",
        "MaxAmountNormalChest",
        "MaxAmountStageBossChest",
        "OpenAllTypeChestAllAtOnce",
        "OpenOneTypeChestAllAtOnce",
        "ReduceAutoOpenActBossChestTime",
        "ReduceAutoOpenNormalChestTime",
        "ReduceAutoOpenStageBossChestTime",
        "UnlockAutoOpenActBossChest",
        "UnlockAutoOpenNormalChest",
        "UnlockAutoOpenStageBossChest",
    ],
    "inventory-storage": [
        "MaxInventorySlot",
        "UnlockStashPageCount",
    ],
    "combat-reward": [
        "AdditionalExp",
        "AdditionalExpActBoss",
        "AdditionalExpNormalMonster",
        "AdditionalExpStageBoss",
        "AdditionalGold",
        "AdditionalGoldActBoss",
        "AdditionalGoldNormalMonster",
        "AdditionalGoldStageBoss",
        "IncreaseExpAmount",
        "IncreaseGoldAmount",
    ],
    "hero-stat": [
        "AllHeroArmor",
        "AllHeroArmorPercent",
        "AllHeroAttackDamage",
        "AllHeroAttackDamagePercent",
        "AllHeroAttackSpeed",
        "AllHeroMoveSpeed",
    ],
    "cube-alchemy": [
        "CubeAlchemyGoldPercent",
        "CubeExpPercent",
    ],
    "offline": [
        "OfflineRewardExpPercent",
        "OfflineRewardGoldPercent",
        "UnlockOfflineReward",
    ],
    "stage-pacing": [
        "WaveCountReduction",
    ],
}
rune_pending_cost_branch_rows = []
for branch_key, icon_names in rune_pending_cost_branch_icon_sets.items():
    branch_icons = [icon_name for icon_name in icon_names if icon_name in rune_pending_cost_icon_counts]
    if branch_icons:
        rune_pending_cost_branch_rows.append((
            branch_key,
            len(branch_icons),
            sum(rune_pending_cost_icon_counts[icon_name] for icon_name in branch_icons),
        ))
rune_pending_cost_branch_count = len(rune_pending_cost_branch_rows)
rune_pending_cost_branch_group_total = sum(row[1] for row in rune_pending_cost_branch_rows)
rune_pending_cost_branch_node_total = sum(row[2] for row in rune_pending_cost_branch_rows)
rune_pending_cost_branch_summary_text = ";".join(
    f"{branch_key}:{node_count}/{group_count}"
    for branch_key, group_count, node_count in rune_pending_cost_branch_rows
)
local_rune_cost_evidence_gate_count = len(
    re.findall(r'LocalRuneCostEvidenceGateRowModel\s*\(', settings_source)
)
local_rune_cost_approximate_evidence_row_count = (
    rune_approximate_cost_nodes
    if "LocalRuneApproximateCostEvidenceRowModel" in settings_source
    and "approximateEvidenceRows" in settings_source
    and "LocalRuneApproximateCostEvidenceRow(row: row)" in settings_source
    else 0
)
local_rune_cost_approximate_evidence_coverage_count = (
    rune_approximate_cost_nodes
    if local_rune_cost_approximate_evidence_row_count
    else 0
)
local_rune_cost_evidence_queue_count = (
    rune_pending_cost_branch_count
    if "LocalRunePendingCostEvidenceQueueRowModel" in settings_source
    and "pendingCostEvidenceQueueRows" in settings_source
    else 0
)
local_rune_cost_evidence_queue_coverage_count = (
    rune_pending_cost_branch_node_total
    if local_rune_cost_evidence_queue_count
    else 0
)
local_rune_cost_evidence_queue_group_coverage_count = (
    rune_pending_cost_branch_group_total
    if local_rune_cost_evidence_queue_count
    else 0
)
local_rune_cost_branch_evidence_row_count = (
    rune_pending_cost_branch_group_total
    if "LocalRunePendingCostBranchEvidenceRowModel" in settings_source
    and "pendingCostBranchEvidenceRows" in settings_source
    else 0
)
local_rune_cost_branch_evidence_coverage_count = (
    rune_pending_cost_branch_node_total
    if local_rune_cost_branch_evidence_row_count
    else 0
)
local_rune_cost_branch_evidence_group_coverage_count = local_rune_cost_branch_evidence_row_count
local_rune_cost_max_level_evidence_queue_count = (
    rune_pending_cost_max_level_queue_count
    if "LocalRunePendingCostMaxLevelEvidenceRowModel" in settings_source
    and "pendingCostMaxLevelEvidenceRows" in settings_source
    else 0
)
local_rune_cost_max_level_evidence_coverage_count = (
    rune_pending_cost_max_level_queue_coverage
    if local_rune_cost_max_level_evidence_queue_count
    else 0
)
local_rune_cost_max_level_evidence_icon_bucket_count = (
    rune_pending_cost_max_level_icon_bucket_total
    if local_rune_cost_max_level_evidence_queue_count
    else 0
)

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
if rune_all_hero_attack_damage_bonus != CURRENT_BASELINE["rune_all_hero_attack_damage_bonus"]:
    issues.append(
        "runtime Rune of War all-hero attack bonus drifted: "
        f"{rune_all_hero_attack_damage_bonus} vs {CURRENT_BASELINE['rune_all_hero_attack_damage_bonus']}"
    )
if rune_all_hero_attack_damage_percent_boost_percent != CURRENT_BASELINE["rune_all_hero_attack_damage_percent_boost_percent"]:
    issues.append(
        "runtime Rune of War all-hero percent attack boost drifted: "
        f"{rune_all_hero_attack_damage_percent_boost_percent} vs {CURRENT_BASELINE['rune_all_hero_attack_damage_percent_boost_percent']}"
    )
if rune_all_hero_armor_bonus != CURRENT_BASELINE["rune_all_hero_armor_bonus"]:
    issues.append(
        "runtime Rune of the Shield all-hero armor bonus drifted: "
        f"{rune_all_hero_armor_bonus} vs {CURRENT_BASELINE['rune_all_hero_armor_bonus']}"
    )
if rune_all_hero_armor_percent_boost_percent != CURRENT_BASELINE["rune_all_hero_armor_percent_boost_percent"]:
    issues.append(
        "runtime Rune of the Shield all-hero percent armor boost drifted: "
        f"{rune_all_hero_armor_percent_boost_percent} vs {CURRENT_BASELINE['rune_all_hero_armor_percent_boost_percent']}"
    )
if rune_all_hero_move_speed_bonus != CURRENT_BASELINE["rune_all_hero_move_speed_bonus"]:
    issues.append(
        "runtime Rune of the Gale all-hero move-speed bonus drifted: "
        f"{rune_all_hero_move_speed_bonus} vs {CURRENT_BASELINE['rune_all_hero_move_speed_bonus']}"
    )
if rune_all_hero_attack_speed_boost_percent != CURRENT_BASELINE["rune_all_hero_attack_speed_boost_percent"]:
    issues.append(
        "runtime Rune of Frenzy all-hero attack-speed boost drifted: "
        f"{rune_all_hero_attack_speed_boost_percent} vs {CURRENT_BASELINE['rune_all_hero_attack_speed_boost_percent']}"
    )
if rune_combat_reward_runtime_nodes != CURRENT_BASELINE["rune_combat_reward_runtime_nodes"]:
    issues.append(
        "runtime combat reward Rune source-node count drifted: "
        f"{rune_combat_reward_runtime_nodes} vs {CURRENT_BASELINE['rune_combat_reward_runtime_nodes']}"
    )
if rune_combat_reward_boost_percent != CURRENT_BASELINE["rune_combat_reward_boost_percent"]:
    issues.append(
        "runtime combat reward Rune boost percent drifted: "
        f"{rune_combat_reward_boost_percent} vs {CURRENT_BASELINE['rune_combat_reward_boost_percent']}"
    )
if rune_cube_reward_runtime_nodes != CURRENT_BASELINE["rune_cube_reward_runtime_nodes"]:
    issues.append(
        "runtime Cube reward Rune source-node count drifted: "
        f"{rune_cube_reward_runtime_nodes} vs {CURRENT_BASELINE['rune_cube_reward_runtime_nodes']}"
    )
if rune_cube_reward_boost_percent != CURRENT_BASELINE["rune_cube_reward_boost_percent"]:
    issues.append(
        "runtime Cube reward Rune boost percent drifted: "
        f"{rune_cube_reward_boost_percent} vs {CURRENT_BASELINE['rune_cube_reward_boost_percent']}"
    )
if rune_inventory_expansion_runtime_nodes != CURRENT_BASELINE["rune_inventory_expansion_runtime_nodes"]:
    issues.append(
        "runtime Rune of Expansion source-node count drifted: "
        f"{rune_inventory_expansion_runtime_nodes} vs {CURRENT_BASELINE['rune_inventory_expansion_runtime_nodes']}"
    )
if rune_inventory_slot_bonus != CURRENT_BASELINE["rune_inventory_slot_bonus"]:
    issues.append(
        "runtime Rune of Expansion inventory bonus drifted: "
        f"{rune_inventory_slot_bonus} vs {CURRENT_BASELINE['rune_inventory_slot_bonus']}"
    )
if rune_stash_page_runtime_nodes != CURRENT_BASELINE["rune_stash_page_runtime_nodes"]:
    issues.append(
        "runtime Rune of Storage source-node count drifted: "
        f"{rune_stash_page_runtime_nodes} vs {CURRENT_BASELINE['rune_stash_page_runtime_nodes']}"
    )
if rune_stash_page_slot_bonus != CURRENT_BASELINE["rune_stash_page_slot_bonus"]:
    issues.append(
        "runtime Rune of Storage stash-page bonus drifted: "
        f"{rune_stash_page_slot_bonus} vs {CURRENT_BASELINE['rune_stash_page_slot_bonus']}"
    )
if rune_stage_clear_target_reduction != CURRENT_BASELINE["rune_stage_clear_target_reduction"]:
    issues.append(
        "runtime Rune of Brevity stage-clear target reduction drifted: "
        f"{rune_stage_clear_target_reduction} vs {CURRENT_BASELINE['rune_stage_clear_target_reduction']}"
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
rune_auto_open_normal_base_cooldown_seconds = int(global_static_number(rune_source, "normalChestAutoOpenBaseCooldown") or 0)
rune_auto_open_stage_boss_base_cooldown_seconds = int(global_static_number(rune_source, "stageBossChestAutoOpenBaseCooldown") or 0)
rune_auto_open_act_boss_base_cooldown_seconds = int(global_static_number(rune_source, "actBossChestAutoOpenBaseCooldown") or 0)
rune_auto_open_normal_reduction_seconds = int(global_static_dictionary_value_sum(rune_source, "normalChestAutoOpenCooldownReductionByNode"))
rune_auto_open_stage_boss_reduction_seconds = int(global_static_dictionary_value_sum(rune_source, "stageBossChestAutoOpenCooldownReductionByNode"))
rune_auto_open_act_boss_reduction_seconds = int(global_static_dictionary_value_sum(rune_source, "actBossChestAutoOpenCooldownReductionByNode"))
auto_open_cooldown_runtime_guard = (
    "AutoOpenChestCooldowns" in stage_source
    and "AutoOpenChestCooldowns" in game_loop_source
    and "tickAutoOpenChests(deltaTime:" in game_loop_source
    and "runSelfTestAutoOpenCooldown(seconds:" in game_loop_source
    and "autoOpenCooldown(for:" in rune_source
    and "normalChestAutoOpenBaseCooldown" in rune_source
    and "stageBossChestAutoOpenBaseCooldown" in rune_source
    and "actBossChestAutoOpenBaseCooldown" in rune_source
    and "normalChestAutoOpenCooldownReductionByNode" in rune_source
    and "stageBossChestAutoOpenCooldownReductionByNode" in rune_source
    and "actBossChestAutoOpenCooldownReductionByNode" in rune_source
    and "openChest(family: family)" in game_loop_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_open_cooldown_save_guard = (
    "autoOpenChestCooldowns" in save_manager_source
    and "autoOpenChestCooldowns: AutoOpenChestCooldowns" in save_manager_source
    and "decodeIfPresent(AutoOpenChestCooldowns.self" in save_manager_source
    and "autoOpenChestCooldowns: autoOpenChestCooldowns" in game_loop_source
    and "autoOpenChestCooldowns = data.autoOpenChestCooldowns" in game_loop_source
)
auto_normal_chest_runtime_guard = (
    "var canAutoOpenNormalChests: Bool" in rune_source
    and "isUnlocked(.autoOpenNormalChests)" in rune_source
    and auto_open_cooldown_runtime_guard
    and "primeAutoOpenCooldown(for: .normalMonster)" in game_loop_source
    and "normalChestAutoOpenCooldown" in rune_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_normal_chest_self_test_guard = (
    "Rune of the Mainspring starts the source Normal Monster auto-open cooldown without opening immediately" in self_test_source
    and "automatic Normal Monster chest cooldown consumes only source Normal Monster boxes" in self_test_source
    and "checked Lubrication normal auto-open rows shorten the cooldown and still open one box per cycle" in self_test_source
)
auto_stage_boss_chest_runtime_guard = (
    "var canAutoOpenStageBossChests: Bool" in rune_source
    and "isUnlocked(.autoOpenStageBossChests)" in rune_source
    and auto_open_cooldown_runtime_guard
    and "primeAutoOpenCooldown(for: .stageBoss)" in game_loop_source
    and "stageBossChestAutoOpenCooldown" in rune_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_stage_boss_chest_self_test_guard = (
    "Rune of the Mainspring starts the source Stage Boss auto-open cooldown without opening immediately" in self_test_source
    and "automatic Stage Boss chest cooldown consumes only source Stage Boss boxes" in self_test_source
)
auto_act_boss_chest_runtime_guard = (
    "var canAutoOpenActBossChests: Bool" in rune_source
    and "isUnlocked(.autoOpenActBossChests)" in rune_source
    and auto_open_cooldown_runtime_guard
    and "primeAutoOpenCooldown(for: .actBoss)" in game_loop_source
    and "actBossChestAutoOpenCooldown" in rune_source
    and "removeFirst(family: ChestFamily)" in stage_source
)
auto_act_boss_chest_self_test_guard = (
    "Rune of the Mainspring starts the source Act Boss auto-open cooldown without opening immediately" in self_test_source
    and "automatic Act Boss chest cooldown consumes only source Act Boss boxes" in self_test_source
    and "save/load round trip preserves auto-open chest cooldowns" in self_test_source
)
chest_capacity_runtime_guard = (
    "case maxNormalChestStorage" in rune_source
    and "case maxNormalChestStorage2" in rune_source
    and "case maxNormalChestStorage3" in rune_source
    and "case maxNormalChestStorage4" in rune_source
    and 'case .maxNormalChestStorage2: return "1052"' in rune_source
    and 'case .maxNormalChestStorage3: return "1061"' in rune_source
    and 'case .maxNormalChestStorage4: return "1072"' in rune_source
    and "case maxNormalChestStorage5" in rune_source
    and 'case .maxNormalChestStorage5: return "1091"' in rune_source
    and "case maxNormalChestStorage6" in rune_source
    and 'case .maxNormalChestStorage6: return "1101"' in rune_source
    and "case maxNormalChestStorage7" in rune_source
    and 'case .maxNormalChestStorage7: return "1121"' in rune_source
    and "case maxNormalChestStorage8" in rune_source
    and 'case .maxNormalChestStorage8: return "1131"' in rune_source
    and "case maxNormalChestStorage9" in rune_source
    and 'case .maxNormalChestStorage9: return "1142"' in rune_source
    and "case maxNormalChestStorage10" in rune_source
    and 'case .maxNormalChestStorage10: return "1161"' in rune_source
    and "case maxNormalChestStorage11" in rune_source
    and 'case .maxNormalChestStorage11: return "1191"' in rune_source
    and "case maxNormalChestStorage12" in rune_source
    and 'case .maxNormalChestStorage12: return "1201"' in rune_source
    and "case maxNormalChestStorage13" in rune_source
    and 'case .maxNormalChestStorage13: return "1241"' in rune_source
    and "case maxNormalChestStorage14" in rune_source
    and 'case .maxNormalChestStorage14: return "11002"' in rune_source
    and "case maxNormalChestStorage15" in rune_source
    and 'case .maxNormalChestStorage15: return "11611"' in rune_source
    and "case maxStageBossChestStorage" in rune_source
    and "case maxStageBossChestStorage2" in rune_source
    and 'case .maxStageBossChestStorage2: return "1102"' in rune_source
    and "case maxStageBossChestStorage3" in rune_source
    and 'case .maxStageBossChestStorage3: return "11003"' in rune_source
    and "case maxStageBossChestStorage4" in rune_source
    and 'case .maxStageBossChestStorage4: return "1111"' in rune_source
    and "case maxStageBossChestStorage5" in rune_source
    and 'case .maxStageBossChestStorage5: return "1132"' in rune_source
    and "case maxStageBossChestStorage6" in rune_source
    and 'case .maxStageBossChestStorage6: return "1141"' in rune_source
    and "case maxStageBossChestStorage7" in rune_source
    and 'case .maxStageBossChestStorage7: return "1172"' in rune_source
    and "case maxStageBossChestStorage8" in rune_source
    and 'case .maxStageBossChestStorage8: return "1181"' in rune_source
    and "case maxStageBossChestStorage9" in rune_source
    and 'case .maxStageBossChestStorage9: return "1202"' in rune_source
    and "case maxStageBossChestStorage10" in rune_source
    and 'case .maxStageBossChestStorage10: return "1221"' in rune_source
    and "case maxStageBossChestStorage11" in rune_source
    and 'case .maxStageBossChestStorage11: return "1251"' in rune_source
    and "case maxStageBossChestStorage12" in rune_source
    and 'case .maxStageBossChestStorage12: return "1261"' in rune_source
    and "case maxStageBossChestStorage13" in rune_source
    and 'case .maxStageBossChestStorage13: return "1281"' in rune_source
    and "case maxActBossChestStorage" in rune_source
    and "case maxActBossChestStorage2" in rune_source
    and 'case .maxActBossChestStorage2: return "1133"' in rune_source
    and "case maxActBossChestStorage3" in rune_source
    and 'case .maxActBossChestStorage3: return "1182"' in rune_source
    and "case maxActBossChestStorage4" in rune_source
    and 'case .maxActBossChestStorage4: return "1203"' in rune_source
    and "case maxActBossChestStorage5" in rune_source
    and 'case .maxActBossChestStorage5: return "1222"' in rune_source
    and "case maxActBossChestStorage6" in rune_source
    and 'case .maxActBossChestStorage6: return "1252"' in rune_source
    and "case maxActBossChestStorage7" in rune_source
    and 'case .maxActBossChestStorage7: return "1262"' in rune_source
    and "case maxActBossChestStorage8" in rune_source
    and 'case .maxActBossChestStorage8: return "1282"' in rune_source
    and "var chestStorageLimits: ChestStorageLimits" in rune_source
    and "maxNormalChestStorageUnlockedCount" in rune_source
    and "maxStageBossChestStorageUnlockedCount" in rune_source
    and "maxActBossChestStorageUnlockedCount" in rune_source
    and "normalMonster: ChestStorageLimits.base.normalMonster + maxNormalChestStorageUnlockedCount * Self.chestStorageCapacityBonus" in rune_source
    and "stageBoss: ChestStorageLimits.base.stageBoss + maxStageBossChestStorageUnlockedCount * Self.chestStorageCapacityBonus" in rune_source
    and "actBoss: ChestStorageLimits.base.actBoss + maxActBossChestStorageUnlockedCount * Self.chestStorageCapacityBonus" in rune_source
    and "mutating func add(_ chest: LootChest, limits: ChestStorageLimits)" in stage_source
    and "chestStorageLimits: runeTree.chestStorageLimits" in game_loop_source
)
chest_capacity_self_test_guard = (
    "source-backed chest-capacity runes raise local box family caps by the conservative scaffold increment" in self_test_source
    and "base chest family storage keeps the newest source Normal Monster box within the local cap" in self_test_source
    and "Rune of Containment chest-capacity scaffold preserves an additional Normal Monster box" in self_test_source
    and "second Rune of Containment chest-capacity scaffold stacks another Normal Monster box slot" in self_test_source
    and "third Rune of Containment chest-capacity scaffold stacks another Normal Monster box slot" in self_test_source
    and "fourth Rune of Containment chest-capacity scaffold stacks another Normal Monster box slot" in self_test_source
    and "fifteenth Rune of Containment chest-capacity scaffold completes the checked Normal Monster box slot family" in self_test_source
    and "second Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot" in self_test_source
    and "third Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot" in self_test_source
    and "fourth Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot" in self_test_source
    and "fifth Rune of the Vault chest-capacity scaffold stacks another Stage Boss box slot" in self_test_source
    and "thirteenth Rune of the Vault chest-capacity scaffold completes the checked Stage Boss box slot family" in self_test_source
    and "second Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "third Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "fourth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "fifth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "sixth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "seventh Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "eighth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "ninth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
    and "tenth Rune of Infinity chest-capacity scaffold stacks another Act Boss box slot" in self_test_source
)
brevity_rune_runtime_guard = (
    "case waveCountReduction1" in rune_source
    and "stageClearTargetReductionBonus" in rune_source
    and "var stageClearTargetReduction: Int" in rune_source
    and "clearTargetReduction: Int = 0" in game_state_source
    and "clearTargetReduction: runeTree.stageClearTargetReduction" in game_loop_source
    and "stageProgressText(clearTargetReduction:" in battle_view_source
)
brevity_rune_self_test_guard = (
    "Rune of Brevity unlocks a checked source stage-clear target reduction scaffold" in self_test_source
    and "Rune of Brevity reduces runtime stage-clear targets without mutating checked source clear counts" in self_test_source
    and "Rune of Brevity refreshes the active battle with a reduced runtime clear target" in self_test_source
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
new_game_plus_snapshot_guard = (
    "case completionSettlement" in battle_scene_snapshot_source
    and "CompletionSettlementSnapshotView" in battle_scene_snapshot_source
    and "CompletionSettlementView(" in battle_scene_snapshot_source
    and "isAwaitingNewGamePlus = true" in battle_scene_snapshot_source
    and "let settlementFixtures: [BattleSceneSnapshot.Fixture]" in self_test_source
    and ".completionSettlement" in self_test_source
    and "battle scene snapshot renderer captures the completion settlement fixture" in self_test_source
    and "--render-battle-scene-fixture completionSettlement" in battle_scene_audit_source
    and "TBH_COMPLETION_SETTLEMENT_SCREENSHOT_PATH" in battle_scene_audit_source
    and "completion_settlement_non_dark_pixels" in battle_scene_audit_source
    and "completion_settlement_light_pixels" in battle_scene_audit_source
    and "completion_settlement_gold_pixels" in battle_scene_audit_source
    and "completion_settlement_accent_pixels" in battle_scene_audit_source
    and "completion_settlement_panel_pixels" in battle_scene_audit_source
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
ground_slam_rock_swift_test_guard = (
    "groundSlamRockChargesExplodeAfterPhysicalAOE" in combat_stats_tests_source
    and "大地强击岩石爆炸" in combat_stats_tests_source
    and "battle.groundSlamRockCharges == 0" in combat_stats_tests_source
)
shield_charge_focused_runtime_guard = (
    "applyHeroFocusedDamageSkill" in battle_source
    and "applySupportFocusedDamageSkill" in battle_source
    and 'if skill.id == "10201"' in battle_source
    and "return applyHeroFocusedDamageSkill(skill)" in battle_source
    and "return applySupportFocusedDamageSkill(skill, member: member)" in battle_source
)
shield_charge_focused_self_test_guard = (
    "Shield Charge keeps source Melee delivery focused on the collision target instead of widening into AOE" in self_test_source
    and "support Knight Shield Charge keeps source Melee delivery focused on the collision target" in self_test_source
    and "BattleTrajectoryCue.visible(for: $0) == .chargeDash" in self_test_source
)
shield_charge_focused_swift_test_guard = (
    "shieldChargeKeepsMeleeCollisionFocusedOnCurrentTarget" in combat_stats_tests_source
    and "shieldChargeLogs.count == 1" in combat_stats_tests_source
    and "$0.damageElement == .physical && $0.delivery == .melee" in combat_stats_tests_source
)
axe_spin_bleed_follow_up_runtime_guard = (
    "AxeSpinBleedScaffold" in battle_source
    and "旋转斧流血追击" in battle_source
    and "appliesBleedingWound" in battle_source
    and "AxeSpinBleedScaffold.followUpDamage" in battle_source
)
axe_spin_bleed_follow_up_self_test_guard = (
    "Axe Spin deals follow-up physical damage to already bleeding enemies" in self_test_source
    and "support Axe Spin keeps source-backed bleeding follow-up damage" in self_test_source
    and "Axe Spin exposes a dedicated spinning impact cue" in self_test_source
    and "Axe Spin bleed follow-up exposes a dedicated rend impact cue" in self_test_source
    and "Axe Spin exposes a dedicated spinning trajectory cue" in self_test_source
    and "Axe Spin bleed follow-up exposes a dedicated rend trajectory cue" in self_test_source
)
axe_spin_bleed_follow_up_visual_guard = (
    "axeSpinImpact" in battle_view_source
    and "bleedRendImpact" in battle_view_source
    and "AxeSpinImpactCue" in battle_view_source
    and "BleedRendImpactCue" in battle_view_source
    and "axeSpinArc" in battle_view_source
    and "bleedRendTrail" in battle_view_source
    and "AxeSpinArcTrailCue" in battle_view_source
    and "BleedRendTrailCue" in battle_view_source
    and "case axeSpin" in battle_scene_snapshot_source
    and "case axeSpinBleedFollowUp" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture axeSpin" in battle_scene_audit_source
    and "--render-battle-scene-fixture axeSpinBleedFollowUp" in battle_scene_audit_source
    and "damage_axe_spin_pixels" in battle_scene_audit_source
    and "damage_axe_spin_bleed_pixels" in battle_scene_audit_source
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
priest_utility_visual_guard = (
    "sanctuaryPulse" in battle_view_source
    and "wrathOfHeavenStorm" in battle_view_source
    and "SanctuaryPulseCue" in battle_view_source
    and "WrathOfHeavenStormCue" in battle_view_source
    and "sanctuaryUtility" in battle_scene_snapshot_source
    and "wrathOfHeavenUtility" in battle_scene_snapshot_source
    and "utility_sanctuary_pixels" in battle_scene_audit_source
    and "utility_wrath_of_heaven_pixels" in battle_scene_audit_source
)
priest_utility_self_test_guard = (
    "Sanctuary healing exposes a dedicated utility cue" in self_test_source
    and "Wrath of Heaven exposes a dedicated lightning utility cue" in self_test_source
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
if not auto_open_cooldown_runtime_guard:
    issues.append("GameEngine must run source auto-open chest cooldowns through tickAutoOpenChests")
if not auto_open_cooldown_save_guard:
    issues.append("SaveData must persist auto-open chest cooldown state")
if not auto_normal_chest_runtime_guard:
    issues.append("GameEngine must auto-open source Normal Monster boxes through the Rune of the Mainspring cooldown runtime node")
if not auto_normal_chest_self_test_guard:
    issues.append("SelfTest must guard automatic Normal Monster chest cooldown timing and Boss-box preservation")
if not auto_stage_boss_chest_runtime_guard:
    issues.append("GameEngine must auto-open source Stage Boss boxes through the Rune of the Mainspring cooldown runtime node")
if not auto_stage_boss_chest_self_test_guard:
    issues.append("SelfTest must guard automatic Stage Boss chest cooldown timing and Act Boss preservation")
if not auto_act_boss_chest_runtime_guard:
    issues.append("GameEngine must auto-open source Act Boss boxes through the Rune of the Mainspring cooldown runtime node")
if not auto_act_boss_chest_self_test_guard:
    issues.append("SelfTest must guard automatic Act Boss chest cooldown timing, lower-tier Boss-box preservation and persistence")
if not chest_capacity_runtime_guard:
    issues.append("chest capacity Rune runtime must apply source-backed per-family box storage limits")
if not chest_capacity_self_test_guard:
    issues.append("SelfTest must guard source-backed chest capacity Rune effects and base cap behavior")
if not brevity_rune_runtime_guard:
    issues.append("Rune of Brevity runtime must reduce clear targets through ProgressTracker and GameLoop")
if not brevity_rune_self_test_guard:
    issues.append("SelfTest must guard Rune of Brevity source mapping, runtime clear target and battle refresh")
if not new_game_plus_runtime_guard:
    issues.append("GameEngine must pause at completion settlement and expose next-playthrough start")
if not new_game_plus_ui_guard:
    issues.append("Battle UI must expose completion settlement and next-playthrough action")
if not new_game_plus_self_test_guard:
    issues.append("SelfTest must guard completion settlement, next playthrough scaling and persistence")
if not new_game_plus_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure the completion settlement")
if not ground_slam_rock_runtime_guard:
    issues.append("Battle runtime must model Ground Slam rocks and later physical-AOE explosion consumption")
if not ground_slam_rock_visual_guard:
    issues.append("Battle UI and scene audit must expose Ground Slam rock explosion impact/trajectory cues")
if not ground_slam_rock_self_test_guard:
    issues.append("SelfTest must guard Ground Slam rock explosion cue mapping and runtime consumption")
if not ground_slam_rock_swift_test_guard:
    issues.append("Swift tests must guard Ground Slam rock charges exploding after later physical AOE")
if not shield_charge_focused_runtime_guard:
    issues.append("Battle runtime must keep Shield Charge on the focused Melee collision target instead of widening it into AOE")
if not shield_charge_focused_self_test_guard:
    issues.append("SelfTest must guard focused Shield Charge delivery for hero and support casts")
if not shield_charge_focused_swift_test_guard:
    issues.append("Swift tests must guard focused Shield Charge delivery")
if not axe_spin_bleed_follow_up_runtime_guard:
    issues.append("Battle runtime must model Axe Spin follow-up damage against already bleeding enemies")
if not axe_spin_bleed_follow_up_self_test_guard:
    issues.append("SelfTest must guard hero and support Axe Spin bleeding follow-up damage")
if not axe_spin_bleed_follow_up_visual_guard:
    issues.append("Battle UI and scene audit must expose dedicated Axe Spin and bleed follow-up visual cues")
if not slayer_utility_visual_guard:
    issues.append("Battle UI and scene audit must expose dedicated Slayer utility cues for General's Cry and Bloodlust")
if not slayer_utility_self_test_guard:
    issues.append("SelfTest must guard General's Cry and Bloodlust dedicated utility cue mapping")
if not attack_speed_utility_visual_guard:
    issues.append("Battle UI and scene audit must expose dedicated attack-speed utility cues for Swift Surge and Quick Loader")
if not attack_speed_utility_self_test_guard:
    issues.append("SelfTest must guard Swift Surge and Quick Loader dedicated utility cue mapping")
if not priest_utility_visual_guard:
    issues.append("Battle UI and scene audit must expose dedicated Priest utility cues for Sanctuary and Wrath of Heaven")
if not priest_utility_self_test_guard:
    issues.append("SelfTest must guard Sanctuary and Wrath of Heaven dedicated utility cue mapping")

equip_slot_block = re.search(r'static\s+let\s+allCases:\s*\[EquipSlot\]\s*=\s*\[(?P<body>.*?)\]', item_source, re.S)
equip_slots = re.findall(r'\.(\w+)', equip_slot_block.group("body")) if equip_slot_block else []
if not equip_slots:
    issues.append("could not locate active EquipSlot.allCases list")

skill_calls = [
    block.removeprefix("Skill(").removesuffix(")")
    for start, block in swift_call_blocks(skills_source, "Skill")
    if start == 0 or not (skills_source[start - 1].isalnum() or skills_source[start - 1] == "_")
]
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

base_attack_function = re.search(
    r'baseAttackSourceSkillID\(for heroClass: HeroClass\) -> String \{(?P<body>.*?)\n    \}',
    skills_source,
    re.S,
)
hero_base_attack_skill_ids = sorted(set(re.findall(r'return "([^"]+)"', base_attack_function.group("body")))) if base_attack_function else []
if len(hero_base_attack_skill_ids) != CURRENT_BASELINE["hero_base_attack_skills"]:
    issues.append("could not locate all six hero base attack source skill IDs")
monster_attack_mapping = re.search(
    r'monsterSourceSkillIDsByName: \[String: String\] = \[(?P<body>.*?)\n    \]',
    skills_source,
    re.S,
)
runtime_monster_attack_skill_ids = sorted(set(re.findall(r': "([^"]+)"', monster_attack_mapping.group("body")))) if monster_attack_mapping else []
if len(runtime_monster_attack_skill_ids) != CURRENT_BASELINE["runtime_monster_attack_skills"]:
    issues.append("could not locate all four checked monster attack source skill IDs")

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
    if len(columns) not in (6, 7):
        issues.append(f"malformed source skill row: {line}")
        continue
    source_skills.append({
        "id": columns[0],
        "name": columns[1],
        "activation": columns[2],
        "damage_type": columns[3],
        "delivery": columns[4],
        "range": columns[5],
        "source_value": columns[6] if len(columns) == 7 else "",
    })
source_skill_ids = [skill["id"] for skill in source_skills]
duplicate_source_skill_ids = sorted({skill_id for skill_id in source_skill_ids if source_skill_ids.count(skill_id) > 1})
if duplicate_source_skill_ids:
    issues.append(f"duplicate source skill ids: {', '.join(duplicate_source_skill_ids)}")
missing_runtime_source_ids = sorted(set(skill_ids) - set(source_skill_ids))
if missing_runtime_source_ids:
    issues.append(f"runtime skill ids missing from source catalog: {', '.join(missing_runtime_source_ids)}")
runtime_hero_skill_source_ids = sorted(set(skill_ids).union(hero_base_attack_skill_ids))
missing_runtime_hero_source_ids = sorted(set(runtime_hero_skill_source_ids) - set(source_skill_ids))
if missing_runtime_hero_source_ids:
    issues.append(f"runtime hero skill source ids missing from source catalog: {', '.join(missing_runtime_hero_source_ids)}")
non_base_attack_source_ids = sorted(
    source_skill_id
    for source_skill_id in hero_base_attack_skill_ids
    if next((skill for skill in source_skills if skill["id"] == source_skill_id), {}).get("activation") != "BASEATTACK"
)
if non_base_attack_source_ids:
    issues.append(f"hero base attack source IDs are not BASEATTACK rows: {', '.join(non_base_attack_source_ids)}")
missing_runtime_monster_source_ids = sorted(set(runtime_monster_attack_skill_ids) - set(source_skill_ids))
if missing_runtime_monster_source_ids:
    issues.append(f"runtime monster attack source ids missing from source catalog: {', '.join(missing_runtime_monster_source_ids)}")
non_base_attack_monster_source_ids = sorted(
    source_skill_id
    for source_skill_id in runtime_monster_attack_skill_ids
    if next((skill for skill in source_skills if skill["id"] == source_skill_id), {}).get("activation") != "BASEATTACK"
)
if non_base_attack_monster_source_ids:
    issues.append(f"runtime monster attack source IDs are not BASEATTACK rows: {', '.join(non_base_attack_monster_source_ids)}")
runtime_modeled_source_ids = sorted(set(runtime_hero_skill_source_ids).union(runtime_monster_attack_skill_ids))
pending_source_skills = [skill for skill in source_skills if skill["id"] not in runtime_modeled_source_ids]
pending_source_skill_ids = {skill["id"] for skill in pending_source_skills}
source_skill_activations = sorted({skill["activation"] for skill in source_skills})
source_skill_damage_types = sorted({skill["damage_type"] for skill in source_skills})
source_skill_deliveries = sorted({skill["delivery"] for skill in source_skills})
source_skill_activation_counts = dict(sorted(Counter(skill["activation"] for skill in source_skills).items()))
source_skill_damage_counts = dict(sorted(Counter(skill["damage_type"] for skill in source_skills).items()))
source_skill_delivery_counts = dict(sorted(Counter(skill["delivery"] for skill in source_skills).items()))
source_skill_range_counts = dict(sorted(Counter(skill["range"] for skill in source_skills).items()))
source_skills_by_prefix = dict(sorted(Counter(skill_id[:1] for skill_id in source_skill_ids).items()))
source_skill_empty_delivery_count = source_skill_delivery_counts.get("", 0)
source_skill_physical_damage_count = source_skill_damage_counts.get("Physical", 0)
source_skill_non_empty_delivery_runtime_count = sum(
    1
    for skill in source_skills
    if skill["delivery"] != "" and skill["id"] in runtime_modeled_source_ids
)
source_skill_non_physical_damage_runtime_count = sum(
    1
    for skill in source_skills
    if skill["damage_type"] != "Physical" and skill["id"] in runtime_modeled_source_ids
)
source_skill_chaos_damage_runtime_count = sum(
    1
    for skill in source_skills
    if skill["damage_type"] == "Chaos" and skill["id"] in runtime_modeled_source_ids
)
source_skill_activation_damage_counts = dict(sorted(Counter(
    (skill["activation"], skill["damage_type"])
    for skill in source_skills
).items()))
source_skill_activation_damage_runtime_counts = dict(sorted(Counter(
    (skill["activation"], skill["damage_type"])
    for skill in source_skills
    if skill["id"] in runtime_modeled_source_ids
).items()))
source_skill_activation_damage_pair_count = len(source_skill_activation_damage_counts)
source_skill_activation_damage_runtime_pair_count = len(source_skill_activation_damage_runtime_counts)
source_skill_baseattack_physical_pending_count = (
    source_skill_activation_damage_counts.get(("BASEATTACK", "Physical"), 0)
    - source_skill_activation_damage_runtime_counts.get(("BASEATTACK", "Physical"), 0)
)
source_skill_cooldown_chaos_runtime_count = source_skill_activation_damage_runtime_counts.get(("COOLDOWN", "Chaos"), 0)
source_skill_cooldown_chaos_pending_ids = sorted(
    skill["id"]
    for skill in pending_source_skills
    if skill["activation"] == "COOLDOWN" and skill["damage_type"] == "Chaos"
)
source_skill_cooldown_chaos_pending_count = len(source_skill_cooldown_chaos_pending_ids)
expected_source_skill_cooldown_chaos_pending_ids = ["309021", "309041", "309051"]
if source_skill_cooldown_chaos_pending_ids != expected_source_skill_cooldown_chaos_pending_ids:
    issues.append(
        "pending COOLDOWN Chaos source IDs changed: "
        + ",".join(source_skill_cooldown_chaos_pending_ids)
    )
source_skill_cooldown_chaos_value_map = {
    skill["id"]: (skill["source_value"], skill["range"])
    for skill in pending_source_skills
    if skill["activation"] == "COOLDOWN" and skill["damage_type"] == "Chaos"
}
expected_source_skill_cooldown_chaos_value_map = {
    "309021": ("800", "700"),
    "309041": ("1700", "700"),
    "309051": ("2300", "600"),
}
if source_skill_cooldown_chaos_value_map != expected_source_skill_cooldown_chaos_value_map:
    issues.append(
        "pending COOLDOWN Chaos source value/range map changed: "
        + ";".join(
            f"{skill_id}:{value}/r{range_value}"
            for skill_id, (value, range_value) in source_skill_cooldown_chaos_value_map.items()
        )
    )
source_skill_cooldown_chaos_value_count = sum(
    1 for value, _ in source_skill_cooldown_chaos_value_map.values() if value
)
source_skill_cooldown_chaos_page_row_count = source_skill_cooldown_chaos_pending_count
source_skill_cooldown_chaos_page_locale_count = source_skill_cooldown_chaos_page_row_count * 2
source_skill_cooldown_chaos_empty_delivery_count = sum(
    1
    for skill in pending_source_skills
    if skill["activation"] == "COOLDOWN" and skill["damage_type"] == "Chaos" and skill["delivery"] == ""
)
source_skill_cooldown_chaos_unnamed_count = sum(
    1
    for skill in pending_source_skills
    if skill["activation"] == "COOLDOWN" and skill["damage_type"] == "Chaos" and skill["name"].startswith("Skill ")
)
source_skill_activation_delivery_counts = dict(sorted(Counter(
    (skill["activation"], skill["delivery"])
    for skill in source_skills
).items()))
source_skill_activation_delivery_runtime_counts = dict(sorted(Counter(
    (skill["activation"], skill["delivery"])
    for skill in source_skills
    if skill["id"] in runtime_modeled_source_ids
).items()))
source_skill_activation_delivery_pair_count = len(source_skill_activation_delivery_counts)
source_skill_activation_delivery_runtime_pair_count = len(source_skill_activation_delivery_runtime_counts)
source_skill_baseattack_empty_delivery_pending_count = (
    source_skill_activation_delivery_counts.get(("BASEATTACK", ""), 0)
    - source_skill_activation_delivery_runtime_counts.get(("BASEATTACK", ""), 0)
)
source_skill_attackcount_empty_delivery_runtime_count = source_skill_activation_delivery_runtime_counts.get(("BASEATTACK_COUNT", ""), 0)
source_skill_damage_delivery_counts = dict(sorted(Counter(
    (skill["damage_type"], skill["delivery"])
    for skill in source_skills
).items()))
source_skill_damage_delivery_runtime_counts = dict(sorted(Counter(
    (skill["damage_type"], skill["delivery"])
    for skill in source_skills
    if skill["id"] in runtime_modeled_source_ids
).items()))
source_skill_damage_delivery_pair_count = len(source_skill_damage_delivery_counts)
source_skill_damage_delivery_runtime_pair_count = len(source_skill_damage_delivery_runtime_counts)
source_skill_empty_delivery_runtime_count = sum(
    count
    for (damage_type, delivery), count in source_skill_damage_delivery_runtime_counts.items()
    if delivery == ""
)
source_skill_physical_empty_delivery_pending_count = (
    source_skill_damage_delivery_counts.get(("Physical", ""), 0)
    - source_skill_damage_delivery_runtime_counts.get(("Physical", ""), 0)
)
source_skill_chaos_empty_delivery_pending_count = (
    source_skill_damage_delivery_counts.get(("Chaos", ""), 0)
    - source_skill_damage_delivery_runtime_counts.get(("Chaos", ""), 0)
)
source_skill_runtime_range_count = sum(
    1
    for skill in source_skills
    if skill["id"] in runtime_modeled_source_ids
)
source_skill_most_common_damage, source_skill_most_common_damage_count = max(
    source_skill_damage_counts.items(),
    key=lambda item: (item[1], item[0]),
) if source_skill_damage_counts else ("", 0)
source_skill_most_common_delivery, source_skill_most_common_delivery_count = max(
    source_skill_delivery_counts.items(),
    key=lambda item: (item[1], item[0] == "", item[0]),
) if source_skill_delivery_counts else ("", 0)
source_skill_most_common_range, source_skill_most_common_range_count = max(
    source_skill_range_counts.items(),
    key=lambda item: (item[1], -int(item[0])),
) if source_skill_range_counts else ("", 0)
source_skill_min_range = min((int(key) for key in source_skill_range_counts), default=0)
source_skill_max_range = max((int(key) for key in source_skill_range_counts), default=0)
pending_source_skill_activation_counts = dict(sorted(Counter(skill["activation"] for skill in pending_source_skills).items()))
pending_source_skill_damage_counts = dict(sorted(Counter(skill["damage_type"] for skill in pending_source_skills).items()))
pending_source_skill_prefix_counts = dict(sorted(Counter(skill["id"][:1] for skill in pending_source_skills).items()))
pending_source_skill_range_counts = dict(sorted(Counter(skill["range"] for skill in pending_source_skills).items()))
pending_source_skill_empty_delivery_count = sum(1 for skill in pending_source_skills if skill["delivery"] == "")
pending_source_skill_six_digit_unnamed_count = sum(
    1
    for skill in pending_source_skills
    if len(skill["id"]) == 6 and skill["id"].isdigit() and skill["name"].startswith("Skill ")
)
pending_source_skill_activation_damage_order = [
    ("BASEATTACK", "Physical"),
    ("BASEATTACK", "Fire"),
    ("BASEATTACK", "Cold"),
    ("BASEATTACK", "Lightning"),
    ("BASEATTACK", "Chaos"),
    ("BASEATTACK_COUNT", "Physical"),
    ("BASEATTACK_COUNT", "Fire"),
    ("BASEATTACK_COUNT", "Cold"),
    ("BASEATTACK_COUNT", "Lightning"),
    ("BASEATTACK_COUNT", "Chaos"),
    ("COOLDOWN", "Physical"),
    ("COOLDOWN", "Fire"),
    ("COOLDOWN", "Cold"),
    ("COOLDOWN", "Lightning"),
    ("COOLDOWN", "Chaos"),
    ("CONTINUOUS", "Physical"),
    ("CONTINUOUS", "Fire"),
    ("CONTINUOUS", "Cold"),
    ("CONTINUOUS", "Lightning"),
    ("CONTINUOUS", "Chaos"),
]
pending_source_skill_activation_damage_queue_ids_by_pair: dict[tuple[str, str], list[str]] = {}
pending_source_skill_activation_damage_value_count = 0
pending_source_skill_activation_damage_empty_delivery_count = 0
for activation, damage_type in pending_source_skill_activation_damage_order:
    pair_skills = [
        skill
        for skill in pending_source_skills
        if skill["activation"] == activation and skill["damage_type"] == damage_type
    ]
    if not pair_skills:
        continue
    pair = (activation, damage_type)
    pending_source_skill_activation_damage_queue_ids_by_pair[pair] = [
        skill["id"] for skill in sorted(pair_skills, key=lambda skill: skill["id"])
    ]
    pending_source_skill_activation_damage_value_count += sum(1 for skill in pair_skills if skill["source_value"])
    pending_source_skill_activation_damage_empty_delivery_count += sum(1 for skill in pair_skills if skill["delivery"] == "")
pending_source_skill_activation_damage_queue_count = len(pending_source_skill_activation_damage_queue_ids_by_pair)
pending_source_skill_activation_damage_queue_coverage_count = sum(
    len(ids) for ids in pending_source_skill_activation_damage_queue_ids_by_pair.values()
)
pending_source_skill_activation_damage_queue_summary = ",".join(
    f"{activation}/{damage_type}:{len(ids)}"
    for (activation, damage_type), ids in pending_source_skill_activation_damage_queue_ids_by_pair.items()
)
expected_pending_source_skill_activation_damage_queue_counts = {
    ("BASEATTACK", "Physical"): 37,
    ("BASEATTACK", "Fire"): 6,
    ("BASEATTACK", "Cold"): 1,
    ("BASEATTACK", "Chaos"): 4,
    ("BASEATTACK_COUNT", "Physical"): 2,
    ("COOLDOWN", "Physical"): 7,
    ("COOLDOWN", "Chaos"): 3,
}
actual_pending_source_skill_activation_damage_queue_counts = {
    pair: len(ids)
    for pair, ids in pending_source_skill_activation_damage_queue_ids_by_pair.items()
}
if actual_pending_source_skill_activation_damage_queue_counts != expected_pending_source_skill_activation_damage_queue_counts:
    issues.append(
        "pending activation/damage queue distribution changed: "
        + pending_source_skill_activation_damage_queue_summary
    )
if pending_source_skill_activation_damage_queue_coverage_count != len(pending_source_skills):
    issues.append(
        "pending activation/damage queues do not cover exactly all pending rows: "
        + str(pending_source_skill_activation_damage_queue_coverage_count)
    )
pending_source_skill_range_evidence_queue_ids_by_range = {
    range_value: [
        skill["id"]
        for skill in sorted(
            [
                skill
                for skill in pending_source_skills
                if skill["range"] == range_value
            ],
            key=lambda skill: skill["id"],
        )
    ]
    for range_value in sorted(pending_source_skill_range_counts)
}
pending_source_skill_range_evidence_queue_count = len(pending_source_skill_range_evidence_queue_ids_by_range)
pending_source_skill_range_evidence_queue_coverage_count = sum(
    len(ids) for ids in pending_source_skill_range_evidence_queue_ids_by_range.values()
)
pending_source_skill_range_evidence_value_coverage_count = sum(
    1 for skill in pending_source_skills if skill["source_value"]
)
pending_source_skill_range_evidence_empty_delivery_count = sum(
    1 for skill in pending_source_skills if skill["delivery"] == ""
)
pending_source_skill_range_evidence_queue_summary = ",".join(
    f"{range_value}:{len(ids)}"
    for range_value, ids in pending_source_skill_range_evidence_queue_ids_by_range.items()
)
if pending_source_skill_range_evidence_queue_coverage_count != len(pending_source_skills):
    issues.append(
        "pending range evidence queues do not cover exactly all pending rows: "
        + str(pending_source_skill_range_evidence_queue_coverage_count)
    )
expected_pending_source_skill_range_evidence_queue_counts = {
    "130": 5,
    "150": 10,
    "170": 8,
    "200": 6,
    "230": 1,
    "250": 4,
    "270": 1,
    "300": 4,
    "450": 1,
    "600": 3,
    "700": 5,
    "800": 8,
    "900": 4,
}
actual_pending_source_skill_range_evidence_queue_counts = {
    range_value: len(ids)
    for range_value, ids in pending_source_skill_range_evidence_queue_ids_by_range.items()
}
if actual_pending_source_skill_range_evidence_queue_counts != expected_pending_source_skill_range_evidence_queue_counts:
    issues.append(
        "pending range evidence queue distribution changed: "
        + pending_source_skill_range_evidence_queue_summary
    )
pending_source_skill_prefix_evidence_queue_ids_by_prefix = {
    prefix: [
        skill["id"]
        for skill in sorted(
            [
                skill
                for skill in pending_source_skills
                if skill["id"].startswith(prefix)
            ],
            key=lambda skill: skill["id"],
        )
    ]
    for prefix in sorted(pending_source_skill_prefix_counts)
}
pending_source_skill_prefix_evidence_queue_count = len(pending_source_skill_prefix_evidence_queue_ids_by_prefix)
pending_source_skill_prefix_evidence_queue_coverage_count = sum(
    len(ids) for ids in pending_source_skill_prefix_evidence_queue_ids_by_prefix.values()
)
pending_source_skill_prefix_evidence_value_coverage_count = sum(
    1 for skill in pending_source_skills if skill["source_value"]
)
pending_source_skill_prefix_evidence_empty_delivery_count = sum(
    1 for skill in pending_source_skills if skill["delivery"] == ""
)
pending_source_skill_prefix_evidence_queue_summary = ",".join(
    f"{prefix}:{len(ids)}"
    for prefix, ids in pending_source_skill_prefix_evidence_queue_ids_by_prefix.items()
)
if pending_source_skill_prefix_evidence_queue_coverage_count != len(pending_source_skills):
    issues.append(
        "pending prefix evidence queues do not cover exactly all pending rows: "
        + str(pending_source_skill_prefix_evidence_queue_coverage_count)
    )
expected_pending_source_skill_prefix_evidence_queue_counts = {
    "1": 16,
    "2": 21,
    "3": 23,
}
actual_pending_source_skill_prefix_evidence_queue_counts = {
    prefix: len(ids)
    for prefix, ids in pending_source_skill_prefix_evidence_queue_ids_by_prefix.items()
}
if actual_pending_source_skill_prefix_evidence_queue_counts != expected_pending_source_skill_prefix_evidence_queue_counts:
    issues.append(
        "pending prefix evidence queue distribution changed: "
        + pending_source_skill_prefix_evidence_queue_summary
    )
pending_source_skill_value_evidence_queue_ids_by_value = {
    source_value: [
        skill["id"]
        for skill in sorted(
            [
                skill
                for skill in pending_source_skills
                if skill["source_value"] == source_value
            ],
            key=lambda skill: skill["id"],
        )
    ]
    for source_value in sorted(
        {skill["source_value"] for skill in pending_source_skills if skill["source_value"]},
        key=int,
    )
}
pending_source_skill_value_evidence_queue_count = len(pending_source_skill_value_evidence_queue_ids_by_value)
pending_source_skill_value_evidence_queue_coverage_count = sum(
    len(ids) for ids in pending_source_skill_value_evidence_queue_ids_by_value.values()
)
pending_source_skill_value_evidence_empty_delivery_count = sum(
    1 for skill in pending_source_skills if skill["source_value"] and skill["delivery"] == ""
)
pending_source_skill_value_evidence_queue_summary = ",".join(
    f"{source_value}:{len(ids)}"
    for source_value, ids in pending_source_skill_value_evidence_queue_ids_by_value.items()
)
expected_pending_source_skill_value_evidence_queue_counts = {
    "800": 1,
    "1000": 3,
    "1350": 1,
    "1500": 5,
    "1700": 1,
    "1800": 1,
    "2000": 1,
    "2300": 2,
}
actual_pending_source_skill_value_evidence_queue_counts = {
    source_value: len(ids)
    for source_value, ids in pending_source_skill_value_evidence_queue_ids_by_value.items()
}
if actual_pending_source_skill_value_evidence_queue_counts != expected_pending_source_skill_value_evidence_queue_counts:
    issues.append(
        "pending value evidence queue distribution changed: "
        + pending_source_skill_value_evidence_queue_summary
    )
expected_pending_source_skill_value_evidence_queue_ids_by_value = {
    "800": ["309021"],
    "1000": ["200421", "201211", "300441"],
    "1350": ["209031"],
    "1500": ["109021", "109031", "109041", "109051", "309031"],
    "1700": ["309041"],
    "1800": ["209021"],
    "2000": ["209051"],
    "2300": ["209041", "309051"],
}
if pending_source_skill_value_evidence_queue_ids_by_value != expected_pending_source_skill_value_evidence_queue_ids_by_value:
    issues.append(
        "pending value evidence queue ID buckets changed: "
        + ";".join(
            f"{source_value}:{','.join(ids)}"
            for source_value, ids in pending_source_skill_value_evidence_queue_ids_by_value.items()
        )
    )
pending_source_skill_damage_candidate_types = ["Physical", "Fire", "Cold", "Chaos"]
pending_source_skill_damage_candidate_ids_by_type = {
    damage_type: [
        skill["id"]
        for skill in pending_source_skills
        if skill["damage_type"] == damage_type
    ]
    for damage_type in pending_source_skill_damage_candidate_types
}
pending_source_skill_damage_candidate_count = sum(
    len(ids)
    for ids in pending_source_skill_damage_candidate_ids_by_type.values()
)
expected_pending_source_skill_damage_candidate_ids_by_type = {
    "Physical": [
        "100111", "100211", "100221", "100311",
        "100411", "100421", "100431", "100511",
        "100521", "100531", "109011", "109021",
        "109031", "109041", "109051", "200111",
        "200211", "200221", "200231", "200241",
        "200311", "200511", "200611", "200621",
        "200711", "200811", "201111", "201211",
        "209011", "209021", "209031", "209041",
        "209051", "300111", "300121", "300131",
        "300211", "300411", "300421", "300431",
        "300511", "300811", "300831", "300841",
        "301111", "309031",
    ],
    "Fire": ["100231", "200911", "300311", "300611", "300821", "300911"],
    "Cold": ["300441"],
    "Chaos": [
        "200411", "200421", "300711", "309011",
        "309021", "309041", "309051",
    ],
}
if pending_source_skill_damage_candidate_ids_by_type != expected_pending_source_skill_damage_candidate_ids_by_type:
    issues.append(
        "pending damage source ID manifest changed: "
        + ";".join(
            f"{damage_type}:{','.join(ids)}"
            for damage_type, ids in pending_source_skill_damage_candidate_ids_by_type.items()
        )
    )
pending_source_skill_physical_damage_candidate_count = len(pending_source_skill_damage_candidate_ids_by_type["Physical"])
pending_source_skill_elemental_damage_types = ["Fire", "Cold", "Chaos"]
pending_source_skill_elemental_damage_candidate_ids_by_type = {
    damage_type: pending_source_skill_damage_candidate_ids_by_type[damage_type]
    for damage_type in pending_source_skill_elemental_damage_types
}
pending_source_skill_elemental_damage_candidate_count = sum(
    len(ids)
    for ids in pending_source_skill_elemental_damage_candidate_ids_by_type.values()
)
expected_pending_source_skill_elemental_damage_candidate_ids_by_type = {
    "Fire": ["100231", "200911", "300311", "300611", "300821", "300911"],
    "Cold": ["300441"],
    "Chaos": [
        "200411", "200421", "300711", "309011",
        "309021", "309041", "309051",
    ],
}
if pending_source_skill_elemental_damage_candidate_ids_by_type != expected_pending_source_skill_elemental_damage_candidate_ids_by_type:
    issues.append(
        "pending elemental damage source ID manifest changed: "
        + ";".join(
            f"{damage_type}:{','.join(ids)}"
            for damage_type, ids in pending_source_skill_elemental_damage_candidate_ids_by_type.items()
        )
    )
pending_source_skill_chaos_damage_candidate_ids = [
    *pending_source_skill_elemental_damage_candidate_ids_by_type["Chaos"]
]
pending_source_skill_fire_damage_candidate_count = len(pending_source_skill_elemental_damage_candidate_ids_by_type["Fire"])
pending_source_skill_cold_damage_candidate_count = len(pending_source_skill_elemental_damage_candidate_ids_by_type["Cold"])
pending_source_skill_chaos_damage_candidate_count = len(pending_source_skill_chaos_damage_candidate_ids)
expected_pending_source_skill_chaos_damage_candidate_ids = [
    "200411", "200421", "300711", "309011",
    "309021", "309041", "309051",
]
if pending_source_skill_chaos_damage_candidate_ids != expected_pending_source_skill_chaos_damage_candidate_ids:
    issues.append(
        "pending Chaos damage source ID manifest changed: "
        + ",".join(pending_source_skill_chaos_damage_candidate_ids)
    )
pending_source_skill_base_attack_candidate_count = pending_source_skill_activation_counts.get("BASEATTACK", 0)
pending_source_skill_base_attack_candidate_ids_by_prefix = {
    prefix: [
        skill["id"]
        for skill in pending_source_skills
        if skill["activation"] == "BASEATTACK" and skill["id"].startswith(prefix)
    ]
    for prefix in sorted(pending_source_skill_prefix_counts)
}
expected_pending_source_skill_base_attack_candidate_ids_by_prefix = {
    "1": [
        "100111", "100211", "100221", "100231",
        "100311", "100411", "100421", "100431",
        "100511", "100521", "100531", "109011",
    ],
    "2": [
        "200111", "200211", "200221", "200231", "200241", "200311",
        "200411", "200421", "200511", "200611", "200621", "200711",
        "200811", "200911", "201111", "201211", "209011",
    ],
    "3": [
        "300111", "300121", "300131", "300211", "300311", "300411",
        "300421", "300431", "300441", "300511", "300611", "300711",
        "300811", "300821", "300831", "300841", "300911", "301111",
        "309011",
    ],
}
if pending_source_skill_base_attack_candidate_ids_by_prefix != expected_pending_source_skill_base_attack_candidate_ids_by_prefix:
    issues.append(
        "pending BASEATTACK source ID manifest changed: "
        + ";".join(
            f"{prefix}:{','.join(ids)}"
            for prefix, ids in pending_source_skill_base_attack_candidate_ids_by_prefix.items()
        )
    )
pending_source_skill_triggered_candidate_count = (
    pending_source_skill_activation_counts.get("BASEATTACK_COUNT", 0)
    + pending_source_skill_activation_counts.get("COOLDOWN", 0)
)
pending_source_skill_triggered_candidate_ids = [
    skill["id"]
    for skill in pending_source_skills
    if skill["activation"] in ("BASEATTACK_COUNT", "COOLDOWN")
]
expected_pending_source_skill_triggered_candidate_ids = [
    "109021", "109031", "109041", "109051",
    "209021", "209031", "209041", "209051",
    "309021", "309031", "309041", "309051",
]
if pending_source_skill_triggered_candidate_ids != expected_pending_source_skill_triggered_candidate_ids:
    issues.append(
        "pending triggered/cooldown source IDs changed: "
        + ",".join(pending_source_skill_triggered_candidate_ids)
    )
pending_source_skill_triggered_value_map = {
    skill["id"]: (skill["source_value"], skill["range"])
    for skill in pending_source_skills
    if skill["activation"] in ("BASEATTACK_COUNT", "COOLDOWN")
}
expected_pending_source_skill_triggered_value_map = {
    "109021": ("1500", "450"),
    "109031": ("1500", "700"),
    "109041": ("1500", "300"),
    "109051": ("1500", "700"),
    "209021": ("1800", "250"),
    "209031": ("1350", "600"),
    "209041": ("2300", "270"),
    "209051": ("2000", "600"),
    "309021": ("800", "700"),
    "309031": ("1500", "800"),
    "309041": ("1700", "700"),
    "309051": ("2300", "600"),
}
if pending_source_skill_triggered_value_map != expected_pending_source_skill_triggered_value_map:
    issues.append(
        "pending triggered/cooldown source value/range map changed: "
        + ";".join(
            f"{skill_id}:{value}/r{range_value}"
            for skill_id, (value, range_value) in pending_source_skill_triggered_value_map.items()
        )
    )
pending_source_skill_triggered_value_count = sum(
    1 for value, _ in pending_source_skill_triggered_value_map.values() if value
)
pending_source_skill_valued_candidates = sorted(
    [
        skill
        for skill in pending_source_skills
        if skill["source_value"]
    ],
    key=lambda skill: (-int(skill["source_value"]), skill["id"]),
)
pending_source_skill_valued_candidate_count = len(pending_source_skill_valued_candidates)
pending_source_skill_valued_empty_delivery_count = sum(
    1 for skill in pending_source_skill_valued_candidates if skill["delivery"] == ""
)
pending_source_skill_valued_unnamed_count = sum(
    1 for skill in pending_source_skill_valued_candidates if skill["name"].startswith("Skill ")
)
pending_source_skill_catalog_only_count = sum(
    1 for skill in pending_source_skills if not skill["source_value"]
)

def pending_source_skill_has_minimum_evidence(skill):
    return (
        bool(skill["source_value"])
        and bool(skill["delivery"])
        and not skill["name"].startswith("Skill ")
    )

pending_source_skill_minimum_evidence_count = sum(
    1 for skill in pending_source_skills if pending_source_skill_has_minimum_evidence(skill)
)
pending_source_skill_value_range_only_count = sum(
    1
    for skill in pending_source_skills
    if skill["source_value"] and not pending_source_skill_has_minimum_evidence(skill)
)
pending_source_skill_runtime_proof_row_count = (
    len(re.findall(r'PendingSourceSkillRuntimeProofRowModel\s*\(', settings_source))
    if "runtimeProofRows" in settings_source
    and "PendingSourceSkillRuntimeProofRow(row: row)" in settings_source
    else 0
)
pending_source_skill_runtime_proof_coverage_count = (
    len(pending_source_skills)
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_catalog_count = (
    len(pending_source_skills)
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_value_range_count = (
    pending_source_skill_valued_candidate_count
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_minimum_ready_count = (
    pending_source_skill_minimum_evidence_count
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_name_missing_count = (
    pending_source_skill_valued_unnamed_count + pending_source_skill_catalog_only_count
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_delivery_missing_count = (
    pending_source_skill_empty_delivery_count
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_ownership_formula_missing_count = (
    len(pending_source_skills)
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_animation_missing_count = (
    len(pending_source_skills)
    if pending_source_skill_runtime_proof_row_count
    else 0
)
pending_source_skill_runtime_proof_sfx_missing_count = (
    len(pending_source_skills)
    if pending_source_skill_runtime_proof_row_count
    else 0
)
if pending_source_skill_runtime_proof_row_count and (
    pending_source_skill_runtime_proof_row_count != CURRENT_BASELINE["pending_source_skill_runtime_proof_rows"]
    or pending_source_skill_runtime_proof_coverage_count != len(pending_source_skills)
):
    issues.append(
        "pending source skill runtime proof matrix no longer covers all pending rows: "
        f"{pending_source_skill_runtime_proof_row_count} rows, "
        f"{pending_source_skill_runtime_proof_coverage_count}/{len(pending_source_skills)} coverage"
    )
pending_source_skill_value_range_queue_ids = [
    skill["id"]
    for skill in sorted(
        [skill for skill in pending_source_skills if skill["source_value"]],
        key=lambda skill: skill["id"],
    )
]
pending_source_skill_nonphysical_baseattack_queue_ids = [
    skill["id"]
    for skill in sorted(
        [
            skill
            for skill in pending_source_skills
            if (
                not skill["source_value"]
                and skill["activation"] == "BASEATTACK"
                and skill["damage_type"] != "Physical"
            )
        ],
        key=lambda skill: skill["id"],
    )
]
pending_source_skill_physical_baseattack_queue_ids = [
    skill["id"]
    for skill in sorted(
        [
            skill
            for skill in pending_source_skills
            if (
                not skill["source_value"]
                and skill["activation"] == "BASEATTACK"
                and skill["damage_type"] == "Physical"
            )
        ],
        key=lambda skill: skill["id"],
    )
]
pending_source_skill_evidence_queue_ids = (
    pending_source_skill_value_range_queue_ids
    + pending_source_skill_nonphysical_baseattack_queue_ids
    + pending_source_skill_physical_baseattack_queue_ids
)
pending_source_skill_evidence_queue_count = sum(
    1
    for queue_ids in (
        pending_source_skill_value_range_queue_ids,
        pending_source_skill_nonphysical_baseattack_queue_ids,
        pending_source_skill_physical_baseattack_queue_ids,
    )
    if queue_ids
)
pending_source_skill_evidence_queue_coverage_count = len(pending_source_skill_evidence_queue_ids)
pending_source_skill_nonphysical_baseattack_queue_damage_counts = Counter(
    skill["damage_type"]
    for skill in pending_source_skills
    if skill["id"] in pending_source_skill_nonphysical_baseattack_queue_ids
)
pending_source_skill_nonphysical_baseattack_queue_summary = " / ".join(
    f"{damage_type} {pending_source_skill_nonphysical_baseattack_queue_damage_counts[damage_type]}"
    for damage_type in ("Fire", "Cold", "Chaos")
    if pending_source_skill_nonphysical_baseattack_queue_damage_counts.get(damage_type, 0) > 0
)
if sorted(pending_source_skill_evidence_queue_ids) != sorted(skill["id"] for skill in pending_source_skills):
    issues.append(
        "pending source skill evidence queues do not cover exactly all pending rows: "
        + ",".join(pending_source_skill_evidence_queue_ids)
    )
if len(set(pending_source_skill_evidence_queue_ids)) != len(pending_source_skill_evidence_queue_ids):
    issues.append("pending source skill evidence queues are not mutually exclusive")
expected_pending_source_skill_nonphysical_baseattack_queue_ids = [
    "100231", "200411", "200911", "300311", "300611",
    "300711", "300821", "300911", "309011",
]
if pending_source_skill_nonphysical_baseattack_queue_ids != expected_pending_source_skill_nonphysical_baseattack_queue_ids:
    issues.append(
        "pending non-Physical BASEATTACK evidence queue changed: "
        + ",".join(pending_source_skill_nonphysical_baseattack_queue_ids)
    )
expected_pending_source_skill_physical_baseattack_queue_ids = [
    "100111", "100211", "100221", "100311", "100411", "100421",
    "100431", "100511", "100521", "100531", "109011", "200111",
    "200211", "200221", "200231", "200241", "200311", "200511",
    "200611", "200621", "200711", "200811", "201111", "209011",
    "300111", "300121", "300131", "300211", "300411",
    "300421", "300431", "300511", "300811", "300831", "300841",
    "301111",
]
if pending_source_skill_physical_baseattack_queue_ids != expected_pending_source_skill_physical_baseattack_queue_ids:
    issues.append(
        "pending Physical BASEATTACK evidence queue changed: "
        + ",".join(pending_source_skill_physical_baseattack_queue_ids)
    )
pending_source_skill_runtime_gate_count = (
    len(re.findall(r'PendingSourceSkillRuntimeGateRowModel\s*\(', settings_source))
)
pending_source_skill_value_detail_candidates = sorted(
    pending_source_skill_valued_candidates,
    key=lambda skill: skill["id"],
)
pending_source_skill_value_detail_page_count = len(pending_source_skill_value_detail_candidates)
pending_source_skill_value_detail_path_text = "; ".join(
    f"{skill['id']}=/zh/skills/active/id-{skill['id']}/"
    for skill in pending_source_skill_value_detail_candidates
)
pending_source_skill_value_detail_evidence_text = (
    f"{pending_source_skill_value_detail_page_count} 页 / Skill ID / 无说明 / 空 delivery / 命中类型 —"
)
pending_source_skill_reviewed_locale_count = 2
pending_source_skill_source_page_snapshot_version = "v1.00.13"
pending_source_skill_value_detail_locale_page_count = (
    pending_source_skill_value_detail_page_count * pending_source_skill_reviewed_locale_count
)
pending_source_skill_value_detail_snapshot_text = (
    f"{pending_source_skill_value_detail_locale_page_count} 中英页 / "
    f"{pending_source_skill_source_page_snapshot_version} / Skill ID / 无说明 / delivery — / 命中类型 —"
)
pending_source_skill_value_evidence_row_count = (
    len(pending_source_skill_value_detail_candidates)
    if "PendingSourceSkillValueEvidenceRowModel" in settings_source
    else 0
)
pending_source_skill_value_evidence_row_ids = [
    skill["id"] for skill in pending_source_skill_value_detail_candidates
]
pending_source_skill_nonphysical_baseattack_evidence_row_count = (
    len(pending_source_skill_nonphysical_baseattack_queue_ids)
    if "PendingSourceSkillBaseAttackEvidenceRowModel" in settings_source
    else 0
)
pending_source_skill_physical_baseattack_evidence_row_count = (
    len(pending_source_skill_physical_baseattack_queue_ids)
    if "PendingSourceSkillBaseAttackEvidenceRowModel" in settings_source
    else 0
)
pending_source_skill_base_attack_evidence_row_count = (
    pending_source_skill_nonphysical_baseattack_evidence_row_count
    + pending_source_skill_physical_baseattack_evidence_row_count
)
pending_source_skill_base_attack_evidence_row_ids = (
    pending_source_skill_nonphysical_baseattack_queue_ids
    + pending_source_skill_physical_baseattack_queue_ids
)
highest_pending_source_value = int(pending_source_skill_valued_candidates[0]["source_value"]) if pending_source_skill_valued_candidates else 0
pending_source_skill_highest_value_candidates = sorted(
    [
        skill
        for skill in pending_source_skill_valued_candidates
        if int(skill["source_value"]) == highest_pending_source_value
    ],
    key=lambda skill: skill["id"],
)
pending_source_skill_highest_value_text = "; ".join(
    f"{skill['id']}={skill['source_value']}/r{skill['range']}"
    for skill in pending_source_skill_highest_value_candidates
)
expected_pending_source_skill_highest_value_text = "209041=2300/r270; 309051=2300/r600"
if pending_source_skill_highest_value_text != expected_pending_source_skill_highest_value_text:
    issues.append(
        "pending source highest-value candidate set changed: "
        + pending_source_skill_highest_value_text
    )
pending_source_skill_highest_detail_path_text = "; ".join(
    f"{skill['id']}=/zh/skills/active/id-{skill['id']}/"
    for skill in pending_source_skill_highest_value_candidates
)
expected_pending_source_skill_highest_detail_path_text = (
    "209041=/zh/skills/active/id-209041/; 309051=/zh/skills/active/id-309051/"
)
if pending_source_skill_highest_detail_path_text != expected_pending_source_skill_highest_detail_path_text:
    issues.append(
        "pending source highest-value detail path set changed: "
        + pending_source_skill_highest_detail_path_text
    )
pending_source_skill_highest_detail_page_count = len(pending_source_skill_highest_value_candidates)
pending_source_skill_highest_detail_evidence_text = (
    f"{pending_source_skill_highest_detail_page_count} 页 / Skill ID / 无说明 / 空 delivery"
)
pending_source_skill_highest_detail_locale_page_count = (
    pending_source_skill_highest_detail_page_count * pending_source_skill_reviewed_locale_count
)
pending_source_skill_highest_detail_snapshot_text = (
    f"{pending_source_skill_highest_detail_locale_page_count} 中英页 / "
    f"{pending_source_skill_source_page_snapshot_version} / Skill ID / 无说明 / delivery —"
)
pending_source_skill_responsibility_bucket_count = 4
pending_source_skill_most_common_range, pending_source_skill_most_common_range_count = max(
    pending_source_skill_range_counts.items(),
    key=lambda item: (item[1], -int(item[0])),
) if pending_source_skill_range_counts else (0, 0)
pending_source_skill_most_common_range = int(pending_source_skill_most_common_range)

runtime_tick_interval = float(global_static_number(game_pacing_source, "runtimeTickInterval") or 0)
combat_simulation_step = float(global_static_number(game_pacing_source, "combatSimulationStep") or 0)
combat_delta_multiplier = float(global_static_number(game_pacing_source, "combatDeltaMultiplier") or 0)
runtime_xp_multiplier = float(global_static_number(game_pacing_source, "appliedXPMultiplier") or 0)
stage_level_buffer = int(global_static_number(game_pacing_source, "stageLevelBuffer") or 0)
minimum_attack_interval = float(global_static_number(game_pacing_source, "minimumAttackInterval") or 0)
minimum_hasted_attack_interval = float(global_static_number(game_pacing_source, "minimumHastedAttackInterval") or 0)
runtime_tick_interval_tenths = int(round(runtime_tick_interval * 10))
combat_simulation_step_centiseconds = int(round(combat_simulation_step * 100))
combat_delta_multiplier_percent = int(round(combat_delta_multiplier * 100))
runtime_xp_multiplier_percent = int(round(runtime_xp_multiplier * 100))
minimum_attack_interval_tenths = int(round(minimum_attack_interval * 10))
minimum_hasted_attack_interval_centiseconds = int(round(minimum_hasted_attack_interval * 100))
game_pacing_guard = (
    "private let tickInterval: TimeInterval = GamePacing.runtimeTickInterval" in game_loop_source
    and "GamePacing.combatSimulationStep" in game_loop_source
    and "GamePacing.simulatedCombatDelta(for: tickInterval)" in game_loop_source
    and "while remainingBattleTime > 0" in game_loop_source
    and "let requestedXP = GamePacing.pacedXP(from: amount)" in hero_source
    and "static func previewGrantedXP(_ amount: Int, for hero: Hero, maxLevel: Int) -> Int" in hero_source
    and "struct HeroLevelCapBreakdown: Equatable" in hero_source
    and "static func levelCapBreakdown(for progress: ProgressTracker) -> HeroLevelCapBreakdown" in hero_source
    and "levelCapBreakdown(for: progress).maxLevel" in hero_source
    and "var formulaText: String" in hero_source
    and "struct HeroLevelCapStatus: Equatable" in hero_source
    and "static func levelCapStatus(for hero: Hero, progress: ProgressTracker) -> HeroLevelCapStatus" in hero_source
    and "var needsNormalization: Bool" in hero_source
    and "var isAtLevelCap: Bool" in hero_source
    and "var canLevelUp: Bool" in hero_source
    and "var nextLevelXPRemaining: Int" in hero_source
    and "var xpSpaceText: String" in hero_source
    and "func clampLevel(to maxLevel: Int) -> Bool" in hero_source
    and "oldLevel != level || oldXP != currentXP || oldHP != currentHP" in hero_source
    and "static let stageLevelBuffer = GamePacing.stageLevelBuffer" in hero_source
    and "GamePacing.minimumAttackInterval" in battle_source
    and "GamePacing.attackInterval(" in battle_source
    and "minimumHastedAttackInterval" in game_pacing_source
    and "static func simulatedCombatDelta(for wallClockDelta: TimeInterval) -> TimeInterval" in game_pacing_source
    and "normalizedMultiplier > 1.0 ? minimumHastedAttackInterval : minimumAttackInterval" in game_pacing_source
    and "func previewVictoryRewards(_ rewards: BattleResult.Rewards) -> BattleResult.Rewards" in game_loop_source
    and "HeroLevelPacing.previewGrantedXP" in game_loop_source
    and "needsSaveAfterStartupNormalization" in game_loop_source
    and "private func saveAfterStartupNormalizationIfNeeded()" in game_loop_source
    and "private func enforceHeroLevelPacing() -> Bool" in game_loop_source
    and "statistics.offlineXP += appliedXP" in game_loop_source
    and "displayedVictoryRewards" in battle_view_source
    and "hero XP gain applies the local runtime pacing multiplier before leveling" in self_test_source
    and "offline XP statistics record only XP actually applied after pacing and level-cap checks" in self_test_source
    and "battle victory reward preview displays XP after pacing without applying it early" in self_test_source
    and "runtime victory applies mined XP through GamePacing before hero leveling" in self_test_source
    and "GameEngine startup clamps and persists stale over-cap hero saves after offline timestamp checks" in self_test_source
    and "hero level cap status exposes remaining upgrade headroom before the local cap" in self_test_source
    and "hero level cap status exposes the current save state against the local cap" in self_test_source
    and "hero level cap status flags stale or test save values before normalization" in self_test_source
)
settings_pacing_review_guard = (
    "LocalPacingReviewView" in settings_source
    and "本地节奏边界" in settings_source
    and "等级上限" in settings_source
    and "等级状态" in settings_source
    and "XP余量" in settings_source
    and "上限公式" in settings_source
    and "currentHeroLevelCapBreakdown" in settings_source
    and "currentHeroLevelCapStatus" in settings_source
    and "currentHeroLevelCapText" in settings_source
    and "currentHeroLevelCapStatusText" in settings_source
    and "currentHeroLevelCapXPText" in settings_source
    and "currentHeroLevelCapFormulaText" in settings_source
    and "HeroLevelPacing.levelCapBreakdown(for: gameEngine.progress)" in settings_source
    and "HeroLevelPacing.levelCapStatus(for: gameEngine.hero, progress: gameEngine.progress)" in settings_source
    and "currentHeroLevelCapStatus.needsNormalization ? .orange : .secondary" in settings_source
    and "GamePacing.runtimeTickInterval" in settings_source
    and "GamePacing.combatSimulationStep" in settings_source
    and "GamePacing.combatDeltaMultiplier" in settings_source
    and "GamePacing.simulatedCombatDelta(for: GamePacing.runtimeTickInterval)" in settings_source
    and "GamePacing.appliedXPMultiplier" in settings_source
    and "GamePacing.stageLevelBuffer" in settings_source
    and "GamePacing.minimumAttackInterval" in settings_source
    and "GamePacing.minimumHastedAttackInterval" in settings_source
    and "GamePacing.playthroughLevelBonus" in settings_source
    and "GamePacing.pacedXP(from: 1)" in settings_source
    and "let pacedXPPreview = GamePacing.pacedXP(from: runtime.xpReward)" in settings_source
    and "实得≈\\(pacedXPPreview)XP" in settings_source
    and "settings stage source rows can preview applied XP from raw mined XP" in self_test_source
    and "hero level cap breakdown exposes stage, buffer and new-game-plus components" in self_test_source
)
if runtime_tick_interval_tenths != CURRENT_BASELINE["runtime_tick_interval_tenths"]:
    issues.append(
        "runtime tick interval drifted: "
        f"{runtime_tick_interval_tenths} vs {CURRENT_BASELINE['runtime_tick_interval_tenths']}"
    )
if combat_simulation_step_centiseconds != CURRENT_BASELINE["combat_simulation_step_centiseconds"]:
    issues.append(
        "combat simulation step drifted: "
        f"{combat_simulation_step_centiseconds} vs {CURRENT_BASELINE['combat_simulation_step_centiseconds']}"
    )
if combat_delta_multiplier_percent != CURRENT_BASELINE["combat_delta_multiplier_percent"]:
    issues.append(
        "combat delta multiplier drifted: "
        f"{combat_delta_multiplier_percent} vs {CURRENT_BASELINE['combat_delta_multiplier_percent']}"
    )
if runtime_xp_multiplier_percent != CURRENT_BASELINE["runtime_xp_multiplier_percent"]:
    issues.append(
        "runtime XP pacing multiplier drifted: "
        f"{runtime_xp_multiplier_percent} vs {CURRENT_BASELINE['runtime_xp_multiplier_percent']}"
    )
if stage_level_buffer != CURRENT_BASELINE["stage_level_buffer"]:
    issues.append(
        "runtime stage level buffer drifted: "
        f"{stage_level_buffer} vs {CURRENT_BASELINE['stage_level_buffer']}"
    )
if minimum_attack_interval_tenths != CURRENT_BASELINE["minimum_attack_interval_tenths"]:
    issues.append(
        "minimum attack interval drifted: "
        f"{minimum_attack_interval_tenths} vs {CURRENT_BASELINE['minimum_attack_interval_tenths']}"
    )
if minimum_hasted_attack_interval_centiseconds != CURRENT_BASELINE["minimum_hasted_attack_interval_centiseconds"]:
    issues.append(
        "minimum hasted attack interval drifted: "
        f"{minimum_hasted_attack_interval_centiseconds} vs {CURRENT_BASELINE['minimum_hasted_attack_interval_centiseconds']}"
    )
if not game_pacing_guard:
    issues.append("GamePacing constants must drive runtime tick, XP application, level cap and attack interval")
if not settings_pacing_review_guard:
    issues.append("Settings UI must expose the local GamePacing tick, XP, level-cap and attack-interval boundaries")

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

source_monster_database_block = block_between(
    stage_source,
    r'static\s+let\s+entries:\s*\[SourceMonsterDatabaseEntry\]\s*=\s*\[',
    r'\n\s*\]\n\n\s*static\s+var\s+rowCount',
)
source_monster_database_entries = [
    (int(entry_id.replace("_", "")), name)
    for entry_id, name in re.findall(
        r'\.init\(id:\s*([0-9_]+),\s*zhName:\s*"([^"]+)"',
        source_monster_database_block,
    )
]
source_monster_database_ids = [
    entry_id
    for entry_id, _ in source_monster_database_entries
]
source_monster_database_names = set(name for _, name in source_monster_database_entries)
source_monster_source_roster_steam_gap_count = max(
    0,
    ORIGINAL["monster_types_min"] - len(source_monster_database_names),
)
source_monster_source_roster_art_gap_names = sorted(
    source_monster_database_names - composition_names
)
source_monster_source_roster_art_gap_count = len(source_monster_source_roster_art_gap_names)
source_monster_attack_speeds = [
    float(value)
    for value in re.findall(r'attackSpeed:\s*([0-9.]+)', source_monster_database_block)
]
source_monster_database_missing_best_farm = len(re.findall(r'bestFarm:\s*"—"', source_monster_database_block))
source_monster_database_stage_coverage = len(composition_names.intersection(source_monster_database_names))
seen_unmapped_source_monster_names: set[str] = set()
source_monster_database_unmapped_entries = [
    (entry_id, name)
    for entry_id, name in source_monster_database_entries
    if name in source_monster_source_roster_art_gap_names
    and name not in seen_unmapped_source_monster_names
    and not seen_unmapped_source_monster_names.add(name)
]
source_monster_database_unmapped_stage_names = [name for _, name in source_monster_database_unmapped_entries]
source_monster_database_unmapped_stage_count = len(source_monster_database_unmapped_stage_names)
source_monster_source_only_sprite_match = re.search(
    r'sourceOnlySpriteIDs:\s*Set<Int>\s*=\s*\[([^\]]+)\]',
    stage_source,
)
source_monster_source_only_sprite_ids = (
    sorted(
        int(value.strip().replace("_", ""))
        for value in source_monster_source_only_sprite_match.group(1).split(",")
        if value.strip()
    )
    if source_monster_source_only_sprite_match
    else []
)
source_monster_source_only_sprite_names = [
    name
    for entry_id, name in source_monster_database_unmapped_entries
    if entry_id in source_monster_source_only_sprite_ids
]
source_monster_source_only_sprite_count = len(source_monster_source_only_sprite_ids)
source_monster_source_only_sprite_resource_names = [
    f"source_monster_{entry_id}"
    for entry_id in source_monster_source_only_sprite_ids
]
missing_source_monster_sprite_files = [
    resource_name
    for resource_name in source_monster_source_only_sprite_resource_names
    if not (stage_path.parent.parent.parent / "Resources" / "Extracted" / f"{resource_name}.png").exists()
]
if source_monster_source_only_sprite_ids != [20042, 20121, 30044]:
    issues.append(
        "source-only monster sprite IDs changed: "
        + ",".join(str(value) for value in source_monster_source_only_sprite_ids)
    )
if source_monster_source_only_sprite_count != source_monster_database_unmapped_stage_count:
    issues.append(
        "source-only monster sprites no longer cover the current source roster runtime gap: "
        f"{source_monster_source_only_sprite_count}/{source_monster_database_unmapped_stage_count}"
    )
if missing_source_monster_sprite_files:
    issues.append(
        "source-only monster sprite resources are missing: "
        + ",".join(missing_source_monster_sprite_files)
    )
source_monster_unmapped_candidate_skill_ids = sorted(
    skill["id"]
    for entry_id, _ in source_monster_database_unmapped_entries
    for skill in source_skills
    if skill["id"].startswith(str(entry_id))
)
source_monster_unmapped_candidate_skill_count = len(source_monster_unmapped_candidate_skill_ids)
source_skills_by_id = {skill["id"]: skill for skill in source_skills}
pending_source_skill_unmapped_monster_candidate_ids = [
    skill_id
    for skill_id in source_monster_unmapped_candidate_skill_ids
    if skill_id in pending_source_skill_ids
]
pending_source_skill_unmapped_monster_candidate_count = len(
    pending_source_skill_unmapped_monster_candidate_ids
)
pending_source_skill_unmapped_monster_candidate_empty_delivery_count = sum(
    1
    for skill_id in pending_source_skill_unmapped_monster_candidate_ids
    if source_skills_by_id.get(skill_id, {}).get("delivery") == ""
)
pending_source_skill_visual_priority_queue_count = (
    len(re.findall(r'PendingSourceSkillVisualPriorityRowModel\s*\(', settings_source))
    if "visualPriorityRows" in settings_source
    else 0
)
pending_source_skill_visual_priority_elemental_count = pending_source_skill_elemental_damage_candidate_count
pending_source_skill_visual_priority_cooldown_chaos_count = source_skill_cooldown_chaos_pending_count
pending_source_skill_visual_priority_unmapped_monster_count = pending_source_skill_unmapped_monster_candidate_count
pending_source_skill_visual_priority_highest_value_count = pending_source_skill_highest_detail_page_count
pending_source_skill_visual_priority_entry_count = (
    pending_source_skill_visual_priority_elemental_count
    + pending_source_skill_visual_priority_cooldown_chaos_count
    + pending_source_skill_visual_priority_unmapped_monster_count
    + pending_source_skill_visual_priority_highest_value_count
)
pending_source_skill_visual_priority_unique_ids = sorted(
    set(
        [
            skill_id
            for ids in pending_source_skill_elemental_damage_candidate_ids_by_type.values()
            for skill_id in ids
        ]
        + source_skill_cooldown_chaos_pending_ids
        + pending_source_skill_unmapped_monster_candidate_ids
        + [skill["id"] for skill in pending_source_skill_highest_value_candidates]
    )
)
pending_source_skill_visual_priority_unique_count = len(
    pending_source_skill_visual_priority_unique_ids
)
pending_source_skill_visual_priority_overlap_count = (
    pending_source_skill_visual_priority_entry_count
    - pending_source_skill_visual_priority_unique_count
)
pending_source_skill_visual_priority_unqueued_count = (
    len(pending_source_skills)
    - pending_source_skill_visual_priority_unique_count
)
pending_source_skill_visual_priority_unique_id_set = set(
    pending_source_skill_visual_priority_unique_ids
)
pending_source_skill_visual_priority_unqueued_skills = [
    skill
    for skill in sorted(pending_source_skills, key=lambda skill: skill["id"])
    if skill["id"] not in pending_source_skill_visual_priority_unique_id_set
]
pending_source_skill_visual_priority_unqueued_ids = [
    skill["id"] for skill in pending_source_skill_visual_priority_unqueued_skills
]
pending_source_skill_visual_priority_unqueued_value_skills = [
    skill
    for skill in pending_source_skill_visual_priority_unqueued_skills
    if skill["source_value"]
]
pending_source_skill_visual_priority_unqueued_baseattack_catalog_skills = [
    skill
    for skill in pending_source_skill_visual_priority_unqueued_skills
    if not skill["source_value"]
    and skill["activation"] == "BASEATTACK"
]
pending_source_skill_visual_priority_unqueued_queue_count = (
    1 if pending_source_skill_visual_priority_unqueued_value_skills else 0
) + (
    1 if pending_source_skill_visual_priority_unqueued_baseattack_catalog_skills else 0
)
pending_source_skill_visual_priority_unqueued_queue_coverage_count = (
    len(pending_source_skill_visual_priority_unqueued_value_skills)
    + len(pending_source_skill_visual_priority_unqueued_baseattack_catalog_skills)
)
pending_source_skill_visual_review_total_queue_count = (
    pending_source_skill_visual_priority_queue_count
    + pending_source_skill_visual_priority_unqueued_queue_count
)
pending_source_skill_visual_review_total_coverage_count = (
    pending_source_skill_visual_priority_unique_count
    + pending_source_skill_visual_priority_unqueued_queue_coverage_count
)
pending_source_skill_visual_priority_unqueued_value_count = len(
    pending_source_skill_visual_priority_unqueued_value_skills
)
pending_source_skill_visual_priority_unqueued_empty_delivery_count = sum(
    1
    for skill in pending_source_skill_visual_priority_unqueued_skills
    if skill["delivery"] == ""
)
pending_source_skill_visual_priority_unqueued_activation_counts = dict(
    sorted(
        Counter(
            skill["activation"]
            for skill in pending_source_skill_visual_priority_unqueued_skills
        ).items()
    )
)
pending_source_skill_visual_priority_unqueued_damage_counts = dict(
    sorted(
        Counter(
            skill["damage_type"]
            for skill in pending_source_skill_visual_priority_unqueued_skills
        ).items()
    )
)
pending_source_skill_visual_priority_unqueued_range_counts = dict(
    sorted(
        Counter(
            skill["range"]
            for skill in pending_source_skill_visual_priority_unqueued_skills
        ).items(),
        key=lambda item: int(item[0]),
    )
)
pending_source_skill_visual_priority_unqueued_activation_summary = ",".join(
    f"{key}:{value}"
    for key, value in pending_source_skill_visual_priority_unqueued_activation_counts.items()
)
pending_source_skill_visual_priority_unqueued_damage_summary = ",".join(
    f"{key}:{value}"
    for key, value in pending_source_skill_visual_priority_unqueued_damage_counts.items()
)
pending_source_skill_visual_priority_unqueued_range_summary = ",".join(
    f"{key}:{value}"
    for key, value in pending_source_skill_visual_priority_unqueued_range_counts.items()
)
if pending_source_skill_visual_priority_unqueued_queue_coverage_count != pending_source_skill_visual_priority_unqueued_count:
    issues.append(
        "visual-priority unqueued review queues do not cover the unqueued diff: "
        + str(pending_source_skill_visual_priority_unqueued_queue_coverage_count)
    )
if pending_source_skill_visual_review_total_coverage_count != len(pending_source_skills):
    issues.append(
        "visual-review priority plus backlog queues do not cover all pending source skills: "
        + str(pending_source_skill_visual_review_total_coverage_count)
        + "/"
        + str(len(pending_source_skills))
    )
source_monster_unmapped_evidence_gate_count = len(
    re.findall(r'SourceMonsterUnmappedEvidenceGateRowModel\s*\(', settings_source)
)
source_monster_unmapped_evidence_queue_count = (
    source_monster_database_unmapped_stage_count
    if "SourceMonsterUnmappedEvidenceQueueRowModel" in settings_source
    and "stageCompositionUnmappedEvidenceQueueRows" in settings_source
    else 0
)
source_monster_unmapped_evidence_queue_coverage_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_unmapped_evidence_queue_count
    else 0
)
if source_monster_unmapped_candidate_skill_ids != ["200421", "201211", "300441"]:
    issues.append(
        "source monster unmapped candidate skill IDs changed: "
        + ",".join(source_monster_unmapped_candidate_skill_ids)
    )
if pending_source_skill_unmapped_monster_candidate_ids != ["200421", "201211", "300441"]:
    issues.append(
        "pending source skill unmapped-monster candidate IDs changed: "
        + ",".join(pending_source_skill_unmapped_monster_candidate_ids)
    )
if any(skill_id not in pending_source_skill_evidence_queue_ids for skill_id in pending_source_skill_unmapped_monster_candidate_ids):
    issues.append(
        "unmapped-monster same-prefix candidates are no longer represented by the existing pending evidence queues: "
        + ",".join(pending_source_skill_unmapped_monster_candidate_ids)
    )

def source_monster_runtime_speed(attack_speed: float) -> int:
    return max(1, int(attack_speed * 10.0 + 0.5))

def source_monster_source_cooldown(attack_speed: float) -> float:
    return 10.0 / source_monster_runtime_speed(attack_speed)

def source_monster_loop_cooldown(attack_speed: float) -> float:
    bounded_interval = max(minimum_attack_interval, source_monster_source_cooldown(attack_speed))
    simulation_step = max(0.01, combat_simulation_step)
    return math.ceil(bounded_interval / simulation_step) * simulation_step

source_monster_source_cooldowns = [
    source_monster_source_cooldown(value)
    for value in source_monster_attack_speeds
]
source_monster_loop_cooldowns = [
    source_monster_loop_cooldown(value)
    for value in source_monster_attack_speeds
]
source_monster_source_cooldown_min_tenths = int(round(min(source_monster_source_cooldowns) * 10)) if source_monster_source_cooldowns else 0
source_monster_source_cooldown_max_tenths = int(round(max(source_monster_source_cooldowns) * 10)) if source_monster_source_cooldowns else 0
source_monster_loop_cooldown_min_tenths = int(round(min(source_monster_loop_cooldowns) * 10)) if source_monster_loop_cooldowns else 0
source_monster_loop_cooldown_max_tenths = int(round(max(source_monster_loop_cooldowns) * 10)) if source_monster_loop_cooldowns else 0

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
loot_uses_source_progression_identity = (
    "SourceItemCatalog.progression(for: type, itemLevel: itemLevel)" in loot_table_source
    and "来源装备" in loot_table_source
    and "sourceGearID: sourceProgression?.id" in loot_table_source
)
synthesis_preview_uses_source_progression = "outputSourceProgression" in item_source and "SourceItemCatalog.progression(for: $0, itemLevel: level)" in item_source
synthesis_preview_uses_source_examples = (
    "struct SourceSynthesisSkipExample" in item_source
    and "sourceSynthesisSkipExamples" in item_source
    and "sourceResultExample" in item_source
    and "sourceResultExample.displayText" in inventory_view_source
    and "Rarity.sourceSynthesisSkipExamples" in settings_source
    and "source result examples" in self_test_source
)
structured_source_gear_identity = (
    "let sourceGearID: String?" in item_source
    and "sourceGearID, let progression = SourceItemCatalog.progression(id: sourceGearID)" in item_source
    and "inferSourceGearID(from: decodedDescription)" in item_source
    and "static func progression(id: String) -> SourceGearLevelProgression?" in item_source
    and "item.sourceGearProgression" in game_art_source
    and "if let source = item.sourceGearProgression" in inventory_view_source
    and "legacy item descriptions migrate source gear IDs into structured source identity" in self_test_source
    and "explicit source gear ID wins over item-level fallback icon resolution" in self_test_source
    and "structured checked source base gear identity" in self_test_source
)
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
    and "item.sourceGearProgression" in game_art_source
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
support_sanctuary_runtime_guard = (
    "activateSupportSanctuaryBuff" in battle_source
    and "applySupportHealingOverTime" in battle_source
    and "healPerSecond" in battle_source
    and 'skill.id == "40401"' in battle_source
    and ".support(member.heroClass)" in battle_source
)
support_sanctuary_self_test_guard = (
    "support Priest Sanctuary applies an active over-time healing field" in self_test_source
    and "support Priest Sanctuary heals the living party after activation on battle ticks" in self_test_source
)
support_sanctuary_swift_test_guard = (
    "supportSanctuaryAppliesOverTimeHealingField" in combat_stats_tests_source
    and "$0.attacker == .support(.priest)" in combat_stats_tests_source
    and '$0.skillName == "圣域"' in combat_stats_tests_source
)
support_wrath_runtime_guard = (
    "activateSupportWrathOfHeavenBuff" in battle_source
    and "applySupportAttackDamageBuffEffects" in battle_source
    and "bonusAttackDamageMultiplier" in battle_source
    and 'skill.id == "40301"' in battle_source
    and "attacker: .support(member.heroClass)" in battle_source
    and "return storeActiveSupportSkillBuff(buff, source: skill)" in battle_source
    and "damageElement: buff.damageElement" in battle_source
    and "delivery: buff.delivery" in battle_source
)
support_wrath_self_test_guard = (
    "support Priest Wrath of Heaven adds checked lightning range damage to later support attacks" in self_test_source
    and "$0.attacker == .support(.priest)" in self_test_source
    and '$0.skillName == "天堂之怒"' in self_test_source
    and "$0.damageElement == .lightning && $0.delivery == .rangeAOE" in self_test_source
)
support_wrath_swift_test_guard = (
    "supportWrathOfHeavenAddsLightningRangeDamageToSupportAttacks" in combat_stats_tests_source
    and "$0.attacker == .support(.priest)" in combat_stats_tests_source
    and '$0.skillName == "天堂之怒"' in combat_stats_tests_source
    and "$0.damageElement == .lightning && $0.delivery == .rangeAOE" in combat_stats_tests_source
)
support_aegis_runtime_guard = (
    "activateSupportAegisFieldBuff" in battle_source
    and "activeSupportSkillBuffs[index].damageAbsorbRemaining" in battle_source
    and "activeSupportSkillBuffs.compactMap" in battle_source
    and 'skill.id == "10401"' in battle_source
    and ".support(member.heroClass)" in battle_source
)
support_aegis_self_test_guard = (
    "support Knight Aegis Field applies a source-value party damage shield" in self_test_source
    and "support Knight Aegis Field blocks incoming monster damage for the living party" in self_test_source
)
support_aegis_swift_test_guard = (
    "supportAegisFieldAppliesPartyDamageShield" in combat_stats_tests_source
    and "$0.attacker == .support(.knight)" in combat_stats_tests_source
    and '$0.skillName == "神盾领域"' in combat_stats_tests_source
)
support_generals_cry_runtime_guard = (
    "activateSupportGeneralsCryBuff" in battle_source
    and 'skill.id == "60301"' in battle_source
    and "stunAliveEnemies()" in battle_source
    and "critRateMultiplier: 1.0 + Double(skill.levelOneValue) / 100.0" in battle_source
    and ".support(member.heroClass)" in battle_source
)
support_generals_cry_self_test_guard = (
    "support Slayer General's Cry applies its source-value party crit coefficient buff" in self_test_source
    and "support Slayer General's Cry stuns live enemies through the current scaffold" in self_test_source
)
support_generals_cry_swift_test_guard = (
    "supportGeneralsRoarAppliesPartyCritCoefficientAndStun" in combat_stats_tests_source
    and "$0.attacker == .support(.slayer)" in combat_stats_tests_source
    and '$0.skillName == "将军怒吼"' in combat_stats_tests_source
)
support_bloodlust_runtime_guard = (
    "applySupportBloodlustSkill" in battle_source
    and "activateSupportBloodlustBuff" in battle_source
    and 'skill.id == "60601"' in battle_source
    and "damageSupportMember(slotIndex: member.slotIndex, amount: hpCost)" in battle_source
    and "supportAttackMultiplier: 1.0 + Double(skill.levelOneValue) / 100.0" in battle_source
    and "attacker: .support(member.heroClass)" in battle_source
)
support_bloodlust_self_test_guard = (
    "support Slayer Bloodlust consumes support HP and applies its checked attack-damage buff" in self_test_source
    and "$0.attacker == .support(.slayer)" in self_test_source
    and '$0.skillName == "嗜血"' in self_test_source
    and "activeSupportAttackMultiplier(slotIndex: supportBloodlustSlot) == 41.0" in self_test_source
)
support_bloodlust_swift_test_guard = (
    "supportBloodlustConsumesSupportHPAndAppliesSupportAttackBuff" in combat_stats_tests_source
    and "$0.attacker == .support(.slayer)" in combat_stats_tests_source
    and '$0.skillName == "嗜血"' in combat_stats_tests_source
    and "activeSupportAttackMultiplier(slotIndex: supportSlot) == 41.0" in combat_stats_tests_source
)
support_sacred_blade_runtime_guard = (
    "activateSupportSacredBladeBuff" in battle_source
    and "applySupportOnHitBuffEffects" in battle_source
    and "activeSupportAttackMultiplier(slotIndex:" in battle_source
    and 'skill.id == "10501"' in battle_source
    and "supportAttackMultiplier: 1.5" in battle_source
    and "healPerHit: max(1, skill.levelOneValue)" in battle_source
)
support_sacred_blade_self_test_guard = (
    "support Knight Sacred Blade applies its source-backed attack buff to that support member" in self_test_source
    and "support Knight Sacred Blade heals that support member on support attacks" in self_test_source
)
support_sacred_blade_swift_test_guard = (
    "supportSacredBladeAppliesSupportAttackBuffAndOnHitHealing" in combat_stats_tests_source
    and "$0.attacker == .support(.knight)" in combat_stats_tests_source
    and '$0.skillName == "神圣之刃"' in combat_stats_tests_source
)
support_quick_loader_runtime_guard = (
    "activateSupportQuickLoaderBuff" in battle_source
    and 'skill.id == "50301"' in battle_source
    and "supportCooldowns" in battle_source
    and "supportAttackInterval(for member: PartyMember)" in battle_source
    and "member.supportSpeed(allHeroMoveSpeedBonus: allHeroMoveSpeedBonus)" in battle_source
    and "activeSupportAttackSpeedMultiplier(slotIndex:" in battle_source
    and "remainingSupportAttacks: max(1, skill.levelOneValue)" in battle_source
    and "supportAttackSpeedMultiplier: 1.5" in battle_source
    and "consumeSupportAttackBuffCharges" in battle_source
)
support_quick_loader_self_test_guard = (
    "support members attack on independent support-speed cooldowns instead of waiting for main hero attacks" in self_test_source
    and "support Hunter Quick Loader applies its checked attack-speed buff to that support member" in self_test_source
    and "support Hunter Quick Loader applies attack-speed charges without exceeding the one-second tick floor" in self_test_source
    and "support Hunter Quick Loader consumes its checked three support-attack charges under the one-second tick floor" in self_test_source
)
support_quick_loader_swift_test_guard = (
    "supportMembersAttackOnIndependentCooldowns" in combat_stats_tests_source
    and "supportQuickLoaderAppliesSupportAttackSpeedScaffold" in combat_stats_tests_source
    and "$0.attacker == .support(.hunter)" in combat_stats_tests_source
    and '$0.skillName == "快速装填"' in combat_stats_tests_source
    and "quickLoaderBaseAttacksAfterWindow >= 3" in combat_stats_tests_source
    and "quickLoaderBaseAttacksAfterWindow <= 17" in combat_stats_tests_source
)
swift_surge_self_test_guard = (
    "Swift Surge applies its checked +500% attack-speed buff without exceeding the one-second tick floor" in self_test_source
    and "swiftSurgeHeroBaseAttacks == baselineSwiftSurgeHeroBaseAttacks" in self_test_source
    and "swiftSurgeHeroBaseAttacks <= 6" in self_test_source
)
swift_surge_swift_test_guard = (
    "swiftSurgeAppliesAttackSpeedBuff" in combat_stats_tests_source
    and "activeHeroAttackSpeedMultiplier == 6.0" in combat_stats_tests_source
    and "hastedBaseAttacks == baselineBaseAttacks" in combat_stats_tests_source
    and "hastedBaseAttacks <= 6" in combat_stats_tests_source
)
support_swift_surge_runtime_guard = (
    "activateSupportSwiftSurgeBuff" in battle_source
    and 'skill.id == "20401"' in battle_source
    and "activeSupportAttackSpeedMultiplier(slotIndex:" in battle_source
    and "supportAttackSpeedMultiplier: 1.0 + Double(skill.levelOneValue) / 100.0" in battle_source
    and "attacker: .support(member.heroClass)" in battle_source
)
support_swift_surge_self_test_guard = (
    "support Ranger Swift Surge applies its checked attack-speed buff without exceeding the one-second tick floor" in self_test_source
    and "$0.attacker == .support(.ranger)" in self_test_source
    and '$0.skillName == "迅捷觉醒"' in self_test_source
    and "activeSupportAttackSpeedMultiplier(slotIndex: supportSwiftSurgeSlot) == 6.0" in self_test_source
    and "supportSwiftSurgeBaseAttacks == baselineSupportSwiftSurgeBaseAttacks" in self_test_source
    and "supportSwiftSurgeBaseAttacks <= 6" in self_test_source
)
support_swift_surge_swift_test_guard = (
    "supportSwiftSurgeAppliesSupportAttackSpeedBuff" in combat_stats_tests_source
    and "$0.attacker == .support(.ranger)" in combat_stats_tests_source
    and '$0.skillName == "迅捷觉醒"' in combat_stats_tests_source
    and "activeSupportAttackSpeedMultiplier(slotIndex: supportSlot) == 6.0" in combat_stats_tests_source
    and "hastedBaseAttacks == baselineBaseAttacks" in combat_stats_tests_source
    and "hastedBaseAttacks <= 6" in combat_stats_tests_source
)
support_frost_bolt_runtime_guard = (
    "applySupportFrostBoltSkill" in battle_source
    and 'skill.id == "50201"' in battle_source
    and "freezeAliveEnemies(at: targetIndices)" in battle_source
    and "attacker: .support(member.heroClass)" in battle_source
)
support_frost_bolt_self_test_guard = (
    "support Hunter Frost Bolt applies checked cold projectile explosion damage across the live wave" in self_test_source
    and "support Hunter Frost Bolt freezes hit enemies enough to delay their next attack tick" in self_test_source
    and "support Hunter Frost Bolt exposes frozen enemy status badges for the current freeze-delay scaffold" in self_test_source
    and "$0.attacker == .support(.hunter)" in self_test_source
    and '$0.skillName == "寒霜弩箭"' in self_test_source
)
support_frost_bolt_swift_test_guard = (
    "supportFrostBoltDealsColdExplosionDamageAndFreezesLiveWave" in combat_stats_tests_source
    and "$0.attacker == .support(.hunter)" in combat_stats_tests_source
    and '$0.skillName == "寒霜弩箭"' in combat_stats_tests_source
    and "$0.coldStatus == .frozen" in combat_stats_tests_source
)
support_range_damage_runtime_guard = (
    "applySupportRangeDamageSkill" in battle_source
    and 'skill.id == "20201"' in battle_source
    and 'skill.id == "20301"' in battle_source
    and 'skill.id == "30601"' in battle_source
    and "applySupportTrackingProjectileSkill(skill, member: member)" in battle_source
    and "let targetIndices = enemyStates.indices.filter" in battle_source
    and "attacker: .support(member.heroClass)" in battle_source
    and "skillName: skill.name" in battle_source
)
support_range_damage_self_test_guard = (
    "support Ranger Scatter Shot applies support-attributed checked tracking projectile damage across the live wave" in self_test_source
    and "support Ranger Arrow Rain applies support-attributed checked physical range damage across the live wave" in self_test_source
    and "support Sorcerer Meteor Strike applies support-attributed checked fire range damage across the live wave" in self_test_source
    and "$0.attacker == .support(.ranger)" in self_test_source
    and "$0.attacker == .support(.sorcerer)" in self_test_source
    and '$0.skillName == "散弹射击"' in self_test_source
    and '$0.skillName == "箭雨"' in self_test_source
    and '$0.skillName == "陨石打击"' in self_test_source
)
support_range_damage_swift_test_guard = (
    "supportScatterShotDealsSupportAttributedTrackingDamageAcrossLiveWave" in combat_stats_tests_source
    and "supportArrowRainDealsSupportAttributedRangeDamageAcrossLiveWave" in combat_stats_tests_source
    and "supportMeteorStrikeDealsSupportAttributedRangeDamageAcrossLiveWave" in combat_stats_tests_source
    and "$0.attacker == .support(.ranger)" in combat_stats_tests_source
    and "$0.attacker == .support(.sorcerer)" in combat_stats_tests_source
    and '$0.skillName == "散弹射击"' in combat_stats_tests_source
    and '$0.skillName == "箭雨"' in combat_stats_tests_source
    and '$0.skillName == "陨石打击"' in combat_stats_tests_source
)
hero_skill_damage_metadata_runtime_guard = (
    "private func skillDamageLogEntry(" in battle_source
    and "damageElement: skill.damageElement" in battle_source
    and "delivery: skill.delivery" in battle_source
    and battle_source.count("skillDamageLogEntry(") >= 9
    and "return applyHeroRangeDamageSkill(skill)" in battle_source
    and "return applyHeroRapidProjectileSkill(skill)" in battle_source
    and "return applyHeroFrostBoltSkill(skill)" in battle_source
    and "return applyHeroSkewerShotSkill(skill)" in battle_source
    and "return applyHeroShockBoltSkill(skill)" in battle_source
)
hero_skill_damage_metadata_self_test_guard = (
    "main hero damage skill logs preserve source element and delivery metadata in live battle logs" in self_test_source
    and 'skillID: "30101"' in self_test_source
    and 'skillID: "50201"' in self_test_source
    and 'skillID: "20101"' in self_test_source
)
hero_skill_damage_metadata_swift_test_guard = (
    "mainHeroDamageSkillLogsCarrySourceElementAndDeliveryMetadata" in combat_stats_tests_source
    and 'skillID: "30101"' in combat_stats_tests_source
    and 'skillID: "50201"' in combat_stats_tests_source
    and 'skillID: "20101"' in combat_stats_tests_source
)
core_offense_passive_runtime_guard = (
    "var attack: Int" in hero_source
    and "passiveAttackDamage" in hero_source
    and "passiveAttackDamageMultiplier" in hero_source
    and "var speed: Int" in hero_source
    and "passiveAttackSpeedMultiplier" in hero_source
    and "private var modifiedHeroAttack" in battle_source
    and "private var heroAttackInterval" in battle_source
)
core_offense_passive_self_test_guard = (
    "Attack Damage and Attack Speed passives change live Knight base-attack damage and cadence" in self_test_source
    and 'passiveIDs: ["101001", "101072"]' in self_test_source
    and 'passiveIDs: ["101061"]' in self_test_source
    and "$0.skillName == nil" in self_test_source
)
core_offense_passive_swift_test_guard = (
    "unlockedPassiveSkillsFeedCoreRuntimeStats" in combat_stats_tests_source
    and 'passiveIDs: ["101001", "101072"]' in combat_stats_tests_source
    and 'passiveIDs: ["101061"]' in combat_stats_tests_source
    and "$0.skillName == nil" in combat_stats_tests_source
    and "attackSpeedBaseAttacks.count > baselineBaseAttacks.count" in combat_stats_tests_source
)
defensive_passive_runtime_guard = (
    "private func modifiedIncomingDamage(_ damage: Int, damageElement: SkillDamageElement = .none)" in battle_source
    and "passiveDamageReduction" in battle_source
    and "passiveDamageAbsorption" in battle_source
    and "passiveAllElementalResistance" in battle_source
    and "hero.takeDamage(damage)" in battle_source
    and "attacker: .monster" in battle_source
)
defensive_passive_self_test_guard = (
    "Damage Reduction, All Elemental Resistance and Damage Absorption passives reduce live monster-hit damage" in self_test_source
    and 'passiveIDs: ["101071"]' in self_test_source
    and 'passiveIDs: ["101062"]' in self_test_source
    and 'passiveIDs: ["401012", "401032"]' in self_test_source
    and 'sourceSkillID: "301015"' in self_test_source
    and "$0.attacker == .monster" in self_test_source
)
defensive_passive_swift_test_guard = (
    "unlockedPassiveSkillsFeedCoreRuntimeStats" in combat_stats_tests_source
    and 'passiveIDs: ["101071"]' in combat_stats_tests_source
    and 'passiveIDs: ["101062"]' in combat_stats_tests_source
    and 'passiveIDs: ["401012", "401032"]' in combat_stats_tests_source
    and 'sourceSkillID: "301015"' in combat_stats_tests_source
    and "$0.attacker == .monster" in combat_stats_tests_source
    and "absorbedPriestIncoming.totalDamage < baselinePriestIncoming.totalDamage" in combat_stats_tests_source
)
monster_crit_runtime_guard = (
    "critRate: attackingMonster.critRate" in battle_source
    and "critDamage: 1.5" in battle_source
    and "onEvent?(.heroDamaged(isCrit: hit.isCrit))" in battle_source
    and "BattleLogEntry(\n                    attacker: .monster" in battle_source
)
monster_crit_self_test_guard = (
    "monster attacks use stored monster crit rate in live damage logs" in self_test_source
    and "zero monster crit rate keeps live incoming hits non-critical" in self_test_source
    and "firstMonsterIncomingLog(monsterCritRate: 1.0)" in self_test_source
    and "firstMonsterIncomingLog(monsterCritRate: 0)" in self_test_source
)
monster_crit_swift_test_guard = (
    "firstMonsterIncomingLog(monsterCritRate: Double) -> BattleLogEntry?" in combat_stats_tests_source
    and "firstMonsterIncomingLog(monsterCritRate: 1.0)" in combat_stats_tests_source
    and "firstMonsterIncomingLog(monsterCritRate: 0)" in combat_stats_tests_source
    and "#expect(guaranteedMonsterCrit?.isCrit == true)" in combat_stats_tests_source
    and "#expect(zeroMonsterCrit?.isCrit == false)" in combat_stats_tests_source
)
avoidance_passive_runtime_guard = (
    "incomingDodgeRollProvider" in battle_source
    and "incomingBlockRollProvider" in battle_source
    and "roll: incomingDodgeRollProvider()" in battle_source
    and "roll: incomingBlockRollProvider()" in battle_source
    and "kind: .dodge" in battle_source
    and "kind: .block" in battle_source
    and "case dodge" in battle_source
    and "case block" in battle_source
    and 'static let incomingDodgeText = "攻击被闪避"' in battle_view_source
    and 'static let incomingBlockText = "攻击被格挡"' in battle_view_source
    and "BattleLogActionText.displayText(for: entry)" in battle_view_source
)
avoidance_passive_self_test_guard = (
    "DodgeChance and BlockChance passives record visible live battle avoidance logs" in self_test_source
    and "incomingDodgeRollProvider: { dodgeRoll }" in self_test_source
    and "incomingBlockRollProvider: { blockRoll }" in self_test_source
    and "dodgedAttack.entry?.kind == .dodge" in self_test_source
    and "blockedAttack.entry?.kind == .block" in self_test_source
)
avoidance_passive_swift_test_guard = (
    "unlockedDodgeAndBlockPassivesRecordVisibleLiveBattleAvoidanceLogs" in combat_stats_tests_source
    and "incomingDodgeRollProvider: { dodgeRoll }" in combat_stats_tests_source
    and "incomingBlockRollProvider: { blockRoll }" in combat_stats_tests_source
    and "dodgedAttack.entry?.kind == .dodge" in combat_stats_tests_source
    and "blockedAttack.entry?.kind == .block" in combat_stats_tests_source
)
sustain_passive_runtime_guard = (
    "PassiveHealingLogName" in battle_source
    and "private func logPassiveHeroHealing(_ name: String, amount: Int)" in battle_source
    and "applyPassiveHpRegen(deltaTime: deltaTime)" in battle_source
    and "applyPassiveAddHpPerHit()" in battle_source
    and "applyPassiveHpLeech(fromDamage: appliedDamage)" in battle_source
    and "applyPassiveAddHpPerKill()" in battle_source
    and 'skillName: name' in battle_source
    and 'kind: .heal' in battle_source
    and '"生命恢复"' in battle_source
    and '"击中回复"' in battle_source
    and '"生命汲取"' in battle_source
    and '"击杀回复"' in battle_source
)
sustain_passive_self_test_guard = (
    "HpRegenPerSec, AddHpPerHit and AddHpPerKill passives record visible live battle healing" in self_test_source
    and "unlocked HpLeech passive records visible live battle healing" in self_test_source
    and 'skillName == "生命恢复"' in self_test_source
    and 'skillName == "击中回复"' in self_test_source
    and 'skillName == "生命汲取"' in self_test_source
    and 'skillName == "击杀回复"' in self_test_source
    and "$0.kind == .heal" in self_test_source
)
sustain_passive_swift_test_guard = (
    "unlockedSustainPassivesRecordVisibleLiveBattleHealing" in combat_stats_tests_source
    and "unlockedHpLeechPassiveHealsFromMainHeroDamage" in combat_stats_tests_source
    and 'skillName == "生命恢复"' in combat_stats_tests_source
    and 'skillName == "击中回复"' in combat_stats_tests_source
    and 'skillName == "生命汲取"' in combat_stats_tests_source
    and 'skillName == "击杀回复"' in combat_stats_tests_source
    and "$0.kind == .heal" in combat_stats_tests_source
)
damage_type_passive_runtime_guard = (
    "private func passiveSkillDamageMultiplier(for skill: Skill)" in battle_source
    and "passivePhysicalDamagePercent" in battle_source
    and "passiveFireDamagePercent" in battle_source
    and "passiveColdDamagePercent" in battle_source
    and "passiveLightningDamagePercent" in battle_source
)
damage_type_passive_self_test_guard = (
    "Physical, Fire, Cold and Lightning damage passives increase matching live skill damage logs" in self_test_source
    and 'passiveIDs: ["501021"]' in self_test_source
    and 'passiveIDs: ["501022"]' in self_test_source
    and 'passiveIDs: ["501061"]' in self_test_source
    and 'passiveIDs: ["601021"]' in self_test_source
    and '$0.skillName == skillName' in self_test_source
)
damage_type_passive_swift_test_guard = (
    "unlockedDamageTypePassivesIncreaseMatchingMainHeroSkillDamage" in combat_stats_tests_source
    and 'unlockedPassiveSkillIDs: ["501021"]' in combat_stats_tests_source
    and 'unlockedPassiveSkillIDs: ["501022"]' in combat_stats_tests_source
    and 'unlockedPassiveSkillIDs: ["501061"]' in combat_stats_tests_source
    and 'unlockedPassiveSkillIDs: ["601021"]' in combat_stats_tests_source
    and '$0.skillName == skillName' in combat_stats_tests_source
)
area_damage_passive_runtime_guard = (
    "private func passiveSkillDamageMultiplier(for skill: Skill)" in battle_source
    and "passiveIncreaseAreaOfEffectDamage" in battle_source
    and "if [.meleeAOE, .rangeAOE, .projectileAOE, .trap].contains(skill.delivery)" in battle_source
    and "multiplier += passiveEffects.passiveIncreaseAreaOfEffectDamage" in battle_source
)
area_damage_passive_self_test_guard = (
    "Increase Area of Effect Damage passive increases Slam Jump's checked AOE skill damage" in self_test_source
    and 'passiveIDs: ["601051"]' in self_test_source
    and '$0.skillName == "猛击跳跃"' in self_test_source
)
area_damage_passive_swift_test_guard = (
    "increaseAreaOfEffectDamagePassiveBoostsSlamJumpDamage" in combat_stats_tests_source
    and 'passiveIDs: ["601051"]' in combat_stats_tests_source
    and '$0.skillName == "猛击跳跃"' in combat_stats_tests_source
)
projectile_damage_passive_runtime_guard = (
    "private func passiveSkillDamageMultiplier(for skill: Skill)" in battle_source
    and "passiveIncreaseProjectileDamage" in battle_source
    and "if [.projectile, .projectileAOE, .summonProjectile].contains(skill.delivery)" in battle_source
    and "multiplier += passiveEffects.passiveIncreaseProjectileDamage" in battle_source
)
projectile_damage_passive_self_test_guard = (
    "Increase Projectile Damage passive increases Scatter Shot's checked projectile skill damage" in self_test_source
    and 'passiveIDs: ["201022"]' in self_test_source
    and '$0.skillName == "散弹射击"' in self_test_source
)
projectile_damage_passive_swift_test_guard = (
    "increaseProjectileDamagePassiveBoostsScatterShotDamage" in combat_stats_tests_source
    and 'passiveIDs: ["201022"]' in combat_stats_tests_source
    and '$0.skillName == "散弹射击"' in combat_stats_tests_source
)
skill_heal_passive_runtime_guard = (
    "private func modifiedSkillHealing(_ amount: Int)" in battle_source
    and "passiveSkillHealIncrease" in battle_source
    and "healPerSecond: modifiedSkillHealing(skill.levelOneValue)" in battle_source
    and "return appliesHeroPassiveHealing ? modifiedSkillHealing(baseHealing) : baseHealing" in battle_source
)
skill_heal_passive_self_test_guard = (
    "Skill Heal Increase passive increases Sanctuary's checked healing-over-time logs" in self_test_source
    and 'passiveIDs: ["401022"]' in self_test_source
    and '$0.skillName == "圣域"' in self_test_source
)
skill_heal_passive_swift_test_guard = (
    "skillHealIncreasePassiveBoostsSanctuaryHealing" in combat_stats_tests_source
    and 'passiveIDs: ["401022"]' in combat_stats_tests_source
    and '$0.skillName == "圣域"' in combat_stats_tests_source
)
skill_duration_passive_runtime_guard = (
    "private func modifiedSkillDuration(for skill: Skill)" in battle_source
    and "passiveSkillDurationIncrease" in battle_source
    and "remainingDuration: modifiedDuration" in battle_source
    and "func activeHeroBuffRemainingDuration(named name: String)" in battle_source
)
skill_duration_passive_self_test_guard = (
    "Skill Duration Increase passive extends Bloodlust's active battle buff duration" in self_test_source
    and 'passiveIDs: ["601072"]' in self_test_source
    and 'activeHeroBuffRemainingDuration(named: "嗜血")' in self_test_source
)
skill_duration_passive_swift_test_guard = (
    "skillDurationIncreasePassiveExtendsBloodlustDuration" in combat_stats_tests_source
    and 'passiveIDs: ["601072"]' in combat_stats_tests_source
    and 'activeHeroBuffRemainingDuration(named: "嗜血")' in combat_stats_tests_source
)
cooldown_cast_speed_runtime_guard = (
    "static func modifiedSkillCooldown(" in battle_source
    and "passiveCooldownReduction" in battle_source
    and "passiveCastSpeed" in battle_source
    and "skillCooldowns[heroSkillCooldownKey(skill)] = modifiedSkillCooldown(for: skill)" in battle_source
)
cooldown_cast_speed_self_test_guard = (
    "Cooldown Reduction and Cast Speed passives increase Fireball's live cooldown cast count" in self_test_source
    and 'passiveIDs: ["301002", "301041", "301051"]' in self_test_source
    and '$0.skillName == "火球术"' in self_test_source
)
cooldown_cast_speed_swift_test_guard = (
    "cooldownReductionAndCastSpeedPassivesIncreaseFireballCastCount" in combat_stats_tests_source
    and 'passiveIDs: ["301002", "301041", "301051"]' in combat_stats_tests_source
    and '$0.skillName == "火球术"' in combat_stats_tests_source
)
derived_skill_damage_metadata_runtime_guard = (
    "private func activeBuffDamageLogEntry(" in battle_source
    and "private func storeActiveHeroBuff(" in battle_source
    and "private func storeActiveSupportSkillBuff(" in battle_source
    and "var damageElement: SkillDamageElement" in battle_source
    and "var delivery: SkillDelivery" in battle_source
    and "sourcedBuff.damageElement = skill.damageElement" in battle_source
    and "sourcedBuff.delivery = skill.delivery" in battle_source
    and "damageElement: buff.damageElement" in battle_source
    and "delivery: buff.delivery" in battle_source
    and 'skillName: "粉碎强击冲击波"' in battle_source
    and "damageElement: .physical" in battle_source
    and "delivery: .meleeAOE" in battle_source
)
derived_skill_damage_metadata_self_test_guard = (
    "Crushing Blow shockwave damage logs carry explicit physical AOE metadata" in self_test_source
    and "Charge Trap explosion damage logs carry explicit trap metadata" in self_test_source
    and "Crossbow Turret damage logs carry explicit summon projectile metadata" in self_test_source
    and "Shock Bolt current damage logs carry explicit lightning projectile metadata" in self_test_source
)
derived_skill_damage_metadata_swift_test_guard = (
    "crushingBlowKillTriggersShockwaveDamage" in combat_stats_tests_source
    and "chargedTrapDetonatesAfterElementalDamage" in combat_stats_tests_source
    and "chargedTrapTriggersOnlyFromActualElementalDamageLogs" in combat_stats_tests_source
    and "crossbowTurretDeploysAndFiresOverTime" in combat_stats_tests_source
    and "supportShockBoltKeepsSupportAttributedCurrentDamage" in combat_stats_tests_source
    and "$0.damageElement == .physical && $0.delivery == .trap" in combat_stats_tests_source
    and "$0.damageElement == .physical && $0.delivery == .summonProjectile" in combat_stats_tests_source
    and "$0.damageElement == .lightning && $0.delivery == .projectile" in combat_stats_tests_source
)
charge_trap_actual_damage_log_runtime_guard = (
    "triggerChargedTrapExplosionIfNeeded(afterLogIndex" in battle_source
    and "didApplyElementalDamageLog(afterLogIndex" in battle_source
    and "entry.kind == .damage" in battle_source
    and "entry.damage > 0" in battle_source
    and "entry.attacker.isHeroSide" in battle_source
    and "entry.damageElement.isElemental" in battle_source
    and "triggerChargedTrapExplosionIfNeeded(after skill" not in battle_source
    and "isElementalDamageSkill" not in battle_source
)
charge_trap_actual_damage_log_self_test_guard = (
    "Charge Trap ignores actual physical damage logs instead of consuming a charge" in self_test_source
    and "Charge Trap detonates only from actual elemental damage logs, including damage-over-time" in self_test_source
    and '$0.skillName == "弩炮塔"' in self_test_source
    and '$0.skillName == "暴风雪"' in self_test_source
)
charge_trap_actual_damage_log_swift_test_guard = (
    "chargedTrapTriggersOnlyFromActualElementalDamageLogs" in combat_stats_tests_source
    and '$0.skillName == "弩炮塔"' in combat_stats_tests_source
    and '$0.skillName == "暴风雪"' in combat_stats_tests_source
    and "$0.attacker.isHeroSide" in combat_stats_tests_source
)
support_ranger_projectile_metadata_runtime_guard = (
    "applySupportPiercingProjectileSkill" in battle_source
    and "applySupportSkewerShotSkill" in battle_source
    and 'skill.id == "20501"' in battle_source
    and 'skill.id == "20601"' in battle_source
    and "damageElement: skill.damageElement" in battle_source
    and "delivery: skill.delivery" in battle_source
)
support_ranger_projectile_metadata_self_test_guard = (
    "support Ranger Piercing Arrow keeps source physical projectile metadata and piercing trajectory" in self_test_source
    and "support Ranger Skewer Shot keeps source projectile metadata, lodged-arrow trajectory and bleeding marker" in self_test_source
    and '$0.skillName == "穿透之箭"' in self_test_source
    and '$0.skillName == "穿刺射击"' in self_test_source
    and "BattleTrajectoryCue.visible(for: $0) == .piercingArrow" in self_test_source
    and "BattleTrajectoryCue.visible(for: $0) == .lodgedArrow" in self_test_source
)
support_ranger_projectile_metadata_swift_test_guard = (
    "supportPiercingArrowKeepsProjectileMetadataAcrossLiveWave" in combat_stats_tests_source
    and "supportSkewerShotKeepsProjectileMetadataAndBleedingMarker" in combat_stats_tests_source
    and '$0.skillName == "穿透之箭"' in combat_stats_tests_source
    and '$0.skillName == "穿刺射击"' in combat_stats_tests_source
    and "BattleTrajectoryCue.visible(for: $0) == .piercingArrow" in combat_stats_tests_source
    and "BattleTrajectoryCue.visible(for: $0) == .lodgedArrow" in combat_stats_tests_source
)
support_charge_trap_runtime_guard = (
    "activateSupportChargeTrapBuff" in battle_source
    and "triggerSupportChargedTrapExplosion" in battle_source
    and 'skill.id == "50401"' in battle_source
    and "activeSupportSkillBuffs.compactMap(\\.trapChargesRemaining)" in battle_source
    and "trapDamageMultiplier: max(1.0, Double(skill.levelOneValue) / 100.0)" in battle_source
)
support_charge_trap_self_test_guard = (
    "support Hunter Charge Trap arms a visible player-side trap" in self_test_source
    and "support Hunter Charge Trap detonates from later support elemental damage" in self_test_source
    and "$0.attacker == .support(.hunter)" in self_test_source
    and '$0.skillName == "充能陷阱爆炸"' in self_test_source
)
support_charge_trap_swift_test_guard = (
    "supportChargedTrapArmsVisibleTrapAndDetonatesFromSupportElementalDamage" in combat_stats_tests_source
    and "$0.attacker == .support(.hunter)" in combat_stats_tests_source
    and '$0.skillName == "充能陷阱爆炸"' in combat_stats_tests_source
    and "PlayerBattleDeployable.visible(for: battle).contains(.chargedTrap)" in combat_stats_tests_source
)
support_resurrection_runtime_guard = (
    "applySupportResurrectionSkill" in battle_source
    and 'skill.id == "40601"' in battle_source
    and "firstDefeatedSupportIndex(excludingSlotIndex: member.slotIndex)" in battle_source
    and "attacker: .support(member.heroClass)" in battle_source
    and "isSupportSkillUsableNow(_ skill: Skill, member: PartyMember)" in battle_source
)
support_resurrection_self_test_guard = (
    "support Priest Resurrection revives another fallen support member with source 300% max HP" in self_test_source
    and "$0.attacker == .support(.priest)" in self_test_source
    and '$0.skillName == "复活"' in self_test_source
)
support_resurrection_swift_test_guard = (
    "supportPriestResurrectionRevivesAnotherFallenSupportMember" in combat_stats_tests_source
    and "$0.attacker == .support(.priest)" in combat_stats_tests_source
    and '$0.skillName == "复活"' in combat_stats_tests_source
)
support_unyielding_will_runtime_guard = (
    "applySupportUnyieldingWillIfAvailable" in battle_source
    and "supportUnyieldingWillSkill" in battle_source
    and "unyieldingWillWasUsed" in battle_source
    and '$0.id == "10601"' in battle_source
    and ".support(member.heroClass)" in battle_source
)
support_unyielding_will_self_test_guard = (
    "support Knight Unyielding Will revives that support member with source 300% HP" in self_test_source
    and "support Knight Unyielding Will is consumed after one support trigger" in self_test_source
)
support_unyielding_will_swift_test_guard = (
    "supportUnyieldingWillRevivesThatSupportMemberOnceFromLethalMonsterDamage" in combat_stats_tests_source
    and "$0.attacker == .support(.knight)" in combat_stats_tests_source
    and '$0.skillName == "不屈意志"' in combat_stats_tests_source
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
battle_hero_sprite_names = sorted(set(re.findall(r'return "(battle_hero_[^"]+)"', game_art_source)))
battle_hero_source_sprite_names = sorted(set(re.findall(r'return "(official_hero_[^"]+)"', game_art_source)))
expected_battle_hero_sprite_names = [
    "battle_hero_hunter",
    "battle_hero_knight",
    "battle_hero_priest",
    "battle_hero_ranger",
    "battle_hero_slayer",
    "battle_hero_sorcerer",
]
expected_official_hero_sprite_names = [
    "official_hero_hunter",
    "official_hero_knight",
    "official_hero_priest",
    "official_hero_ranger",
    "official_hero_slayer",
    "official_hero_sorcerer",
]
battle_hero_sprite_mapping_guard = (
    battle_hero_sprite_names == expected_battle_hero_sprite_names
    and battle_hero_source_sprite_names == expected_official_hero_sprite_names
    and "static func battleHeroSpriteName(for heroClass: HeroClass) -> String" in game_art_source
    and "static func battleHeroPixelSize(for heroClass: HeroClass) -> CGSize" in game_art_source
    and "GameArt.battleHeroDisplaySize(for: heroClass, scale: mainScale)" in battle_view_source
    and "GameArt.battleHeroDisplaySize(for: heroClass, scale: supportScale)" in battle_view_source
    and "imageName: GameArt.battleHeroSpriteName(for: state.member.heroClass)" in battle_view_source
    and "imageName: GameArt.battleHeroSpriteName(for: battle.primaryHeroClass)" in battle_view_source
    and "battle scene hero sprites use dedicated battle sprite files instead of UI portrait files" in self_test_source
    and "battle scene hero sprites resolve to compact transparent battle figures" in self_test_source
    and "battle scene flips player hero sprites to face the right-side monster lane" in self_test_source
)
battle_hero_source_identity_guard = (
    "private static func validateHeroSpriteMappings() -> [SpriteIssue]" in resource_self_test_source
    and "expectedBattleHeroSpriteName(for: heroClass)" in resource_self_test_source
    and "battle sprite must match hero class identity" in resource_self_test_source
    and "battle sprite must use battle_hero_* art" in resource_self_test_source
    and "validateBattleHeroSpriteTransparency" in resource_self_test_source
    and "validateBattleHeroSpriteIsolatedSubject" in resource_self_test_source
    and "validateBattleHeroClassMarkers" in resource_self_test_source
    and "validateBattleHeroSourceProvenance" in resource_self_test_source
    and "battle hero sprites must be unique across all hero classes" in resource_self_test_source
)
battle_hero_sprite_audit_guard = (
    "hero_names = [" in hero_sprite_audit_source
    and all(f'"{name}"' in hero_sprite_audit_source for name in expected_battle_hero_sprite_names)
    and "matches_official_source" in hero_sprite_audit_source
    and "remove_connected_portrait_frame" in hero_sprite_audit_source
    and "hp_bar_green" in hero_sprite_audit_source
    and "packaged_app_hero_sprite_payload_match=checked sprites" in hero_sprite_audit_source
)
battle_hero_sprite_guard = (
    battle_hero_sprite_mapping_guard
    and battle_hero_source_identity_guard
    and battle_hero_sprite_audit_guard
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
    and "sourceValue: Int?" in skills_source
    and "sourceValueText" in skills_source
    and "SourceSkillCatalog.skill(id: \"309021\")?.runtimeDamageElement == .chaos" in self_test_source
    and "SourceSkillCatalog.skill(id: \"309041\")?.sourceValue == 1700" in self_test_source
    and "source skill catalog preserves checked single-page values only where verified" in self_test_source
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
melee_arc_battle_scene_audit = (
    "case meleeArc" in battle_view_source
    and "MeleeArcTrailCue" in battle_view_source
    and "ordinary melee damage entries expose a short melee arc without using movement trajectories" in self_test_source
    and "Crushing Blow's primary melee hit renders the local melee arc instead of the shockwave trajectory cue" in self_test_source
    and "ordinaryMeleeDamageRendersShortArcWithoutMovementTrajectory" in combat_stats_tests_source
    and "case meleeArc" in battle_scene_snapshot_source
    and "case .meleeArc" in battle_scene_snapshot_source
    and 'skillName: "穿透突刺"' in battle_scene_snapshot_source
    and "--render-battle-scene-fixture meleeArc" in battle_scene_audit_source
    and "melee_arc_pixels" in battle_scene_audit_source
    and "TBH_MELEE_ARC_SCREENSHOT_PATH" in battle_scene_audit_source
)
battle_contact_pulse_audit = (
    "enum BattleContactPulse" in battle_view_source
    and "BattleContactPulseView" in battle_view_source
    and "BattleContactPulse.visible(for: visualLogEntry)" in battle_view_source
    and "case contactPulseBaseline" in battle_scene_snapshot_source
    and "case heroContactPulse" in battle_scene_snapshot_source
    and "case monsterContactPulse" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture contactPulseBaseline" in battle_scene_audit_source
    and ".contactPulseBaseline" in self_test_source
    and "case .heroContactPulse" in battle_scene_snapshot_source
    and "case .monsterContactPulse" in battle_scene_snapshot_source
    and "battle scene snapshot renderer captures hero and monster contact-pulse fixtures" in self_test_source
    and "--render-battle-scene-fixture heroContactPulse" in battle_scene_audit_source
    and "--render-battle-scene-fixture monsterContactPulse" in battle_scene_audit_source
    and "TBH_CONTACT_PULSE_BASELINE_SCREENSHOT_PATH" in battle_scene_audit_source
    and "TBH_HERO_CONTACT_PULSE_SCREENSHOT_PATH" in battle_scene_audit_source
    and "TBH_MONSTER_CONTACT_PULSE_SCREENSHOT_PATH" in battle_scene_audit_source
    and "hero_contact_pulse_pixels" in battle_scene_audit_source
    and "monster_contact_pulse_pixels" in battle_scene_audit_source
)
ranger_projectile_battle_scene_audit = (
    "case rapidVolley" in battle_scene_snapshot_source
    and "case scatterShot" in battle_scene_snapshot_source
    and "case arrowRain" in battle_scene_snapshot_source
    and "case piercingArrow" in battle_scene_snapshot_source
    and "case skewerShot" in battle_scene_snapshot_source
    and "case .rapidVolley" in battle_scene_snapshot_source
    and "case .scatterShot" in battle_scene_snapshot_source
    and "case .arrowRain" in battle_scene_snapshot_source
    and "case .piercingArrow" in battle_scene_snapshot_source
    and "case .skewerShot" in battle_scene_snapshot_source
    and 'skillName: "快速射击"' in battle_scene_snapshot_source
    and 'skillName: "散弹射击"' in battle_scene_snapshot_source
    and 'skillName: "箭雨"' in battle_scene_snapshot_source
    and 'skillName: "穿透之箭"' in battle_scene_snapshot_source
    and 'skillName: "穿刺射击"' in battle_scene_snapshot_source
    and "--render-battle-scene-fixture rapidVolley" in battle_scene_audit_source
    and "--render-battle-scene-fixture scatterShot" in battle_scene_audit_source
    and "--render-battle-scene-fixture arrowRain" in battle_scene_audit_source
    and "--render-battle-scene-fixture piercingArrow" in battle_scene_audit_source
    and "--render-battle-scene-fixture skewerShot" in battle_scene_audit_source
    and "rapid_volley_pixels" in battle_scene_audit_source
    and "scatter_shot_pixels" in battle_scene_audit_source
    and "arrow_rain_pixels" in battle_scene_audit_source
    and "piercing_arrow_pixels" in battle_scene_audit_source
    and "skewer_shot_pixels" in battle_scene_audit_source
)
hunter_bolt_battle_scene_audit = (
    "case shockBolt" in battle_scene_snapshot_source
    and "case shockCurrent" in battle_scene_snapshot_source
    and "case .shockBolt" in battle_scene_snapshot_source
    and "case .shockCurrent" in battle_scene_snapshot_source
    and 'skillName: "电击弩箭"' in battle_scene_snapshot_source
    and 'skillName: "电击弩箭电流"' in battle_scene_snapshot_source
    and "--render-battle-scene-fixture shockBolt" in battle_scene_audit_source
    and "--render-battle-scene-fixture shockCurrent" in battle_scene_audit_source
    and "damage_shock_bolt_pixels" in battle_scene_audit_source
    and "damage_shock_current_pixels" in battle_scene_audit_source
)
source_monster_attack_metadata = (
    "let sourceSkillID: String?" in monster_source
    and "var sourceDamageElement: SkillDamageElement" in monster_source
    and "static func sourceSkillID(forMonsterNamed name: String) -> String?" in skills_source
    and '\"燃烧的地狱祭司\": \"301015\"' in skills_source
    and '\"冰冻的地狱祭司\": \"301025\"' in skills_source
    and '\"电流的地狱祭司\": \"301035\"' in skills_source
    and '\"混沌的地狱祭司\": \"301045\"' in skills_source
    and "SourceSkillCatalog.sourceSkillID(forMonsterNamed: monsterName)" in stage_source
    and "let attackElement = attackingMonster.sourceDamageElement" in battle_source
    and "attackerName: attackingMonster.name" in battle_source
    and "var attackerDisplayName: String" in battle_source
    and "modifiedIncomingDamage(hit.amount, damageElement: attackElement)" in battle_source
    and "incomingAttackWasDodged(damageElement: attackElement)" in battle_source
    and "stage elemental hell priests resolve to checked source monster attack metadata" in self_test_source
    and "source-backed monster attacks keep the actual stage monster name in combat logs" in self_test_source
    and "monster source attack elements feed battle log names, metadata and incoming elemental resistance" in self_test_source
)
warding_blessing_elemental_scope_guard = (
    "let continuousResistance = damageElement.isElemental ? continuousIncomingDamageMultiplier : 1.0" in battle_source
    and "Warding Blessing reduces source elemental incoming damage without reducing physical attacks" in self_test_source
    and "unlocked AllElementalResistance and Warding Blessing reduce only fire, cold and lightning incoming damage" in self_test_source
    and "continuousIncomingDamageMultiplier: 0.9" in combat_stats_tests_source
    and "damageElement: .fire" in combat_stats_tests_source
    and "damageElement: .physical" in combat_stats_tests_source
)
source_monster_incoming_visual_audit = (
    "enum BattleIncomingCue" in battle_view_source
    and "BattleIncomingCueView" in battle_view_source
    and "BattleIncomingCue.visible(for: visualLogEntry)" in battle_view_source
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
enemy_status_body_effect_audit = (
    "enum EnemyStatusBadge" in battle_view_source
    and "EnemyStatusAuraView" in battle_view_source
    and "badges.contains(.chilled)" in battle_view_source
    and "badges.contains(.frozen)" in battle_view_source
    and "badges.contains(.stunned)" in battle_view_source
    and "badges.contains(.bleeding)" in battle_view_source
    and "activateBattleSceneSnapshotEnemyStatuses" in battle_source
    and "case enemyStatusEffects" in battle_scene_snapshot_source
    and "case .enemyStatusEffects" in battle_scene_snapshot_source
    and "battle scene snapshot renderer captures enemy status body-effect fixtures" in self_test_source
    and "--render-battle-scene-fixture enemyStatusEffects" in battle_scene_audit_source
    and "TBH_ENEMY_STATUS_EFFECTS_SCREENSHOT_PATH" in battle_scene_audit_source
    and "enemy_status_chilled_pixels" in battle_scene_audit_source
    and "enemy_status_frozen_pixels" in battle_scene_audit_source
    and "enemy_status_stunned_pixels" in battle_scene_audit_source
    and "enemy_status_bleeding_pixels" in battle_scene_audit_source
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
source_skill_delivery_review_view = (
    "GroupBox(\"原版技能 delivery 分布\")" in settings_source
    and "SourceSkillDeliveryReviewView" in settings_source
    and "SourceSkillDeliveryReviewMetrics" in settings_source
    and "SourceSkillDeliveryRowModel" in settings_source
    and "SourceSkillDeliveryRow(row: row)" in settings_source
    and "delivery 仅作源表形态字段，不推导投射物/范围几何/施法帧" in settings_source
    and "空 delivery 不等于无技能效果；未核对前不伪造形态" in settings_source
    and "已接入仅表示本地有运行时映射，不代表原版几何/动画完整" in settings_source
    and "settings source skill delivery review exposes all source delivery buckets" in self_test_source
    and "settings source skill delivery review preserves checked delivery distribution" in self_test_source
    and "settings source skill delivery review distinguishes runtime-mapped and pending delivery rows" in self_test_source
    and "settings source skill delivery review keeps delivery semantics unfabricated" in self_test_source
)
source_skill_damage_review_view = (
    "GroupBox(\"原版技能 damage 分布\")" in settings_source
    and "SourceSkillDamageReviewView" in settings_source
    and "SourceSkillDamageReviewMetrics" in settings_source
    and "SourceSkillDamageRowModel" in settings_source
    and "SourceSkillDamageRow(row: row)" in settings_source
    and "damage 仅作源表伤害类型字段，不代表抗性/异常状态完整" in settings_source
    and "元素类型不等于原版 VFX/SFX 或命中特效已还原" in settings_source
    and "已接入只表示运行时引用该源行，不代表原版元素规则完整" in settings_source
    and "settings source skill damage review exposes all source damage buckets" in self_test_source
    and "settings source skill damage review preserves checked damage distribution" in self_test_source
    and "settings source skill damage review distinguishes runtime-mapped elemental rows" in self_test_source
    and "settings source skill damage review keeps damage semantics unfabricated" in self_test_source
)
source_skill_activation_damage_review_view = (
    "GroupBox(\"原版技能 activation × damage\")" in settings_source
    and "SourceSkillActivationDamageReviewView" in settings_source
    and "SourceSkillActivationDamageReviewMetrics" in settings_source
    and "SourceSkillActivationDamageRowModel" in settings_source
    and "SourceSkillActivationDamageCellModel" in settings_source
    and "SourceSkillActivationDamageRow(row: row)" in settings_source
    and "cooldownChaosPendingIDs" in settings_source
    and "cooldownChaosPendingIDText" in settings_source
    and "Chaos冷却" in settings_source
    and "activation 仅作源表触发字段，不等于完整施法/攻击时序" in settings_source
    and "交叉分布只展示源字段组合，不推导技能归属/触发频率" in settings_source
    and "已接入只表示本地引用该源行，不代表原版运行时语义完整" in settings_source
    and "settings source skill activation-damage review exposes all checked cross-tab buckets" in self_test_source
    and "settings source skill activation-damage review preserves activation runtime counts" in self_test_source
    and 'cooldownChaosPendingIDs == ["309021", "309041", "309051"]' in self_test_source
    and "settings source skill activation-damage review keeps unmodeled cooldown chaos rows explicit" in self_test_source
    and "settings source skill activation-damage review keeps cross-tab semantics unfabricated" in self_test_source
)
source_skill_activation_delivery_review_view = (
    "GroupBox(\"原版技能 activation × delivery\")" in settings_source
    and "SourceSkillActivationDeliveryReviewView" in settings_source
    and "SourceSkillActivationDeliveryReviewMetrics" in settings_source
    and "SourceSkillActivationDeliveryRowModel" in settings_source
    and "SourceSkillActivationDeliveryRow(row: row)" in settings_source
    and "activation/delivery 仅作源表字段组合，不等于完整触发时序或表现形态" in settings_source
    and "空 delivery 不推导无弹道/无范围；attack-count 空形态保持待核对" in settings_source
    and "已接组合只表示本地引用该源行，不代表原版施法帧/动画完整" in settings_source
    and "settings source skill activation-delivery review exposes all checked cross-tab buckets" in self_test_source
    and "settings source skill activation-delivery review preserves activation runtime counts" in self_test_source
    and "settings source skill activation-delivery review preserves base attack delivery gaps" in self_test_source
    and "settings source skill activation-delivery review keeps trigger visual semantics unfabricated" in self_test_source
)
source_skill_damage_delivery_review_view = (
    "GroupBox(\"原版技能 damage × delivery\")" in settings_source
    and "SourceSkillDamageDeliveryReviewView" in settings_source
    and "SourceSkillDamageDeliveryReviewMetrics" in settings_source
    and "SourceSkillDamageDeliveryRowModel" in settings_source
    and "SourceSkillDamageDeliveryCellModel" in settings_source
    and "SourceSkillDamageDeliveryRow(row: row)" in settings_source
    and "damage/delivery 仅作源表字段组合，不等于原版特效已还原" in settings_source
    and "空 delivery 仍保留为待核对形态，不推导无弹道/无范围" in settings_source
    and "已接组合只表示本地引用该源行，不代表命中几何/动画完整" in settings_source
    and "settings source skill damage-delivery review exposes all checked cross-tab buckets" in self_test_source
    and "settings source skill damage-delivery review preserves damage runtime counts" in self_test_source
    and "settings source skill damage-delivery review keeps empty delivery elemental gaps explicit" in self_test_source
    and "settings source skill damage-delivery review keeps visual semantics unfabricated" in self_test_source
)
source_skill_range_review_view = (
    "GroupBox(\"原版技能 range 分布\")" in settings_source
    and "SourceSkillRangeReviewView" in settings_source
    and "SourceSkillRangeReviewMetrics" in settings_source
    and "SourceSkillRangeRowModel" in settings_source
    and "SourceSkillRangeRow(row: row)" in settings_source
    and "range 仅作源表距离字段，不推导命中范围/弹道/移动速度" in settings_source
    and "已接入只表示运行时引用该源行，不代表原版射程几何完整" in settings_source
    and "最小/最大 range 只作数据边界，不当作屏幕像素比例" in settings_source
    and "settings source skill range review exposes all source range buckets" in self_test_source
    and "settings source skill range review preserves checked range distribution" in self_test_source
    and "settings source skill range review distinguishes runtime-mapped and pending range rows" in self_test_source
    and "settings source skill range review keeps range semantics unfabricated" in self_test_source
)
local_skill_runtime_coverage_view = (
    "GroupBox(\"本地技能运行时覆盖\")" in settings_source
    and "LocalSkillRuntimeCoverageView" in settings_source
    and "LocalSkillRuntimeCoverageMetrics" in settings_source
    and "LocalSkillRuntimeCoverageRowModel" in settings_source
    and "sourceCatalogBoundaryText" in settings_source
    and "pendingRuntimeBoundaryText" in settings_source
    and "monsterBoundaryText" in settings_source
    and "源表完整不等于运行时完整" in settings_source
    and "未接入技能不伪造战斗语义" in settings_source
    and "怪物完整技能表/施法帧待核对" in settings_source
    and "settings local skill runtime coverage distinguishes source rows from runtime-modeled rows" in self_test_source
    and "settings local skill runtime coverage keeps named, base-attack and monster buckets explicit" in self_test_source
    and "settings local skill runtime coverage preserves runtime activation distribution" in self_test_source
    and "settings local skill runtime coverage keeps pending source skill rows visible" in self_test_source
)
pending_source_skill_review_view = (
    "GroupBox(\"待接入源技能复核\")" in settings_source
    and "PendingSourceSkillReviewView" in settings_source
    and "PendingSourceSkillReviewMetrics" in settings_source
    and "PendingSourceSkillCategoryRowModel" in settings_source
    and "PendingSourceSkillReadinessRowModel" in settings_source
    and "PendingSourceSkillRuntimeProofRowModel" in settings_source
    and "PendingSourceSkillValueEvidenceRowModel" in settings_source
    and "PendingSourceSkillBaseAttackEvidenceRowModel" in settings_source
    and "PendingSourceSkillUnmappedMonsterCandidateRowModel" in settings_source
    and "PendingSourceSkillRuntimeGateRowModel" in settings_source
    and "PendingSourceSkillEvidenceQueueRowModel" in settings_source
    and "PendingSourceSkillActivationDamageQueueRowModel" in settings_source
    and "PendingSourceSkillRangeEvidenceQueueRowModel" in settings_source
    and "PendingSourceSkillPrefixEvidenceQueueRowModel" in settings_source
    and "PendingSourceSkillValueEvidenceQueueRowModel" in settings_source
    and "PendingSourceSkillVisualPriorityRowModel" in settings_source
    and "responsibilityRows" in settings_source
    and "readinessRows" in settings_source
    and "runtimeProofRows" in settings_source
    and "runtimeProofRowCount" in settings_source
    and "runtimeProofCoverageText" in settings_source
    and "runtimeProofPositiveText" in settings_source
    and "runtimeProofMissingText" in settings_source
    and "runtimeProofMatrixBoundaryText" in settings_source
    and "valueEvidenceRows" in settings_source
    and "baseAttackEvidenceRows" in settings_source
    and "activationDamageQueueRows" in settings_source
    and "rangeEvidenceQueueRows" in settings_source
    and "prefixEvidenceQueueRows" in settings_source
    and "valueEvidenceQueueRows" in settings_source
    and "visualPriorityRows" in settings_source
    and "visualPriorityUnqueuedSkillIDs" in settings_source
    and "visualPriorityUnqueuedQueueRows" in settings_source
    and "visualPriorityUnqueuedActivationRows" in settings_source
    and "visualPriorityUnqueuedDamageRows" in settings_source
    and "visualPriorityUnqueuedRangeRows" in settings_source
    and "PendingSourceSkillValueEvidenceRow(row: row)" in settings_source
    and "PendingSourceSkillBaseAttackEvidenceRow(row: row)" in settings_source
    and "PendingSourceSkillActivationDamageQueueRow(row: row)" in settings_source
    and "PendingSourceSkillRangeEvidenceQueueRow(row: row)" in settings_source
    and "PendingSourceSkillPrefixEvidenceQueueRow(row: row)" in settings_source
    and "PendingSourceSkillValueEvidenceQueueRow(row: row)" in settings_source
    and "PendingSourceSkillVisualPriorityRow(row: row)" in settings_source
    and "PendingSourceSkillUnmappedMonsterCandidateRow(row: row)" in settings_source
    and "value/range 候选逐项" in settings_source
    and "基础攻击候选逐项" in settings_source
    and "activation × damage 队列" in settings_source
    and "range 证据队列" in settings_source
    and "ID 前缀证据队列" in settings_source
    and "value 证据队列" in settings_source
    and "activation × damage 队列只显示待核对复核顺序" in settings_source
    and "range 队列只排列距离档复核顺序" in settings_source
    and "不按 range 数值生成技能射程、AOE、弹道、动作帧或音效" in settings_source
    and "ID 前缀队列只排列源表命名空间复核顺序" in settings_source
    and "不按前缀生成职业、怪物、关卡、技能归属、公式、弹道、动作帧或音效" in settings_source
    and "value 队列只排列单技能页数值复核顺序" in settings_source
    and "不按 value 生成倍率公式、伤害、目标、持续时间、弹道、动作帧或音效" in settings_source
    and "视觉复核优先队列" in settings_source
    and "视觉复核优先队列可重叠" in settings_source
    and "visualPriorityUniqueSkillIDs" in settings_source
    and "visualPriorityCoverageText" in settings_source
    and "visualReviewTotalQueueCount" in settings_source
    and "visualReviewTotalCoverageText" in settings_source
    and "visualReviewTotalCoverageBoundaryText" in settings_source
    and "唯一覆盖" in settings_source
    and "总覆盖" in settings_source
    and "视觉复核总覆盖由优先队列唯一项加低优先 backlog 差集组成" in settings_source
    and "未入视觉" in settings_source
    and "未入视觉优先队列" in settings_source
    and "未入视觉 value/range" in settings_source
    and "未入视觉 Physical BASEATTACK" in settings_source
    and "视觉复核差集" in settings_source
    and "不按未入队状态、Physical damage、value 或 range 生成技能效果、素材、弹道、动作帧或音效" in settings_source
    and "不按元素、value、ID 前缀或未映射怪物关系生成素材、特效、公式、弹道或音效" in settings_source
    and "未映射怪物同前缀候选" in settings_source
    and "不以单页 value/range 生成技能效果、倍率公式、弹道、动作帧或音效" in settings_source
    and "不以 damage、range 或 ID 段生成基础攻击、怪物招式、元素状态、弹道、动作帧或音效" in settings_source
    and "同前缀只作为未映射怪物复核入口" in settings_source
    and "未映射怪物同前缀候选是交叉复核索引" in settings_source
    and "不改变互斥接入队列" in settings_source
    and "runtimeGateRows" in settings_source
    and "evidenceQueueRows" in settings_source
    and "PendingSourceSkillReadinessRow(row: row)" in settings_source
    and "按证据成熟度" in settings_source
    and "成熟度分组互斥统计" in settings_source
    and "PendingSourceSkillRuntimeProofRow(row: row)" in settings_source
    and "runtime 证明矩阵" in settings_source
    and "runtime 已证" in settings_source
    and "runtime 缺证" in settings_source
    and "source catalog、value/range、activation 或 ID 前缀不生成技能归属" in settings_source
    and "PendingSourceSkillEvidenceQueueRow(row: row)" in settings_source
    and "接入证据队列" in settings_source
    and "接入队列为互斥复核顺序" in settings_source
    and "不按 value、damage 或 ID 段推断技能归属、倍率、弹道、动作帧或音效" in settings_source
    and "PendingSourceSkillRuntimeGateRow(row: row)" in settings_source
    and "runtime 接入门槛" in settings_source
    and "接入门槛只定义缺失证据" in settings_source
    and "不生成技能效果、公式、弹道、动作帧或音效" in settings_source
    and "PendingSourceSkillCategoryRow(row: row)" in settings_source
    and "noRuntimeSemanticsBoundaryText" in settings_source
    and "emptyDeliveryBoundaryText" in settings_source
    and "monsterOwnershipBoundaryText" in settings_source
    and "sixDigitUnnamedBoundaryText" in settings_source
    and "checkedMonsterAttackBoundaryText" in settings_source
    and "triggeredPendingBoundaryText" in settings_source
    and "pendingBaseAttackCandidatePrefixRows" in settings_source
    and "基础攻击候选清单" in settings_source
    and "PendingSourceSkillManifestRow(row: row)" in settings_source
    and "pendingDamageCandidateRows" in settings_source
    and "pendingDamageCandidateSummaryText" in settings_source
    and "pendingDamageCandidateIDText" in settings_source
    and "pendingElementalDamageCandidateRows" in settings_source
    and "pendingElementalDamageCandidateSummaryText" in settings_source
    and "pendingElementalDamageCandidateIDText" in settings_source
    and "pendingChaosDamageCandidateIDs" in settings_source
    and "pendingChaosDamageCandidateIDText" in settings_source
    and "伤害类型候选清单" in settings_source
    and "pendingTriggeredCandidateIDs" in settings_source
    and "pendingTriggeredCandidateIDText" in settings_source
    and "触发/冷却候选" in settings_source
    and "pendingTriggeredValueText" in settings_source
    and "触发/冷却 value" in settings_source
    and "触发/冷却 value 来自单技能页" in settings_source
    and "pendingValuedCandidateCount" in settings_source
    and "pendingValuedEmptyDeliveryCount" in settings_source
    and "pendingValuedUnnamedCount" in settings_source
    and "pendingValueDetailSkills" in settings_source
    and "pendingValueDetailPathText" in settings_source
    and "pendingValueDetailEvidenceText" in settings_source
    and "sourcePageSnapshotVersion" in settings_source
    and "reviewedSourcePageLocales" in settings_source
    and "pendingValueDetailLocalePageCount" in settings_source
    and "pendingValueDetailSnapshotText" in settings_source
    and "highestPendingValueLocalePageCount" in settings_source
    and "highestPendingValueSnapshotText" in settings_source
    and "sourcePageSnapshotBoundaryText" in settings_source
    and "valueDetailBoundaryText" in settings_source
    and "highestPendingValueText" in settings_source
    and "highestPendingValueDetailPathText" in settings_source
    and "highestPendingValueDetailEvidenceText" in settings_source
    and "highestValueDetailBoundaryText" in settings_source
    and "pendingValueReadinessText" in settings_source
    and "sourceValueReadinessBoundaryText" in settings_source
    and "value 页证据" in settings_source
    and "页面快照" in settings_source
    and "value 页路径" in settings_source
    and "最高 value 候选" in settings_source
    and "最高页证据" in settings_source
    and "最高页快照" in settings_source
    and "最高页路径" in settings_source
    and "v1.00.13" in settings_source
    and "不是第二独立来源" in settings_source
    and "value 详情页只证明数值/范围" in settings_source
    and "命中类型 —" in settings_source
    and "settings pending source skill review verifies all value-checked detail pages without marking them runtime-ready" in self_test_source
    and "最高 value 详情页当前仍为 Skill ID、无本地化说明且 delivery 为空" in settings_source
    and "有 value 的候选仍需核对本地化名称、归属、delivery 和描述后才可接入 runtime" in settings_source
    and "pendingCooldownChaosValueText" in settings_source
    and "Chaos 冷却 value" in settings_source
    and "Chaos 冷却 value 来自单技能页" in settings_source
    and "PendingSourceSkillCooldownChaosPageEvidenceRowModel" in settings_source
    and "cooldownChaosPageEvidenceRows" in settings_source
    and "cooldownChaosPageLocaleCount" in settings_source
    and "COOLDOWN/Chaos 页证据" in settings_source
    and "cooldownChaosPageSnapshotText" in settings_source
    and "delivery — / Lv —" in settings_source
    and "Chaos 页快照" in settings_source
    and "单源页" in settings_source
    and "不以 COOLDOWN、Chaos、value 或 range 生成运行时技能" in settings_source
    and "rangeBoundaryText" in settings_source
    and "rangeRows" in settings_source
    and "mostCommonRangeText" in settings_source
    and "待接入源技能不生成战斗效果" in settings_source
    and "来源 delivery 为空时不伪造弹道/范围" in settings_source
    and "怪物归属/施法帧待核对" in settings_source
    and "六位未命名源技能先按数据态候选展示" in settings_source
    and "仅四条地狱祭司攻击已接入运行时" in settings_source
    and "触发/冷却候选不伪造怪物技能语义" in settings_source
    and "range 仅作源表距离字段，不推导命中范围/弹道" in settings_source
    and "settings pending source skill review keeps the data-only pending rows visible" in self_test_source
    and "settings pending source skill review preserves pending activation buckets" in self_test_source
    and "settings pending source skill review preserves pending damage buckets" in self_test_source
    and "settings pending source skill review groups pending skills by activation and damage without runtime semantics" in self_test_source
    and "settings pending source skill review preserves pending source ID ranges" in self_test_source
    and "settings pending source skill review keeps no-runtime and unknown-ownership boundaries explicit" in self_test_source
    and "settings pending source skill review preserves pending responsibility buckets" in self_test_source
    and "settings pending source skill review exposes complete pending damage source manifests" in self_test_source
    and "settings pending source skill review exposes visual-priority evidence queues for art and effect review" in self_test_source
    and "settings pending source skill review covers every pending skill with either a priority or backlog visual-review queue" in self_test_source
    and "settings pending source skill review keeps visual-priority queues tied to current source evidence" in self_test_source
    and "settings pending source skill review keeps visual-priority queues from fabricating art or effects" in self_test_source
    and "settings pending source skill review exposes checked triggered source values without runtime semantics" in self_test_source
    and "settings pending source skill review verifies all value-checked detail pages without marking them runtime-ready" in self_test_source
    and "settings pending source skill review separates catalog-only, value-range-only and minimum-evidence readiness without promoting skills to runtime" in self_test_source
    and "settings pending source skill review exposes a runtime proof matrix for every pending source skill" in self_test_source
    and "settings pending source skill review separates existing catalog and value proof from missing identity, delivery and formula proof" in self_test_source
    and "settings pending source skill review keeps pending source skills blocked by missing identity, delivery, ownership, animation and SFX proof" in self_test_source
    and "settings pending source skill review keeps runtime proof matrix from fabricating skill effects" in self_test_source
    and "settings pending source skill review exposes runtime evidence gates before implementation" in self_test_source
    and "settings pending source skill review keeps runtime gates tied to current pending evidence" in self_test_source
    and "settings pending source skill review keeps runtime gates from fabricating skill effects" in self_test_source
    and "settings pending source skill review groups all pending skills into evidence queues" in self_test_source
    and "settings pending source skill review keeps evidence queues tied to source data" in self_test_source
    and "settings pending source skill review keeps evidence queues from fabricating runtime semantics" in self_test_source
    and "settings pending source skill review expands value-checked candidates into per-skill evidence rows" in self_test_source
    and "settings pending source skill review keeps value evidence rows from fabricating runtime effects" in self_test_source
    and "settings pending source skill review expands base-attack catalog candidates into per-skill evidence rows" in self_test_source
    and "settings pending source skill review keeps base-attack evidence rows from fabricating runtime effects" in self_test_source
    and "settings pending source skill review exposes unmapped monster same-prefix candidates as review-only rows" in self_test_source
    and "settings pending source skill review keeps unmapped monster candidate prefixes from becoming runtime semantics" in self_test_source
    and "settings pending source skill review exposes checked cooldown Chaos source values without runtime semantics" in self_test_source
    and "settings pending source skill review exposes dedicated COOLDOWN/Chaos page evidence rows" in self_test_source
    and "settings pending source skill review keeps COOLDOWN/Chaos page evidence from becoming runtime semantics" in self_test_source
    and "settings pending source skill review exposes complete base-attack candidate manifests by source prefix" in self_test_source
    and "settings pending source skill review distinguishes data-only candidates from checked monster attacks" in self_test_source
    and "settings pending source skill review keeps monster responsibility boundaries explicit" in self_test_source
    and "settings pending source skill review preserves source range buckets" in self_test_source
    and "settings pending source skill review keeps source range ordering visible" in self_test_source
    and "settings pending source skill review keeps range semantics unfabricated" in self_test_source
    and "settings pending source skill review groups pending skills by source range without runtime semantics" in self_test_source
    and "settings pending source skill review keeps range evidence queues from fabricating hit shapes" in self_test_source
    and "settings pending source skill review groups pending skills by source ID prefix without runtime semantics" in self_test_source
    and "settings pending source skill review keeps prefix evidence queues from fabricating ownership" in self_test_source
    and "settings pending source skill review groups value-checked skills by source value without runtime formulas" in self_test_source
    and "settings pending source skill review keeps value queues from fabricating combat semantics" in self_test_source
    and 'PendingSourceSkillReviewMetrics.pendingTriggeredCandidateIDs == [' in self_test_source
)
modeled_active_skill_value_review_view = (
    "GroupBox(\"本地主动技能数值表\")" in settings_source
    and "ModeledActiveSkillValueTableView" in settings_source
    and "ModeledActiveSkillValueTableMetrics" in settings_source
    and "ModeledActiveSkillValueRowModel" in settings_source
    and "ModeledActiveSkillValueRow(row: row)" in settings_source
    and "HeroClass.allCases.flatMap" in settings_source
    and "HeroSkills.named(for: heroClass)" in settings_source
    and "SourceSkillCatalog.skill(id: row.skillID)" in settings_source
    and "仅展示当前运行时已建模的 36 个命名主动技能" in settings_source
    and "其余源技能/基础攻击/怪物技能完整运行时语义待核对" in settings_source
    and "settings modeled active skill value review exposes all 36 runtime named skills" in self_test_source
    and "settings modeled active skill value review keeps complete ten-level tables visible" in self_test_source
    and "settings modeled active skill value review keeps source-backed sample values aligned" in self_test_source
    and "settings modeled active skill value review keeps unmodeled source skill boundaries explicit" in self_test_source
)
source_passive_skill_database_view = (
    "GroupBox(\"原版被动技能数据库\")" in settings_source
    and "SourcePassiveSkillDatabaseView" in settings_source
    and "SourcePassiveSkillDatabaseMetrics" in settings_source
    and "SourcePassiveSkillRow" in settings_source
    and "ForEach(PassiveSkills.all)" in settings_source
    and "GameArt.passiveSkillIconName(for: passiveSkill)" in settings_source
    and "SourcePassiveSkillDatabaseMetrics.sourceIconCoverageText" in settings_source
    and "SourcePassiveSkillDatabaseMetrics.sourceIconFamilyCount" in settings_source
    and "SourcePassiveSkillDatabaseMetrics.currentMissingSourceIconStats" in settings_source
    and "IncreaseProjectileDamage" in settings_source
    and "SkillHealIncrease" in settings_source
    and "source_passive_" in game_art_source
    and "无源图标" in settings_source
    and "缺失来源图标的属性不使用本地图标替代" in settings_source
    and "settings passive source review exposes current source icon coverage" in self_test_source
    and "settings passive source review keeps missing source-icon stats explicit" in self_test_source
)
source_rune_database_view = (
    "SourceRuneDatabaseView" in settings_source
    and "ForEach(SourceRuneCatalog.all)" in settings_source
    and "SourceRuneCatalog.runtimeModeledNodes.count" in settings_source
    and "SourceRuneCatalog.runtimeUnmodeledNodes.count" in settings_source
    and "runtimeModeledSourceIDs.contains(sourceNode.id)" in settings_source
    and "GameArt.sourceRuneIconName(for: sourceNode)" in settings_source
)
rune_tree_one_click_unlock = (
    "unlockAllAvailableRuneTreeNodes" in game_loop_source
    and "unlockableRuneTreeNodeCount" in game_loop_source
    and "unlockableRuneTreeGoldCost" in game_loop_source
    and "一键解锁符文" in settings_source
    and "一键消耗" in settings_source
    and "gameEngine.unlockAllAvailableRuneTreeNodes()" in settings_source
    and "gameEngine.unlockableRuneTreeNodeCount == 0" in settings_source
    and "one-click Rune Tree unlock previews and consumes only available checked gold once while refreshing battle state" in self_test_source
)
local_rune_cost_review_view = (
    "GroupBox(\"本地符文成本复核\")" in settings_source
    and "LocalRuneCostReviewView" in settings_source
    and "LocalRuneCostReviewMetrics" in settings_source
    and "LocalRuneCostReviewRowModel" in settings_source
    and "LocalRunePendingCostGroupModel" in settings_source
    and "LocalRunePendingCostBranchRowModel" in settings_source
    and "LocalRunePendingCostEvidenceQueueRowModel" in settings_source
    and "LocalRunePendingCostBranchEvidenceRowModel" in settings_source
    and "LocalRunePendingCostMaxLevelEvidenceRowModel" in settings_source
    and "LocalRuneApproximateCostEvidenceRowModel" in settings_source
    and "LocalRuneCostEvidenceGateRowModel" in settings_source
    and "RuneTreeNode.allCases.map" in settings_source
    and "SourceRuneCatalog.byID[$0.sourceRuneID]" in settings_source
    and "approximateSourceBackedCount" in settings_source
    and "approximateSourceEvidenceText" in settings_source
    and "approximateEvidenceRows" in settings_source
    and "pendingGroups" in settings_source
    and "pendingBranchRows" in settings_source
    and "pendingCostEvidenceQueueRows" in settings_source
    and "pendingCostBranchEvidenceRows" in settings_source
    and "pendingCostMaxLevelEvidenceRows" in settings_source
    and "costEvidenceGateRows" in settings_source
    and "待核对成本分组" in settings_source
    and "待核对玩法分支" in settings_source
    and "待核对成本接入队列" in settings_source
    and "待核价图标组逐项" in settings_source
    and "LocalRunePendingCostBranchEvidenceRow(row: row)" in settings_source
    and "待核价 maxLevel 队列" in settings_source
    and "LocalRunePendingCostMaxLevelEvidenceRow(row: row)" in settings_source
    and "约值成本证据" in settings_source
    and "LocalRuneApproximateCostEvidenceRow(row: row)" in settings_source
    and "成本接入门槛" in settings_source
    and "不按 \\(group.iconName) 图标组或 \\(group.pendingCount) 个重复节点推断符文价格、路径成本、重置退款或点数经济" in settings_source
    and "官方符文分支：2nd Active Skill Slot (~50,000g)" in rune_source
    and "约值成本不参与已核对退款" in settings_source
    and "约值证据只证明页面/指南层成本线索" in settings_source
    and "缺游戏内扣费、路径成本、重置退款和点数经济前，不转入已核对运行时成本" in settings_source
    and "不把 \\(row.costText) 写入运行时扣费、路径成本、重置退款或点数经济" in settings_source
    and "成本待核对节点不伪造成金币成本" in settings_source
    and "重置仅返还已核对金币成本" in settings_source
    and "分组只定位成本缺口所在源表图标/分支" in settings_source
    and "玩法分支只用于排列复核优先级" in settings_source
    and "接入门槛只定义成本缺失证据，不生成符文价格、路径成本、重置退款或点数经济" in settings_source
    and "接入队列只排列互斥复核顺序" in settings_source
    and "不按玩法分支、源表图标、重复节点数量或单源候选数据生成符文价格" in settings_source
    and "maxLevel 队列只排列源表等级上限复核顺序" in settings_source
    and "不按 maxLevel 生成逐级价格、成本梯度、路径成本、重置退款或点数经济" in settings_source
    and "settings local Rune cost review exposes every runtime Rune node" in self_test_source
    and "settings local Rune cost review keeps Rune of Awakening as official-branch approximate cost only" in self_test_source
    and "settings local Rune cost review exposes official approximate Rune cost evidence without marking it verified" in self_test_source
    and "settings local Rune cost review exposes a dedicated approximate-cost evidence row for Rune of Awakening" in self_test_source
    and "settings local Rune cost review keeps approximate-cost evidence from entering runtime economy" in self_test_source
    and "settings local Rune cost review keeps unknown Rune costs explicit" in self_test_source
    and "settings local Rune cost review groups pending costs by source icon family without promoting verified or approximate nodes" in self_test_source
    and "settings local Rune cost review groups pending costs by gameplay branch without inventing prices" in self_test_source
    and "settings local Rune cost review groups pending costs into evidence queues" in self_test_source
    and "settings local Rune cost review expands pending branch icon groups into evidence rows" in self_test_source
    and "settings local Rune cost review keeps branch evidence rows from fabricating Rune prices" in self_test_source
    and "settings local Rune cost review keeps evidence queues from fabricating Rune costs" in self_test_source
    and "settings local Rune cost review groups pending costs by source maxLevel without inventing prices" in self_test_source
    and "settings local Rune cost review keeps maxLevel evidence queues from fabricating Rune costs" in self_test_source
    and "settings local Rune cost review exposes cost evidence gates before pending costs enter runtime" in self_test_source
    and "settings local Rune cost review ties cost gates to current verified, pending and candidate evidence" in self_test_source
)
if local_rune_cost_review_view and (
    local_rune_cost_approximate_evidence_row_count != rune_approximate_cost_nodes
    or local_rune_cost_approximate_evidence_coverage_count != rune_approximate_cost_nodes
):
    issues.append(
        "local Rune approximate-cost evidence rows do not cover all approximate Rune nodes: "
        f"{local_rune_cost_approximate_evidence_row_count}/{rune_approximate_cost_nodes} rows, "
        f"{local_rune_cost_approximate_evidence_coverage_count}/{rune_approximate_cost_nodes} covered"
    )
if local_rune_cost_review_view and (
    rune_pending_cost_branch_group_total != rune_pending_cost_icon_group_count
    or rune_pending_cost_branch_node_total != rune_pending_cost_nodes
):
    issues.append(
        "local Rune pending cost gameplay branches do not cover all pending icon groups/nodes: "
        f"{rune_pending_cost_branch_group_total}/{rune_pending_cost_icon_group_count} groups, "
        f"{rune_pending_cost_branch_node_total}/{rune_pending_cost_nodes} nodes"
    )
if local_rune_cost_review_view and (
    local_rune_cost_evidence_queue_count != rune_pending_cost_branch_count
    or local_rune_cost_evidence_queue_group_coverage_count != rune_pending_cost_icon_group_count
    or local_rune_cost_evidence_queue_coverage_count != rune_pending_cost_nodes
):
    issues.append(
        "local Rune pending cost evidence queues do not cover all pending branches/icon groups/nodes: "
        f"{local_rune_cost_evidence_queue_count}/{rune_pending_cost_branch_count} branches, "
        f"{local_rune_cost_evidence_queue_group_coverage_count}/{rune_pending_cost_icon_group_count} groups, "
        f"{local_rune_cost_evidence_queue_coverage_count}/{rune_pending_cost_nodes} nodes"
    )
if local_rune_cost_review_view and (
    local_rune_cost_branch_evidence_row_count != rune_pending_cost_icon_group_count
    or local_rune_cost_branch_evidence_group_coverage_count != rune_pending_cost_icon_group_count
    or local_rune_cost_branch_evidence_coverage_count != rune_pending_cost_nodes
):
    issues.append(
        "local Rune pending cost branch evidence rows do not cover all pending icon groups/nodes: "
        f"{local_rune_cost_branch_evidence_row_count}/{rune_pending_cost_icon_group_count} groups, "
        f"{local_rune_cost_branch_evidence_coverage_count}/{rune_pending_cost_nodes} nodes"
    )
if local_rune_cost_review_view and (
    local_rune_cost_max_level_evidence_queue_count != rune_pending_cost_max_level_queue_count
    or local_rune_cost_max_level_evidence_coverage_count != rune_pending_cost_nodes
    or local_rune_cost_max_level_evidence_icon_bucket_count != rune_pending_cost_max_level_icon_bucket_total
):
    issues.append(
        "local Rune pending cost maxLevel evidence queues do not cover all pending maxLevel buckets/nodes: "
        f"{local_rune_cost_max_level_evidence_queue_count}/{rune_pending_cost_max_level_queue_count} buckets, "
        f"{local_rune_cost_max_level_evidence_coverage_count}/{rune_pending_cost_nodes} nodes, "
        f"{local_rune_cost_max_level_evidence_icon_bucket_count}/{rune_pending_cost_max_level_icon_bucket_total} icon buckets"
    )
source_rune_evidence_review_rows = len(re.findall(r'SourceRuneEvidenceReviewRowModel\(', settings_source))
source_rune_evidence_independent_sources_match = re.search(
    r'static\s+let\s+independentSourceCount\s*=\s*(\d+)',
    settings_source
)
source_rune_evidence_independent_sources = int(source_rune_evidence_independent_sources_match.group(1)) if source_rune_evidence_independent_sources_match else 0
source_rune_evidence_verified_cost_rows_match = re.search(
    r'static\s+let\s+verifiedCostRows\s*=\s*(\d+)',
    settings_source
)
source_rune_evidence_verified_cost_rows = int(source_rune_evidence_verified_cost_rows_match.group(1)) if source_rune_evidence_verified_cost_rows_match else 0
source_rune_evidence_candidate_cost_rows_match = re.search(
    r'static\s+let\s+candidateCostRows\s*=\s*(\d+)',
    settings_source
)
source_rune_evidence_candidate_cost_rows = int(source_rune_evidence_candidate_cost_rows_match.group(1)) if source_rune_evidence_candidate_cost_rows_match else 0
source_rune_evidence_candidate_cost_gold_total_match = re.search(
    r'static\s+let\s+candidateCostGoldTotal\s*=\s*([0-9_]+)',
    settings_source
)
source_rune_evidence_candidate_cost_gold_total = int(source_rune_evidence_candidate_cost_gold_total_match.group(1).replace("_", "")) if source_rune_evidence_candidate_cost_gold_total_match else 0
source_rune_tbh_city_candidate_cost_table_rows_match = re.search(
    r'static\s+let\s+tbhCityCandidateCostTableRows\s*=\s*(\d+)',
    settings_source
)
source_rune_tbh_city_candidate_cost_table_rows = int(source_rune_tbh_city_candidate_cost_table_rows_match.group(1)) if source_rune_tbh_city_candidate_cost_table_rows_match else 0
source_rune_tbh_city_candidate_cost_table_gold_total_match = re.search(
    r'static\s+let\s+tbhCityCandidateCostTableGoldTotal\s*=\s*([0-9_]+)',
    settings_source
)
source_rune_tbh_city_candidate_cost_table_gold_total = int(source_rune_tbh_city_candidate_cost_table_gold_total_match.group(1).replace("_", "")) if source_rune_tbh_city_candidate_cost_table_gold_total_match else 0
source_rune_candidate_cost_queue_body = block_between(
    settings_source,
    r'static\s+let\s+candidateCostQueueRows\s*:\s*\[SourceRuneCandidateCostQueueRowModel\]\s*=\s*\[',
    r'\n\s*\]\n\s*\n\s*static\s+let\s+rows'
)
source_rune_candidate_cost_queue_rows = len(re.findall(r'SourceRuneCandidateCostQueueRowModel\(', source_rune_candidate_cost_queue_body))
source_rune_candidate_cost_queue_counts = [
    int(value.replace("_", ""))
    for value in re.findall(r'affectedCandidateCount:\s*([0-9_]+)', source_rune_candidate_cost_queue_body)
]
source_rune_candidate_cost_queue_gold_values = [
    int(value.replace("_", ""))
    for value in re.findall(r'candidateGold:\s*([0-9_]+)', source_rune_candidate_cost_queue_body)
]
source_rune_candidate_cost_queue_keys = re.findall(r'key:\s*"([^"]+)"', source_rune_candidate_cost_queue_body)
source_rune_candidate_cost_queue_coverage = sum(source_rune_candidate_cost_queue_counts)
source_rune_candidate_cost_queue_gold_total = sum(source_rune_candidate_cost_queue_gold_values)
source_rune_evidence_timer_rows_match = re.search(
    r'static\s+let\s+timerEvidenceRows\s*=\s*(\d+)',
    settings_source
)
source_rune_evidence_timer_rows = int(source_rune_evidence_timer_rows_match.group(1)) if source_rune_evidence_timer_rows_match else 0
source_rune_candidate_cost_queue_guard = (
    source_rune_candidate_cost_queue_rows == CURRENT_BASELINE["source_rune_candidate_cost_queues"]
    and source_rune_candidate_cost_queue_coverage == CURRENT_BASELINE["source_rune_candidate_cost_queue_coverage"]
    and source_rune_candidate_cost_queue_gold_total == CURRENT_BASELINE["source_rune_candidate_cost_queue_gold_total"]
    and source_rune_candidate_cost_queue_keys == [
        "candidate-10k",
        "candidate-200k",
        "candidate-1m",
        "candidate-lubrication-aggregate",
    ]
    and "SourceRuneCandidateCostQueueRowModel" in settings_source
    and "SourceRuneCandidateCostQueueRow(row: row)" in settings_source
    and "候选成本队列" in settings_source
    and "候选成本队列只拆分 tbh.city 单源证据" in settings_source
    and "不按候选金额生成符文价格、路径成本、重置退款或点数经济" in settings_source
    and "不把润滑合计拆成逐节点价格、路径成本或退款" in settings_source
    and "settings Rune evidence review splits single-source candidate costs into review-only buckets" in self_test_source
    and "settings Rune evidence review keeps tbh.city candidate bucket totals visible without per-node binding" in self_test_source
    and "settings Rune evidence review keeps candidate cost queues from entering runtime cost or refund math" in self_test_source
)
source_rune_tbh_city_candidate_cost_table_guard = (
    source_rune_tbh_city_candidate_cost_table_rows == CURRENT_BASELINE["source_rune_tbh_city_candidate_cost_table_rows"]
    and source_rune_tbh_city_candidate_cost_table_gold_total == CURRENT_BASELINE["source_rune_tbh_city_candidate_cost_table_gold_total"]
    and "完整 total_cost_to_max 表覆盖 197/197 节点" in settings_source
    and "完整候选成本表" in settings_source
    and "10_040_515_050" in settings_source
    and "#1 100G / #21 1,000G / #24 150,000G / #27 50,000G / #13002 10,000G" in settings_source
    and "tbh.city total_cost_to_max 仍是单源候选" in settings_source
    and "不写入运行时扣费、退款或点数经济" in settings_source
    and "10,040,515,050G" in self_test_source
    and "settings Rune evidence review exposes complete tbh.city candidate cost-table coverage without promoting it to verified runtime costs" in self_test_source
)
source_rune_evidence_review_view = (
    "GroupBox(\"符文证据分层\")" in settings_source
    and "SourceRuneEvidenceReviewView" in settings_source
    and "SourceRuneEvidenceReviewMetrics" in settings_source
    and "SourceRuneEvidenceReviewRowModel" in settings_source
    and "GamesRadar / Games.gg / GameRant / Mobalytics / Steam 指南 / Steam 讨论" in settings_source
    and "tbh.city 单源数据镜像" in settings_source
    and "不计入已核对成本或退款" in settings_source
    and "自动开箱成本候选" in settings_source
    and source_rune_tbh_city_candidate_cost_table_guard
    and source_rune_candidate_cost_queue_guard
    and "普通箱 300s / 关卡 Boss 箱 600s / Act Boss 箱 60s / 冷却减少 9s、15s、3s" in settings_source
    and "完整可验证 197 节点成本/路径表仍缺" in settings_source
    and "本地已接入已核对冷却值" in settings_source
    and "settings Rune evidence review exposes Wiki locales, independent sources and candidate mirror count" in self_test_source
    and "settings Rune evidence review exposes source-backed auto-open cooldown runtime evidence" in self_test_source
    and "settings Rune evidence review exposes tbh.city candidate auto-open costs without promoting them to verified costs" in self_test_source
)
game_audio_events = enum_cases(game_audio_source, "GameAudioEvent")
game_audio_resource_names = re.findall(r'case\s+\.(\w+):\s+return\s+"(sfx_[^"]+)"', game_audio_source)
game_audio_resources_by_event = {event: resource for event, resource in game_audio_resource_names}
source_audio_sfx_evidence_rows = len(re.findall(r'SourceAudioSFXEvidenceRowModel\(', settings_source))
source_audio_sfx_event_gate_rows = len(re.findall(r'SourceAudioSFXEventGateRowModel\(', settings_source))
source_audio_sfx_local_events = len(game_audio_events)
source_audio_sfx_local_resources = len(set(game_audio_resources_by_event.values()))
source_audio_sfx_original_isolated_value = global_static_number(settings_source, "originalIsolatedSFXCount")
source_audio_sfx_original_isolated = int(source_audio_sfx_original_isolated_value) if source_audio_sfx_original_isolated_value is not None else -1
source_audio_sfx_steam_duration_seconds = int(global_static_number(settings_source, "steamTrailerDurationSeconds") or 0)
source_audio_sfx_steam_sample_rate_hz = int(global_static_number(settings_source, "steamTrailerSampleRateHz") or 0)
source_audio_sfx_manifest_rows = []
if sfx_manifest_lines:
    header, *manifest_rows = sfx_manifest_lines
    for line in manifest_rows:
        columns = line.split("\t")
        if len(columns) >= 11:
            source_audio_sfx_manifest_rows.append(columns)
source_audio_sfx_manifest_resources = {row[0] for row in source_audio_sfx_manifest_rows}
source_audio_sfx_manifest_events = {row[1] for row in source_audio_sfx_manifest_rows}
source_audio_sfx_manifest_generated = sum(1 for row in source_audio_sfx_manifest_rows if row[2] == "generated_substitute")
source_audio_sfx_manifest_official_true = sum(1 for row in source_audio_sfx_manifest_rows if row[3] != "false")
source_audio_sfx_manifest_guard = (
    len(source_audio_sfx_manifest_rows) == CURRENT_BASELINE["source_audio_sfx_local_resources"]
    and source_audio_sfx_manifest_resources == set(game_audio_resources_by_event.values())
    and source_audio_sfx_manifest_events == set(game_audio_events)
    and source_audio_sfx_manifest_generated == len(source_audio_sfx_manifest_rows)
    and source_audio_sfx_manifest_official_true == 0
    and all("not extracted from original TBH" in row[10] for row in source_audio_sfx_manifest_rows)
)
source_audio_sfx_evidence_guard = (
    "GroupBox(\"原版音频/SFX 证据\")" in settings_source
    and "SourceAudioSFXEvidenceReviewView" in settings_source
    and "SourceAudioSFXEvidenceReviewMetrics" in settings_source
    and source_audio_sfx_evidence_rows == CURRENT_BASELINE["source_audio_sfx_evidence_rows"]
    and source_audio_sfx_event_gate_rows == CURRENT_BASELINE["source_audio_sfx_event_gate_rows"]
    and source_audio_sfx_local_events == CURRENT_BASELINE["source_audio_sfx_local_events"]
    and source_audio_sfx_local_resources == CURRENT_BASELINE["source_audio_sfx_local_resources"]
    and source_audio_sfx_original_isolated == CURRENT_BASELINE["source_audio_sfx_original_isolated"]
    and source_audio_sfx_steam_duration_seconds == CURRENT_BASELINE["source_audio_sfx_steam_duration_seconds"]
    and source_audio_sfx_steam_sample_rate_hz == CURRENT_BASELINE["source_audio_sfx_steam_sample_rate_hz"]
    and "Steam Trailer 只证明整体音频呈现" in settings_source
    and "本地 WAV 必须保持 generated_substitute / officialAudio=false" in settings_source
    and "取得原版单事件音频前不得声明原声音效还原" in settings_source
    and "原版单事件 SFX 接入门槛" in settings_source
    and "eventGateRows" in settings_source
    and "eventGateBoundaryText" in settings_source
    and "SFX 接入门槛只定义补证顺序" in settings_source
    and "不按本地 WAV、Trailer 混音、事件名称、路由完整度或音量包络生成原版单事件音效" in settings_source
    and "basic-combat-hit" in settings_source
    and "skill-cast-release" in settings_source
    and "projectile-impact" in settings_source
    and "buff-status-loop" in settings_source
    and "mix-throttle-randomization" in settings_source
    and "settingsAudioSFXEvidenceReview()" in self_test_source
    and "settings audio SFX review preserves the current Steam Trailer broad audio baseline" in self_test_source
    and "settings audio SFX review exposes per-event evidence gates without promoting substitutes" in self_test_source
    and "settings audio SFX review keeps local WAV cues separate from original SFX claims" in self_test_source
    and "settings audio SFX review keeps Steam trailer and local substitute evidence boundaries explicit" in self_test_source
    and source_audio_sfx_manifest_guard
)
if not source_audio_sfx_evidence_guard:
    issues.append("Settings UI must expose Steam audio baseline and local generated-substitute SFX evidence without claiming original per-event SFX parity")
source_battle_animation_evidence_rows = len(re.findall(r'SourceBattleAnimationEvidenceRowModel\(', settings_source))
source_battle_animation_motion_sample_rows = len(re.findall(r'SourceBattleAnimationMotionSampleRowModel\(', settings_source))
source_battle_animation_action_frame_gate_rows = len(re.findall(r'SourceBattleAnimationActionFrameGateRowModel\(', settings_source))
source_battle_animation_official_width = int(global_static_number(settings_source, "officialVideoWidth") or 0)
source_battle_animation_official_height = int(global_static_number(settings_source, "officialVideoHeight") or 0)
source_battle_animation_official_fps = int(global_static_number(settings_source, "officialFPS") or 0)
source_battle_animation_official_duration_ms = int(global_static_number(settings_source, "officialDurationMilliseconds") or 0)
source_battle_animation_official_frames = int(global_static_number(settings_source, "officialFrameCount") or 0)
source_battle_animation_official_motion_start_frame_value = global_static_number(settings_source, "officialMotionSampleStartFrame")
source_battle_animation_official_motion_start_frame = int(
    source_battle_animation_official_motion_start_frame_value
    if source_battle_animation_official_motion_start_frame_value is not None
    else -1
)
source_battle_animation_official_motion_end_frame_value = global_static_number(settings_source, "officialMotionSampleEndFrame")
source_battle_animation_official_motion_end_frame = int(
    source_battle_animation_official_motion_end_frame_value
    if source_battle_animation_official_motion_end_frame_value is not None
    else -1
)
source_battle_animation_official_motion_sample_ms = int(global_static_number(settings_source, "officialMotionSampleMilliseconds") or 0)
source_battle_animation_official_motion_pixels = int(global_static_number(settings_source, "officialMotionPixels") or 0)
source_battle_animation_official_platform_motion_pixels = int(global_static_number(settings_source, "officialPlatformMotionPixels") or 0)
source_battle_animation_official_non_platform_motion_pixels = int(global_static_number(settings_source, "officialNonPlatformMotionPixels") or 0)
source_battle_animation_official_motion_percent_x10000 = int(global_static_number(settings_source, "officialMotionPercentX10000") or 0)
source_battle_animation_local_render_width_px = int(global_static_number(settings_source, "localRenderWidthPixels") or 0)
source_battle_animation_local_render_height_px = int(global_static_number(settings_source, "localRenderHeightPixels") or 0)
source_battle_animation_local_battle_tab_width_px = int(global_static_number(settings_source, "localBattleTabRenderWidthPixels") or 0)
source_battle_animation_local_battle_tab_height_px = int(global_static_number(settings_source, "localBattleTabRenderHeightPixels") or 0)
source_battle_animation_local_ratio_x100 = int(global_static_number(settings_source, "localConfiguredRatioX100") or 0)
source_battle_animation_local_popover_width_pt = int(global_static_number(settings_source, "localPopoverWidthPoints") or 0)
source_battle_animation_local_popover_height_pt = int(global_static_number(settings_source, "localPopoverHeightPoints") or 0)
source_battle_animation_local_content_height_pt = int(global_static_number(settings_source, "localContentHeightPoints") or 0)
source_battle_animation_local_battle_scene_height_pt = int(global_static_number(settings_source, "localBattleSceneHeightPoints") or 0)
source_battle_animation_local_bottom_tab_height_pt = int(global_static_number(settings_source, "localBottomTabHeightPoints") or 0)
source_battle_animation_exact_action_frames = int(global_static_number(settings_source, "exactOriginalActionFrameCount") or 0)
source_battle_animation_evidence_guard = (
    "GroupBox(\"原版战斗动画证据\")" in settings_source
    and "SourceBattleAnimationEvidenceReviewView" in settings_source
    and "SourceBattleAnimationEvidenceReviewMetrics" in settings_source
    and "SourceBattleAnimationMotionSampleRowModel" in settings_source
    and "SourceBattleAnimationMotionSampleRow" in settings_source
    and "motionSampleRows" in settings_source
    and source_battle_animation_evidence_rows == CURRENT_BASELINE["source_battle_animation_evidence_rows"]
    and source_battle_animation_motion_sample_rows == CURRENT_BASELINE["source_battle_animation_motion_sample_rows"]
    and source_battle_animation_action_frame_gate_rows == CURRENT_BASELINE["source_battle_animation_action_frame_gate_rows"]
    and source_battle_animation_official_width == CURRENT_BASELINE["source_battle_animation_official_width"]
    and source_battle_animation_official_height == CURRENT_BASELINE["source_battle_animation_official_height"]
    and source_battle_animation_official_fps == CURRENT_BASELINE["source_battle_animation_official_fps"]
    and source_battle_animation_official_duration_ms == CURRENT_BASELINE["source_battle_animation_official_duration_ms"]
    and source_battle_animation_official_frames == CURRENT_BASELINE["source_battle_animation_official_frames"]
    and source_battle_animation_official_motion_start_frame == 0
    and source_battle_animation_official_motion_end_frame == 8
    and source_battle_animation_official_motion_sample_ms == CURRENT_BASELINE["source_battle_animation_official_motion_sample_ms"]
    and source_battle_animation_official_motion_pixels == CURRENT_BASELINE["source_battle_animation_official_motion_pixels"]
    and source_battle_animation_official_platform_motion_pixels == CURRENT_BASELINE["source_battle_animation_official_platform_motion_pixels"]
    and source_battle_animation_official_non_platform_motion_pixels == CURRENT_BASELINE["source_battle_animation_official_non_platform_motion_pixels"]
    and source_battle_animation_official_motion_percent_x10000 == CURRENT_BASELINE["source_battle_animation_official_motion_percent_x10000"]
    and source_battle_animation_local_render_width_px == CURRENT_BASELINE["source_battle_animation_local_render_width_px"]
    and source_battle_animation_local_render_height_px == CURRENT_BASELINE["source_battle_animation_local_render_height_px"]
    and source_battle_animation_local_battle_tab_width_px == CURRENT_BASELINE["source_battle_animation_local_battle_tab_width_px"]
    and source_battle_animation_local_battle_tab_height_px == CURRENT_BASELINE["source_battle_animation_local_battle_tab_height_px"]
    and source_battle_animation_local_ratio_x100 == CURRENT_BASELINE["source_battle_animation_local_ratio_x100"]
    and source_battle_animation_local_popover_width_pt == CURRENT_BASELINE["source_battle_animation_local_popover_width_pt"]
    and source_battle_animation_local_popover_height_pt == CURRENT_BASELINE["source_battle_animation_local_popover_height_pt"]
    and source_battle_animation_local_content_height_pt == CURRENT_BASELINE["source_battle_animation_local_content_height_pt"]
    and source_battle_animation_local_battle_scene_height_pt == CURRENT_BASELINE["source_battle_animation_local_battle_scene_height_pt"]
    and source_battle_animation_local_bottom_tab_height_pt == CURRENT_BASELINE["source_battle_animation_local_bottom_tab_height_pt"]
    and source_battle_animation_exact_action_frames == CURRENT_BASELINE["source_battle_animation_exact_action_frames"]
    and "Steam battle media 只证明整体构图和采样运动" in settings_source
    and "本地确定性渲染只用于回归守卫" in settings_source
    and "battle-tab-layout" in settings_source
    and "完整 Battle tab 布局" in settings_source
    and "底部菜单固定在内容区下方" in settings_source
    and "不证明原版 Windows 任务栏窗口比例" in settings_source
    and "官方 frame 0->8 运动采样明细" in settings_source
    and "原版动作帧接入门槛" in settings_source
    and "actionFrameGateRows" in settings_source
    and "actionFrameGateBoundaryText" in settings_source
    and "动作帧门槛只定义接入前必须补齐的原版证据" in settings_source
    and "不按本地速度线、命中闪光、替代特效或单段宣传片运动采样生成原版动作帧" in settings_source
    and "hero-attack-cast" in settings_source
    and "monster-attack-hit-death" in settings_source
    and "projectile-impact-status" in settings_source
    and "timing-audio-sync" in settings_source
    and "officialMotionSampleFramePairText" in settings_source
    and "officialPlatformMotionShareText" in settings_source
    and "officialNonPlatformMotionShareText" in settings_source
    and "只表示 Steam battlescene 宣传片中的固定采样帧对" in settings_source
    and "不拆分为 idle、attack、hit 或 death 帧" in settings_source
    and "不得按当前本地动效声明原版动画还原" in settings_source
    and "settingsBattleAnimationEvidenceReview()" in self_test_source
    and "settings battle animation review preserves official Steam battle media baseline" in self_test_source
    and "settings battle animation review exposes official frame-pair motion sample details" in self_test_source
    and "settings battle animation motion sample rows remain evidence-only" in self_test_source
    and "settings battle animation review exposes action-frame evidence gates without promoting local effects" in self_test_source
    and "frame 0->8 · 0.267s · 30fps" in self_test_source
    and "26,623 px · coverage 0.1906" in self_test_source
    and "11,920 px · 44.8% of changed pixels" in self_test_source
    and "14,703 px · 55.2% of changed pixels" in self_test_source
    and "settings battle animation review keeps local deterministic render separate from original keyframe parity" in self_test_source
    and "settings battle animation review keeps local Battle tab layout footprint guarded without treating it as original layout proof" in self_test_source
    and "settings battle animation review keeps exact original action-frame gaps explicit" in self_test_source
    and "official_motion_pixels" in steam_battle_scene_audit_source
    and "official_motion_percent" in steam_battle_scene_audit_source
    and "motion_sample_time_seconds=\"0.267\"" in battle_scene_audit_source
)
if not source_battle_animation_evidence_guard:
    issues.append("Settings UI must expose official Steam battle animation evidence and local deterministic render boundaries without claiming original keyframe parity")
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
source_monster_database_view = (
    "GroupBox(\"原版怪物数据库\")" in settings_source
    and "SourceMonsterDatabaseView" in settings_source
    and "SourceMonsterDatabaseMetrics" in settings_source
    and "sourceAbsentBestFarmBoundaryText" in settings_source
    and "steamRosterIdentityCoverageText" in settings_source
    and "steamRosterIdentityGapCount" in settings_source
    and "sourceRosterArtGapCount" in settings_source
    and "sourceOnlySpriteRows" in settings_source
    and "sourceOnlySpritePreviewRows" in settings_source
    and "sourceOnlySpritePreviewCount" in settings_source
    and "sourceOnlySpriteCoverageText" in settings_source
    and "sourceOnlySpriteResourceText" in settings_source
    and "SourceMonsterSourceOnlyProofRowModel" in settings_source
    and "SourceMonsterSourceOnlyProofRow" in settings_source
    and "sourceOnlyProofRows" in settings_source
    and "sourceOnlyProofRowCount" in settings_source
    and "sourceOnlyProofCoverageText" in settings_source
    and "SourceMonsterSourcePageFieldEvidenceRowModel" in settings_source
    and "SourceMonsterSourcePageFieldEvidenceRow" in settings_source
    and "sourceOnlyPageFieldEvidenceRows" in settings_source
    and "sourceOnlyPageFieldEvidenceRowCount" in settings_source
    and "sourceOnlyPageFieldSpritePathCount" in settings_source
    and "sourceOnlyPageFieldMoveKnownCount" in settings_source
    and "sourceOnlyPageFieldDamageKnownCount" in settings_source
    and "sourceOnlyPageFieldRangeKnownCount" in settings_source
    and "sourceOnlyPageFieldUnknownDamageRangeCount" in settings_source
    and "sourceOnlyPageFieldSummaryText" in settings_source
    and "sourceOnlyPageFieldBoundaryText" in settings_source
    and "sourcePageFieldEvidenceText" in settings_source
    and "sourcePageFieldText" in settings_source
    and "SourceMonsterSourceStageEvidenceRowModel" in settings_source
    and "SourceMonsterSourceStageEvidenceRow" in settings_source
    and "sourceOnlyStageAppearanceEvidenceRows" in settings_source
    and "sourceOnlyStageAppearanceEvidenceRowCount" in settings_source
    and "sourceOnlyStageAppearanceConfirmedCount" in settings_source
    and "sourceOnlyStageAppearanceAbsentCount" in settings_source
    and "sourceOnlyStageAppearanceTotalStageRows" in settings_source
    and "sourceOnlyStageAppearanceCrossCheckPageCount" in settings_source
    and "sourceOnlyStageAppearanceCoverageText" in settings_source
    and "sourceOnlyStageAppearanceSummaryText" in settings_source
    and "sourceOnlyStageAppearanceBoundaryText" in settings_source
    and "sourceStageAppearanceEvidenceText" in settings_source
    and "sourceOnlyStageProofMissingCount" in settings_source
    and "sourceOnlyRuntimeBlockedCount" in settings_source
    and "sourceOnlySkillOwnershipUnprovenCount" in settings_source
    and "sourceOnlyAnimationFrameMissingCount" in settings_source
    and "sourceOnlyOriginalSFXMissingCount" in settings_source
    and "sourceOnlyPositiveProofText" in settings_source
    and "sourceOnlyBlockedProofText" in settings_source
    and "sourceOnlyProofMatrixBoundaryText" in settings_source
    and "SourceMonsterSourceOnlyProofRow(row: row)" in settings_source
    and "SourceMonsterDatabaseRow" in settings_source
    and "ForEach(rows)" in settings_source
    and "stageCompositionUnmappedRows" in settings_source
    and "stageCompositionUnmappedCount" in settings_source
    and "stageCompositionUnmappedNamesText" in settings_source
    and "stageCompositionUnmappedDetailText" in settings_source
    and "stageCompositionUnmappedBoundaryText" in settings_source
    and "SourceMonsterUnmappedEvidenceGateRowModel" in settings_source
    and "SourceMonsterUnmappedEvidenceQueueRowModel" in settings_source
    and "SourceMonsterSourceOnlySpriteRowModel" in settings_source
    and "SourceMonsterSourceOnlySpritePreviewRow" in settings_source
    and "stageCompositionUnmappedEvidenceGateRows" in settings_source
    and "stageCompositionUnmappedEvidenceGateBoundaryText" in settings_source
    and "stageCompositionUnmappedEvidenceQueueRows" in settings_source
    and "stageCompositionUnmappedEvidenceQueueBoundaryText" in settings_source
    and "bestFarmStageCompositionEvidence" in settings_source
    and "bestFarmStageCompositionContainsMonster" in settings_source
    and "sourceSkillCandidates" in settings_source
    and "sourceSkillCandidateEvidence" in settings_source
    and "sourceSkillCandidateBoundary" in settings_source
    and "sourceOnlySpriteEvidence" in settings_source
    and "stageCompositionUnmappedCandidateSkillCount" in settings_source
    and "StageDefinition.runtimeData(sourceCode: code)" in settings_source
    and "SourceMonsterUnmappedEvidenceGateRow(row: row)" in settings_source
    and "SourceMonsterUnmappedEvidenceQueueRow(row: row)" in settings_source
    and "SourceMonsterUnmappedDatabaseRow" in settings_source
    and "源表未进关卡组成" in settings_source
    and "源空刷取" in settings_source
    and "best-farm 为 — 是源表空值" in settings_source
    and "未映射源怪物" in settings_source
    and "未映射接入门槛" in settings_source
    and "未映射接入队列" in settings_source
    and "源表单张 sprite 预览" in settings_source
    and "source-only 证明矩阵" in settings_source
    and "source-only 页面字段证据" in settings_source
    and "source-only 页面字段" in settings_source
    and "source-only 来源出场证据" in settings_source
    and "source-only 来源出场" in settings_source
    and "source-only 页面字段证据只记录 taskbarhero.org 怪物页上的 sprite URL、Move、Damage、Range" in settings_source
    and "不证明本地移动速度、攻击距离、技能归属、命中形态、动作帧或 SFX" in settings_source
    and "RedExplosionInsect/RedExplosionInsect_Idle_character_2.png" in settings_source
    and "GiantTick/GiantTick_Idle_character_4.png" in settings_source
    and "FrozenWizard/FrozenWizard_Idle_character_2.png" in settings_source
    and "move: 220" in settings_source
    and "move: 400" in settings_source
    and 'damage: "Physical"' in settings_source
    and 'range: "130"' in settings_source
    and "同属 taskbarhero.org v1.00.13 来源族" in settings_source
    and "不是第二独立来源" in settings_source
    and "不解锁本地关卡组成" in settings_source
    and "怪物页 5 stage rows；关卡页 4207=74、3204=39" in settings_source
    and "怪物页 stage appearances 空；仅 Damage Physical / Range 130" in settings_source
    and "怪物页 9 stage rows；关卡页 4303=70、2303=30" in settings_source
    and "source-only 证明" in settings_source
    and "source-only 缺证" in settings_source
    and "缺关卡槽位、运行时遭遇、技能归属、动作帧和 SFX" in settings_source
    and "源表行、best-farm 文本、同前缀技能或单张 sprite 不接入运行时" in settings_source
    and "PixelSprite(" in settings_source
    and "imageName: row.resourceName" in settings_source
    and "只作素材证据，不接入战斗生成、关卡遭遇、技能、掉落或动作帧" in settings_source
    and "无关卡组成/运行时" in settings_source
    and "源表单张 sprite 只作素材证据" in settings_source
    and "接入门槛只定义缺失证据" in settings_source
    and "接入队列只排列互斥复核顺序" in settings_source
    and "不按源表数值、best-farm 文本" in settings_source
    and "现有单张 sprite" in settings_source
    and "不生成关卡遭遇、技能、掉落或动作帧" in settings_source
    and "SourceMonsterDatabaseEntry" in stage_source
    and "static let entries: [SourceMonsterDatabaseEntry]" in stage_source
    and "sourceOnlySpriteIDs" in stage_source
    and "sourceOnlySpriteResourceNames" in stage_source
    and "static var uniqueNameCount" in stage_source
    and "taskbarhero.org Wiki/datamined 61 行怪物数据库" in stage_source
    and "自动循环按战斗步进量化" in stage_source
    and "attackSpeedQuantizationText" in settings_source
    and "SourceMonsterDatabase.sourceCooldownSeconds" in settings_source
    and "SourceMonsterDatabase.localLoopCooldownSeconds" in settings_source
    and "源表单张 sprite 只作资源证据" in stage_source
    and "不声明关卡出场、动作帧或完整怪物技能已还原" in stage_source
    and "不绘制新怪物图" in stage_source
    and "static func runtimeData(sourceCode: String) -> StageRuntimeData?" in stage_source
    and "settings source monster database preserves all 61 Wiki monster rows with unique IDs" in self_test_source
    and "settings source monster database separates source roster identity from stage art coverage" in self_test_source
    and "settings source monster database preserves the checked source-absent best-farm Tick row" in self_test_source
    and "settings source monster database exposes attack-speed quantization by the local timer loop" in self_test_source
    and "settings source monster database covers every checked stage-composition monster name" in self_test_source
    and "剧毒领主 / 扁虱 / 雪山法师" in self_test_source
    and "20042:剧毒领主,20121:扁虱,30044:雪山法师" in self_test_source
    and "settings source monster database exposes source rows missing from current stage-composition art mapping" in self_test_source
    and "settings source monster database exposes source-only sprite evidence without adding runtime encounters" in self_test_source
    and "settings source monster database previews source-only sprites as review-only artwork evidence" in self_test_source
    and "settings source monster database exposes source-only proof rows for every unmapped source monster" in self_test_source
    and "settings source monster database exposes source-page field evidence for source-only monsters" in self_test_source
    and "settings source monster database records source-page sprite, Move, Damage and Range fields without runtime mapping" in self_test_source
    and "settings source monster database keeps source-page fields from becoming runtime movement or skill proof" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyPageFieldEvidenceRowCount == 3" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyPageFieldSpritePathCount == 3" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyPageFieldMoveKnownCount == 3" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyPageFieldDamageKnownCount == 1" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyPageFieldRangeKnownCount == 1" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyPageFieldUnknownDamageRangeCount == 2" in self_test_source
    and "Move 220 / Damage — / Range —" in self_test_source
    and "Move 400 / Damage Physical / Range 130" in self_test_source
    and "settings source monster database exposes source-page stage appearance evidence for source-only monsters" in self_test_source
    and "settings source monster database records confirmed and absent source stage appearances without runtime mapping" in self_test_source
    and "settings source monster database keeps same-source stage appearance evidence from becoming runtime proof" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceEvidenceRowCount == 3" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceConfirmedCount == 2" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceAbsentCount == 1" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceTotalStageRows == 14" in self_test_source
    and "SourceMonsterDatabaseMetrics.sourceOnlyStageAppearanceCrossCheckPageCount == 4" in self_test_source
    and "settings source monster database keeps source-only proof rows blocked from runtime until stage, skill, animation and SFX proof exists" in self_test_source
    and "settings source monster database separates positive source-only proof from missing runtime, skill and animation proof" in self_test_source
    and "settings source monster database keeps source-only proof matrix from fabricating runtime encounters or art" in self_test_source
    and "settings source monster database keeps unmapped source rows data-only" in self_test_source
    and "settings source monster database exposes evidence gates before unmapped monsters can enter runtime" in self_test_source
    and "settings source monster database keeps unmapped monster gates tied to current evidence gaps" in self_test_source
    and "settings source monster database keeps unmapped monster gates from fabricating encounters or art" in self_test_source
    and "settings source monster database groups unmapped rows into evidence queues" in self_test_source
    and "未列出剧毒领主" in self_test_source
    and "未列出雪山法师" in self_test_source
    and "best-farm 无 stage code" in self_test_source
    and "同前缀候选技能 #200421 Chaos BASEATTACK r800 value 1000 delivery 空" in self_test_source
    and "同前缀候选技能 #201211 Physical BASEATTACK r130 value 1000 delivery 空" in self_test_source
    and "同前缀候选技能 #300441 Cold BASEATTACK r800 value 1000 delivery 空" in self_test_source
    and "SourceMonsterDatabaseMetrics.stageCompositionUnmappedCandidateSkillCount == 3" in self_test_source
    and "settings source monster database keeps unmapped evidence queues from fabricating monsters" in self_test_source
    and "settings source monster database keeps data-only and art-animation boundaries explicit" in self_test_source
)
source_monster_source_only_sprite_preview_count = (
    source_monster_source_only_sprite_count
    if source_monster_database_view and "sourceOnlySpritePreviewRows" in settings_source
    else 0
)
source_monster_source_only_proof_rows_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_database_view
    and "SourceMonsterSourceOnlyProofRowModel" in settings_source
    and "sourceOnlyProofRows" in settings_source
    and "SourceMonsterSourceOnlyProofRow(row: row)" in settings_source
    else 0
)
source_monster_source_only_proof_coverage_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_source_only_proof_rows_count
    and "sourceOnlyProofCoverageText" in settings_source
    else 0
)
source_monster_database_metrics_body = (
    enum_block(settings_source, "SourceMonsterDatabaseMetrics")
    if source_monster_database_view
    else ""
)
source_monster_source_page_field_block = block_between(
    source_monster_database_metrics_body,
    r'static\s+var\s+sourceOnlyPageFieldEvidenceRows\s*:',
    r'static\s+func\s+sourceOnlyPageFieldEvidenceRow',
)
source_monster_source_stage_appearance_block = block_between(
    source_monster_database_metrics_body,
    r'static\s+var\s+sourceOnlyStageAppearanceEvidenceRows\s*:',
    r'static\s+func\s+sourceOnlyStageAppearanceEvidenceRow',
)
source_monster_source_page_field_row_count = (
    len(re.findall(r'monsterID:\s*(?:20_042|20_121|30_044)', source_monster_source_page_field_block))
    if source_monster_database_view
    else 0
)
source_monster_source_page_field_sprite_path_count = (
    sum(
        1
        for fragment in [
            "RedExplosionInsect/RedExplosionInsect_Idle_character_2.png",
            "GiantTick/GiantTick_Idle_character_4.png",
            "FrozenWizard/FrozenWizard_Idle_character_2.png",
        ]
        if fragment in source_monster_source_page_field_block
    )
    if source_monster_source_page_field_row_count
    else 0
)
source_monster_source_page_field_move_known_count = (
    len(re.findall(r'move:\s*\d+', source_monster_source_page_field_block))
    if source_monster_source_page_field_row_count
    else 0
)
source_monster_source_page_field_damage_known_count = (
    len(re.findall(r'damage:\s*"Physical"', source_monster_source_page_field_block))
    if source_monster_source_page_field_row_count
    else 0
)
source_monster_source_page_field_range_known_count = (
    len(re.findall(r'range:\s*"130"', source_monster_source_page_field_block))
    if source_monster_source_page_field_row_count
    else 0
)
source_monster_source_page_field_unknown_damage_range_count = (
    len(re.findall(r'damage:\s*"—",\s*\n\s*range:\s*"—"', source_monster_source_page_field_block))
    if source_monster_source_page_field_row_count
    else 0
)
source_monster_source_stage_evidence_row_count = (
    len(re.findall(r'monsterID:\s*(?:20_042|20_121|30_044)', source_monster_source_stage_appearance_block))
    if source_monster_database_view
    else 0
)
source_monster_source_stage_appearance_confirmed_count = (
    len(re.findall(r'hasSourceStageAppearance:\s*true', source_monster_source_stage_appearance_block))
    if source_monster_source_stage_evidence_row_count
    else 0
)
source_monster_source_stage_appearance_absent_count = (
    len(re.findall(r'hasSourceStageAppearance:\s*false', source_monster_source_stage_appearance_block))
    if source_monster_source_stage_evidence_row_count
    else 0
)
source_monster_source_stage_appearance_rows_total = (
    sum(
        int(value)
        for value in re.findall(r'monsterPageStageRowCount:\s*(\d+)', source_monster_source_stage_appearance_block)
    )
    if source_monster_source_stage_evidence_row_count
    else 0
)
source_monster_source_stage_crosscheck_page_count = (
    sum(
        int(value)
        for value in re.findall(r'crossCheckStagePageCount:\s*(\d+)', source_monster_source_stage_appearance_block)
    )
    if source_monster_source_stage_evidence_row_count
    else 0
)
source_monster_source_only_stage_proof_missing_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_source_only_proof_rows_count
    and "sourceOnlyStageProofMissingCount" in settings_source
    else 0
)
source_monster_source_only_runtime_blocked_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_source_only_proof_rows_count
    and "sourceOnlyRuntimeBlockedCount" in settings_source
    else 0
)
source_monster_source_only_skill_ownership_unproven_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_source_only_proof_rows_count
    and "sourceOnlySkillOwnershipUnprovenCount" in settings_source
    else 0
)
source_monster_source_only_animation_frame_missing_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_source_only_proof_rows_count
    and "sourceOnlyAnimationFrameMissingCount" in settings_source
    else 0
)
source_monster_source_only_sfx_missing_count = (
    source_monster_database_unmapped_stage_count
    if source_monster_source_only_proof_rows_count
    and "sourceOnlyOriginalSFXMissingCount" in settings_source
    else 0
)
if source_monster_database_view and (
    source_monster_source_only_proof_rows_count != source_monster_database_unmapped_stage_count
    or source_monster_source_only_proof_coverage_count != source_monster_database_unmapped_stage_count
    or source_monster_source_only_runtime_blocked_count != source_monster_database_unmapped_stage_count
):
    issues.append(
        "source-only monster proof matrix does not cover the current unmapped source rows: "
        f"{source_monster_source_only_proof_rows_count}/{source_monster_database_unmapped_stage_count} rows, "
        f"{source_monster_source_only_proof_coverage_count}/{source_monster_database_unmapped_stage_count} coverage, "
        f"{source_monster_source_only_runtime_blocked_count}/{source_monster_database_unmapped_stage_count} runtime-blocked"
    )
if source_monster_database_view and (
    source_monster_source_page_field_row_count != source_monster_database_unmapped_stage_count
    or source_monster_source_page_field_sprite_path_count != 3
    or source_monster_source_page_field_move_known_count != 3
    or source_monster_source_page_field_damage_known_count != 1
    or source_monster_source_page_field_range_known_count != 1
    or source_monster_source_page_field_unknown_damage_range_count != 2
):
    issues.append(
        "source-only monster page field evidence drifted: "
        f"{source_monster_source_page_field_row_count} rows, "
        f"{source_monster_source_page_field_sprite_path_count} sprite paths, "
        f"{source_monster_source_page_field_move_known_count} move values, "
        f"{source_monster_source_page_field_damage_known_count} damage values, "
        f"{source_monster_source_page_field_range_known_count} range values, "
        f"{source_monster_source_page_field_unknown_damage_range_count} unknown damage/range rows"
    )
if source_monster_database_view and (
    source_monster_source_stage_evidence_row_count != source_monster_database_unmapped_stage_count
    or source_monster_source_stage_appearance_confirmed_count != 2
    or source_monster_source_stage_appearance_absent_count != 1
    or source_monster_source_stage_appearance_rows_total != 14
    or source_monster_source_stage_crosscheck_page_count != 4
):
    issues.append(
        "source-only monster stage appearance evidence drifted: "
        f"{source_monster_source_stage_evidence_row_count} rows, "
        f"{source_monster_source_stage_appearance_confirmed_count} confirmed, "
        f"{source_monster_source_stage_appearance_absent_count} absent, "
        f"{source_monster_source_stage_appearance_rows_total} source rows, "
        f"{source_monster_source_stage_crosscheck_page_count} cross-check pages"
    )
if source_monster_database_view and (
    source_monster_unmapped_evidence_queue_count != source_monster_database_unmapped_stage_count
    or source_monster_unmapped_evidence_queue_coverage_count != source_monster_database_unmapped_stage_count
):
    issues.append(
        "source monster unmapped evidence queues do not cover all unmapped source rows: "
        f"{source_monster_unmapped_evidence_queue_count}/{source_monster_database_unmapped_stage_count} queues, "
        f"{source_monster_unmapped_evidence_queue_coverage_count}/{source_monster_database_unmapped_stage_count} rows"
    )
source_monster_runtime_stats_guard = (
    "SourceMonsterDatabase.entry(zhName: monsterName, stageCode: data.code)" in stage_source
    and "sourceBaseAttack" in stage_source
    and "sourceRuntimeSpeed" in stage_source
    and "SourceMonsterDatabase.runtimeSpeed(fromAttackSpeed:" in stage_source
    and "stage spawn uses source monster ATK and attack-speed scalars" in self_test_source
    and "stage 1101 non-leader encounters use source monster ATK and attack-speed scalars" in self_test_source
    and "stage 4310 boss uses the matching source boss ATK and attack-speed row before local scaling" in self_test_source
)
source_monster_art_evidence_gate_count = len(
    re.findall(r'SourceMonsterArtEvidenceGateRowModel\s*\(', settings_source)
)
source_monster_art_evidence_queue_count = len(
    re.findall(r'SourceMonsterArtEvidenceQueueRowModel\s*\(', settings_source)
)
source_monster_art_evidence_queue_coverage_count = (
    len(composition_names)
    if source_monster_art_evidence_queue_count and "artEvidenceQueueCoverage" in settings_source
    else 0
)
source_monster_art_evidence_queue_roster_gap_count = (
    source_monster_source_roster_steam_gap_count
    if source_monster_art_evidence_queue_count and "steamRosterIdentityGapCount" in settings_source
    else 0
)
source_monster_art_evidence_queue_source_roster_gap_count = (
    source_monster_source_roster_art_gap_count
    if source_monster_art_evidence_queue_count and "artEvidenceQueueSourceRosterArtGapCoverage" in settings_source
    else 0
)
source_monster_art_mapping_view = (
    "GroupBox(\"原版怪物美术映射\")" in settings_source
    and "SourceMonsterArtMappingView" in settings_source
    and "SourceMonsterArtMappingMetrics" in settings_source
    and "SourceMonsterArtEvidenceGateRowModel" in settings_source
    and "SourceMonsterArtEvidenceQueueRowModel" in settings_source
    and "SourceMonsterArtMappingRow" in settings_source
    and "artEvidenceGateRows" in settings_source
    and "artEvidenceQueueRows" in settings_source
    and "artEvidenceQueueBoundaryText" in settings_source
    and "专属美术接入门槛" in settings_source
    and "怪物美术接入队列" in settings_source
    and "SourceMonsterArtEvidenceQueueRow(row: row)" in settings_source
    and "StageDefinition.stageMonsterArtMappings" in settings_source
    and "StageMonsterArtMapping" in stage_source
    and "StageMonsterArtFidelity" in stage_source
    and "GameArt.battleMonsterSpriteName(for: mapping.runtimeMonsterID)" in settings_source
    and "SourceMonsterArtMappingMetrics.slimeFallbackMappings" in settings_source
    and "SourceMonsterArtMappingMetrics.legacyUICropMappings" in settings_source
    and "officialSteamMinimumMonsterTypeCount" in settings_source
    and "steamRosterIdentityCoverageText" in settings_source
    and "steamRosterIdentityGapCount" in settings_source
    and "artMappingCoverageText" in settings_source
    and "sourceRosterArtGapCount" in settings_source
    and "source-roster-art-gap" in settings_source
    and "rosterBoundaryText" in settings_source
    and "Steam 50+" in settings_source
    and "源表去重怪物名录" in settings_source
    and "非史莱姆不得回退到史莱姆图" in settings_source
    and "不绘制或替换新怪物图" in settings_source
    and "接入门槛只定义怪物美术缺失证据，不生成怪物图、动作帧、缩放、音效或完整图鉴" in settings_source
    and "接入队列只排列怪物美术复核顺序；不生成怪物图、动作帧、缩放、音效或完整图鉴，也不按近似同族、通用官方图、现有单张 sprite、源表缺口或 Steam 50+ 下限补齐缺失美术" in settings_source
    and "settings monster art review exposes all 49 checked stage composition monster names" in self_test_source
    and "settings monster art review separates Steam roster identity from source art coverage" in self_test_source
    and "settings monster art review distinguishes extracted, generic and type-near sprite mappings" in self_test_source
    and "settings monster art review keeps approximate monster sprite reuse explicit" in self_test_source
    and "settings monster art review exposes evidence gates before replacing approximate art" in self_test_source
    and "settings monster art review keeps art gates from fabricating monster assets" in self_test_source
    and "settings monster art review groups current art mappings into evidence queues" in self_test_source
    and "settings monster art review keeps art evidence queues from fabricating monster assets" in self_test_source
)
if source_monster_art_mapping_view and (
    source_monster_art_evidence_queue_count != CURRENT_BASELINE["source_monster_art_evidence_queues"]
    or source_monster_art_evidence_queue_coverage_count != len(composition_names)
    or source_monster_art_evidence_queue_roster_gap_count != source_monster_source_roster_steam_gap_count
    or source_monster_art_evidence_queue_source_roster_gap_count != source_monster_source_roster_art_gap_count
):
    issues.append(
        "source monster art evidence queues do not cover the current art mapping boundary: "
        f"{source_monster_art_evidence_queue_count}/{CURRENT_BASELINE['source_monster_art_evidence_queues']} queues, "
        f"{source_monster_art_evidence_queue_coverage_count}/{len(composition_names)} mappings, "
        f"{source_monster_art_evidence_queue_roster_gap_count}/{source_monster_source_roster_steam_gap_count} Steam lower-bound gap, "
        f"{source_monster_art_evidence_queue_source_roster_gap_count}/{source_monster_source_roster_art_gap_count} source art gap"
    )
source_monster_attack_review_view = (
    "GroupBox(\"原版怪物攻击映射\")" in settings_source
    and "SourceMonsterAttackReviewView" in settings_source
    and "SourceMonsterAttackReviewMetrics" in settings_source
    and "SourceMonsterAttackReviewRowModel" in settings_source
    and "SourceMonsterAttackEvidenceGateRowModel" in settings_source
    and "SourceMonsterAttackReviewRow(mapping: mapping)" in settings_source
    and "attackEvidenceGateRows" in settings_source
    and "怪物攻击接入门槛" in settings_source
    and "static var runtimeMonsterAttackMappings" in skills_source
    and "SourceSkillCatalog.runtimeMonsterAttackMappings" in settings_source
    and "SourceSkillCatalog.sourceSkillID(forMonsterNamed: mapping.monsterName)" in settings_source
    and "来源 delivery 为空" in settings_source
    and "运行时不伪造投射物/范围形态" in settings_source
    and "完整怪物技能表/投射物/施法帧待核对" in settings_source
    and "接入门槛只定义怪物攻击缺失证据，不生成怪物技能、投射物、公式、动作帧或音效" in settings_source
    and "settings monster attack review exposes all four checked source attack rows" in self_test_source
    and "settings monster attack review preserves source activation, range and empty delivery boundaries" in self_test_source
    and "settings monster attack review keeps full monster skill and delivery boundaries explicit" in self_test_source
    and "settings monster attack review exposes evidence gates before expanding monster skills" in self_test_source
    and "settings monster attack review keeps attack gates from fabricating skill semantics" in self_test_source
)
source_monster_attack_evidence_gate_count = len(
    re.findall(r'SourceMonsterAttackEvidenceGateRowModel\s*\(', settings_source)
)
source_item_database_view = (
    "GroupBox(\"原版物品数据库\")" in settings_source
    and "SourceItemDatabaseView" in settings_source
    and "SourceGearTypeSourceRow" in settings_source
    and "SourceMaterialSourceRow" in settings_source
    and "SourceStageChestSourceRow" in settings_source
    and "ForEach(SourceItemCatalog.allGearTypes)" in settings_source
    and "ForEach(SourceItemCatalog.allMaterials)" in settings_source
    and "ForEach(SourceItemCatalog.allStageChests)" in settings_source
    and "SourceItemCatalog.totalGearEntryCount" in settings_source
    and "SourceItemCatalog.totalGearLevelProgressionCount" in settings_source
    and "OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText" in settings_source
    and "GameArt.itemIconName(for: material)" in settings_source
    and "GameArt.stageChestIconName(for: chest)" in settings_source
    and "不声明完整词缀/稀有度 5,760 物品记录" in settings_source
    and "settings item source review can summarize checked gear types, aggregate entries and base progressions" in self_test_source
    and "settings item source review keeps exact item-record gaps separate from source-backed item art" in self_test_source
)
exact_item_record_gap_view = (
    "GroupBox(\"精确装备记录缺口\")" in settings_source
    and "ExactItemRecordGapView" in settings_source
    and "ExactItemRecordGapMetrics" in settings_source
    and "ExactItemRecordGapCategoryRowModel" in settings_source
    and "ExactItemRecordGapTypeRowModel" in settings_source
    and "ExactItemMissingEvidenceRowModel" in settings_source
    and "ExactItemRecordCategoryEvidenceQueueRowModel" in settings_source
    and "ExactItemRecordRarityEvidenceQueueRowModel" in settings_source
    and "ExactItemRecordCategoryRarityEvidenceQueueRowModel" in settings_source
    and "ExactItemRecordProgressionEvidenceQueueRowModel" in settings_source
    and "ExactItemRecordTypeEvidenceQueueRowModel" in settings_source
    and "largestMissingTypeEvidenceRows" in settings_source
    and "ExactItemRecordGapCategoryRow(row: row)" in settings_source
    and "ExactItemRecordGapTypeRow(row: row)" in settings_source
    and "ExactItemMissingEvidenceRow(row: row)" in settings_source
    and "ExactItemRecordCategoryEvidenceQueueRow(row: row)" in settings_source
    and "ExactItemRecordRarityEvidenceQueueRow(row: row)" in settings_source
    and "ExactItemRecordCategoryRarityEvidenceQueueRow(row: row)" in settings_source
    and "ExactItemRecordProgressionEvidenceQueueRow(row: row)" in settings_source
    and "ExactItemRecordTypeEvidenceQueueRow(row: row)" in settings_source
    and "categoryEvidenceQueueRows" in settings_source
    and "rarityEvidenceQueueRows" in settings_source
    and "categoryRarityEvidenceQueueRows" in settings_source
    and "progressionEvidenceQueueRows" in settings_source
    and "typeEvidenceQueueRows" in settings_source
    and "精确记录类别队列" in settings_source
    and "精确记录稀有度队列" in settings_source
    and "精确记录类别稀有矩阵" in settings_source
    and "精确记录基础进度队列" in settings_source
    and "精确记录类型队列" in settings_source
    and "精确记录最大类型缺口" in settings_source
    and "精确记录接入门槛" in settings_source
    and "未取得逐件词缀/稀有度记录" in settings_source
    and "基础进度图标不等于完整物品变体" in settings_source
    and "类型页只证明聚合数量/稀有度分布/基础等级进度" in settings_source
    and "属性 rolls/掉落权重待核对" in settings_source
    and "证据清单只定义接入门槛" in settings_source
    and "接入队列只排列复核顺序" in settings_source
    and "不生成装备记录、词缀数值、掉落权重或新图标" in settings_source
    and "不按类别、类型、基础图标或稀有度分布生成装备记录" in settings_source
    and "不生成装备记录、词缀、掉落权重或新图标" in settings_source
    and "不按最大缺口批量生成" in settings_source
    and "不生成装备记录" in settings_source
    and "逐件变体 ID" in settings_source
    and "图标变体证据" in settings_source
    and "来源交叉证明" in settings_source
    and "settings exact item record gap review keeps aggregate, progression and exact-record counts explicit" in self_test_source
    and "settings exact item record gap review preserves weapon and offhand source buckets" in self_test_source
    and "settings exact item record gap review preserves armor and accessory source buckets" in self_test_source
    and "settings exact item record gap review keeps every category marked as exact-record missing" in self_test_source
    and "settings exact item record gap review exposes all source gear type rows as exact-record gaps" in self_test_source
    and "settings exact item record gap review preserves per-type rarity distributions without creating exact variants" in self_test_source
    and "settings exact item record gap review preserves aggregate rarity queues without creating exact variants" in self_test_source
    and "settings exact item record gap review preserves category-rarity matrix queues without creating exact variants" in self_test_source
    and "progressionEvidenceQueueCount == 396" in self_test_source
    and "progressionEvidenceQueueCoverageCount == ExactItemRecordGapMetrics.baseProgressionCount" in self_test_source
    and "settings exact item record gap review exposes missing evidence gates before exact item records can be modeled" in self_test_source
    and "settings exact item record gap review keeps variant and stat-roll boundaries explicit" in self_test_source
    and "settings exact item record gap review groups missing records into evidence queues" in self_test_source
    and "settings exact item record gap review keeps evidence queues tied to source gear progressions" in self_test_source
    and "settings exact item record gap review exposes the largest missing type queues without creating variants" in self_test_source
    and "settings exact item record gap review keeps evidence queues from fabricating item records" in self_test_source
)
exact_item_record_gap_evidence_gate_count = (
    len(re.findall(r'ExactItemMissingEvidenceRowModel\s*\(', settings_source))
    if exact_item_record_gap_view
    else 0
)
source_crafting_rule_review_view = (
    "GroupBox(\"原版合成/Cube/炼金规则\")" in settings_source
    and "SourceCraftingRuleReviewView" in settings_source
    and "SourceCraftingRuleMetrics" in settings_source
    and "SourceCraftingRarityRuleRow" in settings_source
    and "SourceSynthesisSkipExampleRow" in settings_source
    and "ForEach(Rarity.allCases" in settings_source
    and "Rarity.synthesisInputCount" in settings_source
    and "cubeExperience" in settings_source
    and "alchemyGoldValue" in settings_source
    and "cubeRewardRuneCoverageText" in settings_source
    and "cubeRewardBonusPerNodeText" in settings_source
    and "cubeRewardMaximumSideBonusText" in settings_source
    and "cubeRewardRuneBoundaryText" in settings_source
    and "奖励符文" in settings_source
    and "Cube/炼金符文边界" in settings_source
    and "炼金经济曲线仍待核对" in settings_source
    and "完整概率/失败/跳阶表待核对" in settings_source
    and "等级降级公式待核对" in settings_source
    and "合成等级成本待核对" in settings_source
    and "Cube 等级/奖励公式待核对" in settings_source
    and "settings crafting source review summarizes rarity count, input count and modeled next-rarity transitions" in self_test_source
    and "settings crafting source review exposes local Cube and Alchemy reward Rune scaffolds without hiding economy gaps" in self_test_source
    and "settings crafting source review keeps approximate Synthesis skip-tier examples visible" in self_test_source
    and "settings crafting source review keeps Synthesis/Cube unknown boundaries explicit" in self_test_source
)
settings_fidelity_boundary_view = (
    "GroupBox(\"原版复核边界\")" in settings_source
    and "OriginalFidelityBoundaryView" in settings_source
    and "OriginalFidelityBoundaryMetrics" in settings_source
    and "runtimeSkillCoverageText" in settings_source
    and "runtimeModeledSourceSkillCount" in settings_source
    and "totalSourceSkillCount" in settings_source
    and "pendingSourceSkillCount" in settings_source
    and "skillEffectBoundaryText" in settings_source
    and "pendingSkillReadinessText" in settings_source
    and "pendingSkillRuntimeBoundaryText" in settings_source
    and "OriginalFidelityHardGapRowModel" in settings_source
    and "hardGapRows" in settings_source
    and "剩余硬缺口" in settings_source
    and "skill-runtime-evidence" in settings_source
    and "rune-cost-economy" in settings_source
    and "original-pacing-xp-curve" in settings_source
    and "exact-item-records" in settings_source
    and "source-monster-runtime-art" in settings_source
    and "original-action-frames" in settings_source
    and "isolated-original-sfx" in settings_source
    and "原作 Tick \\(GamePacing.runtimeTickInterval)s" in settings_source
    and "战斗推进 \\(GamePacing.simulatedCombatDelta(for: GamePacing.runtimeTickInterval))s" in settings_source
    and "每个运行 tick 只推进 1 秒战斗时间" in settings_source
    and ".fixedSize(horizontal: false, vertical: true)" in settings_source
    and "sourceRuneCoverageText" in settings_source
    and "static let exactItemRecordCount = 0" in settings_source
    and "exactItemRecordCoverageText" in settings_source
    and "sourceGearProgressionCoverageText" in settings_source
    and "passiveSkillSourceCoverageText" in settings_source
    and "passiveSkillSourceIconCoverageText" in settings_source
    and "passiveSkillBoundaryText" in settings_source
    and "battleHeroSpriteCoverageText" in settings_source
    and "battleHeroSourceSpriteCoverageText" in settings_source
    and "battleHeroSpriteBoundaryText" in settings_source
    and "战斗英雄美术边界" in settings_source
    and "原版战斗姿态/动作帧仍待核对" in settings_source
    and "sourceMonsterDatabaseCoverageText" in settings_source
    and "sourceMonsterStageCompositionCoverageText" in settings_source
    and "sourceMonsterDatabaseBoundaryText" in settings_source
    and "怪物数值边界" in settings_source
    and "未进入当前关卡组成/美术映射" in settings_source
    and "HP/金币/经验仍以关卡表为准" in settings_source
    and "不绘制新怪物图" in settings_source
    and "stageMonsterArtCoverageText" in settings_source
    and "stageMonsterSourceRosterArtGapCount" in settings_source
    and "stageMonsterArtBoundaryText" in settings_source
    and "怪物美术边界" in settings_source
    and "源表去重怪物名已覆盖 Steam 50+ 下限" in settings_source
    and "源表未映射怪物" in settings_source
    and "verifiedRuneCostCount" in settings_source
    and "approximateRuneCostCount" in settings_source
    and "unverifiedRuneCostCount" in settings_source
    and "inventoryExpansionCoverageText" in settings_source
    and "runeInventoryExpansionSlotBonusText" in settings_source
    and "directInventoryExpansionSlotBonusText" in settings_source
    and "directInventoryExpansionBaseCostText" in settings_source
    and "directInventoryExpansionSecondCostText" in settings_source
    and "inventoryExpansionBoundaryText" in settings_source
    and "stashPageCoverageText" in settings_source
    and "stashPageSlotBonusText" in settings_source
    and "stashPageBoundaryText" in settings_source
    and "背包扩容边界" in settings_source
    and "仓库页容量边界" in settings_source
    and "MaxInventorySlot 源符文已接入本地背包容量" in settings_source
    and "原版精确成本、上限、叠加规则和背包布局仍待核对" in settings_source
    and "UnlockStashPageCount 源符文已接入本地容量" in settings_source
    and "不声明原版独立仓库页布局、分页上限、路径成本或重置经济" in settings_source
    and "技能特效边界" in settings_source
    and "待接入技能边界" in settings_source
    and "个源技能仍停留在数据态" in settings_source
    and "这些 value/range 只能证明源页数值" in settings_source
    and "个源技能仍缺原版动作帧" in settings_source
    and "命中表现、触发时序和原声音效证据" in settings_source
    and "成本待核对" in settings_source
    and "被动技能边界" in settings_source
    and "不使用本地图标替代" in settings_source
    and "原版解锁路径和完整运行时语义仍待核对" in settings_source
    and "不可替代为原版逐帧动画或原声音效结论" in settings_source
    and "settings fidelity boundary keeps local skill VFX and SFX separate from original per-skill parity" in self_test_source
    and "settings fidelity boundary exposes value-checked pending skills without promoting them to runtime" in self_test_source
    and "settings fidelity boundary keeps pending source skill value pages from implying combat semantics" in self_test_source
    and "settings fidelity boundary distinguishes exact item-record gaps from source gear progression icons" in self_test_source
    and "settings fidelity boundary exposes passive source and icon coverage without hiding unlock gaps" in self_test_source
    and "settings fidelity boundary exposes battle hero sprite coverage without hiding animation gaps" in self_test_source
    and "settings fidelity boundary keeps battle hero sprite provenance separate from original animation parity" in self_test_source
    and "settings fidelity boundary exposes source monster stat rows separately from monster art coverage" in self_test_source
    and "settings fidelity boundary keeps monster stat data from implying full monster art or skill parity" in self_test_source
    and "settings fidelity boundary exposes checked monster art coverage without hiding the source roster art gap" in self_test_source
    and "settings fidelity boundary keeps monster art mappings separate from full original roster parity" in self_test_source
    and "settings fidelity boundary exposes source-backed and direct backpack expansion scaffolds" in self_test_source
    and "settings fidelity boundary keeps original backpack expansion limits and layout unverified" in self_test_source
    and "settings fidelity boundary exposes source-backed storage page capacity scaffolds" in self_test_source
    and "settings fidelity boundary keeps original storage-page layout and economy unverified" in self_test_source
)
if not source_progression_runtime_selector:
    issues.append("SourceItemCatalog must expose runtime source gear progression selection")
if not loot_uses_source_progression_identity:
    issues.append("LootTable.makeItem must use checked source base gear progression name/id")
if not structured_source_gear_identity:
    issues.append("Item must persist structured source gear IDs and use them for icon/detail resolution")
if not synthesis_preview_uses_source_progression:
    issues.append("SynthesisPreview must expose checked source base gear progression identity")
if not synthesis_preview_uses_source_examples:
    issues.append("SynthesisPreview must expose checked approximate source Synthesis result examples")
if not legacy_item_name_inference:
    issues.append("legacy item decoding must infer concrete equipment types from old item names for source gear icons")
if not source_gear_progression_icons:
    issues.append("runtime equipment icons must use checked source_gear progression icons pinned by source_gear_icons.tsv")
if not support_sustained_skill_runtime:
    issues.append("Battle must keep support-member sustained summon/range skill state for Hydra/Snowstorm/Turret")
if not support_sanctuary_runtime_guard:
    issues.append("Battle must keep support-member Sanctuary as a sustained healing field")
if not support_sanctuary_self_test_guard:
    issues.append("SelfTest must guard support-member Sanctuary over-time healing")
if not support_sanctuary_swift_test_guard:
    issues.append("Swift tests must guard support-member Sanctuary over-time healing")
if not support_wrath_runtime_guard:
    issues.append("Battle must keep support-member Wrath of Heaven as a support-attributed attack-added lightning range buff")
if not support_wrath_self_test_guard:
    issues.append("SelfTest must guard support-member Wrath of Heaven attack-added range damage")
if not support_wrath_swift_test_guard:
    issues.append("Swift tests must guard support-member Wrath of Heaven attack-added range damage")
if not support_aegis_runtime_guard:
    issues.append("Battle must keep support-member Aegis Field as a party damage shield")
if not support_aegis_self_test_guard:
    issues.append("SelfTest must guard support-member Aegis Field party shielding")
if not support_aegis_swift_test_guard:
    issues.append("Swift tests must guard support-member Aegis Field party shielding")
if not support_generals_cry_runtime_guard:
    issues.append("Battle must keep support-member General's Cry as a party crit/stun scaffold")
if not support_generals_cry_self_test_guard:
    issues.append("SelfTest must guard support-member General's Cry party crit/stun behavior")
if not support_generals_cry_swift_test_guard:
    issues.append("Swift tests must guard support-member General's Cry party crit/stun behavior")
if not support_bloodlust_runtime_guard:
    issues.append("Battle must keep support-member Bloodlust as a support HP sacrifice and scoped attack buff")
if not support_bloodlust_self_test_guard:
    issues.append("SelfTest must guard support-member Bloodlust HP sacrifice and attack buff")
if not support_bloodlust_swift_test_guard:
    issues.append("Swift tests must guard support-member Bloodlust HP sacrifice and attack buff")
if not support_sacred_blade_runtime_guard:
    issues.append("Battle must keep support-member Sacred Blade as a support attack/on-hit-heal scaffold")
if not support_sacred_blade_self_test_guard:
    issues.append("SelfTest must guard support-member Sacred Blade attack buff and on-hit healing")
if not support_sacred_blade_swift_test_guard:
    issues.append("Swift tests must guard support-member Sacred Blade attack buff and on-hit healing")
if not support_quick_loader_runtime_guard:
    issues.append("Battle must keep support-member Quick Loader as a scoped support attack-speed scaffold")
if not support_quick_loader_self_test_guard:
    issues.append("SelfTest must guard support-member Quick Loader attack-speed charges")
if not support_quick_loader_swift_test_guard:
    issues.append("Swift tests must guard support-member Quick Loader attack-speed charges")
if not swift_surge_self_test_guard:
    issues.append("SelfTest must guard main-hero Swift Surge one-second tick floor")
if not swift_surge_swift_test_guard:
    issues.append("Swift tests must guard main-hero Swift Surge one-second tick floor")
if not support_swift_surge_runtime_guard:
    issues.append("Battle must keep support-member Swift Surge as a scoped source-value attack-speed buff")
if not support_swift_surge_self_test_guard:
    issues.append("SelfTest must guard support-member Swift Surge attack-speed buff")
if not support_swift_surge_swift_test_guard:
    issues.append("Swift tests must guard support-member Swift Surge attack-speed buff")
if not support_frost_bolt_runtime_guard:
    issues.append("Battle must keep support-member Frost Bolt as support-attributed cold explosion and freeze scaffold")
if not support_frost_bolt_self_test_guard:
    issues.append("SelfTest must guard support-member Frost Bolt cold explosion and freeze behavior")
if not support_frost_bolt_swift_test_guard:
    issues.append("Swift tests must guard support-member Frost Bolt cold explosion and freeze behavior")
if not support_range_damage_runtime_guard:
    issues.append("Battle must keep support-member Scatter Shot, Arrow Rain and Meteor Strike as support-attributed current-wave range damage")
if not support_range_damage_self_test_guard:
    issues.append("SelfTest must guard support-member Scatter Shot, Arrow Rain and Meteor Strike range damage")
if not support_range_damage_swift_test_guard:
    issues.append("Swift tests must guard support-member Scatter Shot, Arrow Rain and Meteor Strike range damage")
if not battle_damage_log_metadata_static_guard:
    if damage_log_metadata_missing_lines:
        missing_lines = ",".join(f"Battle.swift:{line}" for line in damage_log_metadata_missing_lines)
        issues.append(
            "BattleLogEntry damage logs must explicitly carry source element/delivery metadata: "
            + missing_lines
        )
    else:
        issues.append("Battle must emit at least one explicit damage BattleLogEntry for metadata auditing")
if not battle_scene_snapshot_damage_metadata_static_guard:
    if snapshot_damage_log_metadata_missing_lines:
        missing_lines = ",".join(
            f"BattleSceneSnapshot.swift:{line}"
            for line in snapshot_damage_log_metadata_missing_lines
        )
        issues.append(
            "Battle scene snapshot damage fixtures must explicitly carry element/delivery metadata: "
            + missing_lines
        )
    else:
        issues.append("Battle scene snapshots must include damage fixtures for visual metadata auditing")
if not battle_scene_snapshot_fixture_audit_guard:
    if battle_scene_audit_missing_fixtures:
        issues.append(
            "Local battle-scene audit must render every BattleSceneSnapshot fixture; missing: "
            + ",".join(battle_scene_audit_missing_fixtures)
        )
    if battle_scene_audit_unknown_fixtures:
        issues.append(
            "Local battle-scene audit references unknown BattleSceneSnapshot fixtures: "
            + ",".join(battle_scene_audit_unknown_fixtures)
        )
    if not battle_scene_snapshot_fixture_cases:
        issues.append("BattleSceneSnapshot must expose an auditable Fixture enum")
if not battle_scene_snapshot_fixture_cli_guard:
    issues.append("BattleSceneSnapshot CLI must reject invalid fixture names and self-test complete fixture categorization")
if not battle_scene_snapshot_hero_class_cli_guard:
    issues.append("BattleSceneSnapshot CLI must reject invalid hero-class names and self-test all hero class render selectors")
if not battle_scene_snapshot_time_cli_guard:
    issues.append("BattleSceneSnapshot CLI must reject invalid fixed animation times and keep local battle-scene renders deterministic")
if not hero_skill_damage_metadata_runtime_guard:
    issues.append("Battle must keep main-hero damaging skill logs carrying source element/delivery metadata explicitly")
if not hero_skill_damage_metadata_self_test_guard:
    issues.append("SelfTest must guard main-hero damaging skill log source metadata")
if not hero_skill_damage_metadata_swift_test_guard:
    issues.append("Swift tests must guard main-hero damaging skill log source metadata")
if not core_offense_passive_runtime_guard:
    issues.append("Hero and Battle must keep AttackDamage and AttackSpeed passives wired into live base attacks")
if not core_offense_passive_self_test_guard:
    issues.append("SelfTest must guard AttackDamage and AttackSpeed passives on live Knight base attacks")
if not core_offense_passive_swift_test_guard:
    issues.append("Swift tests must guard AttackDamage and AttackSpeed passives on live Knight base attacks")
if not defensive_passive_runtime_guard:
    issues.append("Battle must keep DamageReduction, AllElementalResistance and DamageAbsorption wired into live monster hits")
if not defensive_passive_self_test_guard:
    issues.append("SelfTest must guard defensive passives on live monster-hit damage logs")
if not defensive_passive_swift_test_guard:
    issues.append("Swift tests must guard defensive passives on live monster-hit damage logs")
if not monster_crit_runtime_guard:
    issues.append("Battle must feed each monster's stored crit rate into live incoming hit logs")
if not monster_crit_self_test_guard:
    issues.append("SelfTest must guard stored monster crit rate reaching live incoming hit logs")
if not monster_crit_swift_test_guard:
    issues.append("Swift tests must guard stored monster crit rate reaching live incoming hit logs")
if not avoidance_passive_runtime_guard:
    issues.append("Battle and Battle UI must keep DodgeChance and BlockChance visible as distinct live avoidance logs")
if not avoidance_passive_self_test_guard:
    issues.append("SelfTest must guard DodgeChance and BlockChance visible live avoidance logs")
if not avoidance_passive_swift_test_guard:
    issues.append("Swift tests must guard DodgeChance and BlockChance visible live avoidance logs")
if not sustain_passive_runtime_guard:
    issues.append("Battle must keep HpRegenPerSec, AddHpPerHit, HpLeech and AddHpPerKill wired into visible live healing logs")
if not sustain_passive_self_test_guard:
    issues.append("SelfTest must guard sustain passives on visible live healing logs")
if not sustain_passive_swift_test_guard:
    issues.append("Swift tests must guard sustain passives on visible live healing logs")
if not damage_type_passive_runtime_guard:
    issues.append("Battle must keep Physical/Fire/Cold/Lightning damage passives wired into matching skill damage")
if not damage_type_passive_self_test_guard:
    issues.append("SelfTest must guard Physical/Fire/Cold/Lightning damage passives on matching live skill damage")
if not damage_type_passive_swift_test_guard:
    issues.append("Swift tests must guard Physical/Fire/Cold/Lightning damage passives on matching live skill damage")
if not area_damage_passive_runtime_guard:
    issues.append("Battle must keep IncreaseAreaOfEffectDamage wired into AOE skill damage")
if not area_damage_passive_self_test_guard:
    issues.append("SelfTest must guard IncreaseAreaOfEffectDamage on a checked AOE skill")
if not area_damage_passive_swift_test_guard:
    issues.append("Swift tests must guard IncreaseAreaOfEffectDamage on a checked AOE skill")
if not projectile_damage_passive_runtime_guard:
    issues.append("Battle must keep IncreaseProjectileDamage wired into projectile skill damage")
if not projectile_damage_passive_self_test_guard:
    issues.append("SelfTest must guard IncreaseProjectileDamage on a checked projectile skill")
if not projectile_damage_passive_swift_test_guard:
    issues.append("Swift tests must guard IncreaseProjectileDamage on a checked projectile skill")
if not skill_heal_passive_runtime_guard:
    issues.append("Battle must keep SkillHealIncrease wired into checked healing skill output")
if not skill_heal_passive_self_test_guard:
    issues.append("SelfTest must guard SkillHealIncrease on a checked healing-over-time skill")
if not skill_heal_passive_swift_test_guard:
    issues.append("Swift tests must guard SkillHealIncrease on a checked healing-over-time skill")
if not skill_duration_passive_runtime_guard:
    issues.append("Battle must keep SkillDurationIncrease wired into active battle buff duration")
if not skill_duration_passive_self_test_guard:
    issues.append("SelfTest must guard SkillDurationIncrease on a checked active buff")
if not skill_duration_passive_swift_test_guard:
    issues.append("Swift tests must guard SkillDurationIncrease on a checked active buff")
if not cooldown_cast_speed_runtime_guard:
    issues.append("Battle must keep CooldownReduction and CastSpeed wired into live cooldown timers")
if not cooldown_cast_speed_self_test_guard:
    issues.append("SelfTest must guard CooldownReduction and CastSpeed on live Fireball cast count")
if not cooldown_cast_speed_swift_test_guard:
    issues.append("Swift tests must guard CooldownReduction and CastSpeed on live Fireball cast count")
if not derived_skill_damage_metadata_runtime_guard:
    issues.append("Battle must keep derived skill damage logs carrying source element/delivery metadata explicitly")
if not derived_skill_damage_metadata_self_test_guard:
    issues.append("SelfTest must guard derived skill damage log source metadata")
if not derived_skill_damage_metadata_swift_test_guard:
    issues.append("Swift tests must guard derived skill damage log source metadata")
if not charge_trap_actual_damage_log_runtime_guard:
    issues.append("Battle must detonate Charge Trap from actual hero-side elemental damage logs instead of skill metadata")
if not charge_trap_actual_damage_log_self_test_guard:
    issues.append("SelfTest must guard Charge Trap actual-log trigger and physical-log non-trigger behavior")
if not charge_trap_actual_damage_log_swift_test_guard:
    issues.append("Swift tests must guard Charge Trap actual-log trigger and physical-log non-trigger behavior")
if not support_ranger_projectile_metadata_runtime_guard:
    issues.append("Battle must keep support Ranger Piercing Arrow and Skewer Shot source projectile metadata explicit")
if not support_ranger_projectile_metadata_self_test_guard:
    issues.append("SelfTest must guard support Ranger Piercing Arrow and Skewer Shot projectile metadata")
if not support_ranger_projectile_metadata_swift_test_guard:
    issues.append("Swift tests must guard support Ranger Piercing Arrow and Skewer Shot projectile metadata")
if not support_charge_trap_runtime_guard:
    issues.append("Battle must keep support-member Charge Trap as a visible trap and support-attributed explosion scaffold")
if not support_charge_trap_self_test_guard:
    issues.append("SelfTest must guard support-member Charge Trap arming and detonation")
if not support_charge_trap_swift_test_guard:
    issues.append("Swift tests must guard support-member Charge Trap arming and detonation")
if not support_resurrection_runtime_guard:
    issues.append("Battle must keep support-member Resurrection as a support-attributed revive scaffold")
if not support_resurrection_self_test_guard:
    issues.append("SelfTest must guard support-member Resurrection revive behavior")
if not support_resurrection_swift_test_guard:
    issues.append("Swift tests must guard support-member Resurrection revive behavior")
if not support_unyielding_will_runtime_guard:
    issues.append("Battle must keep support-member Unyielding Will as a self-revive scaffold")
if not support_unyielding_will_self_test_guard:
    issues.append("SelfTest must guard support-member Unyielding Will self-revive behavior")
if not support_unyielding_will_swift_test_guard:
    issues.append("Swift tests must guard support-member Unyielding Will self-revive behavior")
if not support_attack_count_skill_runtime:
    issues.append("Battle must keep support-member attack-count skill state for modeled BASEATTACK_COUNT skills")
if not battle_hero_sprite_guard:
    issues.append("Battle hero sprites must keep class-specific transparent source-backed art, resource self-test provenance and local hero-sprite audit coverage")
if not source_base_attack_metadata:
    issues.append("Battle must apply source base attack element/delivery metadata to hero and support attack logs")
if not source_chaos_damage_metadata:
    issues.append("Runtime skill metadata must preserve checked source Chaos damage rows")
if not source_chaos_battle_scene_audit:
    issues.append("Local battle-scene audit must render and gate the checked source Chaos impact cue")
if not melee_arc_battle_scene_audit:
    issues.append("Local battle-scene audit must render and gate ordinary melee arc trajectory cues")
if not battle_contact_pulse_audit:
    issues.append("Local battle-scene audit must render and gate hero and monster contact-pulse feedback")
if not ranger_projectile_battle_scene_audit:
    issues.append("Local battle-scene audit must render and gate all visible Ranger arrow trajectory cues")
if not hunter_bolt_battle_scene_audit:
    issues.append("Local battle-scene audit must render and gate Hunter Shock Bolt main hit and current cues")
if not source_monster_attack_metadata:
    issues.append("Battle must apply checked source monster attack metadata for explicitly mapped elemental priests")
if not warding_blessing_elemental_scope_guard:
    issues.append("Warding Blessing must reduce only source elemental incoming damage, not physical or chaos attacks")
if not source_monster_incoming_visual_audit:
    issues.append("Local battle-scene audit must render and gate source-backed monster incoming cues")
if not enemy_status_body_effect_audit:
    issues.append("Local battle-scene audit must render and gate enemy status body-effect cues")
if not source_skill_database_view:
    issues.append("Settings UI must expose the complete SourceSkillCatalog review table and runtime/data-only coverage")
if not source_skill_delivery_review_view:
    issues.append("Settings UI must expose source skill delivery distribution and no-fabrication boundaries")
if not source_skill_damage_review_view:
    issues.append("Settings UI must expose source skill damage distribution and no-fabrication boundaries")
if not source_skill_activation_damage_review_view:
    issues.append("Settings UI must expose source skill activation-damage cross-tab and no-fabrication boundaries")
if not source_skill_activation_delivery_review_view:
    issues.append("Settings UI must expose source skill activation-delivery cross-tab and trigger visual no-fabrication boundaries")
if not source_skill_damage_delivery_review_view:
    issues.append("Settings UI must expose source skill damage-delivery cross-tab and visual no-fabrication boundaries")
if not source_skill_range_review_view:
    issues.append("Settings UI must expose source skill range distribution and no-fabrication boundaries")
if not local_skill_runtime_coverage_view:
    issues.append("Settings UI must expose local skill runtime coverage and pending-source boundaries")
if not pending_source_skill_review_view:
    issues.append("Settings UI must expose pending source skill buckets without fabricating runtime semantics")
if not modeled_active_skill_value_review_view:
    issues.append("Settings UI must expose modeled active skill value tables and unmodeled source skill boundaries")
if not source_passive_skill_database_view:
    issues.append("Settings UI must expose checked passive skill source rows, source-icon coverage and missing-icon boundaries")
if not source_rune_database_view:
    issues.append("Settings UI must expose the complete SourceRuneCatalog review table and runtime/data-only coverage")
if not rune_tree_one_click_unlock:
    issues.append("Rune Tree must expose one-click available-node unlock through GameEngine, Settings UI and SelfTest")
if not local_rune_cost_review_view:
    issues.append("Settings UI must expose local Rune cost review rows and verified/approximate/pending boundaries")
if not source_rune_evidence_review_view:
    issues.append("Settings UI must expose cross-source Rune evidence tiers and unresolved cost/reset/timer boundaries")
if not source_rune_candidate_cost_queue_guard:
    issues.append("Settings UI must expose tbh.city candidate Rune cost queues without promoting them to runtime costs")
if not source_stage_database_view:
    issues.append("Settings UI must expose the complete mined stage runtime source-data review table")
if not source_monster_database_view:
    issues.append("Settings UI must expose the complete source monster database and data-only art boundary")
if not source_monster_runtime_stats_guard:
    issues.append("Stage runtime monsters must use source monster ATK and attack-speed scalars")
if not source_monster_art_mapping_view:
    issues.append("Settings UI must expose checked stage monster art mappings and fallback boundaries")
if not source_monster_attack_review_view:
    issues.append("Settings UI must expose checked source monster attack mappings and unknown delivery boundaries")
if not source_item_database_view:
    issues.append("Settings UI must expose checked source item, material and stage chest review tables")
if not exact_item_record_gap_view:
    issues.append("Settings UI must expose exact item-record gaps separately from source progression icons")
if not source_crafting_rule_review_view:
    issues.append("Settings UI must expose checked Synthesis/Cube/Alchemy rules and unknown probability boundaries")
if not settings_fidelity_boundary_view:
    issues.append("Settings UI must expose explicit original-fidelity coverage and known-gap boundaries")

source_gear_rows = tsv_lines(item_source, "sourceGearTypeTSV")
source_gear_entries = []
source_gear_rarity_counts: Counter[str] = Counter()
source_gear_progression_ids: list[str] = []
source_gear_title_categories = {
    "Sword": "weapon",
    "Bow": "weapon",
    "Staff": "weapon",
    "Scepter": "weapon",
    "Crossbow": "weapon",
    "Axe": "weapon",
    "Shield": "offhand",
    "Arrow": "offhand",
    "Orb": "offhand",
    "Tome": "offhand",
    "Bolt": "offhand",
    "Hatchet": "offhand",
    "Helmet": "armor",
    "Armor": "armor",
    "Gloves": "armor",
    "Boots": "armor",
    "Amulet": "accessory",
    "Earing": "accessory",
    "Ring": "accessory",
    "Bracer": "accessory",
}
source_gear_category_type_counts: Counter[str] = Counter()
source_gear_category_entry_counts: Counter[str] = Counter()
source_gear_category_progression_counts: Counter[str] = Counter()
source_gear_category_rarity_counts: Counter[tuple[str, str]] = Counter()
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

    category = source_gear_title_categories.get(columns[1])
    if category is None:
        issues.append(f"source gear title has no category mapping: {columns[1]}")
        category = "unknown"
    source_gear_category_type_counts[category] += 1
    source_gear_category_entry_counts[category] += gear_count
    source_gear_category_progression_counts[category] += len(progressions)
    for rarity, count in rarity_counts.items():
        source_gear_category_rarity_counts[(category, rarity)] += count

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
        "category": category,
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
exact_item_record_gap_category_queue_count = (
    len(source_gear_category_entry_counts)
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_rarity_queue_count = (
    len(source_gear_rarity_counts)
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_category_rarity_queue_count = (
    len(source_gear_category_entry_counts) * len(source_gear_rarity_counts)
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_progression_queue_count = (
    source_gear_level_progression_total
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_type_queue_count = (
    len(source_gear_entries)
    if exact_item_record_gap_view
    else 0
)
largest_source_gear_type_count = max(
    (entry["gear_count"] for entry in source_gear_entries),
    default=0,
)
exact_item_record_gap_largest_type_queue_count = (
    sum(1 for entry in source_gear_entries if entry["gear_count"] == largest_source_gear_type_count)
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_queue_coverage_count = (
    sum(entry["gear_count"] for entry in source_gear_entries)
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_rarity_queue_coverage_count = (
    source_gear_rarity_total
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_category_rarity_queue_coverage_count = (
    sum(source_gear_category_rarity_counts.values())
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_progression_queue_coverage_count = (
    source_gear_level_progression_total
    if exact_item_record_gap_view
    else 0
)
exact_item_record_gap_largest_type_queue_coverage_count = (
    sum(
        entry["gear_count"]
        for entry in source_gear_entries
        if entry["gear_count"] == largest_source_gear_type_count
    )
    if exact_item_record_gap_view
    else 0
)
if exact_item_record_gap_queue_coverage_count != source_gear_entry_total:
    issues.append(
        "exact item-record queue coverage does not match aggregate gear entries: "
        f"{exact_item_record_gap_queue_coverage_count} vs {source_gear_entry_total}"
    )
if exact_item_record_gap_rarity_queue_coverage_count != source_gear_entry_total:
    issues.append(
        "exact item-record rarity queue coverage does not match aggregate gear entries: "
        f"{exact_item_record_gap_rarity_queue_coverage_count} vs {source_gear_entry_total}"
    )
if exact_item_record_gap_category_rarity_queue_coverage_count != source_gear_entry_total:
    issues.append(
        "exact item-record category-rarity matrix queue coverage does not match aggregate gear entries: "
        f"{exact_item_record_gap_category_rarity_queue_coverage_count} vs {source_gear_entry_total}"
    )
if exact_item_record_gap_progression_queue_coverage_count != source_gear_level_progression_total:
    issues.append(
        "exact item-record progression queue coverage does not match source base progressions: "
        f"{exact_item_record_gap_progression_queue_coverage_count} vs {source_gear_level_progression_total}"
    )
if exact_item_record_gap_largest_type_queue_coverage_count != largest_source_gear_type_count * exact_item_record_gap_largest_type_queue_count:
    issues.append(
        "exact item-record largest type queue coverage does not match largest type rows: "
        f"{exact_item_record_gap_largest_type_queue_coverage_count} vs "
        f"{largest_source_gear_type_count * exact_item_record_gap_largest_type_queue_count}"
    )

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
battle_log_hero_highlight_entry_limit = static_number(battle_view_source, "BattleLogMetrics", "heroHighlightEntryLimit")
battle_log_panel_height = static_number(battle_view_source, "BattleLogMetrics", "panelHeight")
menu_bar_popover_default_width, menu_bar_popover_default_height = static_cgsize(menu_bar_popover_source, "defaultSize")
menu_bar_content_min_height = int(static_number(menu_bar_popover_source, "MenuBarPopoverLayout", "contentMinHeight") or 0)
menu_bar_bottom_tab_height = int(static_number(menu_bar_popover_source, "MenuBarPopoverLayout", "bottomTabHeight") or 0)
if ".frame(minHeight: MenuBarPopoverLayout.contentMinHeight, maxHeight: .infinity)" not in menu_bar_popover_source:
    issues.append("MenuBarPopover content frame must use the guarded contentMinHeight metric")

battle_scene_render_width_px = int((battle_scene_expected_width or 0) * 2)
battle_scene_render_height_px = int((battle_scene_compact_height or 0) * 2)
battle_tab_layout_render_width_px = int((menu_bar_popover_default_width or 0) * 2)
battle_tab_layout_render_height_px = int((menu_bar_popover_default_height or 0) * 2)
inventory_panel_render_width_px = battle_scene_render_width_px
inventory_panel_render_height_px = 1440
character_panel_render_width_px = battle_scene_render_width_px
character_panel_render_height_px = int((menu_bar_content_min_height or 0) * 2)
chest_panel_render_width_px = battle_scene_render_width_px
chest_panel_render_height_px = 720
original_fidelity_panel_render_width_px = battle_scene_render_width_px
original_fidelity_panel_render_height_px = 1200
rune_evidence_panel_render_width_px = battle_scene_render_width_px
rune_evidence_panel_render_height_px = 1240
skill_evidence_panel_render_width_px = battle_scene_render_width_px
skill_evidence_panel_render_height_px = 1440
passive_evidence_panel_render_width_px = battle_scene_render_width_px
passive_evidence_panel_render_height_px = 1440
battle_scene_configured_ratio_x100 = int(round(
    ((battle_scene_expected_width or 0) / max(battle_scene_compact_height or 1, 1)) * 100
))
battle_scene_local_platform_width_percent = int(round((battle_scene_ground_platform_ratio or 0) * 100))
battle_log_visible_entries = int(battle_log_visible_entry_limit or 0)
battle_log_hero_highlight_entries = int(battle_log_hero_highlight_entry_limit or 0)
battle_log_panel_height_value = int(battle_log_panel_height or 0)
support_formula_review_body = enum_block(settings_source, "SupportFormulaReviewMetrics")
support_formula_review_rows = len(re.findall(r'SupportFormulaReviewRowModel\s*\(', support_formula_review_body))
support_formula_attack_scalar = static_number(settings_source, "SupportFormulaReviewMetrics", "supportAttackScalar") or 0
support_formula_attack_scalar_percent = int(round(support_formula_attack_scalar * 100))
content_frame_index = menu_bar_popover_source.find(".frame(minHeight: MenuBarPopoverLayout.contentMinHeight, maxHeight: .infinity)")
bottom_menu_index = menu_bar_popover_source.find("// 底部菜单栏")
tab_for_each_index = menu_bar_popover_source.find("ForEach(Tab.allCases, id: \\.self)")
menu_bar_bottom_tab_guard = (
    menu_bar_popover_default_width >= int(battle_scene_expected_width or 0)
    and menu_bar_popover_default_height == CURRENT_BASELINE["menu_bar_popover_default_height"]
    and menu_bar_content_min_height == CURRENT_BASELINE["menu_bar_content_min_height"]
    and menu_bar_bottom_tab_height >= 44
    and 0 <= content_frame_index < bottom_menu_index < tab_for_each_index
    and "Spacer(minLength: 0)" not in menu_bar_popover_source
    and ".frame(height: MenuBarPopoverLayout.bottomTabHeight)" in menu_bar_popover_source
    and "menu-bar popover keeps the bottom-tab battle layout within a visible macOS menu window" in self_test_source
    and "bottom-tab popover content can fit the battle scene and battle log without vertical compression" in self_test_source
)

battle_scene_local_audit_guard = (
    "ground_platform_width_ratio = 0.90" in battle_scene_audit_source
    and "min_y < height * 0.9" in battle_scene_audit_source
    and "min_local_ratio = 1.25" in battle_scene_audit_source
    and "max_ground_width_ratio = 0.40" in battle_scene_audit_source
    and "0.84 <= ground_width_to_image_ratio <= 0.96" in battle_scene_audit_source
    and "TBH_RENDERED_SNAPSHOT" in battle_scene_audit_source
    and "scene_width = float(width)" in battle_scene_audit_source
    and "battle ground platform width no longer leaves only subtle side margins" in battle_scene_audit_source
    and "stage_pill_text_pixels" in battle_scene_audit_source
    and "stage_pill_dark_pixels" in battle_scene_audit_source
    and "local_motion_pixels" in battle_scene_audit_source
    and "local_motion_percent" in battle_scene_audit_source
    and "local battle scene motion is static or too subtle between deterministic frames" in battle_scene_audit_source
    and "flame_motion_percent" in battle_scene_audit_source
    and "combatant_motion_pixels" in battle_scene_audit_source
    and "combatant_motion_scene_percent" in battle_scene_audit_source
    and "combatant idle motion is static or too subtle between deterministic frames" in battle_scene_audit_source
    and "player_combatant_motion_pixels" in battle_scene_audit_source
    and "player_combatant_motion_scene_percent" in battle_scene_audit_source
    and "player-side combatant idle motion is static or too subtle between deterministic frames" in battle_scene_audit_source
    and "enemy_combatant_motion_pixels" in battle_scene_audit_source
    and "enemy_combatant_motion_scene_percent" in battle_scene_audit_source
    and "enemy-side combatant idle motion is static or too subtle between deterministic frames" in battle_scene_audit_source
)
official_steam_battle_motion_guard = (
    "== Frame-to-frame motion sample ==" in steam_battle_scene_audit_source
    and "select='eq(n,0)+eq(n,8)'" in steam_battle_scene_audit_source
    and "motion_frame_delta=8" in steam_battle_scene_audit_source
    and "motion_frame_interval_seconds" in steam_battle_scene_audit_source
    and "official_motion_pixels" in steam_battle_scene_audit_source
    and "official_platform_motion_pixels" in steam_battle_scene_audit_source
    and "official_non_platform_motion_pixels" in steam_battle_scene_audit_source
    and "official_motion_percent" in steam_battle_scene_audit_source
    and "official battlescene motion is too subtle between sampled frames" in steam_battle_scene_audit_source
    and "official battlescene lower-platform motion is too subtle between sampled frames" in steam_battle_scene_audit_source
)
battle_scene_self_test_guard = (
    "BattleSceneMetrics.groundPlatformWidthRatio >= 0.86" in self_test_source
    and "BattleSceneMetrics.groundPlatformWidthRatio <= 0.94" in self_test_source
    and "BattleSceneMetrics.compactHeight >= 280" in self_test_source
    and "BattleSceneMetrics.combatantBaselineRatio >= 0.92" in self_test_source
    and "battle scene keeps combatants on the lower ground lane" in self_test_source
    and "BattleSceneMetrics.maximumVisualScaleHeight / BattleSceneMetrics.referenceCompactHeight" in self_test_source
    and "battle scene enlarges the viewport without over-scaling combatants into cropped figures" in self_test_source
    and "battle scene keeps only subtle dark side margins around the ground platform" in self_test_source
)
source_range_visual_guard = (
    "var sourceRange: Int?" in skills_source
    and "let sourceRange: Int?" in battle_source
    and "sourceRange: HeroSkills.baseAttackSourceSkill(for: primaryHeroClass)?.range" in battle_source
    and "sourceRange: HeroSkills.baseAttackSourceSkill(for: member.heroClass)?.range" in battle_source
    and "sourceRange ?? inferredSkill?.sourceRange ?? inferredMonsterSkill?.range" in battle_source
    and "sourceRangeVisualScale(for:" in battle_view_source
    and "sourceRangeScale: rangeScale" in battle_view_source
    and ".scaleEffect(x: sourceRangeScale, y: 1.0, anchor: .center)" in battle_view_source
    and "battle scene uses checked source range as a conservative trajectory-size visual cue" in self_test_source
    and "battle log entries infer element, delivery and source range metadata for visual combat feedback" in self_test_source
    and "source-backed monster battle logs infer checked source attack range" in self_test_source
)
battle_log_self_test_guard = (
    "BattleLogMetrics.visibleEntryLimit >= 50" in self_test_source
    and "BattleLogMetrics.minimumVisibleHeroSideEntries >= 8" in self_test_source
    and "BattleLogMetrics.heroHighlightEntryLimit >= 3" in self_test_source
    and "BattleLogMetrics.panelHeight >= 160" in self_test_source
    and "battle tab keeps a taller scrollable combat log below the visible scene" in self_test_source
    and "battle log display fills the default production window for long fights" in self_test_source
    and "battle log display preserves eight hero-side rows in the default production window" in self_test_source
    and "battle log display keeps the latest monster-side row in the default production window" in self_test_source
    and "battle log default production window scroll target returns to the latest hero-side row after long monster streaks" in self_test_source
    and "battle log panel scroll target uses the retained hero-side row inside the visible production window" in self_test_source
    and "battle log presentation feeds the panel with the default retained production window" in self_test_source
    and "battle log display exposes a fixed hero-side highlight strip" in self_test_source
    and "battle log hero-side highlight strip keeps the latest player-side records" in self_test_source
    and "battle log hero-side highlight strip survives long monster-only tails" in self_test_source
    and "battle log presentation preserves hero focus and scroll target for BattleLogPanel" in self_test_source
    and "struct BattleLogPresentation" in battle_view_source
    and "let battleLogPresentation = BattleLogPresentation(from: gameEngine.recentBattleLog)" in battle_view_source
    and "entries: battleLogPresentation.visibleEntries" in battle_view_source
    and "heroFocusEntries: battleLogPresentation.heroFocusEntries" in battle_view_source
    and "totalCount: battleLogPresentation.totalCount" in battle_view_source
    and "BattleHeroLogFocus(entries: heroFocusEntries)" in battle_view_source
)
battle_log_panel_snapshot_guard = (
    "case battleLogPanel" in battle_scene_snapshot_source
    and "BattleLogPanelSnapshotView" in battle_scene_snapshot_source
    and "makeBattleLogPanelEntries" in battle_scene_snapshot_source
    and "BattleLogPanel(" in battle_scene_snapshot_source
    and "struct BattleLogPanel: View" in battle_view_source
    and "fixture: .battleLogPanel" in self_test_source
    and "battle scene snapshot renderer captures the real battle log panel fixture" in self_test_source
    and "--render-battle-scene-fixture battleLogPanel" in battle_scene_audit_source
    and "TBH_BATTLE_LOG_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and "battle_log_panel_non_dark_pixels" in battle_scene_audit_source
    and "battle_log_panel_title_light_pixels" in battle_scene_audit_source
    and "battle_log_panel_hero_blue_pixels" in battle_scene_audit_source
    and "battle_log_panel_support_purple_pixels" in battle_scene_audit_source
    and "battle_log_panel_monster_red_pixels" in battle_scene_audit_source
    and "battle_log_panel_critical_orange_pixels" in battle_scene_audit_source
)
battle_tab_layout_snapshot_guard = (
    "case battleTabLayout" in battle_scene_snapshot_source
    and "BattleTabLayoutSnapshotView" in battle_scene_snapshot_source
    and "HeroSummaryBar(hero: battle.hero)" in battle_scene_snapshot_source
    and "StageHeaderView(" in battle_scene_snapshot_source
    and "BattleLogPanel(" in battle_scene_snapshot_source
    and "TabBarButton(" in battle_scene_snapshot_source
    and "fixture: .battleTabLayout" in self_test_source
    and "battle scene snapshot renderer captures the full battle tab layout with the bottom menu bar" in self_test_source
    and "--render-battle-scene-fixture battleTabLayout" in battle_scene_audit_source
    and "TBH_BATTLE_TAB_LAYOUT_SCREENSHOT_PATH" in battle_scene_audit_source
    and "battle_tab_layout_scene_warm_pixels" in battle_scene_audit_source
    and "battle_tab_layout_bottom_non_dark_pixels" in battle_scene_audit_source
    and "battle_tab_layout_bottom_accent_pixels" in battle_scene_audit_source
    and f"expected_layout_width = {CURRENT_BASELINE['battle_tab_layout_render_width_px']}" in battle_scene_audit_source
    and f"expected_layout_height = {CURRENT_BASELINE['battle_tab_layout_render_height_px']}" in battle_scene_audit_source
    and "main_hp_pixels, _, main_hp_bbox = collect_region_bbox(0.20, 0.43, 0.22, 0.26, is_hp_green)" in battle_scene_audit_source
    and "support_hp_pixels, _, _ = collect_region_bbox(0.02, 0.30, 0.48, 0.56, is_hp_green)" in battle_scene_audit_source
    and "enemy_hp_frame_pixels, _, enemy_hp_frame_bbox = collect_region_bbox(\n        0.66, 0.89, 0.22, 0.26, is_hp_red\n    )" in battle_scene_audit_source
)
inventory_panel_snapshot_guard = (
    "case inventoryPanel" in battle_scene_snapshot_source
    and "InventoryPanelSnapshotView" in battle_scene_snapshot_source
    and "InventoryView(" in battle_scene_snapshot_source
    and "initialSelectedItems: [selectedItem]" in battle_scene_snapshot_source
    and "SourceItemCatalog.progression(for: type, itemLevel: level)" in battle_scene_snapshot_source
    and "GameArt.itemIconName(for: item)" in inventory_view_source
    and "Picker(\"\", selection:" in inventory_view_source
    and "ForEach(WorseEquipmentHandling.allCases)" in inventory_view_source
    and "EquipmentComparisonView(hero: hero, item: item)" in inventory_view_source
    and "SynthesisPreviewView(" in inventory_view_source
    and "fixture: .inventoryPanel" in self_test_source
    and "battle scene snapshot renderer captures the real inventory panel with source-backed icons and comparison preview" in self_test_source
    and "--render-battle-scene-fixture inventoryPanel" in battle_scene_audit_source
    and "TBH_INVENTORY_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_inventory_width = {CURRENT_BASELINE['inventory_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_inventory_height = {CURRENT_BASELINE['inventory_panel_render_height_px']}" in battle_scene_audit_source
    and "inventory_panel_grid_colored_pixels" in battle_scene_audit_source
    and "inventory_panel_delta_green_pixels" in battle_scene_audit_source
    and "inventory_panel_rarity_pixels" in battle_scene_audit_source
)
character_panel_snapshot_guard = (
    "case characterPanel" in battle_scene_snapshot_source
    and "CharacterPanelSnapshotView" in battle_scene_snapshot_source
    and "CharacterView(" in battle_scene_snapshot_source
    and "HeroParty(primaryClass: .hunter, unlockedSlotCount: 1)" in battle_scene_snapshot_source
    and "RuneTree(unlockedPartySlotCount: 1).directPartySlotUnlockCost(for: slotIndex)" in battle_scene_snapshot_source
    and "activeSkillSlotCount: 2" in battle_scene_snapshot_source
    and "GameArt.heroSpriteName(for: hero.heroClass)" in character_view_source
    and "PartySlotRow(" in character_view_source
    and "ActiveSkillLoadoutEditor(" in character_view_source
    and "PassiveSkillRow(passiveSkill:" in character_view_source
    and "GameArt.itemIconName(for: item)" in character_view_source
    and "fixture: .characterPanel" in self_test_source
    and "battle scene snapshot renderer captures the real character panel with hero art, party unlocks and active skill loadout" in self_test_source
    and "--render-battle-scene-fixture characterPanel" in battle_scene_audit_source
    and "TBH_CHARACTER_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_character_width = {CURRENT_BASELINE['character_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_character_height = {CURRENT_BASELINE['character_panel_render_height_px']}" in battle_scene_audit_source
    and "character_panel_hero_colored_pixels" in battle_scene_audit_source
    and "character_panel_party_orange_pixels" in battle_scene_audit_source
    and "character_panel_skill_colored_pixels" in battle_scene_audit_source
    and "character_panel_passive_icon_pixels" in battle_scene_audit_source
)
chest_panel_snapshot_guard = (
    "case chestPanel" in battle_scene_snapshot_source
    and "ChestPanelSnapshotView" in battle_scene_snapshot_source
    and "ChestControlsView(gameEngine: gameEngine)" in battle_scene_snapshot_source
    and "ChestControlsView(gameEngine: gameEngine)" in settings_source
    and "struct ChestControlsView" in settings_source
    and "ChestAutoOpenStatusStrip(gameEngine: gameEngine)" in settings_source
    and "ChestAutoOpenFamilyBadge(" in settings_source
    and "gameEngine.openAllChests()" in settings_source
    and "gameEngine.openChests(kind: kind)" in settings_source
    and "gameEngine.openChest(id: chest.id)" in settings_source
    and "GameArt.chestIconName(for: chest)" in settings_source
    and "GameArt.chestIconName(for: sampleChest)" in settings_source
    and ".autoOpenNormalChests" in battle_scene_snapshot_source
    and ".autoOpenStageBossChests" in battle_scene_snapshot_source
    and ".autoOpenActBossChests" in battle_scene_snapshot_source
    and "fixture: .chestPanel" in self_test_source
    and "battle scene snapshot renderer captures the real chest controls with batch opening, auto-open status and source-backed chest icons" in self_test_source
    and "--render-battle-scene-fixture chestPanel" in battle_scene_audit_source
    and "TBH_CHEST_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_chest_width = {CURRENT_BASELINE['chest_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_chest_height = {CURRENT_BASELINE['chest_panel_render_height_px']}" in battle_scene_audit_source
    and "chest_panel_button_blue_pixels" in battle_scene_audit_source
    and "chest_panel_auto_green_pixels" in battle_scene_audit_source
    and "chest_panel_icon_colored_pixels" in battle_scene_audit_source
    and "chest_panel_rarity_pixels" in battle_scene_audit_source
    and "settings fidelity boundary hard blocker queue preserves skill, Rune, pacing and exact-item gap counts" in self_test_source
    and "settings fidelity boundary hard blocker queue keeps evidence boundaries from fabricating original parity" in self_test_source
)
original_fidelity_hard_gap_row_count = (
    len(re.findall(r'OriginalFidelityHardGapRowModel\s*\(', settings_source))
    if settings_fidelity_boundary_view
    else 0
)
original_fidelity_panel_snapshot_guard = (
    "case originalFidelityPanel" in battle_scene_snapshot_source
    and "OriginalFidelityPanelSnapshotView" in battle_scene_snapshot_source
    and "ScrollView" in battle_scene_snapshot_source
    and "OriginalFidelityBoundaryView()" in battle_scene_snapshot_source
    and "struct OriginalFidelityBoundaryView" in settings_source
    and "OriginalFidelityBoundaryMetrics.runtimeSkillCoverageText" in settings_source
    and "OriginalFidelityBoundaryMetrics.exactItemRecordCoverageText" in settings_source
    and "OriginalFidelityBoundaryMetrics.skillEffectBoundaryText" in settings_source
    and "OriginalFidelityBoundaryMetrics.stageMonsterArtBoundaryText" in settings_source
    and "fixture: .originalFidelityPanel" in self_test_source
    and "battle scene snapshot renderer captures the real original-fidelity boundary panel" in self_test_source
    and "--render-battle-scene-fixture originalFidelityPanel" in battle_scene_audit_source
    and "TBH_ORIGINAL_FIDELITY_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_original_fidelity_width = {CURRENT_BASELINE['original_fidelity_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_original_fidelity_height = {CURRENT_BASELINE['original_fidelity_panel_render_height_px']}" in battle_scene_audit_source
    and "original_fidelity_panel_pill_pixels" in battle_scene_audit_source
    and "original_fidelity_panel_status_green_pixels" in battle_scene_audit_source
    and "original_fidelity_panel_status_orange_pixels" in battle_scene_audit_source
    and "original_fidelity_panel_status_gap_pixels" in battle_scene_audit_source
)
rune_evidence_panel_snapshot_guard = (
    "case runeEvidencePanel" in battle_scene_snapshot_source
    and "RuneEvidencePanelSnapshotView" in battle_scene_snapshot_source
    and "SourceRuneEvidenceReviewView()" in battle_scene_snapshot_source
    and "LocalRuneCostReviewView()" in battle_scene_snapshot_source
    and "struct SourceRuneEvidenceReviewView" in settings_source
    and "struct LocalRuneCostReviewView" in settings_source
    and "SourceRuneEvidenceReviewMetrics.candidateCostQueueCount" in settings_source
    and "candidateCostQueueGoldTotal" in settings_source
    and "SourceRuneEvidenceReviewMetrics.candidateCostQueueGoldText" in settings_source
    and "LocalRuneCostReviewMetrics.pendingCostEvidenceQueueCount" in settings_source
    and "LocalRuneCostReviewMetrics.pendingCostMaxLevelEvidenceCount" in settings_source
    and "fixture: .runeEvidencePanel" in self_test_source
    and "battle scene snapshot renderer captures the real Rune evidence and cost review panels" in self_test_source
    and "--render-battle-scene-fixture runeEvidencePanel" in battle_scene_audit_source
    and "TBH_RUNE_EVIDENCE_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_rune_evidence_width = {CURRENT_BASELINE['rune_evidence_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_rune_evidence_height = {CURRENT_BASELINE['rune_evidence_panel_render_height_px']}" in battle_scene_audit_source
    and "rune_evidence_panel_non_dark_pixels" in battle_scene_audit_source
    and "rune_evidence_panel_pill_pixels" in battle_scene_audit_source
    and "rune_evidence_panel_text_light_pixels" in battle_scene_audit_source
    and "rune_evidence_panel_orange_pixels" in battle_scene_audit_source
    and "rune_evidence_panel_green_pixels" in battle_scene_audit_source
)
skill_evidence_panel_snapshot_guard = (
    "case skillEvidencePanel" in battle_scene_snapshot_source
    and "SkillEvidencePanelSnapshotView" in battle_scene_snapshot_source
    and "LocalSkillRuntimeCoverageView()" in battle_scene_snapshot_source
    and "SourceSkillDamageReviewView()" in battle_scene_snapshot_source
    and "SourceSkillRangeReviewView()" in battle_scene_snapshot_source
    and "PendingSourceSkillReviewView()" in battle_scene_snapshot_source
    and "struct LocalSkillRuntimeCoverageView" in settings_source
    and "struct SourceSkillDamageReviewView" in settings_source
    and "struct SourceSkillRangeReviewView" in settings_source
    and "struct PendingSourceSkillReviewView" in settings_source
    and "LocalSkillRuntimeCoverageMetrics.runtimeModeledCount" in settings_source
    and "static var runtimeMappedCount: Int" in settings_source
    and "SourceSkillRangeReviewMetrics.rangeBucketCount" in settings_source
    and "PendingSourceSkillReviewMetrics.pendingCount" in settings_source
    and "fixture: .skillEvidencePanel" in self_test_source
    and "battle scene snapshot renderer captures the real source skill and pending-skill review panels" in self_test_source
    and "--render-battle-scene-fixture skillEvidencePanel" in battle_scene_audit_source
    and "TBH_SKILL_EVIDENCE_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_skill_evidence_width = {CURRENT_BASELINE['skill_evidence_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_skill_evidence_height = {CURRENT_BASELINE['skill_evidence_panel_render_height_px']}" in battle_scene_audit_source
    and "skill_evidence_panel_non_dark_pixels" in battle_scene_audit_source
    and "skill_evidence_panel_pill_pixels" in battle_scene_audit_source
    and "skill_evidence_panel_text_light_pixels" in battle_scene_audit_source
    and "skill_evidence_panel_orange_pixels" in battle_scene_audit_source
    and "skill_evidence_panel_green_pixels" in battle_scene_audit_source
)
passive_evidence_panel_snapshot_guard = (
    "case passiveEvidencePanel" in battle_scene_snapshot_source
    and "PassiveEvidencePanelSnapshotView" in battle_scene_snapshot_source
    and "SourcePassiveSkillDatabaseView()" in battle_scene_snapshot_source
    and "SourcePassiveSkillRow(passiveSkill:" in battle_scene_snapshot_source
    and "struct SourcePassiveSkillDatabaseView" in settings_source
    and "struct SourcePassiveSkillRow" in settings_source
    and "SourcePassiveSkillDatabaseMetrics.sourceRowCount" in settings_source
    and "SourcePassiveSkillDatabaseMetrics.sourceIconCoverageText" in settings_source
    and "SourcePassiveSkillDatabaseMetrics.currentMissingSourceIconStats" in settings_source
    and "fixture: .passiveEvidencePanel" in self_test_source
    and "battle scene snapshot renderer captures the real passive skill source and icon review panels" in self_test_source
    and "--render-battle-scene-fixture passiveEvidencePanel" in battle_scene_audit_source
    and "TBH_PASSIVE_EVIDENCE_PANEL_SCREENSHOT_PATH" in battle_scene_audit_source
    and f"expected_passive_evidence_width = {CURRENT_BASELINE['passive_evidence_panel_render_width_px']}" in battle_scene_audit_source
    and f"expected_passive_evidence_height = {CURRENT_BASELINE['passive_evidence_panel_render_height_px']}" in battle_scene_audit_source
    and "passive_evidence_panel_non_dark_pixels" in battle_scene_audit_source
    and "passive_evidence_panel_pill_pixels" in battle_scene_audit_source
    and "passive_evidence_panel_text_light_pixels" in battle_scene_audit_source
    and "passive_evidence_panel_source_icon_pixels" in battle_scene_audit_source
    and "passive_evidence_panel_missing_icon_pixels" in battle_scene_audit_source
)
support_formula_review_guard = (
    "GroupBox(\"支援成员公式复核\")" in settings_source
    and "SupportFormulaReviewView" in settings_source
    and support_formula_review_rows == CURRENT_BASELINE["support_formula_review_rows"]
    and support_formula_attack_scalar_percent == CURRENT_BASELINE["support_formula_attack_scalar_percent"]
    and "static let attackLevelBonusPerHeroLevel = 2" in settings_source
    and "static let hpLevelBonusPerHeroLevel = 10" in settings_source
    and "static let defenseLevelBonusPerHeroLevel = 1" in settings_source
    and "static let speedLevelBonusPerHeroLevel = 0" in settings_source
    and "支援属性仍使用主角等级缩放" in settings_source
    and "独立支援等级/装备公式待核对" in settings_source
    and "本地公式只用于当前支援战斗脚手架" in settings_source
    and "* 0.35" in party_source
    and "max(heroLevel - 1, 0) * 2" in party_source
    and "heroClass.baseStats.hp + max(heroLevel - 1, 0) * 10" in party_source
    and "settingsSupportFormulaReview()" in self_test_source
    and "settings support formula review mirrors the current PartyMember support formulas" in self_test_source
    and "settings support formula review keeps independent support level and equipment gaps explicit" in self_test_source
)
battle_log_element_label_guard = (
    "var battleLogLabel: String?" in skills_source
    and 'return "物理"' in skills_source
    and 'return "火"' in skills_source
    and 'return "冰"' in skills_source
    and 'return "电"' in skills_source
    and 'return "混沌"' in skills_source
    and "entry.damageElement.battleLogLabel" in battle_view_source
    and "BattleLogElementMarker" in battle_view_source
    and "battle log damage elements expose compact Chinese labels for source metadata" in self_test_source
    and "unnamed source monster attacks keep visible damage-element labels" in self_test_source
)
battle_log_action_text_guard = (
    "enum BattleLogActionText" in battle_view_source
    and 'static let incomingDodgeText = "攻击被闪避"' in battle_view_source
    and 'static let incomingBlockText = "攻击被格挡"' in battle_view_source
    and 'static let criticalLabel = "暴击!"' in battle_view_source
    and "BattleLogActionText.displayText(for: entry)" in battle_view_source
    and "BattleLogActionText.criticalText(for: entry)" in battle_view_source
    and "private var actionText" not in battle_view_source
    and "battle log action text keeps damage, healing and buff rows deterministic" in self_test_source
    and "battle log action text disambiguates incoming dodge, block and critical rows" in self_test_source
    and "BattleLogActionTextTests" in combat_stats_tests_source
    and "ordinaryBattleLogRowsUseDeterministicChineseActions" in combat_stats_tests_source
    and "incomingAvoidanceRowsReadFromThePlayerPerspective" in combat_stats_tests_source
    and '== "造成 88 伤害"' in combat_stats_tests_source
    and '== "恢复 25 生命"' in combat_stats_tests_source
    and '== "触发增益"' in combat_stats_tests_source
    and '== "攻击被闪避"' in combat_stats_tests_source
    and '== "攻击被格挡"' in combat_stats_tests_source
    and '== "暴击!"' in combat_stats_tests_source
)
battle_floating_damage_text_guard = (
    "enum BattleFloatingDamageText" in battle_view_source
    and 'static let criticalPrefix = "暴击"' in battle_view_source
    and 'static let dodgeText = "闪避!"' in battle_view_source
    and 'static let blockText = "格挡!"' in battle_view_source
    and 'static let healFallbackText = "治疗"' in battle_view_source
    and 'static let buffFallbackText = "增益"' in battle_view_source
    and 'Text(BattleFloatingDamageText.displayText(for: entry))' in battle_view_source
    and '"CRIT ' not in battle_view_source
    and "floating battle damage text localizes critical hits as visible Chinese battle feedback" in self_test_source
    and "floating battle text keeps heal, buff, dodge and block feedback explicit in the battle lane" in self_test_source
    and "BattleFloatingDamageTextTests" in combat_stats_tests_source
    and "criticalDamageTextUsesChineseBattleFeedback" in combat_stats_tests_source
    and "utilityAndAvoidanceTextStaysExplicitInBattleLane" in combat_stats_tests_source
    and '== "暴击 123"' in combat_stats_tests_source
    and '== "爆炸弩箭 暴击 456"' in combat_stats_tests_source
    and '== "治疗 +25"' in combat_stats_tests_source
    and '== "闪避!"' in combat_stats_tests_source
    and '== "格挡!"' in combat_stats_tests_source
)
battle_floating_damage_style_guard = (
    "enum BattleFloatingDamageTone" in battle_view_source
    and "struct BattleFloatingDamageStyle: Equatable" in battle_view_source
    and "BattleFloatingDamageStyle.presentation(for: entry)" in battle_view_source
    and "tone: .criticalDamage" in battle_view_source
    and "borderOpacity: 0.92" in battle_view_source
    and "shadowRadius: 6" in battle_view_source
    and "verticalOffset: -2" in battle_view_source
    and "floating battle text style makes critical hits visually stronger than ordinary physical hits" in self_test_source
    and "floating battle text style keeps dodge and block feedback readable in the battle lane" in self_test_source
    and "criticalHitsUseStrongerFloatingTextStyle" in combat_stats_tests_source
    and "utilityAndAvoidanceRowsUseReadableFloatingTextStyle" in combat_stats_tests_source
    and "criticalStyle.fontSize > ordinaryStyle.fontSize" in combat_stats_tests_source
    and "criticalStyle.borderOpacity > ordinaryStyle.borderOpacity" in combat_stats_tests_source
    and "criticalStyle.shadowRadius > ordinaryStyle.shadowRadius" in combat_stats_tests_source
    and "dodgeStyle.fontSize > ordinaryStyle.fontSize" in combat_stats_tests_source
    and "blockStyle.fontSize > ordinaryStyle.fontSize" in combat_stats_tests_source
)
battle_floating_avoidance_snapshot_guard = (
    "case dodgeFloating" in battle_scene_snapshot_source
    and "case blockFloating" in battle_scene_snapshot_source
    and "kind: .dodge" in battle_scene_snapshot_source
    and "kind: .block" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture dodgeFloating" in battle_scene_audit_source
    and "--render-battle-scene-fixture blockFloating" in battle_scene_audit_source
    and "TBH_DODGE_FLOATING_SCREENSHOT_PATH" in battle_scene_audit_source
    and "TBH_BLOCK_FLOATING_SCREENSHOT_PATH" in battle_scene_audit_source
    and "dodge_floating_pixels" in battle_scene_audit_source
    and "block_floating_pixels" in battle_scene_audit_source
    and "battle scene snapshot renderer captures critical and avoidance floating feedback fixtures" in self_test_source
)
battle_floating_critical_snapshot_guard = (
    "case criticalFloating" in battle_scene_snapshot_source
    and "isCrit: true" in battle_scene_snapshot_source
    and "kind: .damage" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture criticalFloating" in battle_scene_audit_source
    and "TBH_CRITICAL_FLOATING_SCREENSHOT_PATH" in battle_scene_audit_source
    and "is_critical_floating_orange" in battle_scene_audit_source
    and "critical_floating_pixels" in battle_scene_audit_source
    and "battle scene snapshot renderer captures critical and avoidance floating feedback fixtures" in self_test_source
)
battle_finish_cue_snapshot_guard = (
    "case victoryFinishScene" in battle_scene_snapshot_source
    and "case defeatFinishScene" in battle_scene_snapshot_source
    and "BattleFinishCueView" in battle_view_source
    and "BattleFinishCue.visible(for: battle.result)" in battle_view_source
    and "activateBattleSceneSnapshotTerminalState(victory: true)" in battle_scene_snapshot_source
    and "activateBattleSceneSnapshotTerminalState(victory: false)" in battle_scene_snapshot_source
    and "--render-battle-scene-fixture victoryFinishScene" in battle_scene_audit_source
    and "--render-battle-scene-fixture defeatFinishScene" in battle_scene_audit_source
    and "TBH_VICTORY_FINISH_SCENE_SCREENSHOT_PATH" in battle_scene_audit_source
    and "TBH_DEFEAT_FINISH_SCENE_SCREENSHOT_PATH" in battle_scene_audit_source
    and "victory_finish_gold_pixels" in battle_scene_audit_source
    and "defeat_finish_red_pixels" in battle_scene_audit_source
    and "battle scene snapshot renderer captures victory and defeat finish-cue fixtures" in self_test_source
)
battle_reward_loot_icon_guard = (
    "struct BattleRewardLootPresentation" in battle_view_source
    and "GameArt.itemIconName(for: item)" in battle_view_source
    and "PixelSprite(" in battle_view_source
    and "victory reward banner uses source-backed loot icon presentation" in self_test_source
    and "source_gear_330003" in self_test_source
)
battle_reward_level_cap_guard = (
    "struct BattleVictoryRewardPresentation" in battle_view_source
    and "rewardDetailText" in battle_view_source
    and "rewardDetailIsWarning" in battle_view_source
    and "encounterClearText" in battle_view_source
    and "清理" in battle_view_source
    and "displayedRewards.encountersCleared > 1" in battle_view_source
    and "xpDetailText" in battle_view_source
    and "xpAdjustmentText" in battle_view_source
    and "xpDetailIsWarning" in battle_view_source
    and "XP实得" in battle_view_source
    and "goldAdjustmentText" in battle_view_source
    and "金币实得" in battle_view_source
    and "levelCapXPStopText" in battle_view_source
    and "已达等级上限" in battle_view_source
    and "升级停止" in battle_view_source
    and "HeroLevelPacing.levelCapStatus(" in battle_view_source
    and "victory reward banner exposes local level-cap XP stop" in self_test_source
    and "victory reward banner exposes local applied XP when pacing changes the source reward" in self_test_source
    and "victory reward banner exposes multi-encounter reward context and local applied gold" in self_test_source
    and "victory reward banner exposes multi-encounter context even when reward values are unchanged" in self_test_source
    and "victory reward banner hides reward adjustment detail when displayed rewards are unchanged" in self_test_source
)
battle_reward_banner_snapshot_guard = (
    "case victoryRewardBanner" in battle_scene_snapshot_source
    and "case victoryLevelCapBanner" in battle_scene_snapshot_source
    and "BattleVictoryRewardBannerSnapshotView" in battle_scene_snapshot_source
    and "BattleResultBanner(" in battle_scene_snapshot_source
    and "snapshot-victory-scepter" in battle_scene_snapshot_source
    and "HeroLevelPacing.maxHeroLevel" in battle_scene_snapshot_source
    and "let bannerFixtures: [BattleSceneSnapshot.Fixture]" in self_test_source
    and ".victoryRewardBanner" in self_test_source
    and ".victoryLevelCapBanner" in self_test_source
    and "battle scene snapshot renderer captures victory reward and level-cap banner fixtures" in self_test_source
    and "--render-battle-scene-fixture victoryRewardBanner" in battle_scene_audit_source
    and "--render-battle-scene-fixture victoryLevelCapBanner" in battle_scene_audit_source
    and "TBH_VICTORY_REWARD_BANNER_SCREENSHOT_PATH" in battle_scene_audit_source
    and "TBH_VICTORY_LEVEL_CAP_BANNER_SCREENSHOT_PATH" in battle_scene_audit_source
    and "victory_reward_banner_non_dark_pixels" in battle_scene_audit_source
    and "victory_reward_banner_rarity_pixels" in battle_scene_audit_source
    and "victory_reward_banner_icon_pixels" in battle_scene_audit_source
    and "victory_level_cap_banner_orange_pixels" in battle_scene_audit_source
)
if not battle_scene_local_audit_guard:
    issues.append("Local battle-scene audit must gate the current subtle-side-margin platform and stage pill")
if not official_steam_battle_motion_guard:
    issues.append("Official Steam battle-scene audit must keep frame-to-frame motion sampling and thresholds")
if not battle_scene_self_test_guard:
    issues.append("SelfTest must guard the current subtle-side-margin battle scene geometry")
if not source_range_visual_guard:
    issues.append("Battle logs and trajectory cues must preserve checked source range as a visual scaling guard")
if not battle_log_self_test_guard:
    issues.append("SelfTest must guard visible battle log capacity and panel height")
if not battle_log_panel_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure the real BattleLogPanel")
if not battle_tab_layout_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure the full battle tab layout with the bottom menu bar")
if not inventory_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the inventory panel with source-backed icons, comparison preview and worse-equipment controls")
if not character_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the character panel with hero art, party unlocks and active skill loadout controls")
if not chest_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the chest controls with batch opening, auto-open status and source-backed chest icons")
if not original_fidelity_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the original-fidelity boundary panel with coverage, partial and gap states")
if not rune_evidence_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the real Rune evidence and cost review panels")
if not skill_evidence_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the real source skill and pending-skill review panels")
if not passive_evidence_panel_snapshot_guard:
    issues.append("Screenshot audit must render and measure the real passive skill source and source-icon review panel")
if not battle_log_element_label_guard:
    issues.append("Battle log must expose compact damage-element labels for source-backed unnamed attacks")
if not battle_log_action_text_guard:
    issues.append("Battle log action text must keep deterministic Chinese action text and disambiguate incoming avoidance rows")
if not battle_floating_damage_text_guard:
    issues.append("Floating battle damage text must keep localized Chinese critical-hit feedback")
if not battle_floating_damage_style_guard:
    issues.append("Floating battle text style must make critical, dodge and block feedback visibly stronger")
if not battle_floating_avoidance_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure dodge/block floating feedback")
if not battle_floating_critical_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure critical-hit floating feedback")
if not battle_finish_cue_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure victory/defeat finish cues")
if not battle_reward_loot_icon_guard:
    issues.append("Battle result banner must render dropped loot through source-backed item icons")
if not battle_reward_level_cap_guard:
    issues.append("Battle result banner must explain local level-cap XP stops")
if not battle_reward_banner_snapshot_guard:
    issues.append("Battle-scene screenshot audit must render and measure victory reward and level-cap banners")
if not menu_bar_bottom_tab_guard:
    issues.append("MenuBarPopover must keep the enlarged battle content above the bottom tab bar")

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
    ("battle_hero_sprite_resources", len(battle_hero_sprite_names), ORIGINAL["hero_classes"], CURRENT_BASELINE["battle_hero_sprite_resources"], "class-specific transparent battle hero sprite mappings"),
    ("battle_hero_source_sprite_resources", len(battle_hero_source_sprite_names), ORIGINAL["hero_classes"], CURRENT_BASELINE["battle_hero_source_sprite_resources"], "official hero sprites backing battle hero identity checks"),
    ("source_skill_catalog_entries", len(source_skills), ORIGINAL["active_skills"], CURRENT_BASELINE["source_skill_catalog"], "checked active/base/monster source rows"),
    ("source_skill_review_rows", len(source_skills) if source_skill_database_view else 0, ORIGINAL["active_skills"], CURRENT_BASELINE["source_skill_review_rows"], "settings source skill review table rows"),
    ("source_skill_damage_buckets", len(source_skill_damage_counts) if source_skill_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_damage_buckets"], "settings source skill damage buckets"),
    ("source_skill_physical_damage", source_skill_physical_damage_count if source_skill_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_physical_damage"], "source rows with Physical damage"),
    ("source_skill_non_physical_damage_runtime", source_skill_non_physical_damage_runtime_count if source_skill_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_non_physical_damage_runtime"], "non-physical source rows already runtime-mapped"),
    ("source_skill_chaos_damage_runtime", source_skill_chaos_damage_runtime_count if source_skill_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_chaos_damage_runtime"], "Chaos source rows already runtime-mapped"),
    ("source_skill_most_common_damage_count", source_skill_most_common_damage_count if source_skill_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_most_common_damage_count"], "most common source damage row count"),
    ("source_skill_activation_damage_pairs", source_skill_activation_damage_pair_count if source_skill_activation_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_activation_damage_pairs"], "settings source skill activation-damage cross-tab buckets"),
    ("source_skill_activation_damage_runtime_pairs", source_skill_activation_damage_runtime_pair_count if source_skill_activation_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_activation_damage_runtime_pairs"], "cross-tab buckets already runtime-mapped"),
    ("source_skill_baseattack_physical_pending", source_skill_baseattack_physical_pending_count if source_skill_activation_damage_review_view else 0, None, CURRENT_BASELINE["source_skill_baseattack_physical_pending"], "pending BASEATTACK Physical source rows"),
    ("source_skill_cooldown_chaos_runtime", source_skill_cooldown_chaos_runtime_count if source_skill_activation_damage_review_view else -1, None, CURRENT_BASELINE["source_skill_cooldown_chaos_runtime"], "COOLDOWN Chaos source rows already runtime-mapped"),
    ("source_skill_cooldown_chaos_pending", source_skill_cooldown_chaos_pending_count if source_skill_activation_damage_review_view else -1, None, CURRENT_BASELINE["source_skill_cooldown_chaos_pending"], "pending COOLDOWN Chaos source rows"),
    ("source_skill_cooldown_chaos_value_rows", source_skill_cooldown_chaos_value_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["source_skill_cooldown_chaos_value_rows"], "checked pending COOLDOWN Chaos value fields"),
    ("pending_source_skill_cooldown_chaos_page_rows", source_skill_cooldown_chaos_page_row_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["pending_source_skill_cooldown_chaos_page_rows"], "settings pending COOLDOWN/Chaos page evidence rows"),
    ("pending_source_skill_cooldown_chaos_locale_pages", source_skill_cooldown_chaos_page_locale_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["pending_source_skill_cooldown_chaos_locale_pages"], "reviewed zh/en COOLDOWN/Chaos pages still lacking runtime semantics"),
    ("pending_source_skill_cooldown_chaos_empty_delivery", source_skill_cooldown_chaos_empty_delivery_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["pending_source_skill_cooldown_chaos_empty_delivery"], "pending COOLDOWN/Chaos page rows with empty delivery"),
    ("pending_source_skill_cooldown_chaos_unnamed", source_skill_cooldown_chaos_unnamed_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["pending_source_skill_cooldown_chaos_unnamed"], "pending COOLDOWN/Chaos page rows still named Skill ID"),
    ("source_skill_activation_delivery_pairs", source_skill_activation_delivery_pair_count if source_skill_activation_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_activation_delivery_pairs"], "settings source skill activation-delivery cross-tab buckets"),
    ("source_skill_activation_delivery_runtime_pairs", source_skill_activation_delivery_runtime_pair_count if source_skill_activation_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_activation_delivery_runtime_pairs"], "activation-delivery buckets already runtime-mapped"),
    ("source_skill_baseattack_empty_delivery_pending", source_skill_baseattack_empty_delivery_pending_count if source_skill_activation_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_baseattack_empty_delivery_pending"], "pending BASEATTACK empty-delivery source rows"),
    ("source_skill_attackcount_empty_delivery_runtime", source_skill_attackcount_empty_delivery_runtime_count if source_skill_activation_delivery_review_view else -1, None, CURRENT_BASELINE["source_skill_attackcount_empty_delivery_runtime"], "BASEATTACK_COUNT empty-delivery source rows already runtime-mapped"),
    ("source_skill_damage_delivery_pairs", source_skill_damage_delivery_pair_count if source_skill_damage_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_damage_delivery_pairs"], "settings source skill damage-delivery cross-tab buckets"),
    ("source_skill_damage_delivery_runtime_pairs", source_skill_damage_delivery_runtime_pair_count if source_skill_damage_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_damage_delivery_runtime_pairs"], "damage-delivery buckets already runtime-mapped"),
    ("source_skill_empty_delivery_runtime", source_skill_empty_delivery_runtime_count if source_skill_damage_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_empty_delivery_runtime"], "empty-delivery source rows already runtime-mapped"),
    ("source_skill_physical_empty_delivery_pending", source_skill_physical_empty_delivery_pending_count if source_skill_damage_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_physical_empty_delivery_pending"], "pending Physical empty-delivery source rows"),
    ("source_skill_chaos_empty_delivery_pending", source_skill_chaos_empty_delivery_pending_count if source_skill_damage_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_chaos_empty_delivery_pending"], "pending Chaos empty-delivery source rows"),
    ("source_skill_delivery_buckets", len(source_skill_delivery_counts) if source_skill_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_delivery_buckets"], "settings source skill delivery buckets"),
    ("source_skill_empty_delivery", source_skill_empty_delivery_count if source_skill_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_empty_delivery"], "source rows with empty delivery"),
    ("source_skill_non_empty_delivery_runtime", source_skill_non_empty_delivery_runtime_count if source_skill_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_non_empty_delivery_runtime"], "non-empty delivery rows already runtime-mapped"),
    ("source_skill_most_common_delivery_count", source_skill_most_common_delivery_count if source_skill_delivery_review_view else 0, None, CURRENT_BASELINE["source_skill_most_common_delivery_count"], "most common source delivery row count"),
    ("source_skill_range_buckets", len(source_skill_range_counts) if source_skill_range_review_view else 0, None, CURRENT_BASELINE["source_skill_range_buckets"], "settings source skill range buckets"),
    ("source_skill_min_range", source_skill_min_range if source_skill_range_review_view else 0, None, CURRENT_BASELINE["source_skill_min_range"], "minimum checked source range value"),
    ("source_skill_max_range", source_skill_max_range if source_skill_range_review_view else 0, None, CURRENT_BASELINE["source_skill_max_range"], "maximum checked source range value"),
    ("source_skill_most_common_range_count", source_skill_most_common_range_count if source_skill_range_review_view else 0, None, CURRENT_BASELINE["source_skill_most_common_range_count"], "most common source range row count"),
    ("runtime_named_hero_active_skills", len(skills), CURRENT_BASELINE["active_skills"], CURRENT_BASELINE["active_skills"], "runtime-modeled named hero active skills"),
    ("runtime_hero_base_attack_skills", len(hero_base_attack_skill_ids), CURRENT_BASELINE["hero_base_attack_skills"], CURRENT_BASELINE["hero_base_attack_skills"], "source-backed hero base attack rows with runtime combat metadata"),
    ("runtime_hero_skill_source_rows", len(runtime_hero_skill_source_ids), ORIGINAL["active_skills"], CURRENT_BASELINE["runtime_hero_skill_source_rows"], "runtime hero named skills plus source-backed base attacks"),
    ("runtime_monster_attack_skills", len(runtime_monster_attack_skill_ids), CURRENT_BASELINE["runtime_monster_attack_skills"], CURRENT_BASELINE["runtime_monster_attack_skills"], "checked source-backed monster attack rows with runtime metadata"),
    ("runtime_modeled_source_skills", len(runtime_modeled_source_ids), ORIGINAL["active_skills"], CURRENT_BASELINE["runtime_modeled_source_skills"], "runtime hero source skills plus checked monster attacks"),
    ("active_skill_value_tables", len(skills_with_full_tables), len(skills), CURRENT_BASELINE["modeled_skill_level_tables"], "10-level value tables for modeled skills"),
    ("local_skill_runtime_coverage_source", len(source_skills) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_source"], "settings local skill runtime coverage source rows"),
    ("local_skill_runtime_coverage_modeled", len(runtime_modeled_source_ids) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_modeled"], "settings local skill runtime coverage modeled rows"),
    ("local_skill_runtime_coverage_pending", len(source_skills) - len(runtime_modeled_source_ids) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_pending"], "settings local skill runtime coverage pending rows"),
    ("local_skill_runtime_coverage_rows", len(source_skill_activations) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_rows"], "settings local skill runtime coverage activation rows"),
    ("local_skill_runtime_coverage_hero_named", len(skills) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_hero_named"], "settings local skill runtime coverage named hero skills"),
    ("local_skill_runtime_coverage_hero_base", len(hero_base_attack_skill_ids) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_hero_base"], "settings local skill runtime coverage hero base attacks"),
    ("local_skill_runtime_coverage_monster", len(runtime_monster_attack_skill_ids) if local_skill_runtime_coverage_view else 0, None, CURRENT_BASELINE["local_skill_runtime_coverage_monster"], "settings local skill runtime coverage monster attacks"),
    ("pending_source_skill_review_rows", len(pending_source_skills) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_review_rows"], "settings pending source skill review rows"),
    ("pending_source_skill_empty_delivery", pending_source_skill_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_empty_delivery"], "pending source rows with empty delivery"),
    ("pending_source_skill_activation_buckets", len(pending_source_skill_activation_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_activation_buckets"], "pending source activation buckets"),
    ("pending_source_skill_damage_buckets", len(pending_source_skill_damage_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_damage_buckets"], "pending source damage buckets"),
    ("pending_source_skill_prefix_buckets", len(pending_source_skill_prefix_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_prefix_buckets"], "pending source ID prefix buckets"),
    ("pending_source_skill_responsibility_buckets", pending_source_skill_responsibility_bucket_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_responsibility_buckets"], "pending source responsibility boundary rows"),
    ("pending_source_skill_six_digit_unnamed", pending_source_skill_six_digit_unnamed_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_six_digit_unnamed"], "data-only six-digit unnamed source skill rows"),
    ("pending_source_skill_damage_candidate_manifest", pending_source_skill_damage_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_damage_candidate_manifest"], "exact pending damage source ID manifest"),
    ("pending_source_skill_physical_damage_candidate_manifest", pending_source_skill_physical_damage_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_physical_damage_candidate_manifest"], "exact pending Physical damage source ID manifest"),
    ("pending_source_skill_elemental_damage_candidate_manifest", pending_source_skill_elemental_damage_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_elemental_damage_candidate_manifest"], "exact pending elemental damage source ID manifest"),
    ("pending_source_skill_fire_damage_candidate_manifest", pending_source_skill_fire_damage_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_fire_damage_candidate_manifest"], "exact pending Fire damage source ID manifest"),
    ("pending_source_skill_cold_damage_candidate_manifest", pending_source_skill_cold_damage_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_cold_damage_candidate_manifest"], "exact pending Cold damage source ID manifest"),
    ("pending_source_skill_chaos_damage_candidate_manifest", pending_source_skill_chaos_damage_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_chaos_damage_candidate_manifest"], "exact pending Chaos damage source ID manifest"),
    ("pending_source_skill_base_attack_candidates", pending_source_skill_base_attack_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_base_attack_candidates"], "data-only base attack candidate rows"),
    ("pending_source_skill_base_attack_candidate_manifest", sum(len(ids) for ids in pending_source_skill_base_attack_candidate_ids_by_prefix.values()) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_base_attack_candidate_manifest"], "exact pending BASEATTACK source ID manifest"),
    ("pending_source_skill_triggered_candidates", pending_source_skill_triggered_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_triggered_candidates"], "data-only triggered/cooldown candidate rows"),
    ("pending_source_skill_triggered_candidate_manifest", len(pending_source_skill_triggered_candidate_ids) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_triggered_candidate_manifest"], "exact pending triggered/cooldown source ID manifest"),
    ("pending_source_skill_triggered_value_rows", pending_source_skill_triggered_value_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_triggered_value_rows"], "checked pending triggered/cooldown value fields"),
    ("pending_source_skill_valued_candidates", pending_source_skill_valued_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_valued_candidates"], "pending source rows with checked value fields"),
    ("pending_source_skill_valued_empty_delivery", pending_source_skill_valued_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_valued_empty_delivery"], "value-checked pending source rows still missing delivery"),
    ("pending_source_skill_valued_unnamed", pending_source_skill_valued_unnamed_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_valued_unnamed"], "value-checked pending source rows still unnamed"),
    ("pending_source_skill_catalog_only", pending_source_skill_catalog_only_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_catalog_only"], "pending source rows with catalog metadata only"),
    ("pending_source_skill_value_range_only", pending_source_skill_value_range_only_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_value_range_only"], "pending source rows with checked value/range but still below minimum runtime evidence"),
    ("pending_source_skill_minimum_evidence", pending_source_skill_minimum_evidence_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_minimum_evidence"], "pending source rows meeting minimum runtime evidence gate"),
    ("pending_source_skill_runtime_proof_rows", pending_source_skill_runtime_proof_row_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_rows"], "settings pending source skill runtime proof matrix rows"),
    ("pending_source_skill_runtime_proof_coverage", pending_source_skill_runtime_proof_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_coverage"], "pending source skills covered by runtime proof matrix"),
    ("pending_source_skill_runtime_proof_catalog", pending_source_skill_runtime_proof_catalog_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_catalog"], "pending source skills with source catalog row proof"),
    ("pending_source_skill_runtime_proof_value_range", pending_source_skill_runtime_proof_value_range_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_value_range"], "pending source skills with checked value/range page proof"),
    ("pending_source_skill_runtime_proof_minimum_ready", pending_source_skill_runtime_proof_minimum_ready_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_minimum_ready"], "pending source skills ready for minimum runtime evidence gate"),
    ("pending_source_skill_runtime_proof_name_missing", pending_source_skill_runtime_proof_name_missing_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_name_missing"], "pending source skills still missing localized name/description proof"),
    ("pending_source_skill_runtime_proof_delivery_missing", pending_source_skill_runtime_proof_delivery_missing_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_delivery_missing"], "pending source skills still missing delivery/hit-shape proof"),
    ("pending_source_skill_runtime_proof_ownership_formula_missing", pending_source_skill_runtime_proof_ownership_formula_missing_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_ownership_formula_missing"], "pending source skills still missing ownership/target/formula proof"),
    ("pending_source_skill_runtime_proof_animation_missing", pending_source_skill_runtime_proof_animation_missing_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_animation_missing"], "pending source skills still missing original action-frame/VFX proof"),
    ("pending_source_skill_runtime_proof_sfx_missing", pending_source_skill_runtime_proof_sfx_missing_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_runtime_proof_sfx_missing"], "pending source skills still missing isolated original SFX proof"),
    ("pending_source_skill_runtime_gates", pending_source_skill_runtime_gate_count, None, CURRENT_BASELINE["pending_source_skill_runtime_gates"], "settings pending source skill runtime evidence gates"),
    ("pending_source_skill_evidence_queues", pending_source_skill_evidence_queue_count, None, CURRENT_BASELINE["pending_source_skill_evidence_queues"], "settings pending source skill evidence queue rows"),
    ("pending_source_skill_evidence_queue_coverage", pending_source_skill_evidence_queue_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_evidence_queue_coverage"], "pending source skills covered by mutually exclusive evidence queues"),
    ("pending_source_skill_activation_damage_queues", pending_source_skill_activation_damage_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_activation_damage_queues"], "settings pending source skill activation-damage evidence queues"),
    ("pending_source_skill_activation_damage_queue_coverage", pending_source_skill_activation_damage_queue_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_activation_damage_queue_coverage"], "pending source skills covered by activation-damage evidence queues"),
    ("pending_source_skill_activation_damage_value_coverage", pending_source_skill_activation_damage_value_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_activation_damage_value_coverage"], "value-checked pending rows covered by activation-damage evidence queues"),
    ("pending_source_skill_activation_damage_empty_delivery", pending_source_skill_activation_damage_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_activation_damage_empty_delivery"], "pending activation-damage queue rows still missing delivery"),
    ("pending_source_skill_range_evidence_queues", pending_source_skill_range_evidence_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_range_evidence_queues"], "settings pending source skill range evidence queues"),
    ("pending_source_skill_range_evidence_queue_coverage", pending_source_skill_range_evidence_queue_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_range_evidence_queue_coverage"], "pending source skills covered by source range evidence queues"),
    ("pending_source_skill_range_evidence_value_coverage", pending_source_skill_range_evidence_value_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_range_evidence_value_coverage"], "value-checked pending rows covered by source range evidence queues"),
    ("pending_source_skill_range_evidence_empty_delivery", pending_source_skill_range_evidence_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_range_evidence_empty_delivery"], "pending range evidence queue rows still missing delivery"),
    ("pending_source_skill_prefix_evidence_queues", pending_source_skill_prefix_evidence_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_prefix_evidence_queues"], "settings pending source skill ID-prefix evidence queues"),
    ("pending_source_skill_prefix_evidence_queue_coverage", pending_source_skill_prefix_evidence_queue_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_prefix_evidence_queue_coverage"], "pending source skills covered by source ID-prefix evidence queues"),
    ("pending_source_skill_prefix_evidence_value_coverage", pending_source_skill_prefix_evidence_value_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_prefix_evidence_value_coverage"], "value-checked pending rows covered by source ID-prefix evidence queues"),
    ("pending_source_skill_prefix_evidence_empty_delivery", pending_source_skill_prefix_evidence_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_prefix_evidence_empty_delivery"], "pending prefix evidence queue rows still missing delivery"),
    ("pending_source_skill_value_evidence_queues", pending_source_skill_value_evidence_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_value_evidence_queues"], "settings pending source skill value evidence queues"),
    ("pending_source_skill_value_evidence_queue_coverage", pending_source_skill_value_evidence_queue_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_value_evidence_queue_coverage"], "value-checked pending rows covered by source value evidence queues"),
    ("pending_source_skill_value_evidence_empty_delivery", pending_source_skill_value_evidence_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_value_evidence_empty_delivery"], "pending value evidence queue rows still missing delivery"),
    ("pending_source_skill_visual_priority_queues", pending_source_skill_visual_priority_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_queues"], "settings pending source skill visual-priority review queues"),
    ("pending_source_skill_visual_priority_entries", pending_source_skill_visual_priority_entry_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_entries"], "overlapping pending source skill visual-priority entries"),
    ("pending_source_skill_visual_priority_elemental", pending_source_skill_visual_priority_elemental_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_elemental"], "pending elemental-damage candidates in visual-priority review"),
    ("pending_source_skill_visual_priority_cooldown_chaos", pending_source_skill_visual_priority_cooldown_chaos_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_cooldown_chaos"], "pending COOLDOWN Chaos candidates in visual-priority review"),
    ("pending_source_skill_visual_priority_unmapped_monster", pending_source_skill_visual_priority_unmapped_monster_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unmapped_monster"], "unmapped-monster same-prefix candidates in visual-priority review"),
    ("pending_source_skill_visual_priority_highest_value", pending_source_skill_visual_priority_highest_value_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_highest_value"], "highest-value pending pages in visual-priority review"),
    ("pending_source_skill_visual_priority_unique", pending_source_skill_visual_priority_unique_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unique"], "unique pending source skills covered by overlapping visual-priority queues"),
    ("pending_source_skill_visual_priority_overlap", pending_source_skill_visual_priority_overlap_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["pending_source_skill_visual_priority_overlap"], "overlapping visual-priority queue entries above unique coverage"),
    ("pending_source_skill_visual_priority_unqueued", pending_source_skill_visual_priority_unqueued_count if pending_source_skill_review_view else -1, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued"], "pending source skills not covered by visual-priority queues"),
    ("pending_source_skill_visual_review_total_queues", pending_source_skill_visual_review_total_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_review_total_queues"], "priority plus backlog visual-review queues"),
    ("pending_source_skill_visual_review_total_coverage", pending_source_skill_visual_review_total_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_review_total_coverage"], "pending source skills covered by priority or backlog visual-review queues"),
    ("pending_source_skill_visual_priority_unqueued_queues", pending_source_skill_visual_priority_unqueued_queue_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_queues"], "explicit review queues for pending skills not covered by visual-priority queues"),
    ("pending_source_skill_visual_priority_unqueued_queue_coverage", pending_source_skill_visual_priority_unqueued_queue_coverage_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_queue_coverage"], "unqueued visual-priority diff covered by explicit review queues"),
    ("pending_source_skill_visual_priority_unqueued_value", pending_source_skill_visual_priority_unqueued_value_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_value"], "unqueued visual-priority value/range pages"),
    ("pending_source_skill_visual_priority_unqueued_empty_delivery", pending_source_skill_visual_priority_unqueued_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_empty_delivery"], "unqueued visual-priority rows still missing delivery"),
    ("pending_source_skill_visual_priority_unqueued_activation_buckets", len(pending_source_skill_visual_priority_unqueued_activation_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_activation_buckets"], "activation buckets inside the unqueued visual-priority diff"),
    ("pending_source_skill_visual_priority_unqueued_damage_buckets", len(pending_source_skill_visual_priority_unqueued_damage_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_damage_buckets"], "damage buckets inside the unqueued visual-priority diff"),
    ("pending_source_skill_visual_priority_unqueued_range_buckets", len(pending_source_skill_visual_priority_unqueued_range_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_visual_priority_unqueued_range_buckets"], "source range buckets inside the unqueued visual-priority diff"),
    ("pending_source_skill_value_range_queue", len(pending_source_skill_value_range_queue_ids) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_value_range_queue"], "pending value/range detail page evidence queue"),
    ("pending_source_skill_nonphysical_baseattack_queue", len(pending_source_skill_nonphysical_baseattack_queue_ids) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_nonphysical_baseattack_queue"], "pending non-Physical BASEATTACK catalog evidence queue"),
    ("pending_source_skill_physical_baseattack_queue", len(pending_source_skill_physical_baseattack_queue_ids) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_physical_baseattack_queue"], "pending Physical BASEATTACK catalog evidence queue"),
    ("pending_source_skill_value_evidence_rows", pending_source_skill_value_evidence_row_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_value_evidence_rows"], "per-skill rows for value-checked pending source skills"),
    ("pending_source_skill_base_attack_evidence_rows", pending_source_skill_base_attack_evidence_row_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_base_attack_evidence_rows"], "per-skill rows for catalog-only BASEATTACK pending source skills"),
    ("pending_source_skill_nonphysical_baseattack_evidence_rows", pending_source_skill_nonphysical_baseattack_evidence_row_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_nonphysical_baseattack_evidence_rows"], "per-skill rows for non-Physical BASEATTACK catalog pending source skills"),
    ("pending_source_skill_physical_baseattack_evidence_rows", pending_source_skill_physical_baseattack_evidence_row_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_physical_baseattack_evidence_rows"], "per-skill rows for Physical BASEATTACK catalog pending source skills"),
    ("pending_source_skill_unmapped_monster_candidates", pending_source_skill_unmapped_monster_candidate_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_unmapped_monster_candidates"], "review-only same-prefix pending source skill candidates for unmapped source monsters"),
    ("pending_source_skill_unmapped_monster_candidate_empty_delivery", pending_source_skill_unmapped_monster_candidate_empty_delivery_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_unmapped_monster_candidate_empty_delivery"], "unmapped-monster same-prefix pending candidates still missing delivery"),
    ("pending_source_skill_value_detail_pages", pending_source_skill_value_detail_page_count if pending_source_skill_review_view else 0, CURRENT_BASELINE["pending_source_skill_value_detail_pages"], CURRENT_BASELINE["pending_source_skill_value_detail_pages"], "reviewed value-checked pending detail pages still lacking runtime semantics"),
    ("pending_source_skill_value_detail_locale_pages", pending_source_skill_value_detail_locale_page_count if pending_source_skill_review_view else 0, CURRENT_BASELINE["pending_source_skill_value_detail_locale_pages"], CURRENT_BASELINE["pending_source_skill_value_detail_locale_pages"], "reviewed zh/en value detail pages still lacking runtime semantics"),
    ("pending_source_skill_highest_detail_pages", pending_source_skill_highest_detail_page_count if pending_source_skill_review_view else 0, CURRENT_BASELINE["pending_source_skill_highest_detail_pages"], CURRENT_BASELINE["pending_source_skill_highest_detail_pages"], "reviewed highest-value pending detail pages still lacking runtime semantics"),
    ("pending_source_skill_highest_detail_locale_pages", pending_source_skill_highest_detail_locale_page_count if pending_source_skill_review_view else 0, CURRENT_BASELINE["pending_source_skill_highest_detail_locale_pages"], CURRENT_BASELINE["pending_source_skill_highest_detail_locale_pages"], "reviewed zh/en highest-value pending detail pages still lacking runtime semantics"),
    ("pending_source_skill_checked_monster_attacks", len(runtime_monster_attack_skill_ids) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_checked_monster_attacks"], "checked monster attack rows already wired to runtime metadata"),
    ("pending_source_skill_range_buckets", len(pending_source_skill_range_counts) if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_range_buckets"], "pending source range field buckets"),
    ("pending_source_skill_most_common_range", pending_source_skill_most_common_range if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_most_common_range"], "most common pending source range field"),
    ("pending_source_skill_most_common_range_count", pending_source_skill_most_common_range_count if pending_source_skill_review_view else 0, None, CURRENT_BASELINE["pending_source_skill_most_common_range_count"], "most common pending source range row count"),
    ("modeled_active_skill_value_review_rows", len(skills_with_full_tables) if modeled_active_skill_value_review_view else 0, len(skills), CURRENT_BASELINE["modeled_active_skill_value_review_rows"], "settings modeled active skill value review rows"),
    ("runtime_tick_interval_tenths", runtime_tick_interval_tenths, None, CURRENT_BASELINE["runtime_tick_interval_tenths"], "local runtime loop interval in tenths of a second"),
    ("combat_simulation_step_centiseconds", combat_simulation_step_centiseconds, None, CURRENT_BASELINE["combat_simulation_step_centiseconds"], "local battle simulation substep in centiseconds"),
    ("combat_delta_multiplier_percent", combat_delta_multiplier_percent, None, CURRENT_BASELINE["combat_delta_multiplier_percent"], "local wall-clock to simulated-combat delta percentage"),
    ("runtime_xp_multiplier_percent", runtime_xp_multiplier_percent, None, CURRENT_BASELINE["runtime_xp_multiplier_percent"], "local applied XP percentage before level-up"),
    ("runtime_stage_level_buffer", stage_level_buffer, None, CURRENT_BASELINE["stage_level_buffer"], "local stage-level cap headroom"),
    ("runtime_min_attack_interval_tenths", minimum_attack_interval_tenths, None, CURRENT_BASELINE["minimum_attack_interval_tenths"], "local minimum attack interval in tenths of a second"),
    ("runtime_min_hasted_attack_interval_centiseconds", minimum_hasted_attack_interval_centiseconds, None, CURRENT_BASELINE["minimum_hasted_attack_interval_centiseconds"], "local hasted attack minimum interval in centiseconds"),
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
    ("rune_dependency_edges", len(rune_dependency_edges), None, CURRENT_BASELINE["rune_dependency_edges"], "modeled local prerequisites"),
    ("rune_required_hero_level", rune_required_hero_level, None, CURRENT_BASELINE["rune_required_hero_level"], "checked local Rune Tree level gate"),
    ("rune_party_slot_verified_gold_total", rune_party_slot_verified_gold_total, None, CURRENT_BASELINE["rune_party_slot_verified_gold_total"], "verified Rune of Command gold total for slots 2 and 3"),
    ("rune_direct_party_slot_3_gold", rune_direct_party_slot_3_gold, None, CURRENT_BASELINE["rune_direct_party_slot_3_gold"], "direct unlock path for party slots 2 and 3"),
    ("rune_active_skill_slot_count", rune_active_skill_slot_count, None, CURRENT_BASELINE["rune_active_skill_slot_count"], "Rune of Awakening active-skill slot scaffold"),
    ("rune_all_hero_attack_damage_bonus", rune_all_hero_attack_damage_bonus, None, CURRENT_BASELINE["rune_all_hero_attack_damage_bonus"], "runtime Rune of War all-hero attack scaffold"),
    ("rune_all_hero_attack_damage_percent_boost_percent", rune_all_hero_attack_damage_percent_boost_percent, None, CURRENT_BASELINE["rune_all_hero_attack_damage_percent_boost_percent"], "runtime Rune of War all-hero percent attack scaffold"),
    ("rune_all_hero_armor_bonus", rune_all_hero_armor_bonus, None, CURRENT_BASELINE["rune_all_hero_armor_bonus"], "runtime Rune of the Shield all-hero armor scaffold"),
    ("rune_all_hero_armor_percent_boost_percent", rune_all_hero_armor_percent_boost_percent, None, CURRENT_BASELINE["rune_all_hero_armor_percent_boost_percent"], "runtime Rune of the Shield all-hero percent armor scaffold"),
    ("rune_all_hero_move_speed_bonus", rune_all_hero_move_speed_bonus, None, CURRENT_BASELINE["rune_all_hero_move_speed_bonus"], "runtime Rune of the Gale all-hero move-speed scaffold"),
    ("rune_all_hero_attack_speed_boost_percent", rune_all_hero_attack_speed_boost_percent, None, CURRENT_BASELINE["rune_all_hero_attack_speed_boost_percent"], "runtime Rune of Frenzy all-hero attack-speed scaffold"),
    ("rune_combat_reward_runtime_nodes", rune_combat_reward_runtime_nodes, None, CURRENT_BASELINE["rune_combat_reward_runtime_nodes"], "runtime Wealth/Growth combat reward rows"),
    ("rune_combat_reward_boost_percent", rune_combat_reward_boost_percent, None, CURRENT_BASELINE["rune_combat_reward_boost_percent"], "first checked combat gold/XP reward scaffold"),
    ("rune_cube_reward_runtime_nodes", rune_cube_reward_runtime_nodes, None, CURRENT_BASELINE["rune_cube_reward_runtime_nodes"], "runtime Forging/Alchemy Cube reward rows"),
    ("rune_cube_reward_boost_percent", rune_cube_reward_boost_percent, None, CURRENT_BASELINE["rune_cube_reward_boost_percent"], "first checked Cube XP/alchemy-gold reward scaffold"),
    ("rune_inventory_expansion_runtime_nodes", rune_inventory_expansion_runtime_nodes, None, CURRENT_BASELINE["rune_inventory_expansion_runtime_nodes"], "runtime Rune of Expansion MaxInventorySlot rows"),
    ("rune_inventory_slot_bonus", rune_inventory_slot_bonus, None, CURRENT_BASELINE["rune_inventory_slot_bonus"], "first Rune of Expansion inventory-capacity scaffold"),
    ("rune_stash_page_runtime_nodes", rune_stash_page_runtime_nodes, None, CURRENT_BASELINE["rune_stash_page_runtime_nodes"], "runtime Rune of Storage stash-page rows"),
    ("rune_stash_page_slot_bonus", rune_stash_page_slot_bonus, None, CURRENT_BASELINE["rune_stash_page_slot_bonus"], "first Rune of Storage stash-page capacity scaffold"),
    ("rune_stage_clear_target_reduction", rune_stage_clear_target_reduction, None, CURRENT_BASELINE["rune_stage_clear_target_reduction"], "first Rune of Brevity clear-target scaffold"),
    ("rune_offline_boost_percent", rune_offline_boost_percent, None, CURRENT_BASELINE["rune_offline_boost_percent"], "first checked offline gold/XP boost percent"),
    ("rune_unverified_cost_nodes", rune_unverified_cost_nodes, None, CURRENT_BASELINE["rune_unverified_cost_nodes"], "runtime Rune nodes still marked cost-unverified"),
    ("rune_approximate_cost_nodes", rune_approximate_cost_nodes, None, CURRENT_BASELINE["rune_approximate_cost_nodes"], "runtime Rune nodes with approximate cost only"),
    ("local_rune_cost_review_rows", len(rune_nodes) if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_rows"], "settings local Rune cost review rows"),
    ("local_rune_cost_review_verified", len(rune_nodes) - rune_unverified_cost_nodes if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_verified"], "settings local Rune verified cost rows"),
    ("local_rune_cost_review_approximate", rune_approximate_cost_nodes if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_approximate"], "settings local Rune approximate cost rows"),
    ("local_rune_cost_review_approximate_source", rune_approximate_cost_source_nodes if local_rune_cost_review_view else 0, CURRENT_BASELINE["local_rune_cost_review_approximate_source"], CURRENT_BASELINE["local_rune_cost_review_approximate_source"], "settings local Rune official approximate-cost evidence rows"),
    ("local_rune_cost_review_approximate_evidence_rows", local_rune_cost_approximate_evidence_row_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_approximate_evidence_rows"], "settings Rune approximate-cost evidence rows kept out of runtime economy"),
    ("local_rune_cost_review_approximate_evidence_coverage", local_rune_cost_approximate_evidence_coverage_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_approximate_evidence_coverage"], "approximate Rune cost nodes covered by explicit evidence rows"),
    ("local_rune_cost_review_pending", rune_pending_cost_nodes if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_pending"], "settings local Rune pending cost rows"),
    ("local_rune_cost_review_pending_groups", rune_pending_cost_icon_group_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_pending_groups"], "settings local Rune pending cost source-icon groups"),
    ("local_rune_cost_review_pending_branches", rune_pending_cost_branch_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_pending_branches"], "settings local Rune pending cost gameplay branches"),
    ("local_rune_cost_review_evidence_gates", local_rune_cost_evidence_gate_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_evidence_gates"], "settings Rune cost evidence gates before verified cost modeling"),
    ("local_rune_cost_review_evidence_queues", local_rune_cost_evidence_queue_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_evidence_queues"], "settings Rune pending-cost evidence queues"),
    ("local_rune_cost_review_evidence_queue_coverage", local_rune_cost_evidence_queue_coverage_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_evidence_queue_coverage"], "pending Rune cost nodes covered by evidence queues"),
    ("local_rune_cost_review_evidence_queue_group_coverage", local_rune_cost_evidence_queue_group_coverage_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_evidence_queue_group_coverage"], "pending Rune cost icon groups covered by evidence queues"),
    ("local_rune_cost_review_branch_evidence_rows", local_rune_cost_branch_evidence_row_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_branch_evidence_rows"], "settings Rune pending-cost branch/icon evidence rows"),
    ("local_rune_cost_review_branch_evidence_coverage", local_rune_cost_branch_evidence_coverage_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_branch_evidence_coverage"], "pending Rune cost nodes covered by branch/icon evidence rows"),
    ("local_rune_cost_review_branch_evidence_group_coverage", local_rune_cost_branch_evidence_group_coverage_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_branch_evidence_group_coverage"], "pending Rune cost icon groups covered by branch/icon evidence rows"),
    ("local_rune_cost_review_max_level_evidence_queues", local_rune_cost_max_level_evidence_queue_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_max_level_evidence_queues"], "settings Rune pending-cost maxLevel evidence buckets"),
    ("local_rune_cost_review_max_level_evidence_coverage", local_rune_cost_max_level_evidence_coverage_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_max_level_evidence_coverage"], "pending Rune cost nodes covered by maxLevel evidence buckets"),
    ("local_rune_cost_review_max_level_evidence_icon_buckets", local_rune_cost_max_level_evidence_icon_bucket_count if local_rune_cost_review_view else 0, None, CURRENT_BASELINE["local_rune_cost_review_max_level_evidence_icon_buckets"], "pending Rune cost icon buckets inside maxLevel evidence rows"),
    ("source_rune_evidence_review_rows", source_rune_evidence_review_rows if source_rune_evidence_review_view else 0, None, CURRENT_BASELINE["source_rune_evidence_review_rows"], "settings cross-source Rune evidence tier rows"),
    ("source_rune_evidence_independent_sources", source_rune_evidence_independent_sources if source_rune_evidence_review_view else 0, None, CURRENT_BASELINE["source_rune_evidence_independent_sources"], "non-Wiki Rune evidence pages checked"),
    ("source_rune_evidence_verified_cost_rows", source_rune_evidence_verified_cost_rows if source_rune_evidence_review_view else 0, None, CURRENT_BASELINE["source_rune_evidence_verified_cost_rows"], "cross-source verified Rune cost rows"),
    ("source_rune_evidence_candidate_cost_rows", source_rune_evidence_candidate_cost_rows if source_rune_evidence_review_view else 0, None, CURRENT_BASELINE["source_rune_evidence_candidate_cost_rows"], "single-source candidate Rune cost rows kept out of verified costs"),
    ("source_rune_evidence_candidate_cost_gold_total", source_rune_evidence_candidate_cost_gold_total if source_rune_evidence_review_view else 0, None, CURRENT_BASELINE["source_rune_evidence_candidate_cost_gold_total"], "single-source candidate Rune cost total kept out of verified refunds"),
    ("source_rune_tbh_city_candidate_cost_table_rows", source_rune_tbh_city_candidate_cost_table_rows if source_rune_tbh_city_candidate_cost_table_guard else 0, None, CURRENT_BASELINE["source_rune_tbh_city_candidate_cost_table_rows"], "complete tbh.city total_cost_to_max candidate Rune table rows kept out of verified costs"),
    ("source_rune_tbh_city_candidate_cost_table_gold_total", source_rune_tbh_city_candidate_cost_table_gold_total if source_rune_tbh_city_candidate_cost_table_guard else 0, None, CURRENT_BASELINE["source_rune_tbh_city_candidate_cost_table_gold_total"], "complete tbh.city candidate Rune table total kept out of runtime costs and refunds"),
    ("source_rune_candidate_cost_queues", source_rune_candidate_cost_queue_rows if source_rune_candidate_cost_queue_guard else 0, None, CURRENT_BASELINE["source_rune_candidate_cost_queues"], "review-only buckets for tbh.city candidate Rune costs"),
    ("source_rune_candidate_cost_queue_coverage", source_rune_candidate_cost_queue_coverage if source_rune_candidate_cost_queue_guard else 0, None, CURRENT_BASELINE["source_rune_candidate_cost_queue_coverage"], "single-source candidate Rune cost rows covered by review buckets"),
    ("source_rune_candidate_cost_queue_gold_total", source_rune_candidate_cost_queue_gold_total if source_rune_candidate_cost_queue_guard else 0, None, CURRENT_BASELINE["source_rune_candidate_cost_queue_gold_total"], "review bucket total kept out of runtime costs and refunds"),
    ("source_rune_evidence_timer_rows", source_rune_evidence_timer_rows if source_rune_evidence_review_view else 0, None, CURRENT_BASELINE["source_rune_evidence_timer_rows"], "auto-open timer evidence rows with checked runtime cooldowns"),
    ("source_audio_sfx_evidence_rows", source_audio_sfx_evidence_rows if source_audio_sfx_evidence_guard else 0, None, CURRENT_BASELINE["source_audio_sfx_evidence_rows"], "settings Steam audio baseline and local SFX evidence rows"),
    ("source_audio_sfx_event_gate_rows", source_audio_sfx_event_gate_rows if source_audio_sfx_evidence_guard else 0, None, CURRENT_BASELINE["source_audio_sfx_event_gate_rows"], "settings original per-event SFX evidence gates"),
    ("source_audio_sfx_local_events", source_audio_sfx_local_events if source_audio_sfx_evidence_guard else 0, None, CURRENT_BASELINE["source_audio_sfx_local_events"], "GameAudioEvent cases covered by local substitute SFX"),
    ("source_audio_sfx_local_resources", source_audio_sfx_local_resources if source_audio_sfx_manifest_guard else 0, None, CURRENT_BASELINE["source_audio_sfx_local_resources"], "unique local generated-substitute WAV resources"),
    ("source_audio_sfx_original_isolated", source_audio_sfx_original_isolated if source_audio_sfx_evidence_guard else -1, None, CURRENT_BASELINE["source_audio_sfx_original_isolated"], "isolated original per-event SFX currently available"),
    ("source_audio_sfx_steam_duration_seconds", source_audio_sfx_steam_duration_seconds if source_audio_sfx_evidence_guard else 0, None, CURRENT_BASELINE["source_audio_sfx_steam_duration_seconds"], "Steam Trailer HLS broad audio duration baseline"),
    ("source_audio_sfx_steam_sample_rate_hz", source_audio_sfx_steam_sample_rate_hz if source_audio_sfx_evidence_guard else 0, None, CURRENT_BASELINE["source_audio_sfx_steam_sample_rate_hz"], "Steam Trailer HLS audio sample-rate baseline"),
    ("source_battle_animation_evidence_rows", source_battle_animation_evidence_rows if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_evidence_rows"], "settings official battle animation evidence rows"),
    ("source_battle_animation_motion_sample_rows", source_battle_animation_motion_sample_rows if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_motion_sample_rows"], "settings official frame-pair motion sample detail rows"),
    ("source_battle_animation_action_frame_gate_rows", source_battle_animation_action_frame_gate_rows if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_action_frame_gate_rows"], "settings original action-frame evidence gates"),
    ("source_battle_animation_official_width", source_battle_animation_official_width if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_width"], "official Steam battle media width"),
    ("source_battle_animation_official_height", source_battle_animation_official_height if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_height"], "official Steam battle media height"),
    ("source_battle_animation_official_fps", source_battle_animation_official_fps if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_fps"], "official Steam battle media fps"),
    ("source_battle_animation_official_duration_ms", source_battle_animation_official_duration_ms if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_duration_ms"], "official Steam battle media duration in milliseconds"),
    ("source_battle_animation_official_frames", source_battle_animation_official_frames if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_frames"], "official Steam battle media frame count"),
    ("source_battle_animation_official_motion_sample_ms", source_battle_animation_official_motion_sample_ms if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_motion_sample_ms"], "official frame 0 to 8 sample interval"),
    ("source_battle_animation_official_motion_pixels", source_battle_animation_official_motion_pixels if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_motion_pixels"], "official frame 0 to 8 changed pixels"),
    ("source_battle_animation_official_platform_motion_pixels", source_battle_animation_official_platform_motion_pixels if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_platform_motion_pixels"], "official lower-platform changed pixels"),
    ("source_battle_animation_official_non_platform_motion_pixels", source_battle_animation_official_non_platform_motion_pixels if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_non_platform_motion_pixels"], "official non-platform changed pixels"),
    ("source_battle_animation_official_motion_percent_x10000", source_battle_animation_official_motion_percent_x10000 if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_official_motion_percent_x10000"], "official sampled motion percent x10000"),
    ("source_battle_animation_local_render_width_px", source_battle_animation_local_render_width_px if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_render_width_px"], "local deterministic battle scene render width"),
    ("source_battle_animation_local_render_height_px", source_battle_animation_local_render_height_px if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_render_height_px"], "local deterministic battle scene render height"),
    ("source_battle_animation_local_battle_tab_width_px", source_battle_animation_local_battle_tab_width_px if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_battle_tab_width_px"], "local full Battle tab render width"),
    ("source_battle_animation_local_battle_tab_height_px", source_battle_animation_local_battle_tab_height_px if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_battle_tab_height_px"], "local full Battle tab render height"),
    ("source_battle_animation_local_ratio_x100", source_battle_animation_local_ratio_x100 if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_ratio_x100"], "local configured battle-scene ratio x100"),
    ("source_battle_animation_local_popover_width_pt", source_battle_animation_local_popover_width_pt if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_popover_width_pt"], "local menu-bar popover width in points"),
    ("source_battle_animation_local_popover_height_pt", source_battle_animation_local_popover_height_pt if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_popover_height_pt"], "local menu-bar popover height in points"),
    ("source_battle_animation_local_content_height_pt", source_battle_animation_local_content_height_pt if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_content_height_pt"], "local popover content height in points"),
    ("source_battle_animation_local_battle_scene_height_pt", source_battle_animation_local_battle_scene_height_pt if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_battle_scene_height_pt"], "local Battle scene height in points"),
    ("source_battle_animation_local_bottom_tab_height_pt", source_battle_animation_local_bottom_tab_height_pt if source_battle_animation_evidence_guard else 0, None, CURRENT_BASELINE["source_battle_animation_local_bottom_tab_height_pt"], "local bottom tab bar height in points"),
    ("source_battle_animation_exact_action_frames", source_battle_animation_exact_action_frames if source_battle_animation_evidence_guard else -1, None, CURRENT_BASELINE["source_battle_animation_exact_action_frames"], "exact original action-frame groups currently verified"),
    ("rune_auto_open_normal_base_cooldown_seconds", rune_auto_open_normal_base_cooldown_seconds, None, CURRENT_BASELINE["rune_auto_open_normal_base_cooldown_seconds"], "source Normal Monster auto-open cooldown seconds"),
    ("rune_auto_open_stage_boss_base_cooldown_seconds", rune_auto_open_stage_boss_base_cooldown_seconds, None, CURRENT_BASELINE["rune_auto_open_stage_boss_base_cooldown_seconds"], "source Stage Boss auto-open cooldown seconds"),
    ("rune_auto_open_act_boss_base_cooldown_seconds", rune_auto_open_act_boss_base_cooldown_seconds, None, CURRENT_BASELINE["rune_auto_open_act_boss_base_cooldown_seconds"], "source Act Boss auto-open cooldown seconds"),
    ("rune_auto_open_normal_reduction_seconds", rune_auto_open_normal_reduction_seconds, None, CURRENT_BASELINE["rune_auto_open_normal_reduction_seconds"], "checked Normal Monster auto-open cooldown reductions"),
    ("rune_auto_open_stage_boss_reduction_seconds", rune_auto_open_stage_boss_reduction_seconds, None, CURRENT_BASELINE["rune_auto_open_stage_boss_reduction_seconds"], "checked Stage Boss auto-open cooldown reductions"),
    ("rune_auto_open_act_boss_reduction_seconds", rune_auto_open_act_boss_reduction_seconds, None, CURRENT_BASELINE["rune_auto_open_act_boss_reduction_seconds"], "checked Act Boss auto-open cooldown reductions"),
    ("direct_inventory_expansion_slot_bonus", direct_inventory_expansion_slot_bonus, None, CURRENT_BASELINE["direct_inventory_expansion_slot_bonus"], "repeatable direct backpack expansion slot bonus"),
    ("direct_inventory_expansion_base_gold_cost", direct_inventory_expansion_base_gold_cost, None, CURRENT_BASELINE["direct_inventory_expansion_base_gold_cost"], "repeatable direct backpack expansion base cost"),
    ("worse_equipment_handling_modes", worse_equipment_handling_modes, None, CURRENT_BASELINE["worse_equipment_handling_modes"], "keep/alchemy/discard weaker loot handling modes"),
    ("acts", len(chapter_cases), ORIGINAL["acts"], CURRENT_BASELINE["acts"], "Chapter enum"),
    ("display_stages", display_stage_count, ORIGINAL["stages"], CURRENT_BASELINE["display_stages"], "StageDefinition.all navigation skeleton"),
    ("runtime_stage_rows", len(set(stage_codes)), ORIGINAL["difficulty_stage_rows"], CURRENT_BASELINE["runtime_stage_rows"], "mined difficulty-stage data rows"),
    ("source_stage_review_rows", len(set(stage_codes)) if source_stage_database_view else 0, ORIGINAL["difficulty_stage_rows"], CURRENT_BASELINE["source_stage_review_rows"], "settings mined stage source-data review table rows"),
    ("stage_composition_rows", len(set(composition_codes)), ORIGINAL["difficulty_stage_rows"], None, "mined composition rows"),
    ("stage_composition_names", len(composition_names), None, 49, "unique names in mined composition rows"),
    ("source_monster_database_rows", len(source_monster_database_ids) if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_database_rows"], "settings source monster database rows"),
    ("source_monster_database_unique_ids", len(set(source_monster_database_ids)) if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_database_unique_ids"], "settings source monster database unique IDs"),
    ("source_monster_database_unique_names", len(source_monster_database_names) if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_database_unique_names"], "settings source monster database unique monster names"),
    ("source_monster_database_stage_coverage", source_monster_database_stage_coverage if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_database_stage_coverage"], "source monster database coverage of checked stage-composition names"),
    ("source_monster_database_unmapped_stage_rows", source_monster_database_unmapped_stage_count if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_database_unmapped_stage_rows"], "source monster database rows not present in current stage-composition art mapping"),
    ("source_monster_source_only_sprites", source_monster_source_only_sprite_count if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_source_only_sprites"], "source-only monster sprite resources for source rows that still lack stage/runtime encounters"),
    ("source_monster_source_only_sprite_preview_rows", source_monster_source_only_sprite_preview_count, None, CURRENT_BASELINE["source_monster_source_only_sprite_preview_rows"], "Settings preview rows for source-only monster sprite evidence"),
    ("source_monster_source_only_proof_rows", source_monster_source_only_proof_rows_count, None, CURRENT_BASELINE["source_monster_source_only_proof_rows"], "Settings source-only monster proof matrix rows"),
    ("source_monster_source_only_proof_coverage", source_monster_source_only_proof_coverage_count, None, CURRENT_BASELINE["source_monster_source_only_proof_coverage"], "source-only monster proof matrix coverage of unmapped source rows"),
    ("source_monster_source_stage_evidence_rows", source_monster_source_stage_evidence_row_count, None, CURRENT_BASELINE["source_monster_source_stage_evidence_rows"], "Settings source-only monster stage appearance evidence rows"),
    ("source_monster_source_stage_appearance_confirmed", source_monster_source_stage_appearance_confirmed_count, None, CURRENT_BASELINE["source_monster_source_stage_appearance_confirmed"], "source-only monsters with same-source stage appearance page evidence"),
    ("source_monster_source_stage_appearance_absent", source_monster_source_stage_appearance_absent_count, None, CURRENT_BASELINE["source_monster_source_stage_appearance_absent"], "source-only monsters whose source page has no stage appearances"),
    ("source_monster_source_stage_appearance_rows_total", source_monster_source_stage_appearance_rows_total, None, CURRENT_BASELINE["source_monster_source_stage_appearance_rows_total"], "same-source monster page stage appearance row total"),
    ("source_monster_source_stage_crosscheck_pages", source_monster_source_stage_crosscheck_page_count, None, CURRENT_BASELINE["source_monster_source_stage_crosscheck_pages"], "same-source stage pages cross-checking source-only monster appearances"),
    ("source_monster_source_page_field_rows", source_monster_source_page_field_row_count, None, CURRENT_BASELINE["source_monster_source_page_field_rows"], "Settings source-only monster page field evidence rows"),
    ("source_monster_source_page_field_sprite_paths", source_monster_source_page_field_sprite_path_count, None, CURRENT_BASELINE["source_monster_source_page_field_sprite_paths"], "source-only monster page sprite URL fields"),
    ("source_monster_source_page_field_move_known", source_monster_source_page_field_move_known_count, None, CURRENT_BASELINE["source_monster_source_page_field_move_known"], "source-only monster page Move fields"),
    ("source_monster_source_page_field_damage_known", source_monster_source_page_field_damage_known_count, None, CURRENT_BASELINE["source_monster_source_page_field_damage_known"], "source-only monster page Damage fields with known values"),
    ("source_monster_source_page_field_range_known", source_monster_source_page_field_range_known_count, None, CURRENT_BASELINE["source_monster_source_page_field_range_known"], "source-only monster page Range fields with known values"),
    ("source_monster_source_page_field_unknown_damage_range", source_monster_source_page_field_unknown_damage_range_count, None, CURRENT_BASELINE["source_monster_source_page_field_unknown_damage_range"], "source-only monster page rows with unknown Damage and Range"),
    ("source_monster_source_only_stage_proof_missing", source_monster_source_only_stage_proof_missing_count, None, CURRENT_BASELINE["source_monster_source_only_stage_proof_missing"], "source-only monster rows still missing stage-composition proof"),
    ("source_monster_source_only_runtime_blocked", source_monster_source_only_runtime_blocked_count, None, CURRENT_BASELINE["source_monster_source_only_runtime_blocked"], "source-only monster rows blocked from runtime encounters"),
    ("source_monster_source_only_skill_ownership_unproven", source_monster_source_only_skill_ownership_unproven_count, None, CURRENT_BASELINE["source_monster_source_only_skill_ownership_unproven"], "source-only monster rows with unproven source skill ownership"),
    ("source_monster_source_only_animation_frame_missing", source_monster_source_only_animation_frame_missing_count, None, CURRENT_BASELINE["source_monster_source_only_animation_frame_missing"], "source-only monster rows still missing original animation frames"),
    ("source_monster_source_only_sfx_missing", source_monster_source_only_sfx_missing_count, None, CURRENT_BASELINE["source_monster_source_only_sfx_missing"], "source-only monster rows still missing isolated original SFX"),
    ("source_monster_unmapped_evidence_gates", source_monster_unmapped_evidence_gate_count if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_unmapped_evidence_gates"], "settings source monster evidence gates before unmapped monster runtime/art mapping"),
    ("source_monster_unmapped_evidence_queues", source_monster_unmapped_evidence_queue_count if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_unmapped_evidence_queues"], "settings source monster unmapped evidence queues"),
    ("source_monster_unmapped_evidence_queue_coverage", source_monster_unmapped_evidence_queue_coverage_count if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_unmapped_evidence_queue_coverage"], "unmapped source monster rows covered by evidence queues"),
    ("source_monster_unmapped_candidate_skills", source_monster_unmapped_candidate_skill_count if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_unmapped_candidate_skills"], "same-prefix source skill candidates kept review-only"),
    ("source_monster_database_missing_best_farm", source_monster_database_missing_best_farm if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_database_missing_best_farm"], "source monster database rows whose source best-farm field is explicitly absent"),
    ("source_monster_runtime_attack_coverage", source_monster_database_stage_coverage if source_monster_runtime_stats_guard else 0, None, CURRENT_BASELINE["source_monster_runtime_attack_coverage"], "runtime stage-composition monsters using source base ATK"),
    ("source_monster_runtime_speed_coverage", source_monster_database_stage_coverage if source_monster_runtime_stats_guard else 0, None, CURRENT_BASELINE["source_monster_runtime_speed_coverage"], "runtime stage-composition monsters using source attack-speed scalar"),
    ("source_monster_source_cooldown_min_tenths", source_monster_source_cooldown_min_tenths if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_source_cooldown_min_tenths"], "fastest source attack cooldown in tenths of a second"),
    ("source_monster_source_cooldown_max_tenths", source_monster_source_cooldown_max_tenths if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_source_cooldown_max_tenths"], "slowest source attack cooldown in tenths of a second"),
    ("source_monster_loop_cooldown_min_tenths", source_monster_loop_cooldown_min_tenths if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_loop_cooldown_min_tenths"], "fastest local loop-quantized monster cooldown in tenths"),
    ("source_monster_loop_cooldown_max_tenths", source_monster_loop_cooldown_max_tenths if source_monster_database_view else 0, None, CURRENT_BASELINE["source_monster_loop_cooldown_max_tenths"], "slowest local loop-quantized monster cooldown in tenths"),
    ("source_monster_art_review_rows", len(composition_names) if source_monster_art_mapping_view else 0, None, CURRENT_BASELINE["source_monster_art_review_rows"], "settings stage monster art mapping review rows"),
    ("source_monster_steam_minimum", ORIGINAL["monster_types_min"], ORIGINAL["monster_types_min"], CURRENT_BASELINE["source_monster_steam_minimum"], "official Steam monster type lower bound"),
    ("source_monster_source_roster_steam_gap", source_monster_source_roster_steam_gap_count if source_monster_database_view else 0, 0, CURRENT_BASELINE["source_monster_source_roster_steam_gap"], "Steam monster lower-bound gap after source-name de-duplication"),
    ("source_monster_unchecked_roster_gap_minimum", source_monster_source_roster_steam_gap_count if source_monster_art_mapping_view else 0, 0, CURRENT_BASELINE["source_monster_unchecked_roster_gap_minimum"], "legacy Steam monster lower-bound gap metric after source-name de-duplication"),
    ("source_monster_art_evidence_gates", source_monster_art_evidence_gate_count if source_monster_art_mapping_view else 0, None, CURRENT_BASELINE["source_monster_art_evidence_gates"], "settings monster art evidence gates before dedicated sprite/frame replacement"),
    ("source_monster_art_evidence_queues", source_monster_art_evidence_queue_count if source_monster_art_mapping_view else 0, None, CURRENT_BASELINE["source_monster_art_evidence_queues"], "settings monster art evidence queues before dedicated sprite/frame replacement"),
    ("source_monster_art_evidence_queue_coverage", source_monster_art_evidence_queue_coverage_count if source_monster_art_mapping_view else 0, None, CURRENT_BASELINE["source_monster_art_evidence_queue_coverage"], "stage-composition monster art mappings covered by evidence queues"),
    ("source_monster_art_evidence_queue_roster_gap", source_monster_art_evidence_queue_roster_gap_count if source_monster_art_mapping_view else 0, 0, CURRENT_BASELINE["source_monster_art_evidence_queue_roster_gap"], "legacy Steam monster lower-bound gap covered by evidence queues"),
    ("source_monster_art_evidence_queue_source_roster_gap", source_monster_art_evidence_queue_source_roster_gap_count if source_monster_art_mapping_view else 0, None, CURRENT_BASELINE["source_monster_art_evidence_queue_source_roster_gap"], "source monster names still missing current battle art/runtime mapping"),
    ("source_monster_attack_review_rows", len(runtime_monster_attack_skill_ids) if source_monster_attack_review_view else 0, CURRENT_BASELINE["runtime_monster_attack_skills"], CURRENT_BASELINE["source_monster_attack_review_rows"], "settings checked monster attack source mapping review rows"),
    ("source_monster_attack_evidence_gates", source_monster_attack_evidence_gate_count if source_monster_attack_review_view else 0, None, CURRENT_BASELINE["source_monster_attack_evidence_gates"], "settings monster attack evidence gates before full skill/delivery modeling"),
    ("difficulty_tiers", len(difficulty_cases), ORIGINAL["difficulty_tiers"], CURRENT_BASELINE["difficulty_tiers"], "Difficulty enum"),
    ("item_rarities", len(rarity_cases), ORIGINAL["item_rarities"], CURRENT_BASELINE["item_rarities"], "Rarity enum"),
    ("equipment_types", len(equipment_types), ORIGINAL["equipment_types"], CURRENT_BASELINE["equipment_types"], "EquipmentType enum"),
    ("active_equip_slots", len(equip_slots), None, CURRENT_BASELINE["equip_slots"], "EquipSlot.allCases"),
    ("source_gear_type_rows", len(source_gear_entries), ORIGINAL["equipment_types"], CURRENT_BASELINE["source_gear_type_rows"], "checked gear type pages"),
    ("source_gear_entry_aggregate", source_gear_entry_total, ORIGINAL["item_records"], CURRENT_BASELINE["source_gear_entry_aggregate"], "checked per-type aggregate gear counts"),
    ("source_gear_level_progressions", source_gear_level_progression_total, 396, CURRENT_BASELINE["source_gear_level_progressions"], "checked base item level IDs"),
    ("source_gear_rarity_distribution", source_gear_rarity_total, ORIGINAL["item_records"], CURRENT_BASELINE["source_gear_entry_aggregate"], "checked per-type rarity-count totals"),
    ("exact_item_record_gap_review_rows", len(source_gear_category_entry_counts) if exact_item_record_gap_view else 0, None, CURRENT_BASELINE["exact_item_record_gap_review_rows"], "settings exact item-record gap category rows"),
    ("exact_item_record_gap_review_type_rows", len(source_gear_entries) if exact_item_record_gap_view else 0, None, CURRENT_BASELINE["exact_item_record_gap_review_type_rows"], "settings exact item-record gap type rows"),
    ("exact_item_record_gap_evidence_gates", exact_item_record_gap_evidence_gate_count, None, CURRENT_BASELINE["exact_item_record_gap_evidence_gates"], "settings missing-evidence gates before exact item-record modeling"),
    ("exact_item_record_gap_category_queues", exact_item_record_gap_category_queue_count, None, CURRENT_BASELINE["exact_item_record_gap_category_queues"], "settings exact item-record category evidence queues"),
    ("exact_item_record_gap_rarity_queues", exact_item_record_gap_rarity_queue_count, None, CURRENT_BASELINE["exact_item_record_gap_rarity_queues"], "settings exact item-record rarity evidence queues"),
    ("exact_item_record_gap_category_rarity_queues", exact_item_record_gap_category_rarity_queue_count, None, CURRENT_BASELINE["exact_item_record_gap_category_rarity_queues"], "settings exact item-record category-rarity matrix evidence queues"),
    ("exact_item_record_gap_progression_queues", exact_item_record_gap_progression_queue_count, None, CURRENT_BASELINE["exact_item_record_gap_progression_queues"], "settings exact item-record base progression evidence queues"),
    ("exact_item_record_gap_type_queues", exact_item_record_gap_type_queue_count, None, CURRENT_BASELINE["exact_item_record_gap_type_queues"], "settings exact item-record type evidence queues"),
    ("exact_item_record_gap_largest_type_queues", exact_item_record_gap_largest_type_queue_count, None, CURRENT_BASELINE["exact_item_record_gap_largest_type_queues"], "settings exact item-record largest missing type queues"),
    ("exact_item_record_gap_queue_coverage", exact_item_record_gap_queue_coverage_count, None, CURRENT_BASELINE["exact_item_record_gap_queue_coverage"], "aggregate gear entries covered by exact item-record queues"),
    ("exact_item_record_gap_rarity_queue_coverage", exact_item_record_gap_rarity_queue_coverage_count, None, CURRENT_BASELINE["exact_item_record_gap_rarity_queue_coverage"], "aggregate rarity entries covered by exact item-record rarity queues"),
    ("exact_item_record_gap_category_rarity_queue_coverage", exact_item_record_gap_category_rarity_queue_coverage_count, None, CURRENT_BASELINE["exact_item_record_gap_category_rarity_queue_coverage"], "aggregate category-rarity matrix entries covered by exact item-record queues"),
    ("exact_item_record_gap_progression_queue_coverage", exact_item_record_gap_progression_queue_coverage_count, None, CURRENT_BASELINE["exact_item_record_gap_progression_queue_coverage"], "source base progressions covered by exact item-record queues"),
    ("exact_item_record_gap_largest_type_queue_coverage", exact_item_record_gap_largest_type_queue_coverage_count, None, CURRENT_BASELINE["exact_item_record_gap_largest_type_queue_coverage"], "aggregate gear entries covered by largest missing type queues"),
    ("exact_item_record_gap_review_aggregate", source_gear_entry_total if exact_item_record_gap_view else 0, None, CURRENT_BASELINE["exact_item_record_gap_review_aggregate"], "settings aggregate gear rows used for exact-record gap review"),
    ("exact_item_record_gap_review_progressions", source_gear_level_progression_total if exact_item_record_gap_view else 0, None, CURRENT_BASELINE["exact_item_record_gap_review_progressions"], "settings source base progressions used for exact-record gap review"),
    ("exact_item_record_gap_review_missing", ORIGINAL["item_records"] - len(exact_item_record_markers) if exact_item_record_gap_view else 0, None, CURRENT_BASELINE["exact_item_record_gap_review_missing"], "settings exact per-variant item rows still missing"),
    ("original_fidelity_hard_gap_rows", original_fidelity_hard_gap_row_count, None, CURRENT_BASELINE["original_fidelity_hard_gap_rows"], "settings compact review queue for current hard original-fidelity blockers"),
    ("source_material_rows", len(source_materials), ORIGINAL["material_rows"], CURRENT_BASELINE["source_material_rows"], "checked material rows from item page"),
    ("source_material_categories", len(source_material_category_counts), ORIGINAL["material_categories"], CURRENT_BASELINE["source_material_categories"], "Decoration/Engraving/Inscription/Crafting/Offering/Soul Stone"),
    ("source_stage_chest_rows", len(source_stage_chests), ORIGINAL["stage_chests"], CURRENT_BASELINE["source_stage_chest_rows"], "checked stage chest rows from item page"),
    ("exact_item_records", len(exact_item_record_markers), ORIGINAL["item_records"], 0, "full per-rarity/per-affix item records still unavailable"),
    ("chest_catalog_entries", chest_catalog_entries, 59, None, "current chest-family catalog rows vs Wiki item rows"),
    ("chest_families", len(chest_families), 3, 3, "Normal/Stage Boss/Act Boss families"),
    ("soul_stone_kinds", len(soul_stones), 4, CURRENT_BASELINE["soul_stones"], "Soul Stone material kinds"),
    ("synthesis_input_count", synthesis_inputs, ORIGINAL["synthesis_inputs"], CURRENT_BASELINE["synthesis_inputs"], "checked same-rarity input count"),
    ("source_crafting_rule_review_rows", len(rarity_cases) if source_crafting_rule_review_view else 0, ORIGINAL["item_rarities"], CURRENT_BASELINE["source_crafting_rule_review_rows"], "settings source Synthesis/Cube/Alchemy rule review rows"),
    ("player_status_badges", len(player_status_badges), None, CURRENT_BASELINE["player_status_badges"], "compact player-side battle status badge cases"),
    ("player_active_status_mappings", len(player_status_active_mappings), None, CURRENT_BASELINE["player_active_status_mappings"], "active buff/summon/trap names visible in battle UI"),
    ("player_continuous_status_mappings", len(player_status_continuous_mappings), source_skill_activation_counts.get("CONTINUOUS", 0), CURRENT_BASELINE["player_continuous_status_mappings"], "source CONTINUOUS Priest blessings visible in battle UI"),
    ("player_deployable_markers", len(player_deployable_markers), None, CURRENT_BASELINE["player_deployable_markers"], "Hydra/trap/turret field markers"),
    ("support_formula_review_rows", support_formula_review_rows if support_formula_review_guard else 0, None, CURRENT_BASELINE["support_formula_review_rows"], "settings support-member formula boundary rows"),
    ("support_formula_attack_scalar_percent", support_formula_attack_scalar_percent if support_formula_review_guard else 0, None, CURRENT_BASELINE["support_formula_attack_scalar_percent"], "local support attack scalar percent"),
    ("menu_bar_popover_default_width", menu_bar_popover_default_width, None, CURRENT_BASELINE["menu_bar_popover_default_width"], "visible menu-bar popover default width"),
    ("menu_bar_popover_default_height", menu_bar_popover_default_height, None, CURRENT_BASELINE["menu_bar_popover_default_height"], "visible menu-bar popover default height"),
    ("menu_bar_content_min_height", menu_bar_content_min_height, None, CURRENT_BASELINE["menu_bar_content_min_height"], "content area above the bottom tab bar"),
    ("battle_scene_render_width_px", battle_scene_render_width_px, None, CURRENT_BASELINE["battle_scene_render_width_px"], "deterministic battle scene render width"),
    ("battle_scene_render_height_px", battle_scene_render_height_px, None, CURRENT_BASELINE["battle_scene_render_height_px"], "deterministic battle scene render height"),
    ("battle_tab_layout_render_width_px", battle_tab_layout_render_width_px, None, CURRENT_BASELINE["battle_tab_layout_render_width_px"], "full battle tab render width"),
    ("battle_tab_layout_render_height_px", battle_tab_layout_render_height_px, None, CURRENT_BASELINE["battle_tab_layout_render_height_px"], "full battle tab render height"),
    ("inventory_panel_render_width_px", inventory_panel_render_width_px, None, CURRENT_BASELINE["inventory_panel_render_width_px"], "inventory panel render width"),
    ("inventory_panel_render_height_px", inventory_panel_render_height_px, None, CURRENT_BASELINE["inventory_panel_render_height_px"], "inventory panel render height"),
    ("character_panel_render_width_px", character_panel_render_width_px, None, CURRENT_BASELINE["character_panel_render_width_px"], "character panel render width"),
    ("character_panel_render_height_px", character_panel_render_height_px, None, CURRENT_BASELINE["character_panel_render_height_px"], "character panel render height"),
    ("chest_panel_render_width_px", chest_panel_render_width_px, None, CURRENT_BASELINE["chest_panel_render_width_px"], "chest controls panel render width"),
    ("chest_panel_render_height_px", chest_panel_render_height_px, None, CURRENT_BASELINE["chest_panel_render_height_px"], "chest controls panel render height"),
    ("original_fidelity_panel_render_width_px", original_fidelity_panel_render_width_px, None, CURRENT_BASELINE["original_fidelity_panel_render_width_px"], "original-fidelity boundary panel render width"),
    ("original_fidelity_panel_render_height_px", original_fidelity_panel_render_height_px, None, CURRENT_BASELINE["original_fidelity_panel_render_height_px"], "original-fidelity boundary panel render height"),
    ("rune_evidence_panel_render_width_px", rune_evidence_panel_render_width_px, None, CURRENT_BASELINE["rune_evidence_panel_render_width_px"], "Rune evidence/cost panel render width"),
    ("rune_evidence_panel_render_height_px", rune_evidence_panel_render_height_px, None, CURRENT_BASELINE["rune_evidence_panel_render_height_px"], "Rune evidence/cost panel render height"),
    ("skill_evidence_panel_render_width_px", skill_evidence_panel_render_width_px, None, CURRENT_BASELINE["skill_evidence_panel_render_width_px"], "source skill/pending review panel render width"),
    ("skill_evidence_panel_render_height_px", skill_evidence_panel_render_height_px, None, CURRENT_BASELINE["skill_evidence_panel_render_height_px"], "source skill/pending review panel render height"),
    ("passive_evidence_panel_render_width_px", passive_evidence_panel_render_width_px, None, CURRENT_BASELINE["passive_evidence_panel_render_width_px"], "passive skill source/icon review panel render width"),
    ("passive_evidence_panel_render_height_px", passive_evidence_panel_render_height_px, None, CURRENT_BASELINE["passive_evidence_panel_render_height_px"], "passive skill source/icon review panel render height"),
    ("battle_scene_configured_ratio_x100", battle_scene_configured_ratio_x100, None, CURRENT_BASELINE["battle_scene_configured_ratio_x100"], "configured local battle scene width/height ratio x100"),
    ("battle_scene_local_platform_pct", battle_scene_local_platform_width_percent, None, CURRENT_BASELINE["battle_scene_local_platform_width_percent"], "local macOS subtle-side-margin platform ratio"),
    ("battle_log_visible_entries", battle_log_visible_entries, None, CURRENT_BASELINE["battle_log_visible_entries"], "recent combat log rows visible in battle tab"),
    ("battle_log_hero_highlight_entries", battle_log_hero_highlight_entries, None, 3, "fixed player-side combat log rows visible above the full log"),
    ("battle_log_panel_height", battle_log_panel_height_value, None, CURRENT_BASELINE["battle_log_panel_height"], "reserved battle log panel height"),
]

print("source_files=" + ",".join(str(path) for path in [hero_path, skills_path, rune_path, stage_path, difficulty_path, chapter_path, item_path, inventory_path, loot_table_path, game_loop_path, save_manager_path, battle_path, monster_path, battle_view_path, menu_bar_popover_path, inventory_view_path, character_view_path, battle_scene_snapshot_path, self_test_path, resource_self_test_path, battle_scene_audit_path, steam_battle_scene_audit_path, hero_sprite_audit_path, game_art_path, settings_path, source_gear_manifest_path, combat_stats_tests_path]))
print("original_reference=Steam store and taskbarhero.org Wiki facts already recorded in docs/original-fidelity-review.md")
print()
print("area                         current       original      status      note")
print("---------------------------  ------------  ------------  ----------  ---------------------------------------------")
for name, count, original, expected_current, note in rows:
    if name in {"data_only_rune_source_nodes", "unmodeled_only_rune_icon_families"} and count == 0:
        status = "covered"
    else:
        status = row_status(name, count, original, expected_current)
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
print("source_skill_physical_damage_count=" + str(source_skill_physical_damage_count))
print("source_skill_non_physical_damage_runtime_count=" + str(source_skill_non_physical_damage_runtime_count))
print("source_skill_chaos_damage_runtime_count=" + str(source_skill_chaos_damage_runtime_count))
print("source_skill_most_common_damage=" + source_skill_most_common_damage)
print("source_skill_most_common_damage_count=" + str(source_skill_most_common_damage_count))
print("source_skill_activation_damage_pairs=" + str(source_skill_activation_damage_pair_count))
print("source_skill_activation_damage_runtime_pairs=" + str(source_skill_activation_damage_runtime_pair_count))
print("source_skill_activation_damage_counts=" + ",".join(
    f"{activation}/{damage}:{count}"
    for (activation, damage), count in source_skill_activation_damage_counts.items()
))
print("source_skill_activation_damage_runtime_counts=" + ",".join(
    f"{activation}/{damage}:{count}"
    for (activation, damage), count in source_skill_activation_damage_runtime_counts.items()
))
print("source_skill_baseattack_physical_pending_count=" + str(source_skill_baseattack_physical_pending_count))
print("source_skill_cooldown_chaos_runtime_count=" + str(source_skill_cooldown_chaos_runtime_count))
print("source_skill_cooldown_chaos_pending_count=" + str(source_skill_cooldown_chaos_pending_count))
print("source_skill_cooldown_chaos_pending_ids=" + ",".join(source_skill_cooldown_chaos_pending_ids))
print("source_skill_cooldown_chaos_value_map=" + ";".join(
    f"{skill_id}:{value}/r{range_value}"
    for skill_id, (value, range_value) in source_skill_cooldown_chaos_value_map.items()
))
print("source_skill_cooldown_chaos_value_count=" + str(source_skill_cooldown_chaos_value_count))
print("pending_source_skill_cooldown_chaos_page_rows=" + str(source_skill_cooldown_chaos_page_row_count))
print("pending_source_skill_cooldown_chaos_locale_pages=" + str(source_skill_cooldown_chaos_page_locale_count))
print("pending_source_skill_cooldown_chaos_empty_delivery=" + str(source_skill_cooldown_chaos_empty_delivery_count))
print("pending_source_skill_cooldown_chaos_unnamed=" + str(source_skill_cooldown_chaos_unnamed_count))
print("source_skill_activation_delivery_pairs=" + str(source_skill_activation_delivery_pair_count))
print("source_skill_activation_delivery_runtime_pairs=" + str(source_skill_activation_delivery_runtime_pair_count))
print("source_skill_activation_delivery_counts=" + ",".join(
    f"{activation}/{delivery or 'EMPTY'}:{count}"
    for (activation, delivery), count in source_skill_activation_delivery_counts.items()
))
print("source_skill_activation_delivery_runtime_counts=" + ",".join(
    f"{activation}/{delivery or 'EMPTY'}:{count}"
    for (activation, delivery), count in source_skill_activation_delivery_runtime_counts.items()
))
print("source_skill_baseattack_empty_delivery_pending_count=" + str(source_skill_baseattack_empty_delivery_pending_count))
print("source_skill_attackcount_empty_delivery_runtime_count=" + str(source_skill_attackcount_empty_delivery_runtime_count))
print("source_skill_damage_delivery_pairs=" + str(source_skill_damage_delivery_pair_count))
print("source_skill_damage_delivery_runtime_pairs=" + str(source_skill_damage_delivery_runtime_pair_count))
print("source_skill_damage_delivery_counts=" + ",".join(
    f"{damage}/{delivery or 'EMPTY'}:{count}"
    for (damage, delivery), count in source_skill_damage_delivery_counts.items()
))
print("source_skill_damage_delivery_runtime_counts=" + ",".join(
    f"{damage}/{delivery or 'EMPTY'}:{count}"
    for (damage, delivery), count in source_skill_damage_delivery_runtime_counts.items()
))
print("source_skill_empty_delivery_runtime_count=" + str(source_skill_empty_delivery_runtime_count))
print("source_skill_physical_empty_delivery_pending_count=" + str(source_skill_physical_empty_delivery_pending_count))
print("source_skill_chaos_empty_delivery_pending_count=" + str(source_skill_chaos_empty_delivery_pending_count))
print("source_skill_deliveries=" + ",".join(source_skill_deliveries))
print("source_skill_delivery_counts=" + ",".join(f"{key or 'EMPTY'}:{value}" for key, value in source_skill_delivery_counts.items()))
print("source_skill_empty_delivery_count=" + str(source_skill_empty_delivery_count))
print("source_skill_non_empty_delivery_runtime_count=" + str(source_skill_non_empty_delivery_runtime_count))
print("source_skill_most_common_delivery=" + (source_skill_most_common_delivery or "EMPTY"))
print("source_skill_most_common_delivery_count=" + str(source_skill_most_common_delivery_count))
print("source_skill_range_counts=" + ",".join(f"{key}:{value}" for key, value in source_skill_range_counts.items()))
print("source_skill_runtime_range_count=" + str(source_skill_runtime_range_count))
print("source_skill_min_range=" + str(source_skill_min_range))
print("source_skill_max_range=" + str(source_skill_max_range))
print("source_skill_most_common_range=" + str(source_skill_most_common_range))
print("source_skill_most_common_range_count=" + str(source_skill_most_common_range_count))
print("source_skills_by_prefix=" + ",".join(f"{prefix}:{count}" for prefix, count in source_skills_by_prefix.items()))
print("pending_source_skill_activation_counts=" + ",".join(f"{key}:{value}" for key, value in pending_source_skill_activation_counts.items()))
print("pending_source_skill_damage_counts=" + ",".join(f"{key}:{value}" for key, value in pending_source_skill_damage_counts.items()))
print("pending_source_skill_prefix_counts=" + ",".join(f"{key}:{value}" for key, value in pending_source_skill_prefix_counts.items()))
print("pending_source_skill_range_counts=" + ",".join(f"{key}:{value}" for key, value in pending_source_skill_range_counts.items()))
print("pending_source_skill_empty_delivery_count=" + str(pending_source_skill_empty_delivery_count))
print("pending_source_skill_responsibility_buckets=" + str(pending_source_skill_responsibility_bucket_count))
print("pending_source_skill_six_digit_unnamed_count=" + str(pending_source_skill_six_digit_unnamed_count))
print("pending_source_skill_damage_candidate_count=" + str(pending_source_skill_damage_candidate_count))
print("pending_source_skill_damage_candidate_ids_by_type=" + ";".join(
    f"{damage_type}:{','.join(ids)}"
    for damage_type, ids in pending_source_skill_damage_candidate_ids_by_type.items()
))
print("pending_source_skill_physical_damage_candidate_count=" + str(pending_source_skill_physical_damage_candidate_count))
print("pending_source_skill_elemental_damage_candidate_count=" + str(pending_source_skill_elemental_damage_candidate_count))
print("pending_source_skill_elemental_damage_candidate_ids_by_type=" + ";".join(
    f"{damage_type}:{','.join(ids)}"
    for damage_type, ids in pending_source_skill_elemental_damage_candidate_ids_by_type.items()
))
print("pending_source_skill_fire_damage_candidate_count=" + str(pending_source_skill_fire_damage_candidate_count))
print("pending_source_skill_cold_damage_candidate_count=" + str(pending_source_skill_cold_damage_candidate_count))
print("pending_source_skill_chaos_damage_candidate_count=" + str(pending_source_skill_chaos_damage_candidate_count))
print("pending_source_skill_chaos_damage_candidate_ids=" + ",".join(pending_source_skill_chaos_damage_candidate_ids))
print("pending_source_skill_base_attack_candidate_count=" + str(pending_source_skill_base_attack_candidate_count))
print("pending_source_skill_base_attack_candidate_ids_by_prefix=" + ";".join(
    f"{prefix}:{','.join(ids)}"
    for prefix, ids in pending_source_skill_base_attack_candidate_ids_by_prefix.items()
))
print("pending_source_skill_triggered_candidate_count=" + str(pending_source_skill_triggered_candidate_count))
print("pending_source_skill_triggered_candidate_ids=" + ",".join(pending_source_skill_triggered_candidate_ids))
print("pending_source_skill_triggered_value_map=" + ";".join(
    f"{skill_id}:{value}/r{range_value}"
    for skill_id, (value, range_value) in pending_source_skill_triggered_value_map.items()
))
print("pending_source_skill_triggered_value_count=" + str(pending_source_skill_triggered_value_count))
print("pending_source_skill_valued_candidate_count=" + str(pending_source_skill_valued_candidate_count))
print("pending_source_skill_valued_empty_delivery_count=" + str(pending_source_skill_valued_empty_delivery_count))
print("pending_source_skill_valued_unnamed_count=" + str(pending_source_skill_valued_unnamed_count))
print("pending_source_skill_catalog_only_count=" + str(pending_source_skill_catalog_only_count))
print("pending_source_skill_value_range_only_count=" + str(pending_source_skill_value_range_only_count))
print("pending_source_skill_minimum_evidence_count=" + str(pending_source_skill_minimum_evidence_count))
print("pending_source_skill_runtime_proof_rows=" + str(pending_source_skill_runtime_proof_row_count))
print("pending_source_skill_runtime_proof_coverage=" + str(pending_source_skill_runtime_proof_coverage_count) + "/" + str(len(pending_source_skills)))
print("pending_source_skill_runtime_proof_catalog=" + str(pending_source_skill_runtime_proof_catalog_count))
print("pending_source_skill_runtime_proof_value_range=" + str(pending_source_skill_runtime_proof_value_range_count))
print("pending_source_skill_runtime_proof_minimum_ready=" + str(pending_source_skill_runtime_proof_minimum_ready_count))
print("pending_source_skill_runtime_proof_name_missing=" + str(pending_source_skill_runtime_proof_name_missing_count))
print("pending_source_skill_runtime_proof_delivery_missing=" + str(pending_source_skill_runtime_proof_delivery_missing_count))
print("pending_source_skill_runtime_proof_ownership_formula_missing=" + str(pending_source_skill_runtime_proof_ownership_formula_missing_count))
print("pending_source_skill_runtime_proof_animation_missing=" + str(pending_source_skill_runtime_proof_animation_missing_count))
print("pending_source_skill_runtime_proof_sfx_missing=" + str(pending_source_skill_runtime_proof_sfx_missing_count))
print("pending_source_skill_runtime_gates=" + str(pending_source_skill_runtime_gate_count))
print("pending_source_skill_evidence_queues=" + str(pending_source_skill_evidence_queue_count))
print("pending_source_skill_evidence_queue_coverage=" + str(pending_source_skill_evidence_queue_coverage_count))
print("pending_source_skill_activation_damage_queues=" + str(pending_source_skill_activation_damage_queue_count))
print("pending_source_skill_activation_damage_queue_coverage=" + str(pending_source_skill_activation_damage_queue_coverage_count))
print("pending_source_skill_activation_damage_value_coverage=" + str(pending_source_skill_activation_damage_value_count))
print("pending_source_skill_activation_damage_empty_delivery=" + str(pending_source_skill_activation_damage_empty_delivery_count))
print("pending_source_skill_activation_damage_queue_summary=" + pending_source_skill_activation_damage_queue_summary)
print("pending_source_skill_range_evidence_queues=" + str(pending_source_skill_range_evidence_queue_count))
print("pending_source_skill_range_evidence_queue_coverage=" + str(pending_source_skill_range_evidence_queue_coverage_count))
print("pending_source_skill_range_evidence_value_coverage=" + str(pending_source_skill_range_evidence_value_coverage_count))
print("pending_source_skill_range_evidence_empty_delivery=" + str(pending_source_skill_range_evidence_empty_delivery_count))
print("pending_source_skill_range_evidence_queue_summary=" + pending_source_skill_range_evidence_queue_summary)
print("pending_source_skill_prefix_evidence_queues=" + str(pending_source_skill_prefix_evidence_queue_count))
print("pending_source_skill_prefix_evidence_queue_coverage=" + str(pending_source_skill_prefix_evidence_queue_coverage_count))
print("pending_source_skill_prefix_evidence_value_coverage=" + str(pending_source_skill_prefix_evidence_value_coverage_count))
print("pending_source_skill_prefix_evidence_empty_delivery=" + str(pending_source_skill_prefix_evidence_empty_delivery_count))
print("pending_source_skill_prefix_evidence_queue_summary=" + pending_source_skill_prefix_evidence_queue_summary)
print("pending_source_skill_value_evidence_queues=" + str(pending_source_skill_value_evidence_queue_count))
print("pending_source_skill_value_evidence_queue_coverage=" + str(pending_source_skill_value_evidence_queue_coverage_count))
print("pending_source_skill_value_evidence_empty_delivery=" + str(pending_source_skill_value_evidence_empty_delivery_count))
print("pending_source_skill_value_evidence_queue_summary=" + pending_source_skill_value_evidence_queue_summary)
print("pending_source_skill_value_range_queue_ids=" + ",".join(pending_source_skill_value_range_queue_ids))
print("pending_source_skill_nonphysical_baseattack_queue_ids=" + ",".join(pending_source_skill_nonphysical_baseattack_queue_ids))
print("pending_source_skill_nonphysical_baseattack_queue_summary=" + pending_source_skill_nonphysical_baseattack_queue_summary)
print("pending_source_skill_physical_baseattack_queue_ids=" + ",".join(pending_source_skill_physical_baseattack_queue_ids))
print("pending_source_skill_value_evidence_rows=" + str(pending_source_skill_value_evidence_row_count))
print("pending_source_skill_value_evidence_row_ids=" + ",".join(pending_source_skill_value_evidence_row_ids))
print("pending_source_skill_base_attack_evidence_rows=" + str(pending_source_skill_base_attack_evidence_row_count))
print("pending_source_skill_nonphysical_baseattack_evidence_rows=" + str(pending_source_skill_nonphysical_baseattack_evidence_row_count))
print("pending_source_skill_physical_baseattack_evidence_rows=" + str(pending_source_skill_physical_baseattack_evidence_row_count))
print("pending_source_skill_base_attack_evidence_row_ids=" + ",".join(pending_source_skill_base_attack_evidence_row_ids))
print("pending_source_skill_unmapped_monster_candidate_ids=" + ",".join(pending_source_skill_unmapped_monster_candidate_ids))
print("pending_source_skill_unmapped_monster_candidates=" + str(pending_source_skill_unmapped_monster_candidate_count))
print("pending_source_skill_unmapped_monster_candidate_empty_delivery=" + str(pending_source_skill_unmapped_monster_candidate_empty_delivery_count))
print("pending_source_skill_visual_priority_queues=" + str(pending_source_skill_visual_priority_queue_count))
print("pending_source_skill_visual_priority_entries=" + str(pending_source_skill_visual_priority_entry_count))
print("pending_source_skill_visual_priority_elemental=" + str(pending_source_skill_visual_priority_elemental_count))
print("pending_source_skill_visual_priority_cooldown_chaos=" + str(pending_source_skill_visual_priority_cooldown_chaos_count))
print("pending_source_skill_visual_priority_unmapped_monster=" + str(pending_source_skill_visual_priority_unmapped_monster_count))
print("pending_source_skill_visual_priority_highest_value=" + str(pending_source_skill_visual_priority_highest_value_count))
print("pending_source_skill_visual_priority_unique=" + str(pending_source_skill_visual_priority_unique_count))
print("pending_source_skill_visual_priority_overlap=" + str(pending_source_skill_visual_priority_overlap_count))
print("pending_source_skill_visual_priority_unqueued=" + str(pending_source_skill_visual_priority_unqueued_count))
print("pending_source_skill_visual_priority_unique_ids=" + ",".join(pending_source_skill_visual_priority_unique_ids))
print("pending_source_skill_visual_review_total_queues=" + str(pending_source_skill_visual_review_total_queue_count))
print("pending_source_skill_visual_review_total_coverage=" + str(pending_source_skill_visual_review_total_coverage_count))
print("pending_source_skill_visual_priority_unqueued_queues=" + str(pending_source_skill_visual_priority_unqueued_queue_count))
print("pending_source_skill_visual_priority_unqueued_queue_coverage=" + str(pending_source_skill_visual_priority_unqueued_queue_coverage_count))
print("pending_source_skill_visual_priority_unqueued_value=" + str(pending_source_skill_visual_priority_unqueued_value_count))
print("pending_source_skill_visual_priority_unqueued_empty_delivery=" + str(pending_source_skill_visual_priority_unqueued_empty_delivery_count))
print("pending_source_skill_visual_priority_unqueued_activation_buckets=" + str(len(pending_source_skill_visual_priority_unqueued_activation_counts)))
print("pending_source_skill_visual_priority_unqueued_damage_buckets=" + str(len(pending_source_skill_visual_priority_unqueued_damage_counts)))
print("pending_source_skill_visual_priority_unqueued_range_buckets=" + str(len(pending_source_skill_visual_priority_unqueued_range_counts)))
print("pending_source_skill_visual_priority_unqueued_ids=" + ",".join(pending_source_skill_visual_priority_unqueued_ids))
print("pending_source_skill_visual_priority_unqueued_activation_summary=" + pending_source_skill_visual_priority_unqueued_activation_summary)
print("pending_source_skill_visual_priority_unqueued_damage_summary=" + pending_source_skill_visual_priority_unqueued_damage_summary)
print("pending_source_skill_visual_priority_unqueued_range_summary=" + pending_source_skill_visual_priority_unqueued_range_summary)
print("pending_source_skill_value_detail_pages=" + str(pending_source_skill_value_detail_page_count))
print("pending_source_skill_value_detail_path_text=" + pending_source_skill_value_detail_path_text)
print("pending_source_skill_value_detail_evidence_text=" + pending_source_skill_value_detail_evidence_text)
print("pending_source_skill_value_detail_locale_pages=" + str(pending_source_skill_value_detail_locale_page_count))
print("pending_source_skill_value_detail_snapshot_text=" + pending_source_skill_value_detail_snapshot_text)
print("pending_source_skill_highest_value=" + str(highest_pending_source_value))
print("pending_source_skill_highest_value_text=" + pending_source_skill_highest_value_text)
print("pending_source_skill_highest_detail_pages=" + str(pending_source_skill_highest_detail_page_count))
print("pending_source_skill_highest_detail_path_text=" + pending_source_skill_highest_detail_path_text)
print("pending_source_skill_highest_detail_evidence_text=" + pending_source_skill_highest_detail_evidence_text)
print("pending_source_skill_highest_detail_locale_pages=" + str(pending_source_skill_highest_detail_locale_page_count))
print("pending_source_skill_highest_detail_snapshot_text=" + pending_source_skill_highest_detail_snapshot_text)
print("pending_source_skill_checked_monster_attack_count=" + str(len(runtime_monster_attack_skill_ids)))
print("pending_source_skill_most_common_range=" + str(pending_source_skill_most_common_range))
print("pending_source_skill_most_common_range_count=" + str(pending_source_skill_most_common_range_count))
print("runtime_hero_base_attack_source_ids=" + ",".join(hero_base_attack_skill_ids))
print("runtime_hero_skill_source_coverage=" + ratio(len(set(runtime_hero_skill_source_ids) & set(source_skill_ids)), len(runtime_hero_skill_source_ids)))
print("runtime_monster_attack_source_ids=" + ",".join(runtime_monster_attack_skill_ids))
print("runtime_modeled_source_skill_coverage=" + ratio(len(set(runtime_modeled_source_ids) & set(source_skill_ids)), len(runtime_modeled_source_ids)))
print("runtime_skill_source_coverage=" + ratio(len(set(skill_ids) & set(source_skill_ids)), len(skill_ids)))
print("runtime_tick_interval_seconds=" + str(runtime_tick_interval))
print("combat_simulation_step_seconds=" + str(combat_simulation_step))
print("combat_delta_multiplier_percent=" + str(combat_delta_multiplier_percent))
print("combat_simulated_delta_per_tick_seconds=" + str(round(runtime_tick_interval * combat_delta_multiplier, 3)))
print("runtime_xp_multiplier_percent=" + str(runtime_xp_multiplier_percent))
print("runtime_stage_level_buffer=" + str(stage_level_buffer))
print("runtime_min_attack_interval_seconds=" + str(minimum_attack_interval))
print("runtime_min_hasted_attack_interval_seconds=" + str(minimum_hasted_attack_interval))
print("game_pacing_guard=" + ("enabled" if game_pacing_guard else "missing"))
print("settings_pacing_review_guard=" + ("enabled" if settings_pacing_review_guard else "missing"))
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
print("rune_all_hero_attack_damage_bonus=" + str(rune_all_hero_attack_damage_bonus))
print("rune_all_hero_attack_damage_percent_boost_percent=" + str(rune_all_hero_attack_damage_percent_boost_percent))
print("rune_all_hero_armor_bonus=" + str(rune_all_hero_armor_bonus))
print("rune_all_hero_armor_percent_boost_percent=" + str(rune_all_hero_armor_percent_boost_percent))
print("rune_all_hero_move_speed_bonus=" + str(rune_all_hero_move_speed_bonus))
print("rune_all_hero_attack_speed_boost_percent=" + str(rune_all_hero_attack_speed_boost_percent))
print("rune_combat_reward_runtime_nodes=" + str(rune_combat_reward_runtime_nodes))
print("rune_combat_reward_boost_percent=" + str(rune_combat_reward_boost_percent))
print("rune_cube_reward_runtime_nodes=" + str(rune_cube_reward_runtime_nodes))
print("rune_cube_reward_boost_percent=" + str(rune_cube_reward_boost_percent))
print("rune_inventory_expansion_runtime_nodes=" + str(rune_inventory_expansion_runtime_nodes))
print("rune_inventory_slot_bonus=" + str(rune_inventory_slot_bonus))
print("rune_stash_page_runtime_nodes=" + str(rune_stash_page_runtime_nodes))
print("rune_stash_page_slot_bonus=" + str(rune_stash_page_slot_bonus))
print("rune_stage_clear_target_reduction=" + str(rune_stage_clear_target_reduction))
print("rune_offline_boost_percent=" + str(rune_offline_boost_percent))
print("rune_unverified_cost_nodes=" + ",".join(unverified_cost_nodes))
print("rune_approximate_cost_nodes=" + ",".join(approximate_cost_nodes))
print("rune_approximate_cost_source_nodes=" + ",".join(approximate_cost_source_nodes))
print("rune_pending_cost_nodes=" + str(rune_pending_cost_nodes))
print("rune_pending_cost_icon_groups=" + ",".join(rune_pending_cost_icon_groups))
print("rune_pending_cost_branches=" + rune_pending_cost_branch_summary_text)
print("local_rune_cost_review_evidence_gates=" + str(local_rune_cost_evidence_gate_count))
print("local_rune_cost_review_approximate_evidence_rows=" + str(local_rune_cost_approximate_evidence_row_count))
print("local_rune_cost_review_approximate_evidence_coverage=" + str(local_rune_cost_approximate_evidence_coverage_count))
print("local_rune_cost_review_evidence_queues=" + str(local_rune_cost_evidence_queue_count))
print("local_rune_cost_review_evidence_queue_coverage=" + str(local_rune_cost_evidence_queue_coverage_count))
print("local_rune_cost_review_evidence_queue_group_coverage=" + str(local_rune_cost_evidence_queue_group_coverage_count))
print("local_rune_cost_review_branch_evidence_rows=" + str(local_rune_cost_branch_evidence_row_count))
print("local_rune_cost_review_branch_evidence_coverage=" + str(local_rune_cost_branch_evidence_coverage_count))
print("local_rune_cost_review_branch_evidence_group_coverage=" + str(local_rune_cost_branch_evidence_group_coverage_count))
print("local_rune_cost_review_max_level_evidence_queues=" + str(local_rune_cost_max_level_evidence_queue_count))
print("local_rune_cost_review_max_level_evidence_coverage=" + str(local_rune_cost_max_level_evidence_coverage_count))
print("local_rune_cost_review_max_level_evidence_icon_buckets=" + str(local_rune_cost_max_level_evidence_icon_bucket_count))
print("local_rune_cost_review_max_level_evidence_summary=" + rune_pending_cost_max_level_summary_text)
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
print("brevity_rune_runtime_guard=" + ("enabled" if brevity_rune_runtime_guard else "missing"))
print("brevity_rune_self_test_guard=" + ("enabled" if brevity_rune_self_test_guard else "missing"))
print("new_game_plus_runtime_guard=" + ("enabled" if new_game_plus_runtime_guard else "missing"))
print("new_game_plus_ui_guard=" + ("enabled" if new_game_plus_ui_guard else "missing"))
print("new_game_plus_self_test_guard=" + ("enabled" if new_game_plus_self_test_guard else "missing"))
print("new_game_plus_snapshot_guard=" + ("enabled" if new_game_plus_snapshot_guard else "missing"))
print("ground_slam_rock_runtime_guard=" + ("enabled" if ground_slam_rock_runtime_guard else "missing"))
print("ground_slam_rock_visual_guard=" + ("enabled" if ground_slam_rock_visual_guard else "missing"))
print("ground_slam_rock_self_test_guard=" + ("enabled" if ground_slam_rock_self_test_guard else "missing"))
print("ground_slam_rock_swift_test_guard=" + ("enabled" if ground_slam_rock_swift_test_guard else "missing"))
print("shield_charge_focused_runtime_guard=" + ("enabled" if shield_charge_focused_runtime_guard else "missing"))
print("shield_charge_focused_self_test_guard=" + ("enabled" if shield_charge_focused_self_test_guard else "missing"))
print("shield_charge_focused_swift_test_guard=" + ("enabled" if shield_charge_focused_swift_test_guard else "missing"))
print("axe_spin_bleed_follow_up_runtime_guard=" + ("enabled" if axe_spin_bleed_follow_up_runtime_guard else "missing"))
print("axe_spin_bleed_follow_up_self_test_guard=" + ("enabled" if axe_spin_bleed_follow_up_self_test_guard else "missing"))
print("axe_spin_bleed_follow_up_visual_guard=" + ("enabled" if axe_spin_bleed_follow_up_visual_guard else "missing"))
print("slayer_utility_visual_guard=" + ("enabled" if slayer_utility_visual_guard else "missing"))
print("slayer_utility_self_test_guard=" + ("enabled" if slayer_utility_self_test_guard else "missing"))
print("attack_speed_utility_visual_guard=" + ("enabled" if attack_speed_utility_visual_guard else "missing"))
print("attack_speed_utility_self_test_guard=" + ("enabled" if attack_speed_utility_self_test_guard else "missing"))
print("priest_utility_visual_guard=" + ("enabled" if priest_utility_visual_guard else "missing"))
print("priest_utility_self_test_guard=" + ("enabled" if priest_utility_self_test_guard else "missing"))
print("runtime_source_gear_progression_names=" + ("enabled" if source_progression_runtime_selector and loot_uses_source_progression_identity else "missing"))
print("structured_source_gear_identity=" + ("enabled" if structured_source_gear_identity else "missing"))
print("source_gear_progression_icons=" + ("enabled" if source_gear_progression_icons else "missing"))
print("synthesis_preview_source_progression=" + ("enabled" if synthesis_preview_uses_source_progression else "missing"))
print("synthesis_preview_source_examples=" + ("enabled" if synthesis_preview_uses_source_examples else "missing"))
print("legacy_item_name_inference=" + ("enabled" if legacy_item_name_inference else "missing"))
print("support_sustained_skill_runtime=" + ("enabled" if support_sustained_skill_runtime else "missing"))
print("support_sanctuary_runtime_guard=" + ("enabled" if support_sanctuary_runtime_guard else "missing"))
print("support_sanctuary_self_test_guard=" + ("enabled" if support_sanctuary_self_test_guard else "missing"))
print("support_sanctuary_swift_test_guard=" + ("enabled" if support_sanctuary_swift_test_guard else "missing"))
print("support_wrath_runtime_guard=" + ("enabled" if support_wrath_runtime_guard else "missing"))
print("support_wrath_self_test_guard=" + ("enabled" if support_wrath_self_test_guard else "missing"))
print("support_wrath_swift_test_guard=" + ("enabled" if support_wrath_swift_test_guard else "missing"))
print("support_aegis_runtime_guard=" + ("enabled" if support_aegis_runtime_guard else "missing"))
print("support_aegis_self_test_guard=" + ("enabled" if support_aegis_self_test_guard else "missing"))
print("support_aegis_swift_test_guard=" + ("enabled" if support_aegis_swift_test_guard else "missing"))
print("support_generals_cry_runtime_guard=" + ("enabled" if support_generals_cry_runtime_guard else "missing"))
print("support_generals_cry_self_test_guard=" + ("enabled" if support_generals_cry_self_test_guard else "missing"))
print("support_generals_cry_swift_test_guard=" + ("enabled" if support_generals_cry_swift_test_guard else "missing"))
print("support_bloodlust_runtime_guard=" + ("enabled" if support_bloodlust_runtime_guard else "missing"))
print("support_bloodlust_self_test_guard=" + ("enabled" if support_bloodlust_self_test_guard else "missing"))
print("support_bloodlust_swift_test_guard=" + ("enabled" if support_bloodlust_swift_test_guard else "missing"))
print("support_sacred_blade_runtime_guard=" + ("enabled" if support_sacred_blade_runtime_guard else "missing"))
print("support_sacred_blade_self_test_guard=" + ("enabled" if support_sacred_blade_self_test_guard else "missing"))
print("support_sacred_blade_swift_test_guard=" + ("enabled" if support_sacred_blade_swift_test_guard else "missing"))
print("support_quick_loader_runtime_guard=" + ("enabled" if support_quick_loader_runtime_guard else "missing"))
print("support_quick_loader_self_test_guard=" + ("enabled" if support_quick_loader_self_test_guard else "missing"))
print("support_quick_loader_swift_test_guard=" + ("enabled" if support_quick_loader_swift_test_guard else "missing"))
print("swift_surge_self_test_guard=" + ("enabled" if swift_surge_self_test_guard else "missing"))
print("swift_surge_swift_test_guard=" + ("enabled" if swift_surge_swift_test_guard else "missing"))
print("support_swift_surge_runtime_guard=" + ("enabled" if support_swift_surge_runtime_guard else "missing"))
print("support_swift_surge_self_test_guard=" + ("enabled" if support_swift_surge_self_test_guard else "missing"))
print("support_swift_surge_swift_test_guard=" + ("enabled" if support_swift_surge_swift_test_guard else "missing"))
print("support_frost_bolt_runtime_guard=" + ("enabled" if support_frost_bolt_runtime_guard else "missing"))
print("support_frost_bolt_self_test_guard=" + ("enabled" if support_frost_bolt_self_test_guard else "missing"))
print("support_frost_bolt_swift_test_guard=" + ("enabled" if support_frost_bolt_swift_test_guard else "missing"))
print("support_range_damage_runtime_guard=" + ("enabled" if support_range_damage_runtime_guard else "missing"))
print("support_range_damage_self_test_guard=" + ("enabled" if support_range_damage_self_test_guard else "missing"))
print("support_range_damage_swift_test_guard=" + ("enabled" if support_range_damage_swift_test_guard else "missing"))
print("battle_damage_log_direct_damage_entries=" + str(len(damage_log_blocks)))
print("battle_damage_log_metadata_static_guard=" + ("enabled" if battle_damage_log_metadata_static_guard else "missing"))
print("charge_trap_actual_damage_log_runtime_guard=" + ("enabled" if charge_trap_actual_damage_log_runtime_guard else "missing"))
print("charge_trap_actual_damage_log_self_test_guard=" + ("enabled" if charge_trap_actual_damage_log_self_test_guard else "missing"))
print("charge_trap_actual_damage_log_swift_test_guard=" + ("enabled" if charge_trap_actual_damage_log_swift_test_guard else "missing"))
print("battle_scene_snapshot_damage_entries=" + str(len(snapshot_damage_log_blocks)))
print("battle_scene_snapshot_damage_metadata_static_guard=" + ("enabled" if battle_scene_snapshot_damage_metadata_static_guard else "missing"))
print("battle_scene_snapshot_fixture_count=" + str(len(battle_scene_snapshot_fixture_cases)))
print("battle_scene_snapshot_audited_fixture_count=" + str(len(set(battle_scene_audit_fixture_arguments))))
print("battle_scene_snapshot_fixture_audit_guard=" + ("enabled" if battle_scene_snapshot_fixture_audit_guard else "missing"))
print("battle_scene_snapshot_fixture_cli_guard=" + ("enabled" if battle_scene_snapshot_fixture_cli_guard else "missing"))
print("battle_scene_snapshot_hero_class_cli_guard=" + ("enabled" if battle_scene_snapshot_hero_class_cli_guard else "missing"))
print("battle_scene_snapshot_time_argument_count=" + str(len(battle_scene_audit_time_arguments)))
print("battle_scene_snapshot_time_cli_guard=" + ("enabled" if battle_scene_snapshot_time_cli_guard else "missing"))
print("hero_skill_damage_metadata_runtime_guard=" + ("enabled" if hero_skill_damage_metadata_runtime_guard else "missing"))
print("hero_skill_damage_metadata_self_test_guard=" + ("enabled" if hero_skill_damage_metadata_self_test_guard else "missing"))
print("hero_skill_damage_metadata_swift_test_guard=" + ("enabled" if hero_skill_damage_metadata_swift_test_guard else "missing"))
print("core_offense_passive_runtime_guard=" + ("enabled" if core_offense_passive_runtime_guard else "missing"))
print("core_offense_passive_self_test_guard=" + ("enabled" if core_offense_passive_self_test_guard else "missing"))
print("core_offense_passive_swift_test_guard=" + ("enabled" if core_offense_passive_swift_test_guard else "missing"))
print("defensive_passive_runtime_guard=" + ("enabled" if defensive_passive_runtime_guard else "missing"))
print("defensive_passive_self_test_guard=" + ("enabled" if defensive_passive_self_test_guard else "missing"))
print("defensive_passive_swift_test_guard=" + ("enabled" if defensive_passive_swift_test_guard else "missing"))
print("monster_crit_runtime_guard=" + ("enabled" if monster_crit_runtime_guard else "missing"))
print("monster_crit_self_test_guard=" + ("enabled" if monster_crit_self_test_guard else "missing"))
print("monster_crit_swift_test_guard=" + ("enabled" if monster_crit_swift_test_guard else "missing"))
print("avoidance_passive_runtime_guard=" + ("enabled" if avoidance_passive_runtime_guard else "missing"))
print("avoidance_passive_self_test_guard=" + ("enabled" if avoidance_passive_self_test_guard else "missing"))
print("avoidance_passive_swift_test_guard=" + ("enabled" if avoidance_passive_swift_test_guard else "missing"))
print("sustain_passive_runtime_guard=" + ("enabled" if sustain_passive_runtime_guard else "missing"))
print("sustain_passive_self_test_guard=" + ("enabled" if sustain_passive_self_test_guard else "missing"))
print("sustain_passive_swift_test_guard=" + ("enabled" if sustain_passive_swift_test_guard else "missing"))
print("damage_type_passive_runtime_guard=" + ("enabled" if damage_type_passive_runtime_guard else "missing"))
print("damage_type_passive_self_test_guard=" + ("enabled" if damage_type_passive_self_test_guard else "missing"))
print("damage_type_passive_swift_test_guard=" + ("enabled" if damage_type_passive_swift_test_guard else "missing"))
print("area_damage_passive_runtime_guard=" + ("enabled" if area_damage_passive_runtime_guard else "missing"))
print("area_damage_passive_self_test_guard=" + ("enabled" if area_damage_passive_self_test_guard else "missing"))
print("area_damage_passive_swift_test_guard=" + ("enabled" if area_damage_passive_swift_test_guard else "missing"))
print("projectile_damage_passive_runtime_guard=" + ("enabled" if projectile_damage_passive_runtime_guard else "missing"))
print("projectile_damage_passive_self_test_guard=" + ("enabled" if projectile_damage_passive_self_test_guard else "missing"))
print("projectile_damage_passive_swift_test_guard=" + ("enabled" if projectile_damage_passive_swift_test_guard else "missing"))
print("skill_heal_passive_runtime_guard=" + ("enabled" if skill_heal_passive_runtime_guard else "missing"))
print("skill_heal_passive_self_test_guard=" + ("enabled" if skill_heal_passive_self_test_guard else "missing"))
print("skill_heal_passive_swift_test_guard=" + ("enabled" if skill_heal_passive_swift_test_guard else "missing"))
print("skill_duration_passive_runtime_guard=" + ("enabled" if skill_duration_passive_runtime_guard else "missing"))
print("skill_duration_passive_self_test_guard=" + ("enabled" if skill_duration_passive_self_test_guard else "missing"))
print("skill_duration_passive_swift_test_guard=" + ("enabled" if skill_duration_passive_swift_test_guard else "missing"))
print("cooldown_cast_speed_runtime_guard=" + ("enabled" if cooldown_cast_speed_runtime_guard else "missing"))
print("cooldown_cast_speed_self_test_guard=" + ("enabled" if cooldown_cast_speed_self_test_guard else "missing"))
print("cooldown_cast_speed_swift_test_guard=" + ("enabled" if cooldown_cast_speed_swift_test_guard else "missing"))
print("support_ranger_projectile_metadata_runtime_guard=" + ("enabled" if support_ranger_projectile_metadata_runtime_guard else "missing"))
print("support_ranger_projectile_metadata_self_test_guard=" + ("enabled" if support_ranger_projectile_metadata_self_test_guard else "missing"))
print("support_ranger_projectile_metadata_swift_test_guard=" + ("enabled" if support_ranger_projectile_metadata_swift_test_guard else "missing"))
print("support_charge_trap_runtime_guard=" + ("enabled" if support_charge_trap_runtime_guard else "missing"))
print("support_charge_trap_self_test_guard=" + ("enabled" if support_charge_trap_self_test_guard else "missing"))
print("support_charge_trap_swift_test_guard=" + ("enabled" if support_charge_trap_swift_test_guard else "missing"))
print("support_resurrection_runtime_guard=" + ("enabled" if support_resurrection_runtime_guard else "missing"))
print("support_resurrection_self_test_guard=" + ("enabled" if support_resurrection_self_test_guard else "missing"))
print("support_resurrection_swift_test_guard=" + ("enabled" if support_resurrection_swift_test_guard else "missing"))
print("support_unyielding_will_runtime_guard=" + ("enabled" if support_unyielding_will_runtime_guard else "missing"))
print("support_unyielding_will_self_test_guard=" + ("enabled" if support_unyielding_will_self_test_guard else "missing"))
print("support_unyielding_will_swift_test_guard=" + ("enabled" if support_unyielding_will_swift_test_guard else "missing"))
print("support_attack_count_skill_runtime=" + ("enabled" if support_attack_count_skill_runtime else "missing"))
print("support_formula_review_rows=" + str(support_formula_review_rows))
print("support_formula_attack_scalar_percent=" + str(support_formula_attack_scalar_percent))
print("support_formula_review_guard=" + ("enabled" if support_formula_review_guard else "missing"))
print("source_base_attack_metadata=" + ("enabled" if source_base_attack_metadata else "missing"))
print("source_chaos_damage_metadata=" + ("enabled" if source_chaos_damage_metadata else "missing"))
print("source_chaos_battle_scene_audit=" + ("enabled" if source_chaos_battle_scene_audit else "missing"))
print("battle_contact_pulse_audit=" + ("enabled" if battle_contact_pulse_audit else "missing"))
print("ranger_projectile_battle_scene_audit=" + ("enabled" if ranger_projectile_battle_scene_audit else "missing"))
print("hunter_bolt_battle_scene_audit=" + ("enabled" if hunter_bolt_battle_scene_audit else "missing"))
print("source_monster_attack_metadata=" + ("enabled" if source_monster_attack_metadata else "missing"))
print("warding_blessing_elemental_scope_guard=" + ("enabled" if warding_blessing_elemental_scope_guard else "missing"))
print("source_monster_incoming_visual_audit=" + ("enabled" if source_monster_incoming_visual_audit else "missing"))
print("enemy_status_body_effect_audit=" + ("enabled" if enemy_status_body_effect_audit else "missing"))
print("source_gear_rarity_counts=" + ",".join(f"{key}:{source_gear_rarity_counts[key]}" for key in sorted(source_gear_rarity_counts)))
print("source_gear_category_type_counts=" + ",".join(f"{key}:{source_gear_category_type_counts[key]}" for key in sorted(source_gear_category_type_counts)))
print("source_gear_category_entry_counts=" + ",".join(f"{key}:{source_gear_category_entry_counts[key]}" for key in sorted(source_gear_category_entry_counts)))
print("source_gear_category_progression_counts=" + ",".join(f"{key}:{source_gear_category_progression_counts[key]}" for key in sorted(source_gear_category_progression_counts)))
print("source_material_category_counts=" + ",".join(f"{key}:{source_material_category_counts[key]}" for key in sorted(source_material_category_counts)))
print("source_material_rarity_counts=" + ",".join(f"{key}:{source_material_rarity_counts[key]}" for key in sorted(source_material_rarity_counts)))
print("source_stage_chest_rarity_counts=" + ",".join(f"{key}:{source_stage_chest_rarity_counts[key]}" for key in sorted(source_stage_chest_rarity_counts)))
print("source_soul_stone_ids=" + ",".join(source_soul_stone_ids))
print("stage_code_span=" + (f"{min(stage_codes)}..{max(stage_codes)}" if stage_codes else "none"))
print("composition_name_count=" + str(len(composition_names)))
print("battle_hero_sprite_names=" + ",".join(battle_hero_sprite_names))
print("battle_hero_source_sprite_names=" + ",".join(battle_hero_source_sprite_names))
print("battle_hero_sprite_mapping_guard=" + ("enabled" if battle_hero_sprite_mapping_guard else "missing"))
print("battle_hero_source_identity_guard=" + ("enabled" if battle_hero_source_identity_guard else "missing"))
print("battle_hero_sprite_audit_guard=" + ("enabled" if battle_hero_sprite_audit_guard else "missing"))
print("battle_hero_sprite_guard=" + ("enabled" if battle_hero_sprite_guard else "missing"))
print("player_status_badge_cases=" + ",".join(player_status_badges))
print("player_active_status_skill_names=" + ",".join(skill_name for skill_name, _ in player_status_active_mappings))
print("player_continuous_status_skill_names=" + ",".join(skill_name for skill_name, _ in player_status_continuous_mappings))
print("player_deployable_skill_names=" + ",".join(skill_name for skill_name, _ in player_deployable_mappings))
print("menu_bar_popover_default_size=" + f"{menu_bar_popover_default_width}x{menu_bar_popover_default_height}")
print("menu_bar_content_min_height=" + str(menu_bar_content_min_height))
print("menu_bar_bottom_tab_guard=" + ("enabled" if menu_bar_bottom_tab_guard else "missing"))
print("battle_scene_local_render_size=" + f"{battle_scene_render_width_px}x{battle_scene_render_height_px}")
print("battle_tab_layout_render_size=" + f"{battle_tab_layout_render_width_px}x{battle_tab_layout_render_height_px}")
print("inventory_panel_render_size=" + f"{inventory_panel_render_width_px}x{inventory_panel_render_height_px}")
print("character_panel_render_size=" + f"{character_panel_render_width_px}x{character_panel_render_height_px}")
print("chest_panel_render_size=" + f"{chest_panel_render_width_px}x{chest_panel_render_height_px}")
print("original_fidelity_panel_render_size=" + f"{original_fidelity_panel_render_width_px}x{original_fidelity_panel_render_height_px}")
print("rune_evidence_panel_render_size=" + f"{rune_evidence_panel_render_width_px}x{rune_evidence_panel_render_height_px}")
print("skill_evidence_panel_render_size=" + f"{skill_evidence_panel_render_width_px}x{skill_evidence_panel_render_height_px}")
print("passive_evidence_panel_render_size=" + f"{passive_evidence_panel_render_width_px}x{passive_evidence_panel_render_height_px}")
print("battle_scene_configured_ratio=" + f"{battle_scene_configured_ratio_x100 / 100:.2f}")
print("battle_scene_local_platform_width_percent=" + str(battle_scene_local_platform_width_percent))
print("battle_scene_local_audit_guard=" + ("enabled" if battle_scene_local_audit_guard else "missing"))
print("official_steam_battle_motion_guard=" + ("enabled" if official_steam_battle_motion_guard else "missing"))
print("battle_scene_self_test_guard=" + ("enabled" if battle_scene_self_test_guard else "missing"))
print("source_range_visual_guard=" + ("enabled" if source_range_visual_guard else "missing"))
print("battle_log_visible_entries=" + str(battle_log_visible_entries))
print("battle_log_hero_highlight_entries=" + str(battle_log_hero_highlight_entries))
print("battle_log_panel_height=" + str(battle_log_panel_height_value))
print("battle_log_self_test_guard=" + ("enabled" if battle_log_self_test_guard else "missing"))
print("battle_log_panel_snapshot_guard=" + ("enabled" if battle_log_panel_snapshot_guard else "missing"))
print("battle_tab_layout_snapshot_guard=" + ("enabled" if battle_tab_layout_snapshot_guard else "missing"))
print("inventory_panel_snapshot_guard=" + ("enabled" if inventory_panel_snapshot_guard else "missing"))
print("character_panel_snapshot_guard=" + ("enabled" if character_panel_snapshot_guard else "missing"))
print("chest_panel_snapshot_guard=" + ("enabled" if chest_panel_snapshot_guard else "missing"))
print("original_fidelity_panel_snapshot_guard=" + ("enabled" if original_fidelity_panel_snapshot_guard else "missing"))
print("rune_evidence_panel_snapshot_guard=" + ("enabled" if rune_evidence_panel_snapshot_guard else "missing"))
print("skill_evidence_panel_snapshot_guard=" + ("enabled" if skill_evidence_panel_snapshot_guard else "missing"))
print("passive_evidence_panel_snapshot_guard=" + ("enabled" if passive_evidence_panel_snapshot_guard else "missing"))
print("battle_log_element_label_guard=" + ("enabled" if battle_log_element_label_guard else "missing"))
print("battle_log_action_text_guard=" + ("enabled" if battle_log_action_text_guard else "missing"))
print("battle_floating_damage_text_guard=" + ("enabled" if battle_floating_damage_text_guard else "missing"))
print("battle_floating_damage_style_guard=" + ("enabled" if battle_floating_damage_style_guard else "missing"))
print("battle_floating_avoidance_snapshot_guard=" + ("enabled" if battle_floating_avoidance_snapshot_guard else "missing"))
print("battle_floating_critical_snapshot_guard=" + ("enabled" if battle_floating_critical_snapshot_guard else "missing"))
print("battle_finish_cue_snapshot_guard=" + ("enabled" if battle_finish_cue_snapshot_guard else "missing"))
print("battle_reward_loot_icon_guard=" + ("enabled" if battle_reward_loot_icon_guard else "missing"))
print("battle_reward_level_cap_guard=" + ("enabled" if battle_reward_level_cap_guard else "missing"))
print("battle_reward_banner_snapshot_guard=" + ("enabled" if battle_reward_banner_snapshot_guard else "missing"))
print("original_fidelity_hard_gap_rows=" + str(original_fidelity_hard_gap_row_count))
print("source_item_database_guard=" + ("enabled" if source_item_database_view else "missing"))
print("exact_item_record_gap_guard=" + ("enabled" if exact_item_record_gap_view else "missing"))
print("exact_item_record_gap_evidence_gates=" + str(exact_item_record_gap_evidence_gate_count))
print("exact_item_record_gap_category_queues=" + str(exact_item_record_gap_category_queue_count))
print("exact_item_record_gap_rarity_queues=" + str(exact_item_record_gap_rarity_queue_count))
print("exact_item_record_gap_category_rarity_queues=" + str(exact_item_record_gap_category_rarity_queue_count))
print("exact_item_record_gap_progression_queues=" + str(exact_item_record_gap_progression_queue_count))
print("exact_item_record_gap_type_queues=" + str(exact_item_record_gap_type_queue_count))
print("exact_item_record_gap_largest_type_queues=" + str(exact_item_record_gap_largest_type_queue_count))
print("exact_item_record_gap_queue_coverage=" + str(exact_item_record_gap_queue_coverage_count))
print("exact_item_record_gap_rarity_queue_coverage=" + str(exact_item_record_gap_rarity_queue_coverage_count))
print("exact_item_record_gap_category_rarity_queue_coverage=" + str(exact_item_record_gap_category_rarity_queue_coverage_count))
print("exact_item_record_gap_progression_queue_coverage=" + str(exact_item_record_gap_progression_queue_coverage_count))
print("exact_item_record_gap_largest_type_queue_coverage=" + str(exact_item_record_gap_largest_type_queue_coverage_count))
print("source_crafting_rule_review_guard=" + ("enabled" if source_crafting_rule_review_view else "missing"))
print("source_monster_database_guard=" + ("enabled" if source_monster_database_view else "missing"))
print("source_monster_database_rows=" + str(len(source_monster_database_ids)))
print("source_monster_database_unique_ids=" + str(len(set(source_monster_database_ids))))
print("source_monster_database_unique_names=" + str(len(source_monster_database_names)))
print("source_monster_source_roster_identity_coverage=" + str(len(source_monster_database_names)) + "/" + str(ORIGINAL["monster_types_min"]) + "+")
print("source_monster_source_roster_steam_gap=" + str(source_monster_source_roster_steam_gap_count))
print("source_monster_database_stage_coverage=" + str(source_monster_database_stage_coverage) + "/" + str(len(composition_names)))
print("source_monster_database_unmapped_stage_rows=" + str(source_monster_database_unmapped_stage_count))
print("source_monster_database_unmapped_stage_names=" + ",".join(source_monster_database_unmapped_stage_names))
print("source_monster_source_only_sprites=" + str(source_monster_source_only_sprite_count) + "/" + str(source_monster_database_unmapped_stage_count))
print("source_monster_source_only_sprite_resources=" + ",".join(source_monster_source_only_sprite_resource_names))
print("source_monster_source_only_sprite_preview_rows=" + str(source_monster_source_only_sprite_preview_count) + "/" + str(source_monster_source_only_sprite_count))
print("source_monster_source_only_proof_rows=" + str(source_monster_source_only_proof_rows_count))
print("source_monster_source_only_proof_coverage=" + str(source_monster_source_only_proof_coverage_count) + "/" + str(source_monster_database_unmapped_stage_count))
print("source_monster_source_stage_evidence_rows=" + str(source_monster_source_stage_evidence_row_count))
print("source_monster_source_stage_appearance_confirmed=" + str(source_monster_source_stage_appearance_confirmed_count))
print("source_monster_source_stage_appearance_absent=" + str(source_monster_source_stage_appearance_absent_count))
print("source_monster_source_stage_appearance_rows_total=" + str(source_monster_source_stage_appearance_rows_total))
print("source_monster_source_stage_crosscheck_pages=" + str(source_monster_source_stage_crosscheck_page_count))
print("source_monster_source_page_field_rows=" + str(source_monster_source_page_field_row_count))
print("source_monster_source_page_field_sprite_paths=" + str(source_monster_source_page_field_sprite_path_count))
print("source_monster_source_page_field_move_known=" + str(source_monster_source_page_field_move_known_count))
print("source_monster_source_page_field_damage_known=" + str(source_monster_source_page_field_damage_known_count))
print("source_monster_source_page_field_range_known=" + str(source_monster_source_page_field_range_known_count))
print("source_monster_source_page_field_unknown_damage_range=" + str(source_monster_source_page_field_unknown_damage_range_count))
print("source_monster_source_only_stage_proof_missing=" + str(source_monster_source_only_stage_proof_missing_count))
print("source_monster_source_only_runtime_blocked=" + str(source_monster_source_only_runtime_blocked_count))
print("source_monster_source_only_skill_ownership_unproven=" + str(source_monster_source_only_skill_ownership_unproven_count))
print("source_monster_source_only_animation_frame_missing=" + str(source_monster_source_only_animation_frame_missing_count))
print("source_monster_source_only_sfx_missing=" + str(source_monster_source_only_sfx_missing_count))
print("source_monster_unmapped_evidence_gates=" + str(source_monster_unmapped_evidence_gate_count))
print("source_monster_unmapped_evidence_queues=" + str(source_monster_unmapped_evidence_queue_count))
print("source_monster_unmapped_evidence_queue_coverage=" + str(source_monster_unmapped_evidence_queue_coverage_count))
print("source_monster_unmapped_candidate_skill_ids=" + ",".join(source_monster_unmapped_candidate_skill_ids))
print("source_monster_unmapped_candidate_skills=" + str(source_monster_unmapped_candidate_skill_count))
print("source_monster_runtime_stats_guard=" + ("enabled" if source_monster_runtime_stats_guard else "missing"))
print("source_monster_source_cooldown_range=" + f"{source_monster_source_cooldown_min_tenths / 10:g}s-{source_monster_source_cooldown_max_tenths / 10:g}s")
print("source_monster_loop_cooldown_range=" + f"{source_monster_loop_cooldown_min_tenths / 10:g}s-{source_monster_loop_cooldown_max_tenths / 10:g}s")
print("source_monster_art_mapping_guard=" + ("enabled" if source_monster_art_mapping_view else "missing"))
print("source_monster_art_evidence_gates=" + str(source_monster_art_evidence_gate_count))
print("source_monster_art_evidence_queues=" + str(source_monster_art_evidence_queue_count))
print("source_monster_art_evidence_queue_coverage=" + str(source_monster_art_evidence_queue_coverage_count))
print("source_monster_art_evidence_queue_roster_gap=" + str(source_monster_art_evidence_queue_roster_gap_count))
print("source_monster_art_evidence_queue_source_roster_gap=" + str(source_monster_art_evidence_queue_source_roster_gap_count))
print("source_monster_stage_composition_coverage=" + str(len(composition_names)) + "/" + str(len(source_monster_database_names)))
print("source_monster_attack_review_guard=" + ("enabled" if source_monster_attack_review_view else "missing"))
print("source_monster_attack_evidence_gates=" + str(source_monster_attack_evidence_gate_count))
print("local_skill_runtime_coverage_guard=" + ("enabled" if local_skill_runtime_coverage_view else "missing"))
print("source_skill_damage_review_guard=" + ("enabled" if source_skill_damage_review_view else "missing"))
print("source_skill_activation_damage_review_guard=" + ("enabled" if source_skill_activation_damage_review_view else "missing"))
print("source_skill_activation_delivery_review_guard=" + ("enabled" if source_skill_activation_delivery_review_view else "missing"))
print("source_skill_damage_delivery_review_guard=" + ("enabled" if source_skill_damage_delivery_review_view else "missing"))
print("source_skill_delivery_review_guard=" + ("enabled" if source_skill_delivery_review_view else "missing"))
print("source_skill_range_review_guard=" + ("enabled" if source_skill_range_review_view else "missing"))
print("pending_source_skill_review_guard=" + ("enabled" if pending_source_skill_review_view else "missing"))
print("modeled_active_skill_value_review_guard=" + ("enabled" if modeled_active_skill_value_review_view else "missing"))
print("source_passive_skill_database_guard=" + ("enabled" if source_passive_skill_database_view else "missing"))
print("derived_skill_damage_metadata_runtime_guard=" + ("enabled" if derived_skill_damage_metadata_runtime_guard else "missing"))
print("derived_skill_damage_metadata_self_test_guard=" + ("enabled" if derived_skill_damage_metadata_self_test_guard else "missing"))
print("derived_skill_damage_metadata_swift_test_guard=" + ("enabled" if derived_skill_damage_metadata_swift_test_guard else "missing"))
print("settings_fidelity_boundary_guard=" + ("enabled" if settings_fidelity_boundary_view else "missing"))
print("local_rune_cost_review_guard=" + ("enabled" if local_rune_cost_review_view else "missing"))
print("source_rune_evidence_review_guard=" + ("enabled" if source_rune_evidence_review_view else "missing"))
print("source_rune_evidence_review_rows=" + str(source_rune_evidence_review_rows))
print("source_rune_evidence_independent_sources=" + str(source_rune_evidence_independent_sources))
print("source_rune_evidence_verified_cost_rows=" + str(source_rune_evidence_verified_cost_rows))
print("source_rune_evidence_candidate_cost_rows=" + str(source_rune_evidence_candidate_cost_rows))
print("source_rune_evidence_candidate_cost_gold_total=" + str(source_rune_evidence_candidate_cost_gold_total))
print("source_rune_tbh_city_candidate_cost_table_guard=" + ("enabled" if source_rune_tbh_city_candidate_cost_table_guard else "missing"))
print("source_rune_tbh_city_candidate_cost_table_rows=" + str(source_rune_tbh_city_candidate_cost_table_rows))
print("source_rune_tbh_city_candidate_cost_table_gold_total=" + str(source_rune_tbh_city_candidate_cost_table_gold_total))
print("source_rune_candidate_cost_queue_guard=" + ("enabled" if source_rune_candidate_cost_queue_guard else "missing"))
print("source_rune_candidate_cost_queues=" + str(source_rune_candidate_cost_queue_rows))
print("source_rune_candidate_cost_queue_coverage=" + str(source_rune_candidate_cost_queue_coverage))
print("source_rune_candidate_cost_queue_gold_total=" + str(source_rune_candidate_cost_queue_gold_total))
print("source_rune_candidate_cost_queue_keys=" + ",".join(source_rune_candidate_cost_queue_keys))
print("source_rune_evidence_timer_rows=" + str(source_rune_evidence_timer_rows))
print("source_audio_sfx_evidence_guard=" + ("enabled" if source_audio_sfx_evidence_guard else "missing"))
print("source_audio_sfx_manifest_guard=" + ("enabled" if source_audio_sfx_manifest_guard else "missing"))
print("source_audio_sfx_evidence_rows=" + str(source_audio_sfx_evidence_rows))
print("source_audio_sfx_event_gate_rows=" + str(source_audio_sfx_event_gate_rows))
print("source_audio_sfx_local_events=" + str(source_audio_sfx_local_events))
print("source_audio_sfx_local_resources=" + str(source_audio_sfx_local_resources))
print("source_audio_sfx_original_isolated=" + str(source_audio_sfx_original_isolated))
print("source_audio_sfx_steam_duration_seconds=" + str(source_audio_sfx_steam_duration_seconds))
print("source_audio_sfx_steam_sample_rate_hz=" + str(source_audio_sfx_steam_sample_rate_hz))
print("source_battle_animation_evidence_guard=" + ("enabled" if source_battle_animation_evidence_guard else "missing"))
print("source_battle_animation_evidence_rows=" + str(source_battle_animation_evidence_rows))
print("source_battle_animation_motion_sample_rows=" + str(source_battle_animation_motion_sample_rows))
print("source_battle_animation_action_frame_gate_rows=" + str(source_battle_animation_action_frame_gate_rows))
print("source_battle_animation_official_size=" + f"{source_battle_animation_official_width}x{source_battle_animation_official_height}")
print("source_battle_animation_official_fps=" + str(source_battle_animation_official_fps))
print("source_battle_animation_official_duration_ms=" + str(source_battle_animation_official_duration_ms))
print("source_battle_animation_official_frames=" + str(source_battle_animation_official_frames))
print("source_battle_animation_official_motion_sample_ms=" + str(source_battle_animation_official_motion_sample_ms))
print("source_battle_animation_official_motion_pixels=" + str(source_battle_animation_official_motion_pixels))
print("source_battle_animation_official_platform_motion_pixels=" + str(source_battle_animation_official_platform_motion_pixels))
print("source_battle_animation_official_non_platform_motion_pixels=" + str(source_battle_animation_official_non_platform_motion_pixels))
print("source_battle_animation_official_motion_percent_x10000=" + str(source_battle_animation_official_motion_percent_x10000))
print("source_battle_animation_local_render_size=" + f"{source_battle_animation_local_render_width_px}x{source_battle_animation_local_render_height_px}")
print("source_battle_animation_local_battle_tab_render_size=" + f"{source_battle_animation_local_battle_tab_width_px}x{source_battle_animation_local_battle_tab_height_px}")
print("source_battle_animation_local_ratio=" + f"{source_battle_animation_local_ratio_x100 / 100:.2f}")
print("source_battle_animation_local_layout_footprint=" + f"{source_battle_animation_local_popover_width_pt}x{source_battle_animation_local_popover_height_pt}pt/content{source_battle_animation_local_content_height_pt}pt/scene{source_battle_animation_local_battle_scene_height_pt}pt/tab{source_battle_animation_local_bottom_tab_height_pt}pt")
print("source_battle_animation_exact_action_frames=" + str(source_battle_animation_exact_action_frames))
print("auto_open_cooldown_runtime_guard=" + ("enabled" if auto_open_cooldown_runtime_guard else "missing"))
print("auto_open_cooldown_save_guard=" + ("enabled" if auto_open_cooldown_save_guard else "missing"))
print("rune_auto_open_normal_base_cooldown_seconds=" + str(rune_auto_open_normal_base_cooldown_seconds))
print("rune_auto_open_stage_boss_base_cooldown_seconds=" + str(rune_auto_open_stage_boss_base_cooldown_seconds))
print("rune_auto_open_act_boss_base_cooldown_seconds=" + str(rune_auto_open_act_boss_base_cooldown_seconds))
print("rune_auto_open_normal_reduction_seconds=" + str(rune_auto_open_normal_reduction_seconds))
print("rune_auto_open_stage_boss_reduction_seconds=" + str(rune_auto_open_stage_boss_reduction_seconds))
print("rune_auto_open_act_boss_reduction_seconds=" + str(rune_auto_open_act_boss_reduction_seconds))

if issues:
    print()
    for issue in issues:
        print(f"gameplay_fidelity_issue={issue}", file=sys.stderr)
    sys.exit(1)

print("local gameplay fidelity audit passed")
PY
