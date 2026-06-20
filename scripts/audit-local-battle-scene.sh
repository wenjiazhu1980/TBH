#!/usr/bin/env bash
set -euo pipefail

app_name="${APP_NAME:-TBH}"
keep_screenshot="${KEEP_SCREENSHOT:-0}"
input_screenshot="${SCREENSHOT_PATH:-}"
render_snapshot="${RENDER_BATTLE_SCENE:-1}"
capture_running_app="${CAPTURE_RUNNING_APP:-0}"
packaged_render="${PACKAGED_BATTLE_SCENE_RENDER:-0}"
motion_sample_time_seconds="0.267"
packaged_tbh_binary="${PACKAGED_TBH_BINARY:-dist/TBH.app/Contents/MacOS/TBH}"
packaged_tbh_resource_bundle="${PACKAGED_TBH_RESOURCE_BUNDLE:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle}"
packaged_cli_binary=""
rendered_snapshot=0
tmpdir="$(mktemp -d)"
screenshot_path="$tmpdir/tbh-local-battle-scene.png"
motion_screenshot_path="$tmpdir/tbh-local-battle-scene-motion.png"
melee_arc_screenshot_path="$tmpdir/tbh-local-battle-scene-melee-arc.png"
rapid_volley_screenshot_path="$tmpdir/tbh-local-battle-scene-rapid-volley.png"
scatter_shot_screenshot_path="$tmpdir/tbh-local-battle-scene-scatter-shot.png"
arrow_rain_screenshot_path="$tmpdir/tbh-local-battle-scene-arrow-rain.png"
piercing_arrow_screenshot_path="$tmpdir/tbh-local-battle-scene-piercing-arrow.png"
skewer_shot_screenshot_path="$tmpdir/tbh-local-battle-scene-skewer-shot.png"
explosive_bolt_screenshot_path="$tmpdir/tbh-local-battle-scene-explosive-bolt.png"
meteor_strike_screenshot_path="$tmpdir/tbh-local-battle-scene-meteor-strike.png"
lightning_strike_screenshot_path="$tmpdir/tbh-local-battle-scene-lightning-strike.png"
shock_bolt_screenshot_path="$tmpdir/tbh-local-battle-scene-shock-bolt.png"
trap_burst_screenshot_path="$tmpdir/tbh-local-battle-scene-trap-burst.png"
summon_projectile_screenshot_path="$tmpdir/tbh-local-battle-scene-summon-projectile.png"
shock_current_screenshot_path="$tmpdir/tbh-local-battle-scene-shock-current.png"
shield_charge_screenshot_path="$tmpdir/tbh-local-battle-scene-shield-charge.png"
slam_jump_screenshot_path="$tmpdir/tbh-local-battle-scene-slam-jump.png"
earthquake_impact_screenshot_path="$tmpdir/tbh-local-battle-scene-earthquake-impact.png"
rock_explosion_screenshot_path="$tmpdir/tbh-local-battle-scene-rock-explosion.png"
axe_spin_screenshot_path="$tmpdir/tbh-local-battle-scene-axe-spin.png"
axe_spin_bleed_screenshot_path="$tmpdir/tbh-local-battle-scene-axe-spin-bleed-follow-up.png"
shockwave_impact_screenshot_path="$tmpdir/tbh-local-battle-scene-shockwave-impact.png"
chaos_burst_screenshot_path="$tmpdir/tbh-local-battle-scene-chaos-burst.png"
monster_fire_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-fire-incoming.png"
monster_cold_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-cold-incoming.png"
monster_lightning_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-lightning-incoming.png"
monster_chaos_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-chaos-incoming.png"
enemy_status_effects_screenshot_path="$tmpdir/tbh-local-battle-scene-enemy-status-effects.png"
contact_pulse_baseline_screenshot_path="$tmpdir/tbh-local-battle-scene-contact-pulse-baseline.png"
hero_contact_pulse_screenshot_path="$tmpdir/tbh-local-battle-scene-hero-contact-pulse.png"
monster_contact_pulse_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-contact-pulse.png"
heal_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-heal-utility.png"
sanctuary_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-sanctuary-utility.png"
resurrection_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-resurrection-utility.png"
shield_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-shield-utility.png"
wrath_of_heaven_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-wrath-of-heaven-utility.png"
sacred_blade_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-sacred-blade-utility.png"
swift_surge_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-swift-surge-utility.png"
quick_loader_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-quick-loader-utility.png"
generals_cry_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-generals-cry-utility.png"
bloodlust_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-bloodlust-utility.png"
critical_floating_screenshot_path="$tmpdir/tbh-local-battle-scene-critical-floating.png"
dodge_floating_screenshot_path="$tmpdir/tbh-local-battle-scene-dodge-floating.png"
block_floating_screenshot_path="$tmpdir/tbh-local-battle-scene-block-floating.png"
victory_finish_scene_screenshot_path="$tmpdir/tbh-local-battle-scene-victory-finish.png"
defeat_finish_scene_screenshot_path="$tmpdir/tbh-local-battle-scene-defeat-finish.png"
status_row_screenshot_path="$tmpdir/tbh-local-battle-status-row.png"
crowded_status_row_screenshot_path="$tmpdir/tbh-local-battle-status-row-crowded.png"
battle_log_panel_screenshot_path="$tmpdir/tbh-local-battle-log-panel.png"
victory_reward_banner_screenshot_path="$tmpdir/tbh-local-victory-reward-banner.png"
victory_level_cap_banner_screenshot_path="$tmpdir/tbh-local-victory-level-cap-banner.png"
completion_settlement_screenshot_path="$tmpdir/tbh-local-completion-settlement.png"
battle_tab_layout_screenshot_path="$tmpdir/tbh-local-battle-tab-layout.png"
inventory_panel_screenshot_path="$tmpdir/tbh-local-inventory-panel.png"
character_panel_screenshot_path="$tmpdir/tbh-local-character-panel.png"
chest_panel_screenshot_path="$tmpdir/tbh-local-chest-panel.png"
original_fidelity_panel_screenshot_path="$tmpdir/tbh-local-original-fidelity-panel.png"
rune_evidence_panel_screenshot_path="$tmpdir/tbh-local-rune-evidence-panel.png"
skill_evidence_panel_screenshot_path="$tmpdir/tbh-local-skill-evidence-panel.png"
passive_evidence_panel_screenshot_path="$tmpdir/tbh-local-passive-evidence-panel.png"

cleanup() {
  if [[ "$keep_screenshot" == "1" ]]; then
    echo "Kept local screenshot in: $tmpdir"
  else
    rm -rf "$tmpdir"
  fi
}
trap cleanup EXIT

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

render_battle_scene_snapshot() {
  local render_source="swiftpm"
  if [[ "$packaged_render" == "1" ]]; then
    render_source="packaged"
    if [[ ! -x "$packaged_tbh_binary" ]]; then
      echo "PACKAGED_TBH_BINARY is not executable: $packaged_tbh_binary" >&2
      exit 2
    fi
    if [[ ! -d "$packaged_tbh_resource_bundle" ]]; then
      echo "PACKAGED_TBH_RESOURCE_BUNDLE does not exist: $packaged_tbh_resource_bundle" >&2
      exit 2
    fi
    local packaged_cli_dir="$tmpdir/tbh-packaged-cli"
    mkdir -p "$packaged_cli_dir"
    cp "$packaged_tbh_binary" "$packaged_cli_dir/TBH"
    cp -R "$packaged_tbh_resource_bundle" "$packaged_cli_dir/"
    packaged_cli_binary="$packaged_cli_dir/TBH"
  else
    require_tool swift
  fi

  echo "Rendering deterministic local battle scene snapshot via $render_source..."
  render_battle_scene_snapshot_one "$screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture frostBolt
  render_battle_scene_snapshot_one "$motion_screenshot_path" --render-battle-scene-time "$motion_sample_time_seconds" \
    --render-battle-scene-fixture frostBolt
  render_battle_scene_snapshot_one "$melee_arc_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture meleeArc
  render_battle_scene_snapshot_one "$rapid_volley_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture rapidVolley
  render_battle_scene_snapshot_one "$scatter_shot_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture scatterShot
  render_battle_scene_snapshot_one "$arrow_rain_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture arrowRain
  render_battle_scene_snapshot_one "$piercing_arrow_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture piercingArrow
  render_battle_scene_snapshot_one "$skewer_shot_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture skewerShot
  render_battle_scene_snapshot_one "$explosive_bolt_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture explosiveBolt
  render_battle_scene_snapshot_one "$meteor_strike_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture meteorStrike
  render_battle_scene_snapshot_one "$lightning_strike_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture lightningStrike
  render_battle_scene_snapshot_one "$shock_bolt_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture shockBolt
  render_battle_scene_snapshot_one "$trap_burst_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture trapBurst
  render_battle_scene_snapshot_one "$summon_projectile_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture summonProjectile
  render_battle_scene_snapshot_one "$shock_current_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture shockCurrent
  render_battle_scene_snapshot_one "$shield_charge_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture shieldCharge
  render_battle_scene_snapshot_one "$slam_jump_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture slamJump
  render_battle_scene_snapshot_one "$earthquake_impact_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture earthquakeImpact
  render_battle_scene_snapshot_one "$rock_explosion_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture earthquakeRockExplosion
  render_battle_scene_snapshot_one "$axe_spin_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture axeSpin
  render_battle_scene_snapshot_one "$axe_spin_bleed_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture axeSpinBleedFollowUp
  render_battle_scene_snapshot_one "$shockwave_impact_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture shockwaveImpact
  render_battle_scene_snapshot_one "$chaos_burst_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture chaosBurst
  render_battle_scene_snapshot_one "$monster_fire_incoming_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture monsterFireIncoming
  render_battle_scene_snapshot_one "$monster_cold_incoming_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture monsterColdIncoming
  render_battle_scene_snapshot_one "$monster_lightning_incoming_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture monsterLightningIncoming
  render_battle_scene_snapshot_one "$monster_chaos_incoming_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture monsterChaosIncoming
  render_battle_scene_snapshot_one "$enemy_status_effects_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture enemyStatusEffects
  render_battle_scene_snapshot_one "$contact_pulse_baseline_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture contactPulseBaseline
  render_battle_scene_snapshot_one "$hero_contact_pulse_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture heroContactPulse
  render_battle_scene_snapshot_one "$monster_contact_pulse_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture monsterContactPulse
  render_battle_scene_snapshot_one "$heal_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture healUtility
  render_battle_scene_snapshot_one "$sanctuary_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture sanctuaryUtility
  render_battle_scene_snapshot_one "$resurrection_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture resurrectionUtility
  render_battle_scene_snapshot_one "$shield_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture shieldUtility
  render_battle_scene_snapshot_one "$wrath_of_heaven_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture wrathOfHeavenUtility
  render_battle_scene_snapshot_one "$sacred_blade_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture sacredBladeUtility
  render_battle_scene_snapshot_one "$swift_surge_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture swiftSurgeUtility
  render_battle_scene_snapshot_one "$quick_loader_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture quickLoaderUtility
  render_battle_scene_snapshot_one "$generals_cry_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture generalsCryUtility
  render_battle_scene_snapshot_one "$bloodlust_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture bloodlustUtility
  render_battle_scene_snapshot_one "$critical_floating_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture criticalFloating
  render_battle_scene_snapshot_one "$dodge_floating_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture dodgeFloating
  render_battle_scene_snapshot_one "$block_floating_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture blockFloating
  render_battle_scene_snapshot_one "$victory_finish_scene_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture victoryFinishScene
  render_battle_scene_snapshot_one "$defeat_finish_scene_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture defeatFinishScene
  render_battle_scene_snapshot_one "$status_row_screenshot_path" \
    --render-battle-scene-fixture playerStatusRow
  render_battle_scene_snapshot_one "$crowded_status_row_screenshot_path" \
    --render-battle-scene-fixture playerStatusRowCrowded
  render_battle_scene_snapshot_one "$battle_log_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture battleLogPanel
  render_battle_scene_snapshot_one "$victory_reward_banner_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture victoryRewardBanner
  render_battle_scene_snapshot_one "$victory_level_cap_banner_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture victoryLevelCapBanner
  render_battle_scene_snapshot_one "$completion_settlement_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture completionSettlement
  render_battle_scene_snapshot_one "$battle_tab_layout_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture battleTabLayout
  render_battle_scene_snapshot_one "$inventory_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture inventoryPanel
  render_battle_scene_snapshot_one "$character_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture characterPanel
  render_battle_scene_snapshot_one "$chest_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture chestPanel
  render_battle_scene_snapshot_one "$original_fidelity_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture originalFidelityPanel
  render_battle_scene_snapshot_one "$rune_evidence_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture runeEvidencePanel
  render_battle_scene_snapshot_one "$skill_evidence_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture skillEvidencePanel
  render_battle_scene_snapshot_one "$passive_evidence_panel_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture passiveEvidencePanel
  rendered_snapshot=1
}

render_battle_scene_snapshot_one() {
  local output_path="$1"
  shift

  if [[ "$packaged_render" == "1" ]]; then
    "$packaged_cli_binary" --render-battle-scene "$output_path" "$@" >/dev/null
  else
    env CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/clang-module-cache}" \
      swift run --disable-sandbox --disable-index-store TBH --render-battle-scene "$output_path" "$@" >/dev/null
  fi
}

if [[ -n "$input_screenshot" ]]; then
  if [[ ! -f "$input_screenshot" ]]; then
    echo "SCREENSHOT_PATH does not exist: $input_screenshot" >&2
    exit 2
  fi
  screenshot_path="$input_screenshot"
elif [[ "$render_snapshot" == "1" ]]; then
  render_battle_scene_snapshot
else
  if [[ "$capture_running_app" != "1" ]]; then
    render_battle_scene_snapshot
  elif ! pgrep -x "$app_name" >/dev/null 2>&1; then
    render_battle_scene_snapshot
  else
    require_tool osascript
    require_tool screencapture
  fi
fi

click_status_item() {
  osascript <<APPLESCRIPT
tell application "System Events"
  if not (exists process "$app_name") then error "$app_name process is not visible to System Events"
  tell process "$app_name"
    click menu bar item 1 of menu bar 2
  end tell
end tell
APPLESCRIPT
}

analyze_screenshot() {
  local check_party_layout="${CHECK_PARTY_LAYOUT:-$rendered_snapshot}"
  local motion_path="${MOTION_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    motion_path="$motion_screenshot_path"
  fi
  local melee_arc_path="${MELEE_ARC_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    melee_arc_path="$melee_arc_screenshot_path"
  fi
  local rapid_volley_path="${RAPID_VOLLEY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    rapid_volley_path="$rapid_volley_screenshot_path"
  fi
  local scatter_shot_path="${SCATTER_SHOT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    scatter_shot_path="$scatter_shot_screenshot_path"
  fi
  local arrow_rain_path="${ARROW_RAIN_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    arrow_rain_path="$arrow_rain_screenshot_path"
  fi
  local piercing_arrow_path="${PIERCING_ARROW_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    piercing_arrow_path="$piercing_arrow_screenshot_path"
  fi
  local skewer_shot_path="${SKEWER_SHOT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    skewer_shot_path="$skewer_shot_screenshot_path"
  fi
  local explosive_bolt_path="${EXPLOSIVE_BOLT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    explosive_bolt_path="$explosive_bolt_screenshot_path"
  fi
  local meteor_strike_path="${METEOR_STRIKE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    meteor_strike_path="$meteor_strike_screenshot_path"
  fi
  local lightning_strike_path="${LIGHTNING_STRIKE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    lightning_strike_path="$lightning_strike_screenshot_path"
  fi
  local shock_bolt_path="${SHOCK_BOLT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    shock_bolt_path="$shock_bolt_screenshot_path"
  fi
  local trap_burst_path="${TRAP_BURST_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    trap_burst_path="$trap_burst_screenshot_path"
  fi
  local summon_projectile_path="${SUMMON_PROJECTILE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    summon_projectile_path="$summon_projectile_screenshot_path"
  fi
  local shock_current_path="${SHOCK_CURRENT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    shock_current_path="$shock_current_screenshot_path"
  fi
  local shield_charge_path="${SHIELD_CHARGE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    shield_charge_path="$shield_charge_screenshot_path"
  fi
  local slam_jump_path="${SLAM_JUMP_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    slam_jump_path="$slam_jump_screenshot_path"
  fi
  local earthquake_impact_path="${EARTHQUAKE_IMPACT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    earthquake_impact_path="$earthquake_impact_screenshot_path"
  fi
  local rock_explosion_path="${ROCK_EXPLOSION_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    rock_explosion_path="$rock_explosion_screenshot_path"
  fi
  local axe_spin_path="${AXE_SPIN_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    axe_spin_path="$axe_spin_screenshot_path"
  fi
  local axe_spin_bleed_path="${AXE_SPIN_BLEED_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    axe_spin_bleed_path="$axe_spin_bleed_screenshot_path"
  fi
  local shockwave_impact_path="${SHOCKWAVE_IMPACT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    shockwave_impact_path="$shockwave_impact_screenshot_path"
  fi
  local chaos_burst_path="${CHAOS_BURST_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    chaos_burst_path="$chaos_burst_screenshot_path"
  fi
  local monster_fire_incoming_path="${MONSTER_FIRE_INCOMING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    monster_fire_incoming_path="$monster_fire_incoming_screenshot_path"
  fi
  local monster_cold_incoming_path="${MONSTER_COLD_INCOMING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    monster_cold_incoming_path="$monster_cold_incoming_screenshot_path"
  fi
  local monster_lightning_incoming_path="${MONSTER_LIGHTNING_INCOMING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    monster_lightning_incoming_path="$monster_lightning_incoming_screenshot_path"
  fi
  local monster_chaos_incoming_path="${MONSTER_CHAOS_INCOMING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    monster_chaos_incoming_path="$monster_chaos_incoming_screenshot_path"
  fi
  local enemy_status_effects_path="${ENEMY_STATUS_EFFECTS_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    enemy_status_effects_path="$enemy_status_effects_screenshot_path"
  fi
  local contact_pulse_baseline_path="${CONTACT_PULSE_BASELINE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    contact_pulse_baseline_path="$contact_pulse_baseline_screenshot_path"
  fi
  local hero_contact_pulse_path="${HERO_CONTACT_PULSE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    hero_contact_pulse_path="$hero_contact_pulse_screenshot_path"
  fi
  local monster_contact_pulse_path="${MONSTER_CONTACT_PULSE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    monster_contact_pulse_path="$monster_contact_pulse_screenshot_path"
  fi
  local heal_utility_path="${HEAL_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    heal_utility_path="$heal_utility_screenshot_path"
  fi
  local sanctuary_utility_path="${SANCTUARY_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    sanctuary_utility_path="$sanctuary_utility_screenshot_path"
  fi
  local resurrection_utility_path="${RESURRECTION_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    resurrection_utility_path="$resurrection_utility_screenshot_path"
  fi
  local utility_path="${UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    utility_path="$shield_utility_screenshot_path"
  fi
  local wrath_of_heaven_utility_path="${WRATH_OF_HEAVEN_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    wrath_of_heaven_utility_path="$wrath_of_heaven_utility_screenshot_path"
  fi
  local sacred_blade_utility_path="${SACRED_BLADE_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    sacred_blade_utility_path="$sacred_blade_utility_screenshot_path"
  fi
  local swift_surge_utility_path="${SWIFT_SURGE_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    swift_surge_utility_path="$swift_surge_utility_screenshot_path"
  fi
  local quick_loader_utility_path="${QUICK_LOADER_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    quick_loader_utility_path="$quick_loader_utility_screenshot_path"
  fi
  local generals_cry_utility_path="${GENERALS_CRY_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    generals_cry_utility_path="$generals_cry_utility_screenshot_path"
  fi
  local bloodlust_utility_path="${BLOODLUST_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    bloodlust_utility_path="$bloodlust_utility_screenshot_path"
  fi
  local critical_floating_path="${CRITICAL_FLOATING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    critical_floating_path="$critical_floating_screenshot_path"
  fi
  local dodge_floating_path="${DODGE_FLOATING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    dodge_floating_path="$dodge_floating_screenshot_path"
  fi
  local block_floating_path="${BLOCK_FLOATING_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    block_floating_path="$block_floating_screenshot_path"
  fi
  local victory_finish_scene_path="${VICTORY_FINISH_SCENE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    victory_finish_scene_path="$victory_finish_scene_screenshot_path"
  fi
  local defeat_finish_scene_path="${DEFEAT_FINISH_SCENE_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    defeat_finish_scene_path="$defeat_finish_scene_screenshot_path"
  fi
  local status_row_path="${STATUS_ROW_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    status_row_path="$status_row_screenshot_path"
  fi
  local crowded_status_row_path="${CROWDED_STATUS_ROW_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    crowded_status_row_path="$crowded_status_row_screenshot_path"
  fi
  local battle_log_panel_path="${BATTLE_LOG_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    battle_log_panel_path="$battle_log_panel_screenshot_path"
  fi
  local victory_reward_banner_path="${VICTORY_REWARD_BANNER_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    victory_reward_banner_path="$victory_reward_banner_screenshot_path"
  fi
  local victory_level_cap_banner_path="${VICTORY_LEVEL_CAP_BANNER_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    victory_level_cap_banner_path="$victory_level_cap_banner_screenshot_path"
  fi
  local completion_settlement_path="${COMPLETION_SETTLEMENT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    completion_settlement_path="$completion_settlement_screenshot_path"
  fi
  local battle_tab_layout_path="${BATTLE_TAB_LAYOUT_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    battle_tab_layout_path="$battle_tab_layout_screenshot_path"
  fi
  local inventory_panel_path="${INVENTORY_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    inventory_panel_path="$inventory_panel_screenshot_path"
  fi
  local character_panel_path="${CHARACTER_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    character_panel_path="$character_panel_screenshot_path"
  fi
  local chest_panel_path="${CHEST_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    chest_panel_path="$chest_panel_screenshot_path"
  fi
  local original_fidelity_panel_path="${ORIGINAL_FIDELITY_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    original_fidelity_panel_path="$original_fidelity_panel_screenshot_path"
  fi
  local rune_evidence_panel_path="${RUNE_EVIDENCE_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    rune_evidence_panel_path="$rune_evidence_panel_screenshot_path"
  fi
  local skill_evidence_panel_path="${SKILL_EVIDENCE_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    skill_evidence_panel_path="$skill_evidence_panel_screenshot_path"
  fi
  local passive_evidence_panel_path="${PASSIVE_EVIDENCE_PANEL_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    passive_evidence_panel_path="$passive_evidence_panel_screenshot_path"
  fi
  TBH_CHECK_PARTY_LAYOUT="$check_party_layout" \
    TBH_RENDERED_SNAPSHOT="$rendered_snapshot" \
    TBH_MOTION_SAMPLE_TIME_SECONDS="$motion_sample_time_seconds" \
    TBH_MOTION_SCREENSHOT_PATH="$motion_path" \
    TBH_MELEE_ARC_SCREENSHOT_PATH="$melee_arc_path" \
    TBH_RAPID_VOLLEY_SCREENSHOT_PATH="$rapid_volley_path" \
    TBH_SCATTER_SHOT_SCREENSHOT_PATH="$scatter_shot_path" \
    TBH_ARROW_RAIN_SCREENSHOT_PATH="$arrow_rain_path" \
    TBH_PIERCING_ARROW_SCREENSHOT_PATH="$piercing_arrow_path" \
    TBH_SKEWER_SHOT_SCREENSHOT_PATH="$skewer_shot_path" \
    TBH_EXPLOSIVE_BOLT_SCREENSHOT_PATH="$explosive_bolt_path" \
    TBH_METEOR_STRIKE_SCREENSHOT_PATH="$meteor_strike_path" \
    TBH_LIGHTNING_STRIKE_SCREENSHOT_PATH="$lightning_strike_path" \
    TBH_SHOCK_BOLT_SCREENSHOT_PATH="$shock_bolt_path" \
    TBH_TRAP_BURST_SCREENSHOT_PATH="$trap_burst_path" \
    TBH_SUMMON_PROJECTILE_SCREENSHOT_PATH="$summon_projectile_path" \
    TBH_SHOCK_CURRENT_SCREENSHOT_PATH="$shock_current_path" \
    TBH_SHIELD_CHARGE_SCREENSHOT_PATH="$shield_charge_path" \
    TBH_SLAM_JUMP_SCREENSHOT_PATH="$slam_jump_path" \
    TBH_EARTHQUAKE_IMPACT_SCREENSHOT_PATH="$earthquake_impact_path" \
    TBH_ROCK_EXPLOSION_SCREENSHOT_PATH="$rock_explosion_path" \
    TBH_AXE_SPIN_SCREENSHOT_PATH="$axe_spin_path" \
    TBH_AXE_SPIN_BLEED_SCREENSHOT_PATH="$axe_spin_bleed_path" \
    TBH_SHOCKWAVE_IMPACT_SCREENSHOT_PATH="$shockwave_impact_path" \
    TBH_CHAOS_BURST_SCREENSHOT_PATH="$chaos_burst_path" \
    TBH_MONSTER_FIRE_INCOMING_SCREENSHOT_PATH="$monster_fire_incoming_path" \
    TBH_MONSTER_COLD_INCOMING_SCREENSHOT_PATH="$monster_cold_incoming_path" \
    TBH_MONSTER_LIGHTNING_INCOMING_SCREENSHOT_PATH="$monster_lightning_incoming_path" \
    TBH_MONSTER_CHAOS_INCOMING_SCREENSHOT_PATH="$monster_chaos_incoming_path" \
    TBH_ENEMY_STATUS_EFFECTS_SCREENSHOT_PATH="$enemy_status_effects_path" \
    TBH_CONTACT_PULSE_BASELINE_SCREENSHOT_PATH="$contact_pulse_baseline_path" \
    TBH_HERO_CONTACT_PULSE_SCREENSHOT_PATH="$hero_contact_pulse_path" \
    TBH_MONSTER_CONTACT_PULSE_SCREENSHOT_PATH="$monster_contact_pulse_path" \
    TBH_HEAL_UTILITY_SCREENSHOT_PATH="$heal_utility_path" \
    TBH_SANCTUARY_UTILITY_SCREENSHOT_PATH="$sanctuary_utility_path" \
    TBH_RESURRECTION_UTILITY_SCREENSHOT_PATH="$resurrection_utility_path" \
    TBH_UTILITY_SCREENSHOT_PATH="$utility_path" \
    TBH_WRATH_OF_HEAVEN_UTILITY_SCREENSHOT_PATH="$wrath_of_heaven_utility_path" \
    TBH_SACRED_BLADE_UTILITY_SCREENSHOT_PATH="$sacred_blade_utility_path" \
    TBH_SWIFT_SURGE_UTILITY_SCREENSHOT_PATH="$swift_surge_utility_path" \
    TBH_QUICK_LOADER_UTILITY_SCREENSHOT_PATH="$quick_loader_utility_path" \
    TBH_GENERALS_CRY_UTILITY_SCREENSHOT_PATH="$generals_cry_utility_path" \
    TBH_BLOODLUST_UTILITY_SCREENSHOT_PATH="$bloodlust_utility_path" \
    TBH_CRITICAL_FLOATING_SCREENSHOT_PATH="$critical_floating_path" \
    TBH_DODGE_FLOATING_SCREENSHOT_PATH="$dodge_floating_path" \
    TBH_BLOCK_FLOATING_SCREENSHOT_PATH="$block_floating_path" \
    TBH_VICTORY_FINISH_SCENE_SCREENSHOT_PATH="$victory_finish_scene_path" \
    TBH_DEFEAT_FINISH_SCENE_SCREENSHOT_PATH="$defeat_finish_scene_path" \
    TBH_STATUS_ROW_SCREENSHOT_PATH="$status_row_path" \
    TBH_CROWDED_STATUS_ROW_SCREENSHOT_PATH="$crowded_status_row_path" \
    TBH_BATTLE_LOG_PANEL_SCREENSHOT_PATH="$battle_log_panel_path" \
    TBH_VICTORY_REWARD_BANNER_SCREENSHOT_PATH="$victory_reward_banner_path" \
    TBH_VICTORY_LEVEL_CAP_BANNER_SCREENSHOT_PATH="$victory_level_cap_banner_path" \
    TBH_COMPLETION_SETTLEMENT_SCREENSHOT_PATH="$completion_settlement_path" \
    TBH_BATTLE_TAB_LAYOUT_SCREENSHOT_PATH="$battle_tab_layout_path" \
    TBH_INVENTORY_PANEL_SCREENSHOT_PATH="$inventory_panel_path" \
    TBH_CHARACTER_PANEL_SCREENSHOT_PATH="$character_panel_path" \
    TBH_CHEST_PANEL_SCREENSHOT_PATH="$chest_panel_path" \
    TBH_ORIGINAL_FIDELITY_PANEL_SCREENSHOT_PATH="$original_fidelity_panel_path" \
    TBH_RUNE_EVIDENCE_PANEL_SCREENSHOT_PATH="$rune_evidence_panel_path" \
    TBH_SKILL_EVIDENCE_PANEL_SCREENSHOT_PATH="$skill_evidence_panel_path" \
    TBH_PASSIVE_EVIDENCE_PANEL_SCREENSHOT_PATH="$passive_evidence_panel_path" \
    python3 - "$screenshot_path" <<'PY'
import sys
import os

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for screenshot analysis: {exc}", file=sys.stderr)
    sys.exit(2)

path = sys.argv[1]
image = Image.open(path).convert("RGB")
width, height = image.size
pixels = image.load()

total = width * height
if total <= 0:
    print("screenshot has invalid dimensions", file=sys.stderr)
    sys.exit(1)

non_black = 0
luma_sum = 0.0
for y in range(height):
    for x in range(width):
        red, green, blue = pixels[x, y]
        luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        luma_sum += luma
        if red > 8 or green > 8 or blue > 8:
            non_black += 1

mean_luma = luma_sum / total
non_black_ratio = non_black / total
if mean_luma < 3 or non_black_ratio < 0.03:
    print(
        f"screenshot appears blank or black: mean_luma={mean_luma:.2f}, non_black={non_black_ratio:.2%}",
        file=sys.stderr,
    )
    sys.exit(1)

warm_rows = []
minimum_warm_hits_per_row = max(48, min(100, int(width * 0.20)))
for y in range(height):
    xs = []
    for x in range(width):
        red, green, blue = pixels[x, y]
        is_warm_ground = (
            red >= 120
            and 55 <= green <= 190
            and blue <= 115
            and red > green * 1.12
            and green > blue * 1.05
        )
        if is_warm_ground:
            xs.append(x)

    if len(xs) >= minimum_warm_hits_per_row:
        warm_rows.append((y, min(xs), max(xs), len(xs)))

groups = []
current = []
for row in warm_rows:
    if not current or row[0] <= current[-1][0] + 2:
        current.append(row)
    else:
        groups.append(current)
        current = [row]
if current:
    groups.append(current)

candidates = []
for group in groups:
    min_y = min(row[0] for row in group)
    max_y = max(row[0] for row in group)
    min_x = min(row[1] for row in group)
    max_x = max(row[2] for row in group)
    band_width = max_x - min_x + 1
    band_height = max_y - min_y + 1
    total_hits = sum(row[3] for row in group)
    minimum_band_width = max(120, int(width * 0.45))
    if band_width >= minimum_band_width and band_height >= 8 and min_y < height * 0.9:
        candidates.append((band_width * band_height, total_hits, min_x, min_y, max_x, max_y))

if not candidates:
    print("could not locate the warm battle ground strip in the screenshot", file=sys.stderr)
    sys.exit(1)

_, total_hits, min_x, min_y, max_x, max_y = max(candidates)
band_width = max_x - min_x + 1
band_height = max_y - min_y + 1

official_ratio = 776 / 180
ground_ratio = 0.14
ground_platform_width_ratio = 0.90
ground_platform_side_inset_ratio = (1 - ground_platform_width_ratio) / 2
estimated_scene_width = band_width / ground_platform_width_ratio
estimated_scene_ratio = estimated_scene_width / (band_height / ground_ratio)
ground_width_ratio = band_height / band_width
ground_width_to_image_ratio = band_width / width

min_local_ratio = 1.25
max_local_ratio = 4.65
max_ground_width_ratio = 0.40

if not (min_local_ratio <= estimated_scene_ratio <= max_local_ratio):
    print(
        "battle scene geometry is outside the expected local strip range: "
        f"estimated_ratio={estimated_scene_ratio:.2f}, "
        f"expected={min_local_ratio:.2f}-{max_local_ratio:.2f}, "
        f"official_ratio={official_ratio:.2f}",
        file=sys.stderr,
    )
    sys.exit(1)

if ground_width_ratio > max_ground_width_ratio:
    print(
        "battle ground strip is too tall for the official-style horizontal lane: "
        f"ground_h_to_w={ground_width_ratio:.3f}, max={max_ground_width_ratio:.3f}",
        file=sys.stderr,
    )
    sys.exit(1)

if not (0.84 <= ground_width_to_image_ratio <= 0.96):
    print(
        "battle ground platform width no longer leaves only subtle side margins: "
        f"ground_w_to_image={ground_width_to_image_ratio:.3f}, expected=0.84-0.96",
        file=sys.stderr,
    )
    sys.exit(1)

check_party_layout = os.environ.get("TBH_CHECK_PARTY_LAYOUT") == "1"
rendered_snapshot = os.environ.get("TBH_RENDERED_SNAPSHOT") == "1"
primary_metrics = None
support_metrics = None
primary_steel_pixels = 0
party_centroid_gap = 0.0
stage_pill_text_pixels = 0
stage_pill_dark_pixels = 0
main_hp_pixels = 0
support_hp_pixels = 0
enemy_hp_frame_span = 0.0
deployable_teal_pixels = 0
impact_cold_pixels = 0
trajectory_cold_pixels = 0
flame_motion_pixels = 0
flame_motion_percent = 0.0
local_motion_pixels = 0
local_motion_percent = 0.0
combatant_motion_pixels = 0
combatant_motion_scene_percent = 0.0
player_combatant_motion_pixels = 0
player_combatant_motion_scene_percent = 0.0
enemy_combatant_motion_pixels = 0
enemy_combatant_motion_scene_percent = 0.0
melee_arc_pixels = 0
rapid_volley_pixels = 0
scatter_shot_pixels = 0
arrow_rain_pixels = 0
piercing_arrow_pixels = 0
skewer_shot_pixels = 0
damage_explosive_fire_pixels = 0
damage_meteor_fire_pixels = 0
damage_meteor_vertical_span = 0
damage_lightning_pixels = 0
damage_shock_bolt_pixels = 0
damage_trap_teal_pixels = 0
damage_summon_fire_pixels = 0
damage_shock_current_pixels = 0
damage_shield_charge_pixels = 0
damage_slam_jump_pixels = 0
damage_earthquake_pixels = 0
damage_rock_explosion_pixels = 0
damage_axe_spin_pixels = 0
damage_axe_spin_bleed_pixels = 0
damage_shockwave_pixels = 0
damage_chaos_pixels = 0
monster_fire_incoming_pixels = 0
monster_cold_incoming_pixels = 0
monster_lightning_incoming_pixels = 0
monster_chaos_incoming_pixels = 0
enemy_status_chilled_pixels = 0
enemy_status_frozen_pixels = 0
enemy_status_stunned_pixels = 0
enemy_status_bleeding_pixels = 0
hero_contact_pulse_pixels = 0
monster_contact_pulse_pixels = 0
utility_heal_pixels = 0
utility_sanctuary_pixels = 0
utility_resurrection_pixels = 0
utility_shield_pixels = 0
utility_wrath_of_heaven_pixels = 0
utility_sacred_blade_pixels = 0
utility_sacred_blade_white_pixels = 0
utility_swift_surge_pixels = 0
utility_quick_loader_pixels = 0
utility_generals_cry_pixels = 0
utility_bloodlust_pixels = 0
critical_floating_pixels = 0
dodge_floating_pixels = 0
block_floating_pixels = 0
victory_finish_gold_pixels = 0
defeat_finish_red_pixels = 0
status_row_non_dark_pixels = 0
status_row_gold_pixels = 0
status_row_teal_pixels = 0
status_row_green_pixels = 0
status_row_light_pixels = 0
crowded_status_row_non_dark_pixels = 0
crowded_status_row_light_pixels = 0
crowded_status_row_overflow_light_pixels = 0
battle_log_panel_non_dark_pixels = 0
battle_log_panel_light_pixels = 0
battle_log_panel_title_light_pixels = 0
battle_log_panel_hero_blue_pixels = 0
battle_log_panel_support_purple_pixels = 0
battle_log_panel_monster_red_pixels = 0
battle_log_panel_critical_orange_pixels = 0
victory_reward_banner_non_dark_pixels = 0
victory_reward_banner_light_pixels = 0
victory_reward_banner_green_pixels = 0
victory_reward_banner_gold_pixels = 0
victory_reward_banner_rarity_pixels = 0
victory_reward_banner_icon_pixels = 0
victory_level_cap_banner_non_dark_pixels = 0
victory_level_cap_banner_light_pixels = 0
victory_level_cap_banner_green_pixels = 0
victory_level_cap_banner_orange_pixels = 0
completion_settlement_non_dark_pixels = 0
completion_settlement_light_pixels = 0
completion_settlement_gold_pixels = 0
completion_settlement_accent_pixels = 0
completion_settlement_panel_pixels = 0
battle_tab_layout_non_dark_pixels = 0
battle_tab_layout_content_non_dark_pixels = 0
battle_tab_layout_bottom_non_dark_pixels = 0
battle_tab_layout_bottom_light_pixels = 0
battle_tab_layout_bottom_accent_pixels = 0
battle_tab_layout_scene_warm_pixels = 0
inventory_panel_non_dark_pixels = 0
inventory_panel_control_light_pixels = 0
inventory_panel_grid_colored_pixels = 0
inventory_panel_detail_non_dark_pixels = 0
inventory_panel_delta_green_pixels = 0
inventory_panel_rarity_pixels = 0
character_panel_non_dark_pixels = 0
character_panel_hero_colored_pixels = 0
character_panel_party_orange_pixels = 0
character_panel_skill_colored_pixels = 0
character_panel_passive_icon_pixels = 0
character_panel_equipment_rarity_pixels = 0
chest_panel_non_dark_pixels = 0
chest_panel_button_blue_pixels = 0
chest_panel_auto_green_pixels = 0
chest_panel_icon_colored_pixels = 0
chest_panel_rarity_pixels = 0
original_fidelity_panel_non_dark_pixels = 0
original_fidelity_panel_status_green_pixels = 0
original_fidelity_panel_status_orange_pixels = 0
original_fidelity_panel_status_gap_pixels = 0
original_fidelity_panel_pill_pixels = 0
original_fidelity_panel_text_light_pixels = 0
rune_evidence_panel_non_dark_pixels = 0
rune_evidence_panel_pill_pixels = 0
rune_evidence_panel_text_light_pixels = 0
rune_evidence_panel_orange_pixels = 0
rune_evidence_panel_green_pixels = 0
rune_evidence_panel_blue_pixels = 0
skill_evidence_panel_non_dark_pixels = 0
skill_evidence_panel_pill_pixels = 0
skill_evidence_panel_text_light_pixels = 0
skill_evidence_panel_orange_pixels = 0
skill_evidence_panel_green_pixels = 0
skill_evidence_panel_blue_pixels = 0
skill_evidence_panel_purple_pixels = 0
passive_evidence_panel_non_dark_pixels = 0
passive_evidence_panel_pill_pixels = 0
passive_evidence_panel_text_light_pixels = 0
passive_evidence_panel_source_icon_pixels = 0
passive_evidence_panel_missing_icon_pixels = 0
passive_evidence_panel_green_pixels = 0

status_row_path = os.environ.get("TBH_STATUS_ROW_SCREENSHOT_PATH", "")
if status_row_path:
    if not os.path.exists(status_row_path):
        print(f"status-row screenshot does not exist: {status_row_path}", file=sys.stderr)
        sys.exit(2)

    status_image = Image.open(status_row_path).convert("RGB")
    status_width, status_height = status_image.size
    if status_width < 300 or status_height < 20:
        print(
            "status-row screenshot has invalid dimensions: "
            f"{status_width}x{status_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    status_pixels = status_image.load()
    for y in range(status_height):
        for x in range(status_width):
            red, green, blue = status_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 35:
                status_row_non_dark_pixels += 1
            if red >= 150 and green >= 100 and blue <= 120 and red > green * 1.03:
                status_row_gold_pixels += 1
            if green >= 110 and blue >= 95 and red <= 160 and green > red * 1.05 and blue > red * 0.90:
                status_row_teal_pixels += 1
            if green >= 110 and red <= 150 and blue <= 170 and green > red * 1.05:
                status_row_green_pixels += 1
            if red >= 145 and green >= 145 and blue >= 145:
                status_row_light_pixels += 1

    min_status_non_dark_pixels = max(800, min(9000, int(status_width * status_height * 0.12)))
    if status_row_non_dark_pixels < min_status_non_dark_pixels:
        print(
            "player status row appears blank or too faint: "
            f"status_row_non_dark_pixels={status_row_non_dark_pixels}, min={min_status_non_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if status_row_gold_pixels < 50:
        print(
            "player status row is missing the gold Might/Sacred-style badge pixels: "
            f"status_row_gold_pixels={status_row_gold_pixels}, min=50",
            file=sys.stderr,
        )
        sys.exit(1)

    if status_row_teal_pixels < 80:
        print(
            "player status row is missing the teal Warding/Trap-style badge pixels: "
            f"status_row_teal_pixels={status_row_teal_pixels}, min=80",
            file=sys.stderr,
        )
        sys.exit(1)

    if status_row_green_pixels < 40:
        print(
            "player status row is missing the green active-combat indicator or shield badge pixels: "
            f"status_row_green_pixels={status_row_green_pixels}, min=40",
            file=sys.stderr,
        )
        sys.exit(1)

    if status_row_light_pixels < 200:
        print(
            "player status row text/icons are missing or too dim: "
            f"status_row_light_pixels={status_row_light_pixels}, min=200",
            file=sys.stderr,
        )
        sys.exit(1)

crowded_status_row_path = os.environ.get("TBH_CROWDED_STATUS_ROW_SCREENSHOT_PATH", "")
if crowded_status_row_path:
    if not os.path.exists(crowded_status_row_path):
        print(f"crowded status-row screenshot does not exist: {crowded_status_row_path}", file=sys.stderr)
        sys.exit(2)

    crowded_status_image = Image.open(crowded_status_row_path).convert("RGB")
    crowded_status_width, crowded_status_height = crowded_status_image.size
    if crowded_status_width < 300 or crowded_status_height < 20:
        print(
            "crowded status-row screenshot has invalid dimensions: "
            f"{crowded_status_width}x{crowded_status_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    crowded_status_pixels = crowded_status_image.load()
    overflow_region_start = int(crowded_status_width * 0.72)
    for y in range(crowded_status_height):
        for x in range(crowded_status_width):
            red, green, blue = crowded_status_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 35:
                crowded_status_row_non_dark_pixels += 1
            if red >= 145 and green >= 145 and blue >= 145:
                crowded_status_row_light_pixels += 1
                if x >= overflow_region_start:
                    crowded_status_row_overflow_light_pixels += 1

    min_crowded_status_non_dark_pixels = max(
        1200,
        min(12000, int(crowded_status_width * crowded_status_height * 0.18)),
    )
    if crowded_status_row_non_dark_pixels < min_crowded_status_non_dark_pixels:
        print(
            "crowded player status row appears blank or too faint: "
            f"crowded_status_row_non_dark_pixels={crowded_status_row_non_dark_pixels}, "
            f"min={min_crowded_status_non_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if crowded_status_row_light_pixels < 260:
        print(
            "crowded player status row text/icons are missing or too dim: "
            f"crowded_status_row_light_pixels={crowded_status_row_light_pixels}, min=260",
            file=sys.stderr,
        )
        sys.exit(1)

    if crowded_status_row_overflow_light_pixels < 8:
        print(
            "crowded player status row overflow count is missing or too dim: "
            f"crowded_status_row_overflow_light_pixels={crowded_status_row_overflow_light_pixels}, min=8",
            file=sys.stderr,
        )
        sys.exit(1)

battle_log_panel_path = os.environ.get("TBH_BATTLE_LOG_PANEL_SCREENSHOT_PATH", "")
if battle_log_panel_path:
    if not os.path.exists(battle_log_panel_path):
        print(f"battle-log panel screenshot does not exist: {battle_log_panel_path}", file=sys.stderr)
        sys.exit(2)

    battle_log_panel_image = Image.open(battle_log_panel_path).convert("RGB")
    battle_log_panel_width, battle_log_panel_height = battle_log_panel_image.size
    if battle_log_panel_width < 600 or battle_log_panel_height < 300:
        print(
            "battle-log panel screenshot has invalid dimensions: "
            f"{battle_log_panel_width}x{battle_log_panel_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    battle_log_panel_pixels = battle_log_panel_image.load()
    title_region_bottom = max(26, int(battle_log_panel_height * 0.24))
    for y in range(battle_log_panel_height):
        for x in range(battle_log_panel_width):
            red, green, blue = battle_log_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 42:
                battle_log_panel_non_dark_pixels += 1
            if red >= 145 and green >= 145 and blue >= 145:
                battle_log_panel_light_pixels += 1
                if y <= title_region_bottom:
                    battle_log_panel_title_light_pixels += 1
            if blue >= 135 and green >= 70 and red <= 135 and blue > green * 1.12 and blue > red * 1.55:
                battle_log_panel_hero_blue_pixels += 1
            if red >= 105 and blue >= 125 and green <= 145 and blue > green * 1.08 and red > green * 0.92:
                battle_log_panel_support_purple_pixels += 1
            if red >= 145 and green <= 130 and blue <= 130 and red > green * 1.15:
                battle_log_panel_monster_red_pixels += 1
            if red >= 150 and 70 <= green <= 195 and blue <= 130 and red > green * 1.05:
                battle_log_panel_critical_orange_pixels += 1

    min_battle_log_non_dark_pixels = max(
        3500,
        min(18000, int(battle_log_panel_width * battle_log_panel_height * 0.045)),
    )
    if battle_log_panel_non_dark_pixels < min_battle_log_non_dark_pixels:
        print(
            "battle-log panel appears blank or too faint: "
            f"battle_log_panel_non_dark_pixels={battle_log_panel_non_dark_pixels}, "
            f"min={min_battle_log_non_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_log_panel_light_pixels < 450:
        print(
            "battle-log panel text/icons are missing or too dim: "
            f"battle_log_panel_light_pixels={battle_log_panel_light_pixels}, min=450",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_log_panel_title_light_pixels < 45:
        print(
            "battle-log panel title/count region is missing or too dim: "
            f"battle_log_panel_title_light_pixels={battle_log_panel_title_light_pixels}, min=45",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_log_panel_hero_blue_pixels < 30:
        print(
            "battle-log panel is missing visible main-hero blue rows: "
            f"battle_log_panel_hero_blue_pixels={battle_log_panel_hero_blue_pixels}, min=30",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_log_panel_support_purple_pixels < 20:
        print(
            "battle-log panel is missing visible support purple rows: "
            f"battle_log_panel_support_purple_pixels={battle_log_panel_support_purple_pixels}, min=20",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_log_panel_monster_red_pixels < 30:
        print(
            "battle-log panel is missing visible monster red rows: "
            f"battle_log_panel_monster_red_pixels={battle_log_panel_monster_red_pixels}, min=30",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_log_panel_critical_orange_pixels < 10:
        print(
            "battle-log panel is missing visible critical-hit orange text: "
            f"battle_log_panel_critical_orange_pixels={battle_log_panel_critical_orange_pixels}, min=10",
            file=sys.stderr,
        )
        sys.exit(1)

victory_reward_banner_path = os.environ.get("TBH_VICTORY_REWARD_BANNER_SCREENSHOT_PATH", "")
if victory_reward_banner_path:
    if not os.path.exists(victory_reward_banner_path):
        print(f"victory reward banner screenshot does not exist: {victory_reward_banner_path}", file=sys.stderr)
        sys.exit(2)

    victory_reward_banner_image = Image.open(victory_reward_banner_path).convert("RGB")
    reward_banner_width, reward_banner_height = victory_reward_banner_image.size
    if reward_banner_width < 600 or reward_banner_height < 90:
        print(
            "victory reward banner screenshot has invalid dimensions: "
            f"{reward_banner_width}x{reward_banner_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    reward_banner_pixels = victory_reward_banner_image.load()
    for y in range(reward_banner_height):
        for x in range(reward_banner_width):
            red, green, blue = reward_banner_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 42:
                victory_reward_banner_non_dark_pixels += 1
            if red >= 145 and green >= 145 and blue >= 145:
                victory_reward_banner_light_pixels += 1
            if green >= 130 and red <= 140 and blue <= 140 and green > red * 1.18:
                victory_reward_banner_green_pixels += 1
            if red >= 145 and 95 <= green <= 215 and blue <= 130 and red > blue * 1.25:
                victory_reward_banner_gold_pixels += 1
            if blue >= 150 and 65 <= green <= 170 and red <= 115 and blue > red * 1.70:
                victory_reward_banner_rarity_pixels += 1
            if max(red, green, blue) - min(red, green, blue) >= 80 and luma > 55:
                victory_reward_banner_icon_pixels += 1

    if victory_reward_banner_non_dark_pixels < 2800:
        print(
            "victory reward banner appears blank or too faint: "
            f"victory_reward_banner_non_dark_pixels={victory_reward_banner_non_dark_pixels}, min=2800",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_reward_banner_light_pixels < 320:
        print(
            "victory reward banner text is missing or too dim: "
            f"victory_reward_banner_light_pixels={victory_reward_banner_light_pixels}, min=320",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_reward_banner_green_pixels < 25:
        print(
            "victory reward banner success icon is missing: "
            f"victory_reward_banner_green_pixels={victory_reward_banner_green_pixels}, min=25",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_reward_banner_rarity_pixels < 45:
        print(
            "victory reward banner source-backed rare loot color is missing: "
            f"victory_reward_banner_rarity_pixels={victory_reward_banner_rarity_pixels}, min=45",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_reward_banner_icon_pixels < 120:
        print(
            "victory reward banner loot icon/detail color appears missing: "
            f"victory_reward_banner_icon_pixels={victory_reward_banner_icon_pixels}, min=120",
            file=sys.stderr,
        )
        sys.exit(1)

victory_level_cap_banner_path = os.environ.get("TBH_VICTORY_LEVEL_CAP_BANNER_SCREENSHOT_PATH", "")
if victory_level_cap_banner_path:
    if not os.path.exists(victory_level_cap_banner_path):
        print(f"victory level-cap banner screenshot does not exist: {victory_level_cap_banner_path}", file=sys.stderr)
        sys.exit(2)

    victory_level_cap_banner_image = Image.open(victory_level_cap_banner_path).convert("RGB")
    level_cap_banner_width, level_cap_banner_height = victory_level_cap_banner_image.size
    if level_cap_banner_width < 600 or level_cap_banner_height < 90:
        print(
            "victory level-cap banner screenshot has invalid dimensions: "
            f"{level_cap_banner_width}x{level_cap_banner_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    level_cap_banner_pixels = victory_level_cap_banner_image.load()
    for y in range(level_cap_banner_height):
        for x in range(level_cap_banner_width):
            red, green, blue = level_cap_banner_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 42:
                victory_level_cap_banner_non_dark_pixels += 1
            if red >= 145 and green >= 145 and blue >= 145:
                victory_level_cap_banner_light_pixels += 1
            if green >= 130 and red <= 140 and blue <= 140 and green > red * 1.18:
                victory_level_cap_banner_green_pixels += 1
            if red >= 150 and 70 <= green <= 195 and blue <= 130 and red > green * 1.05:
                victory_level_cap_banner_orange_pixels += 1

    if victory_level_cap_banner_non_dark_pixels < 2200:
        print(
            "victory level-cap banner appears blank or too faint: "
            f"victory_level_cap_banner_non_dark_pixels={victory_level_cap_banner_non_dark_pixels}, min=2200",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_level_cap_banner_light_pixels < 220:
        print(
            "victory level-cap banner summary text is missing or too dim: "
            f"victory_level_cap_banner_light_pixels={victory_level_cap_banner_light_pixels}, min=220",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_level_cap_banner_green_pixels < 25:
        print(
            "victory level-cap banner success icon is missing: "
            f"victory_level_cap_banner_green_pixels={victory_level_cap_banner_green_pixels}, min=25",
            file=sys.stderr,
        )
        sys.exit(1)

    if victory_level_cap_banner_orange_pixels < 50:
        print(
            "victory level-cap banner warning detail is missing: "
            f"victory_level_cap_banner_orange_pixels={victory_level_cap_banner_orange_pixels}, min=50",
            file=sys.stderr,
        )
        sys.exit(1)

completion_settlement_path = os.environ.get("TBH_COMPLETION_SETTLEMENT_SCREENSHOT_PATH", "")
if completion_settlement_path:
    if not os.path.exists(completion_settlement_path):
        print(f"completion settlement screenshot does not exist: {completion_settlement_path}", file=sys.stderr)
        sys.exit(2)

    completion_settlement_image = Image.open(completion_settlement_path).convert("RGB")
    settlement_width, settlement_height = completion_settlement_image.size
    expected_settlement_width = 1232
    expected_settlement_height = 640
    if (
        settlement_width != expected_settlement_width
        or settlement_height != expected_settlement_height
    ):
        print(
            "completion settlement screenshot has invalid dimensions: "
            f"{settlement_width}x{settlement_height}, "
            f"expected={expected_settlement_width}x{expected_settlement_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    settlement_pixels = completion_settlement_image.load()
    for y in range(settlement_height):
        for x in range(settlement_width):
            red, green, blue = settlement_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 42:
                completion_settlement_non_dark_pixels += 1
            if red >= 145 and green >= 145 and blue >= 145:
                completion_settlement_light_pixels += 1
            if red >= 170 and green >= 135 and blue <= 90:
                completion_settlement_gold_pixels += 1
            if blue >= 130 and 65 <= green <= 180 and red <= 145 and blue > red * 1.20:
                completion_settlement_accent_pixels += 1
            if 52 <= luma <= 130 and max(red, green, blue) - min(red, green, blue) <= 42:
                completion_settlement_panel_pixels += 1

    if completion_settlement_non_dark_pixels < 18000:
        print(
            "completion settlement appears blank or too faint: "
            f"completion_settlement_non_dark_pixels={completion_settlement_non_dark_pixels}, min=18000",
            file=sys.stderr,
        )
        sys.exit(1)

    if completion_settlement_light_pixels < 1200:
        print(
            "completion settlement text/buttons are missing or too dim: "
            f"completion_settlement_light_pixels={completion_settlement_light_pixels}, min=1200",
            file=sys.stderr,
        )
        sys.exit(1)

    if completion_settlement_gold_pixels < 160:
        print(
            "completion settlement crown/stat emphasis is missing: "
            f"completion_settlement_gold_pixels={completion_settlement_gold_pixels}, min=160",
            file=sys.stderr,
        )
        sys.exit(1)

    if completion_settlement_accent_pixels < 120:
        print(
            "completion settlement next-playthrough action accent is missing: "
            f"completion_settlement_accent_pixels={completion_settlement_accent_pixels}, min=120",
            file=sys.stderr,
        )
        sys.exit(1)

    if completion_settlement_panel_pixels < 3000:
        print(
            "completion settlement retained-progress/stat panel is missing: "
            f"completion_settlement_panel_pixels={completion_settlement_panel_pixels}, min=3000",
            file=sys.stderr,
        )
        sys.exit(1)

battle_tab_layout_path = os.environ.get("TBH_BATTLE_TAB_LAYOUT_SCREENSHOT_PATH", "")
if battle_tab_layout_path:
    if not os.path.exists(battle_tab_layout_path):
        print(f"battle-tab layout screenshot does not exist: {battle_tab_layout_path}", file=sys.stderr)
        sys.exit(2)

    battle_tab_layout_image = Image.open(battle_tab_layout_path).convert("RGB")
    battle_tab_layout_width, battle_tab_layout_height = battle_tab_layout_image.size
    expected_layout_width = 1280
    expected_layout_height = 1200
    if (
        battle_tab_layout_width != expected_layout_width
        or battle_tab_layout_height != expected_layout_height
    ):
        print(
            "battle-tab layout screenshot has invalid dimensions: "
            f"{battle_tab_layout_width}x{battle_tab_layout_height}, "
            f"expected={expected_layout_width}x{expected_layout_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    battle_tab_layout_pixels = battle_tab_layout_image.load()
    bottom_region_start = max(0, battle_tab_layout_height - 130)
    content_region_bottom = max(0, bottom_region_start - 8)
    scene_region_top = int(battle_tab_layout_height * 0.07)
    scene_region_bottom = int(battle_tab_layout_height * 0.85)
    for y in range(battle_tab_layout_height):
        for x in range(battle_tab_layout_width):
            red, green, blue = battle_tab_layout_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luma > 35:
                battle_tab_layout_non_dark_pixels += 1
                if y < content_region_bottom:
                    battle_tab_layout_content_non_dark_pixels += 1
                elif y >= bottom_region_start:
                    battle_tab_layout_bottom_non_dark_pixels += 1
            if y >= bottom_region_start:
                if red >= 145 and green >= 145 and blue >= 145:
                    battle_tab_layout_bottom_light_pixels += 1
                if blue >= 130 and 65 <= green <= 170 and red <= 135 and blue > red * 1.35:
                    battle_tab_layout_bottom_accent_pixels += 1
            elif scene_region_top <= y <= scene_region_bottom:
                if (
                    red >= 120
                    and 55 <= green <= 190
                    and blue <= 115
                    and red > green * 1.12
                    and green > blue * 1.05
                ):
                    battle_tab_layout_scene_warm_pixels += 1

    min_layout_non_dark_pixels = int(battle_tab_layout_width * battle_tab_layout_height * 0.035)
    if battle_tab_layout_non_dark_pixels < min_layout_non_dark_pixels:
        print(
            "battle-tab layout appears blank or too dark: "
            f"battle_tab_layout_non_dark_pixels={battle_tab_layout_non_dark_pixels}, "
            f"min={min_layout_non_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_tab_layout_content_non_dark_pixels < 55000:
        print(
            "battle-tab layout content area is missing visible battle content: "
            f"battle_tab_layout_content_non_dark_pixels={battle_tab_layout_content_non_dark_pixels}, min=55000",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_tab_layout_scene_warm_pixels < 80000:
        print(
            "battle-tab layout is missing the visible warm battle lane: "
            f"battle_tab_layout_scene_warm_pixels={battle_tab_layout_scene_warm_pixels}, min=80000",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_tab_layout_bottom_non_dark_pixels < 1400:
        print(
            "battle-tab layout bottom menu bar appears blank: "
            f"battle_tab_layout_bottom_non_dark_pixels={battle_tab_layout_bottom_non_dark_pixels}, min=1400",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_tab_layout_bottom_light_pixels < 220:
        print(
            "battle-tab layout bottom menu labels/icons are missing or too dim: "
            f"battle_tab_layout_bottom_light_pixels={battle_tab_layout_bottom_light_pixels}, min=220",
            file=sys.stderr,
        )
        sys.exit(1)

    if battle_tab_layout_bottom_accent_pixels < 40:
        print(
            "battle-tab layout selected battle tab accent is missing: "
            f"battle_tab_layout_bottom_accent_pixels={battle_tab_layout_bottom_accent_pixels}, min=40",
            file=sys.stderr,
        )
        sys.exit(1)

inventory_panel_path = os.environ.get("TBH_INVENTORY_PANEL_SCREENSHOT_PATH", "")
if inventory_panel_path:
    if not os.path.exists(inventory_panel_path):
        print(f"inventory panel screenshot does not exist: {inventory_panel_path}", file=sys.stderr)
        sys.exit(2)

    inventory_panel_image = Image.open(inventory_panel_path).convert("RGB")
    inventory_panel_width, inventory_panel_height = inventory_panel_image.size
    expected_inventory_width = 1232
    expected_inventory_height = 1440
    if (
        inventory_panel_width != expected_inventory_width
        or inventory_panel_height != expected_inventory_height
    ):
        print(
            "inventory panel screenshot has invalid dimensions: "
            f"{inventory_panel_width}x{inventory_panel_height}, "
            f"expected={expected_inventory_width}x{expected_inventory_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    inventory_panel_pixels = inventory_panel_image.load()
    control_region_bottom = int(inventory_panel_height * 0.12)
    grid_region_bottom = int(inventory_panel_height * 0.55)
    detail_region_top = int(inventory_panel_height * 0.52)
    for y in range(inventory_panel_height):
        for x in range(inventory_panel_width):
            red, green, blue = inventory_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                inventory_panel_non_dark_pixels += 1
                if y <= control_region_bottom and red >= 125 and green >= 125 and blue >= 125:
                    inventory_panel_control_light_pixels += 1
                if y >= detail_region_top:
                    inventory_panel_detail_non_dark_pixels += 1
            if y <= grid_region_bottom and luma > 45 and chroma >= 28:
                inventory_panel_grid_colored_pixels += 1
            if y >= detail_region_top and green >= 120 and green > red * 1.18 and green > blue * 1.18:
                inventory_panel_delta_green_pixels += 1
            if (
                (blue >= 120 and red <= 110 and green <= 170)
                or (red >= 155 and 70 <= green <= 175 and blue <= 105)
                or (red >= 150 and blue >= 120 and green <= 105)
            ):
                inventory_panel_rarity_pixels += 1

    min_inventory_non_dark_pixels = 90000
    if inventory_panel_non_dark_pixels < min_inventory_non_dark_pixels:
        print(
            "inventory panel appears blank or too dark: "
            f"inventory_panel_non_dark_pixels={inventory_panel_non_dark_pixels}, "
            f"min={min_inventory_non_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if inventory_panel_control_light_pixels < 1500:
        print(
            "inventory panel capacity/handling controls are missing or too dim: "
            f"inventory_panel_control_light_pixels={inventory_panel_control_light_pixels}, min=1500",
            file=sys.stderr,
        )
        sys.exit(1)

    if inventory_panel_grid_colored_pixels < 2500:
        print(
            "inventory panel item grid lacks visible source-backed icon color: "
            f"inventory_panel_grid_colored_pixels={inventory_panel_grid_colored_pixels}, min=2500",
            file=sys.stderr,
        )
        sys.exit(1)

    if inventory_panel_detail_non_dark_pixels < 40000:
        print(
            "inventory panel selected-item detail area is missing: "
            f"inventory_panel_detail_non_dark_pixels={inventory_panel_detail_non_dark_pixels}, min=40000",
            file=sys.stderr,
        )
        sys.exit(1)

    if inventory_panel_delta_green_pixels < 600:
        print(
            "inventory panel equipment comparison positive delta preview is missing: "
            f"inventory_panel_delta_green_pixels={inventory_panel_delta_green_pixels}, min=600",
            file=sys.stderr,
        )
        sys.exit(1)

    if inventory_panel_rarity_pixels < 2000:
        print(
            "inventory panel rarity colors are missing from item grid/detail preview: "
            f"inventory_panel_rarity_pixels={inventory_panel_rarity_pixels}, min=2000",
            file=sys.stderr,
        )
        sys.exit(1)

character_panel_path = os.environ.get("TBH_CHARACTER_PANEL_SCREENSHOT_PATH", "")
if character_panel_path:
    if not os.path.exists(character_panel_path):
        print(f"character panel screenshot does not exist: {character_panel_path}", file=sys.stderr)
        sys.exit(2)

    character_panel_image = Image.open(character_panel_path).convert("RGB")
    character_panel_width, character_panel_height = character_panel_image.size
    expected_character_width = 1232
    expected_character_height = 976
    if (
        character_panel_width != expected_character_width
        or character_panel_height != expected_character_height
    ):
        print(
            "character panel screenshot has invalid dimensions: "
            f"{character_panel_width}x{character_panel_height}, "
            f"expected={expected_character_width}x{expected_character_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    character_panel_pixels = character_panel_image.load()
    hero_region_bottom = int(character_panel_height * 0.23)
    party_region_top = int(character_panel_height * 0.35)
    skill_region_top = int(character_panel_height * 0.50)
    passive_region_top = int(character_panel_height * 0.66)
    equipment_region_top = int(character_panel_height * 0.68)
    for y in range(character_panel_height):
        for x in range(character_panel_width):
            red, green, blue = character_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                character_panel_non_dark_pixels += 1
            if y <= hero_region_bottom and luma > 38 and chroma >= 28:
                character_panel_hero_colored_pixels += 1
            if (
                y >= party_region_top
                and red >= 145
                and 70 <= green <= 190
                and blue <= 120
                and red > blue * 1.35
            ):
                character_panel_party_orange_pixels += 1
            if y >= skill_region_top and luma > 45 and chroma >= 30:
                character_panel_skill_colored_pixels += 1
            if y >= passive_region_top and luma > 45 and chroma >= 24:
                character_panel_passive_icon_pixels += 1
            if (
                y >= equipment_region_top
                and (
                    (blue >= 120 and red <= 120 and green <= 180)
                    or (red >= 145 and 70 <= green <= 185 and blue <= 120)
                    or (red >= 145 and blue >= 115 and green <= 115)
                )
            ):
                character_panel_equipment_rarity_pixels += 1

    if character_panel_non_dark_pixels < 40000:
        print(
            "character panel appears blank or too dark: "
            f"character_panel_non_dark_pixels={character_panel_non_dark_pixels}, min=40000",
            file=sys.stderr,
        )
        sys.exit(1)

    if character_panel_hero_colored_pixels < 2500:
        print(
            "character panel hero art is missing or too dim: "
            f"character_panel_hero_colored_pixels={character_panel_hero_colored_pixels}, min=2500",
            file=sys.stderr,
        )
        sys.exit(1)

chest_panel_path = os.environ.get("TBH_CHEST_PANEL_SCREENSHOT_PATH", "")
if chest_panel_path:
    if not os.path.exists(chest_panel_path):
        print(f"chest panel screenshot does not exist: {chest_panel_path}", file=sys.stderr)
        sys.exit(2)

    chest_panel_image = Image.open(chest_panel_path).convert("RGB")
    chest_panel_width, chest_panel_height = chest_panel_image.size
    expected_chest_width = 1232
    expected_chest_height = 720
    if chest_panel_width != expected_chest_width or chest_panel_height != expected_chest_height:
        print(
            "chest panel screenshot has invalid dimensions: "
            f"{chest_panel_width}x{chest_panel_height}, "
            f"expected={expected_chest_width}x{expected_chest_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    chest_panel_pixels = chest_panel_image.load()
    auto_region_bottom = int(chest_panel_height * 0.34)
    controls_region_bottom = int(chest_panel_height * 0.48)
    icon_region_left = int(chest_panel_width * 0.16)
    for y in range(chest_panel_height):
        for x in range(chest_panel_width):
            red, green, blue = chest_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                chest_panel_non_dark_pixels += 1
            if (
                y <= controls_region_bottom
                and blue >= 120
                and green >= 70
                and red <= 130
                and blue > red * 1.25
            ):
                chest_panel_button_blue_pixels += 1
            if (
                y <= auto_region_bottom
                and green >= 80
                and green > red * 1.15
                and green > blue * 1.15
            ):
                chest_panel_auto_green_pixels += 1
            if x <= icon_region_left and luma > 35 and chroma >= 28:
                chest_panel_icon_colored_pixels += 1
            if (
                chroma >= 38
                and (
                    (red >= 140 and green >= 85 and blue <= 125)
                    or (blue >= 110 and red <= 135 and green <= 190)
                    or (red >= 145 and green >= 120 and blue <= 95)
                )
            ):
                chest_panel_rarity_pixels += 1

    min_chest_non_dark_pixels = int(120000 * chest_panel_width / 1472)
    if chest_panel_non_dark_pixels < min_chest_non_dark_pixels:
        print(
            "chest panel appears blank or too dark: "
            f"chest_panel_non_dark_pixels={chest_panel_non_dark_pixels}, "
            f"min={min_chest_non_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if chest_panel_button_blue_pixels < 4000:
        print(
            "chest panel batch-open button accent is missing: "
            f"chest_panel_button_blue_pixels={chest_panel_button_blue_pixels}, min=4000",
            file=sys.stderr,
        )
        sys.exit(1)

    if chest_panel_auto_green_pixels < 1600:
        print(
            "chest panel auto-open status is missing: "
            f"chest_panel_auto_green_pixels={chest_panel_auto_green_pixels}, min=1600",
            file=sys.stderr,
        )
        sys.exit(1)

    if chest_panel_icon_colored_pixels < 7000:
        print(
            "chest panel source-backed chest icons are missing: "
            f"chest_panel_icon_colored_pixels={chest_panel_icon_colored_pixels}, min=7000",
            file=sys.stderr,
        )
        sys.exit(1)

    if chest_panel_rarity_pixels < 5000:
        print(
            "chest panel rarity/source-family color is missing: "
            f"chest_panel_rarity_pixels={chest_panel_rarity_pixels}, min=5000",
            file=sys.stderr,
        )
        sys.exit(1)

original_fidelity_panel_path = os.environ.get("TBH_ORIGINAL_FIDELITY_PANEL_SCREENSHOT_PATH", "")
if original_fidelity_panel_path:
    if not os.path.exists(original_fidelity_panel_path):
        print(f"original fidelity panel screenshot does not exist: {original_fidelity_panel_path}", file=sys.stderr)
        sys.exit(2)

    original_fidelity_panel_image = Image.open(original_fidelity_panel_path).convert("RGB")
    original_fidelity_panel_width, original_fidelity_panel_height = original_fidelity_panel_image.size
    expected_original_fidelity_width = 1232
    expected_original_fidelity_height = 1200
    if (
        original_fidelity_panel_width != expected_original_fidelity_width
        or original_fidelity_panel_height != expected_original_fidelity_height
    ):
        print(
            "original fidelity panel screenshot has invalid dimensions: "
            f"{original_fidelity_panel_width}x{original_fidelity_panel_height}, "
            f"expected={expected_original_fidelity_width}x{expected_original_fidelity_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    original_fidelity_panel_pixels = original_fidelity_panel_image.load()
    pill_region_bottom = int(original_fidelity_panel_height * 0.18)
    for y in range(original_fidelity_panel_height):
        for x in range(original_fidelity_panel_width):
            red, green, blue = original_fidelity_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                original_fidelity_panel_non_dark_pixels += 1
            if y <= pill_region_bottom and luma > 42:
                original_fidelity_panel_pill_pixels += 1
            if red >= 180 and green >= 180 and blue >= 180:
                original_fidelity_panel_text_light_pixels += 1
            if green >= 95 and green > red * 1.12 and green > blue * 1.12:
                original_fidelity_panel_status_green_pixels += 1
            if red >= 150 and green >= 95 and blue <= 95 and red > blue * 1.35:
                original_fidelity_panel_status_orange_pixels += 1
            if x <= 55 and 45 <= luma <= 170 and chroma <= 28:
                original_fidelity_panel_status_gap_pixels += 1

    if original_fidelity_panel_non_dark_pixels < 160000:
        print(
            "original fidelity panel appears blank or too dark: "
            f"original_fidelity_panel_non_dark_pixels={original_fidelity_panel_non_dark_pixels}, min=160000",
            file=sys.stderr,
        )
        sys.exit(1)

    if original_fidelity_panel_pill_pixels < 300:
        print(
            "original fidelity panel summary pills are missing: "
            f"original_fidelity_panel_pill_pixels={original_fidelity_panel_pill_pixels}, min=300",
            file=sys.stderr,
        )
        sys.exit(1)

    if original_fidelity_panel_text_light_pixels < 6000:
        print(
            "original fidelity panel readable text is missing: "
            f"original_fidelity_panel_text_light_pixels={original_fidelity_panel_text_light_pixels}, min=6000",
            file=sys.stderr,
        )
        sys.exit(1)

    if original_fidelity_panel_status_green_pixels < 250:
        print(
            "original fidelity panel covered-status markers are missing: "
            f"original_fidelity_panel_status_green_pixels={original_fidelity_panel_status_green_pixels}, min=250",
            file=sys.stderr,
        )
        sys.exit(1)

    min_original_status_orange_pixels = int(750 * original_fidelity_panel_width / 1472)
    if original_fidelity_panel_status_orange_pixels < min_original_status_orange_pixels:
        print(
            "original fidelity panel partial-status markers are missing: "
            f"original_fidelity_panel_status_orange_pixels={original_fidelity_panel_status_orange_pixels}, "
            f"min={min_original_status_orange_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if original_fidelity_panel_status_gap_pixels < 2500:
        print(
            "original fidelity panel gap-status markers are missing: "
            f"original_fidelity_panel_status_gap_pixels={original_fidelity_panel_status_gap_pixels}, min=2500",
            file=sys.stderr,
        )
        sys.exit(1)

rune_evidence_panel_path = os.environ.get("TBH_RUNE_EVIDENCE_PANEL_SCREENSHOT_PATH", "")
if rune_evidence_panel_path:
    if not os.path.exists(rune_evidence_panel_path):
        print(f"Rune evidence panel screenshot does not exist: {rune_evidence_panel_path}", file=sys.stderr)
        sys.exit(2)

    rune_evidence_panel_image = Image.open(rune_evidence_panel_path).convert("RGB")
    rune_evidence_panel_width, rune_evidence_panel_height = rune_evidence_panel_image.size
    expected_rune_evidence_width = 1232
    expected_rune_evidence_height = 1240
    if (
        rune_evidence_panel_width != expected_rune_evidence_width
        or rune_evidence_panel_height != expected_rune_evidence_height
    ):
        print(
            "Rune evidence panel screenshot has invalid dimensions: "
            f"{rune_evidence_panel_width}x{rune_evidence_panel_height}, "
            f"expected={expected_rune_evidence_width}x{expected_rune_evidence_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    rune_evidence_panel_pixels = rune_evidence_panel_image.load()
    pill_region_bottom = int(rune_evidence_panel_height * 0.34)
    for y in range(rune_evidence_panel_height):
        for x in range(rune_evidence_panel_width):
            red, green, blue = rune_evidence_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                rune_evidence_panel_non_dark_pixels += 1
            if y <= pill_region_bottom and luma > 42 and chroma >= 18:
                rune_evidence_panel_pill_pixels += 1
            if red >= 175 and green >= 175 and blue >= 175:
                rune_evidence_panel_text_light_pixels += 1
            if red >= 150 and green >= 85 and blue <= 110 and red > blue * 1.35:
                rune_evidence_panel_orange_pixels += 1
            if green >= 95 and green > red * 1.12 and green > blue * 1.12:
                rune_evidence_panel_green_pixels += 1
            if blue >= 120 and 55 <= green <= 190 and red <= 145 and blue > red * 1.18:
                rune_evidence_panel_blue_pixels += 1

    if rune_evidence_panel_non_dark_pixels < 120000:
        print(
            "Rune evidence panel appears blank or too dark: "
            f"rune_evidence_panel_non_dark_pixels={rune_evidence_panel_non_dark_pixels}, min=120000",
            file=sys.stderr,
        )
        sys.exit(1)

    if rune_evidence_panel_pill_pixels < 600:
        print(
            "Rune evidence panel summary pills are missing: "
            f"rune_evidence_panel_pill_pixels={rune_evidence_panel_pill_pixels}, min=600",
            file=sys.stderr,
        )
        sys.exit(1)

    if rune_evidence_panel_text_light_pixels < 9000:
        print(
            "Rune evidence panel readable text is missing: "
            f"rune_evidence_panel_text_light_pixels={rune_evidence_panel_text_light_pixels}, min=9000",
            file=sys.stderr,
        )
        sys.exit(1)

    if rune_evidence_panel_orange_pixels < 2500:
        print(
            "Rune evidence panel pending-cost markers are missing: "
            f"rune_evidence_panel_orange_pixels={rune_evidence_panel_orange_pixels}, min=2500",
            file=sys.stderr,
        )
        sys.exit(1)

    if rune_evidence_panel_green_pixels < 200:
        print(
            "Rune evidence panel verified-cost markers are missing: "
            f"rune_evidence_panel_green_pixels={rune_evidence_panel_green_pixels}, min=200",
            file=sys.stderr,
        )
        sys.exit(1)

skill_evidence_panel_path = os.environ.get("TBH_SKILL_EVIDENCE_PANEL_SCREENSHOT_PATH", "")
if skill_evidence_panel_path:
    if not os.path.exists(skill_evidence_panel_path):
        print(f"skill evidence panel screenshot does not exist: {skill_evidence_panel_path}", file=sys.stderr)
        sys.exit(2)

    skill_evidence_panel_image = Image.open(skill_evidence_panel_path).convert("RGB")
    skill_evidence_panel_width, skill_evidence_panel_height = skill_evidence_panel_image.size
    expected_skill_evidence_width = 1232
    expected_skill_evidence_height = 1440
    if (
        skill_evidence_panel_width != expected_skill_evidence_width
        or skill_evidence_panel_height != expected_skill_evidence_height
    ):
        print(
            "skill evidence panel screenshot has invalid dimensions: "
            f"{skill_evidence_panel_width}x{skill_evidence_panel_height}, "
            f"expected={expected_skill_evidence_width}x{expected_skill_evidence_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    skill_evidence_panel_pixels = skill_evidence_panel_image.load()
    pill_region_bottom = int(skill_evidence_panel_height * 0.42)
    for y in range(skill_evidence_panel_height):
        for x in range(skill_evidence_panel_width):
            red, green, blue = skill_evidence_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                skill_evidence_panel_non_dark_pixels += 1
            if y <= pill_region_bottom and luma > 42 and chroma >= 18:
                skill_evidence_panel_pill_pixels += 1
            if red >= 175 and green >= 175 and blue >= 175:
                skill_evidence_panel_text_light_pixels += 1
            if red >= 150 and green >= 85 and blue <= 120 and red > blue * 1.25:
                skill_evidence_panel_orange_pixels += 1
            if green >= 95 and green > red * 1.10 and green > blue * 1.10:
                skill_evidence_panel_green_pixels += 1
            if blue >= 120 and 55 <= green <= 190 and red <= 145 and blue > red * 1.18:
                skill_evidence_panel_blue_pixels += 1
            if red >= 115 and blue >= 130 and green <= 150 and blue > green * 1.05:
                skill_evidence_panel_purple_pixels += 1

    if skill_evidence_panel_non_dark_pixels < 100000:
        print(
            "skill evidence panel appears blank or too dark: "
            f"skill_evidence_panel_non_dark_pixels={skill_evidence_panel_non_dark_pixels}, min=100000",
            file=sys.stderr,
        )
        sys.exit(1)

    if skill_evidence_panel_pill_pixels < 600:
        print(
            "skill evidence panel summary pills are missing: "
            f"skill_evidence_panel_pill_pixels={skill_evidence_panel_pill_pixels}, min=600",
            file=sys.stderr,
        )
        sys.exit(1)

    if skill_evidence_panel_text_light_pixels < 9000:
        print(
            "skill evidence panel readable text is missing: "
            f"skill_evidence_panel_text_light_pixels={skill_evidence_panel_text_light_pixels}, min=9000",
            file=sys.stderr,
        )
        sys.exit(1)

    if skill_evidence_panel_orange_pixels < 800:
        print(
            "skill evidence panel pending-source markers are missing: "
            f"skill_evidence_panel_orange_pixels={skill_evidence_panel_orange_pixels}, min=800",
            file=sys.stderr,
        )
        sys.exit(1)

passive_evidence_panel_path = os.environ.get("TBH_PASSIVE_EVIDENCE_PANEL_SCREENSHOT_PATH", "")
if passive_evidence_panel_path:
    if not os.path.exists(passive_evidence_panel_path):
        print(f"passive evidence panel screenshot does not exist: {passive_evidence_panel_path}", file=sys.stderr)
        sys.exit(2)

    passive_evidence_panel_image = Image.open(passive_evidence_panel_path).convert("RGB")
    passive_evidence_panel_width, passive_evidence_panel_height = passive_evidence_panel_image.size
    expected_passive_evidence_width = 1232
    expected_passive_evidence_height = 1440
    if (
        passive_evidence_panel_width != expected_passive_evidence_width
        or passive_evidence_panel_height != expected_passive_evidence_height
    ):
        print(
            "passive evidence panel screenshot has invalid dimensions: "
            f"{passive_evidence_panel_width}x{passive_evidence_panel_height}, "
            f"expected={expected_passive_evidence_width}x{expected_passive_evidence_height}",
            file=sys.stderr,
        )
        sys.exit(1)

    passive_evidence_panel_pixels = passive_evidence_panel_image.load()
    pill_region_bottom = int(passive_evidence_panel_height * 0.32)
    for y in range(passive_evidence_panel_height):
        for x in range(passive_evidence_panel_width):
            red, green, blue = passive_evidence_panel_pixels[x, y]
            luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            chroma = max(red, green, blue) - min(red, green, blue)
            if luma > 35:
                passive_evidence_panel_non_dark_pixels += 1
            if y <= pill_region_bottom and luma > 42 and chroma >= 18:
                passive_evidence_panel_pill_pixels += 1
            if red >= 175 and green >= 175 and blue >= 175:
                passive_evidence_panel_text_light_pixels += 1
            if green >= 95 and green > red * 1.10 and green > blue * 1.10:
                passive_evidence_panel_green_pixels += 1
            if red >= 145 and green >= 75 and blue <= 120 and red > blue * 1.25:
                passive_evidence_panel_missing_icon_pixels += 1
            if chroma >= 28 and luma > 45 and not (red >= 145 and green >= 75 and blue <= 120 and red > blue * 1.25):
                passive_evidence_panel_source_icon_pixels += 1

    if passive_evidence_panel_non_dark_pixels < 80000:
        print(
            "passive evidence panel appears blank or too dark: "
            f"passive_evidence_panel_non_dark_pixels={passive_evidence_panel_non_dark_pixels}, min=80000",
            file=sys.stderr,
        )
        sys.exit(1)

    if passive_evidence_panel_pill_pixels < 400:
        print(
            "passive evidence panel summary pills are missing: "
            f"passive_evidence_panel_pill_pixels={passive_evidence_panel_pill_pixels}, min=400",
            file=sys.stderr,
        )
        sys.exit(1)

    if passive_evidence_panel_text_light_pixels < 6000:
        print(
            "passive evidence panel readable text is missing: "
            f"passive_evidence_panel_text_light_pixels={passive_evidence_panel_text_light_pixels}, min=6000",
            file=sys.stderr,
        )
        sys.exit(1)

    if passive_evidence_panel_source_icon_pixels < 1200:
        print(
            "passive evidence panel source-icon colors are missing: "
            f"passive_evidence_panel_source_icon_pixels={passive_evidence_panel_source_icon_pixels}, min=1200",
            file=sys.stderr,
        )
        sys.exit(1)

    if passive_evidence_panel_missing_icon_pixels < 300:
        print(
            "passive evidence panel missing-source-icon markers are missing: "
            f"passive_evidence_panel_missing_icon_pixels={passive_evidence_panel_missing_icon_pixels}, min=300",
            file=sys.stderr,
        )
        sys.exit(1)

motion_path = os.environ.get("TBH_MOTION_SCREENSHOT_PATH", "")
if motion_path:
    if not os.path.exists(motion_path):
        print(f"motion screenshot does not exist: {motion_path}", file=sys.stderr)
        sys.exit(2)
    motion_image = Image.open(motion_path).convert("RGB")
    if motion_image.size != image.size:
        print(
            f"motion screenshot size mismatch: base={image.size}, motion={motion_image.size}",
            file=sys.stderr,
        )
        sys.exit(1)

    motion_pixels = motion_image.load()
    for y in range(height):
        for x in range(width):
            red, green, blue = pixels[x, y]
            next_red, next_green, next_blue = motion_pixels[x, y]
            if abs(red - next_red) + abs(green - next_green) + abs(blue - next_blue) > 36:
                local_motion_pixels += 1

    total_pixel_count = max(1, width * height)
    local_motion_percent = local_motion_pixels / total_pixel_count
    min_local_motion_pixels = max(6_000, int(total_pixel_count * 0.002))
    if local_motion_pixels < min_local_motion_pixels:
        print(
            "local battle scene motion is static or too subtle between deterministic frames: "
            f"local_motion_pixels={local_motion_pixels}, min={min_local_motion_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            red, green, blue = pixels[x, y]
            next_red, next_green, next_blue = motion_pixels[x, y]
            if abs(red - next_red) + abs(green - next_green) + abs(blue - next_blue) > 18:
                flame_motion_pixels += 1

    min_flame_motion_pixels = max(120, int(band_width * band_height * 0.012))
    if flame_motion_pixels < min_flame_motion_pixels:
        print(
            "animated flame strip is static or too subtle between deterministic frames: "
            f"flame_motion_pixels={flame_motion_pixels}, min={min_flame_motion_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)
    flame_motion_percent = flame_motion_pixels / max(1, band_width * band_height)

if check_party_layout:
    if rendered_snapshot:
        scene_width = float(width)
        scene_height = float(height)
        scene_left = 0.0
        scene_top = 0.0
    else:
        scene_width = estimated_scene_width
        scene_height = band_height / ground_ratio
        scene_left = min_x - scene_width * ground_platform_side_inset_ratio
        scene_top = max(0.0, max_y + 1 - scene_height)

    def is_warm_ground_color(red, green, blue):
        return (
            red >= 120
            and 55 <= green <= 190
            and blue <= 115
            and red > green * 1.12
            and green > blue * 1.05
        )

    def is_dark_backdrop(red, green, blue):
        return red < 38 and green < 58 and blue < 68

    def is_hp_green(red, green, blue):
        return green >= 125 and green > red * 1.25 and green > blue * 1.15

    def is_hp_red(red, green, blue):
        return red >= 180 and green <= 130 and blue <= 145 and red > green * 1.25 and red > blue * 1.15

    def is_stage_text_pixel(red, green, blue):
        return red >= 185 and green >= 185 and blue >= 185

    def is_stage_pill_dark_pixel(red, green, blue):
        return red < 28 and green < 38 and blue < 44

    def is_hp_frame_gray(red, green, blue):
        luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return (
            80 <= luma <= 190
            and max(red, green, blue) - min(red, green, blue) <= 40
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        )

    def is_deployable_teal(red, green, blue):
        return (
            green >= 175
            and blue >= 150
            and red <= 140
            and green > red * 1.35
            and blue > red * 1.25
        )

    def is_impact_cold(red, green, blue):
        return (
            blue >= 190
            and green >= 175
            and red <= 150
            and blue > red * 1.35
            and green > red * 1.25
        )

    def is_enemy_status_chilled(red, green, blue):
        return (
            green >= 180
            and blue >= 190
            and red <= 175
            and blue > red * 1.18
            and green > red * 1.12
            and not is_hp_green(red, green, blue)
            and not is_hp_red(red, green, blue)
        )

    def is_enemy_status_frozen(red, green, blue):
        return (
            blue >= 175
            and 90 <= green <= 205
            and red <= 170
            and blue > red * 1.22
            and blue > green * 1.04
            and not is_hp_green(red, green, blue)
            and not is_hp_red(red, green, blue)
        ) or (
            red >= 185
            and green >= 205
            and blue >= 225
            and not is_hp_green(red, green, blue)
            and not is_hp_red(red, green, blue)
        )

    def is_enemy_status_stunned(red, green, blue):
        return (
            red >= 190
            and green >= 135
            and blue <= 135
            and red > blue * 1.35
            and green > blue * 1.08
            and not is_hp_red(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        )

    def is_enemy_status_bleeding(red, green, blue):
        return (
            red >= 130
            and green <= 115
            and blue <= 135
            and red > green * 1.20
            and red > blue * 1.20
            and not is_hp_red(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        )

    def is_impact_fire(red, green, blue):
        return (
            red >= 180
            and 45 <= green <= 170
            and blue <= 95
            and red > green * 1.20
            and green > blue * 1.15
        )

    def is_impact_lightning(red, green, blue):
        return (
            red >= 185
            and green >= 170
            and blue <= 140
            and red > blue * 1.35
            and green > blue * 1.25
        ) or (
            red >= 210
            and green >= 210
            and blue >= 185
        )

    def is_impact_earth(red, green, blue):
        return (
            red >= 100
            and 55 <= green <= 170
            and 35 <= blue <= 130
            and red > blue * 1.18
            and green > blue * 1.02
        )

    def is_impact_rock_explosion(red, green, blue):
        return (
            red >= 150
            and 85 <= green <= 195
            and 35 <= blue <= 145
            and red > blue * 1.35
            and green > blue * 1.05
            and red >= green * 1.03
        )

    def is_impact_shockwave(red, green, blue):
        luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return (
            100 <= luma <= 245
            and max(red, green, blue) - min(red, green, blue) <= 70
            and blue >= red - 18
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        ) or (
            red >= 190 and green >= 190 and blue >= 185
        )

    def is_impact_chaos(red, green, blue):
        purple = (
            red >= 130
            and blue >= 150
            and 60 <= green <= 190
            and blue >= green * 1.15
            and red >= green * 1.05
        )
        green_flare = (
            green >= 145
            and 35 <= red <= 130
            and 80 <= blue <= 200
            and green > red * 1.45
            and green > blue * 1.10
        )
        return (
            (purple or green_flare)
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def is_charge_dash_light(red, green, blue):
        luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return (
            luma >= 125
            and max(red, green, blue) - min(red, green, blue) <= 70
            and blue >= red - 22
            and green >= red - 22
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def is_leap_arc_gold(red, green, blue):
        return (
            red >= 170
            and green >= 120
            and 65 <= blue <= 185
            and red >= green
            and green > blue * 1.08
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        ) or (
            red >= 210
            and green >= 200
            and blue >= 180
            and not is_warm_ground_color(red, green, blue)
        )

    def is_axe_spin_gold(red, green, blue):
        return (
            red >= 170
            and green >= 115
            and 35 <= blue <= 175
            and red >= green * 1.08
            and green > blue * 1.20
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        ) or (
            red >= 205
            and green >= 190
            and blue >= 170
            and max(red, green, blue) - min(red, green, blue) <= 70
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def is_bleed_rend_red(red, green, blue):
        return (
            red >= 145
            and green <= 120
            and blue <= 125
            and red > green * 1.25
            and red > blue * 1.25
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def is_utility_shield_blue(red, green, blue):
        return (
            blue >= 165
            and green >= 125
            and red <= 140
            and blue > red * 1.35
            and green > red * 1.15
        )

    def is_utility_heal_green(red, green, blue):
        return (
            green >= 165
            and blue >= 110
            and red <= 175
            and green > red * 1.20
            and green > blue * 1.05
        )

    def is_utility_gold(red, green, blue):
        return (
            red >= 185
            and green >= 135
            and blue <= 125
            and red > blue * 1.45
            and green > blue * 1.18
        )

    def is_utility_blood_red(red, green, blue):
        return (
            red >= 170
            and green <= 95
            and blue <= 105
            and red > green * 1.75
            and red > blue * 1.55
        )

    def is_utility_bright_white(red, green, blue):
        return red >= 190 and green >= 190 and blue >= 185

    def is_critical_floating_orange(red, green, blue):
        return (
            red >= 185
            and 80 <= green <= 190
            and blue <= 125
            and red > green * 1.12
            and red > blue * 1.55
            and not is_hp_red(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def is_dodge_floating_mint(red, green, blue):
        return (
            green >= 175
            and blue >= 135
            and red <= 160
            and green > red * 1.25
            and blue > red * 1.05
            and not is_hp_green(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        )

    def is_block_floating_blue(red, green, blue):
        return (
            blue >= 170
            and green >= 105
            and red <= 150
            and blue > red * 1.35
            and blue > green * 1.05
            and not is_hp_green(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        )

    def is_hero_contact_pulse(red, green, blue):
        return (
            red >= 185
            and green >= 135
            and blue <= 170
            and red > blue * 1.20
            and green > blue * 0.95
            and not is_hp_red(red, green, blue)
            and not is_hp_green(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        ) or (
            red >= 205
            and green >= 205
            and blue >= 190
            and not is_hp_red(red, green, blue)
            and not is_hp_green(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
        )

    def is_monster_contact_pulse(red, green, blue):
        return (
            red >= 170
            and 40 <= green <= 215
            and blue <= 150
            and red > blue * 1.35
            and green > blue * 1.05
            and not is_hp_green(red, green, blue)
        )

    def is_foreground_pixel(red, green, blue):
        luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return (
            luma > 35
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def is_steel_knight_pixel(red, green, blue):
        luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return (
            35 <= luma <= 230
            and abs(red - green) <= 34
            and abs(green - blue) <= 46
            and blue >= red - 12
            and not is_dark_backdrop(red, green, blue)
            and not is_warm_ground_color(red, green, blue)
            and not is_hp_green(red, green, blue)
        )

    def collect_region(x_start_ratio, x_end_ratio, y_start_ratio, y_end_ratio, predicate):
        x_start = max(0, int(scene_left + scene_width * x_start_ratio))
        x_end = min(width, int(scene_left + scene_width * x_end_ratio))
        y_start = max(0, int(scene_top + scene_height * y_start_ratio))
        y_end = min(height, int(scene_top + scene_height * y_end_ratio))
        count = 0
        x_sum = 0

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                red, green, blue = pixels[x, y]
                if predicate(red, green, blue):
                    count += 1
                    x_sum += x

        centroid_x = (x_sum / count) if count else None
        return count, centroid_x

    def collect_region_bbox(x_start_ratio, x_end_ratio, y_start_ratio, y_end_ratio, predicate):
        x_start = max(0, int(scene_left + scene_width * x_start_ratio))
        x_end = min(width, int(scene_left + scene_width * x_end_ratio))
        y_start = max(0, int(scene_top + scene_height * y_start_ratio))
        y_end = min(height, int(scene_top + scene_height * y_end_ratio))
        count = 0
        x_sum = 0
        y_sum = 0
        x_min = width
        x_max = -1
        y_min = height
        y_max = -1

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                red, green, blue = pixels[x, y]
                if predicate(red, green, blue):
                    count += 1
                    x_sum += x
                    y_sum += y
                    x_min = min(x_min, x)
                    x_max = max(x_max, x)
                    y_min = min(y_min, y)
                    y_max = max(y_max, y)

        centroid = ((x_sum / count, y_sum / count) if count else None)
        bbox = ((x_min, y_min, x_max, y_max) if count else None)
        return count, centroid, bbox

    enemy_status_effects_path = os.environ.get("TBH_ENEMY_STATUS_EFFECTS_SCREENSHOT_PATH", "")
    if enemy_status_effects_path:
        if not os.path.exists(enemy_status_effects_path):
            print(f"enemy-status screenshot does not exist: {enemy_status_effects_path}", file=sys.stderr)
            sys.exit(2)

        enemy_status_image = Image.open(enemy_status_effects_path).convert("RGB")
        status_width, status_height = enemy_status_image.size
        if status_width != width or status_height != height:
            print(
                "enemy-status screenshot size mismatch: "
                f"base={width}x{height}, status={status_width}x{status_height}",
                file=sys.stderr,
            )
            sys.exit(1)

        status_pixels = enemy_status_image.load()

        def count_status_region(x_start_ratio, x_end_ratio, y_start_ratio, y_end_ratio, predicate):
            x_start = max(0, int(status_width * x_start_ratio))
            x_end = min(status_width, int(status_width * x_end_ratio))
            y_start = max(0, int(status_height * y_start_ratio))
            y_end = min(status_height, int(status_height * y_end_ratio))
            count = 0

            for y in range(y_start, y_end):
                for x in range(x_start, x_end):
                    red, green, blue = status_pixels[x, y]
                    if predicate(red, green, blue):
                        count += 1

            return count

        enemy_status_chilled_pixels = count_status_region(
            0.50, 0.92, 0.58, 0.92, is_enemy_status_chilled
        )
        enemy_status_frozen_pixels = count_status_region(
            0.58, 0.92, 0.58, 0.90, is_enemy_status_frozen
        )
        enemy_status_stunned_pixels = count_status_region(
            0.62, 0.92, 0.20, 0.46, is_enemy_status_stunned
        )
        enemy_status_bleeding_pixels = count_status_region(
            0.70, 0.88, 0.62, 0.78, is_enemy_status_bleeding
        )

        if enemy_status_chilled_pixels < 35:
            print(
                "enemy chilled body-effect pixels are missing or too faint: "
                f"enemy_status_chilled_pixels={enemy_status_chilled_pixels}, min=35",
                file=sys.stderr,
            )
            sys.exit(1)

        if enemy_status_frozen_pixels < 55:
            print(
                "enemy frozen body-effect pixels are missing or too faint: "
                f"enemy_status_frozen_pixels={enemy_status_frozen_pixels}, min=55",
                file=sys.stderr,
            )
            sys.exit(1)

        if enemy_status_stunned_pixels < 6:
            print(
                "enemy stunned body-effect pixels are missing or too faint: "
                f"enemy_status_stunned_pixels={enemy_status_stunned_pixels}, min=6",
                file=sys.stderr,
            )
            sys.exit(1)

        if enemy_status_bleeding_pixels < 8:
            print(
                "enemy bleeding body-effect pixels are missing or too faint: "
                f"enemy_status_bleeding_pixels={enemy_status_bleeding_pixels}, min=8",
                file=sys.stderr,
            )
            sys.exit(1)

    primary_pixels, primary_centroid = collect_region(0.20, 0.43, 0.35, 0.96, is_foreground_pixel)
    support_pixels, support_centroid = collect_region(0.02, 0.26, 0.45, 0.96, is_foreground_pixel)
    primary_steel_pixels, _ = collect_region(0.20, 0.43, 0.35, 0.96, is_steel_knight_pixel)
    stage_pill_text_pixels, stage_pill_text_centroid, _ = collect_region_bbox(
        0.06, 0.15, 0.30, 0.52, is_stage_text_pixel
    )
    stage_pill_dark_pixels, _, _ = collect_region_bbox(
        0.06, 0.15, 0.30, 0.52, is_stage_pill_dark_pixel
    )
    main_hp_pixels, _, main_hp_bbox = collect_region_bbox(0.20, 0.43, 0.22, 0.26, is_hp_green)
    support_hp_pixels, _, _ = collect_region_bbox(0.02, 0.30, 0.48, 0.56, is_hp_green)
    enemy_hp_frame_pixels, _, enemy_hp_frame_bbox = collect_region_bbox(
        0.66, 0.89, 0.22, 0.26, is_hp_red
    )
    deployable_teal_pixels, _, deployable_teal_bbox = collect_region_bbox(
        0.34, 0.50, 0.30, 0.36, is_deployable_teal
    )
    impact_cold_pixels, _, impact_cold_bbox = collect_region_bbox(
        0.52, 0.76, 0.40, 0.90, is_impact_cold
    )
    trajectory_cold_pixels, _, trajectory_cold_bbox = collect_region_bbox(
        0.42, 0.68, 0.40, 0.70, is_impact_cold
    )

    primary_metrics = (primary_pixels, primary_centroid)
    support_metrics = (support_pixels, support_centroid)

    min_primary_pixels = max(180, int(scene_width * scene_height * 0.025))
    min_support_pixels = max(120, int(scene_width * scene_height * 0.012))
    min_primary_steel_pixels = max(120, int(scene_width * scene_height * 0.012))
    min_party_centroid_gap = scene_width * 0.08
    min_stage_pill_text_pixels = 24
    min_stage_pill_dark_pixels = 500
    min_main_hp_pixels = max(480, int(scene_width * 0.70))
    min_support_hp_pixels = max(300, int(scene_width * 0.50))
    min_enemy_hp_frame_span = scene_width * 0.055
    min_deployable_teal_pixels = max(10, int(scene_width * 0.08))
    min_impact_cold_pixels = max(24, int(scene_width * 0.11))
    min_trajectory_cold_pixels = max(18, int(scene_width * 0.09))
    min_combatant_motion_pixels = max(420, int(scene_width * scene_height * 0.006))
    min_player_combatant_motion_pixels = max(180, int(scene_width * scene_height * 0.0015))
    min_enemy_combatant_motion_pixels = max(120, int(scene_width * scene_height * 0.001))

    def count_combatant_motion_pixels(x_min_ratio, x_max_ratio):
        if not motion_path:
            return 0

        x_start = max(0, int(scene_left + scene_width * x_min_ratio))
        x_end = min(width, int(scene_left + scene_width * x_max_ratio))
        y_start = max(0, int(scene_top + scene_height * 0.48))
        y_end = min(height, int(scene_top + scene_height * 0.96))
        count = 0

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                red, green, blue = pixels[x, y]
                next_red, next_green, next_blue = motion_pixels[x, y]
                base_foreground = is_foreground_pixel(red, green, blue) and not is_impact_cold(red, green, blue)
                next_foreground = is_foreground_pixel(next_red, next_green, next_blue) and not is_impact_cold(next_red, next_green, next_blue)
                if not (base_foreground or next_foreground):
                    continue

                if abs(red - next_red) + abs(green - next_green) + abs(blue - next_blue) > 30:
                    count += 1

        return count

    combatant_motion_pixels = count_combatant_motion_pixels(0.12, 0.98)
    player_combatant_motion_pixels = count_combatant_motion_pixels(0.12, 0.63)
    enemy_combatant_motion_pixels = count_combatant_motion_pixels(0.68, 0.98)
    scene_area = max(1.0, scene_width * scene_height)
    combatant_motion_scene_percent = combatant_motion_pixels / scene_area
    player_combatant_motion_scene_percent = player_combatant_motion_pixels / scene_area
    enemy_combatant_motion_scene_percent = enemy_combatant_motion_pixels / scene_area

    if primary_pixels < min_primary_pixels:
        print(
            "primary hero lane does not contain enough foreground pixels: "
            f"primary_pixels={primary_pixels}, min={min_primary_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if primary_steel_pixels < min_primary_steel_pixels:
        print(
            "primary hero lane does not contain enough steel-gray Knight silhouette pixels: "
            f"primary_hero_steel_pixels={primary_steel_pixels}, min={min_primary_steel_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if support_pixels < min_support_pixels:
        print(
            "support hero lane does not contain enough foreground pixels on the player-left side: "
            f"support_pixels={support_pixels}, min={min_support_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if stage_pill_text_pixels < min_stage_pill_text_pixels:
        print(
            "stage pill text is missing or too faint in the upper-left lane: "
            f"stage_pill_text_pixels={stage_pill_text_pixels}, min={min_stage_pill_text_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if stage_pill_dark_pixels < min_stage_pill_dark_pixels:
        print(
            "stage pill dark backing is missing or too small: "
            f"stage_pill_dark_pixels={stage_pill_dark_pixels}, min={min_stage_pill_dark_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if stage_pill_text_centroid is None:
        print("could not locate stage pill text centroid", file=sys.stderr)
        sys.exit(1)

    stage_text_x, stage_text_y = stage_pill_text_centroid
    if not (
        scene_left + scene_width * 0.07 <= stage_text_x <= scene_left + scene_width * 0.14
        and scene_top + scene_height * 0.30 <= stage_text_y <= scene_top + scene_height * 0.50
    ):
        print(
            "stage pill text drifted away from the official-style upper-left position: "
            f"centroid=({stage_text_x:.1f},{stage_text_y:.1f})",
            file=sys.stderr,
        )
        sys.exit(1)

    if main_hp_pixels < min_main_hp_pixels:
        print(
            "primary hero top HP bar is missing or too small: "
            f"main_hp_pixels={main_hp_pixels}, min={min_main_hp_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if support_hp_pixels < min_support_hp_pixels:
        print(
            "support HP bars are missing or too small: "
            f"support_hp_pixels={support_hp_pixels}, min={min_support_hp_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if main_hp_bbox is None:
        print("could not locate primary hero HP bar bounds", file=sys.stderr)
        sys.exit(1)

    main_hp_span = main_hp_bbox[2] - main_hp_bbox[0] + 1
    if main_hp_span < scene_width * 0.11:
        print(
            "primary hero HP bar is too narrow for the battle strip: "
            f"main_hp_span={main_hp_span:.1f}, min={scene_width * 0.11:.1f}",
            file=sys.stderr,
        )
        sys.exit(1)

    if enemy_hp_frame_bbox is None:
        print("could not locate enemy HP bar bounds", file=sys.stderr)
        sys.exit(1)

    enemy_hp_frame_span = enemy_hp_frame_bbox[2] - enemy_hp_frame_bbox[0] + 1
    if enemy_hp_frame_pixels < 6 or enemy_hp_frame_span < min_enemy_hp_frame_span:
        print(
            "enemy top HP bar is missing or too narrow: "
            f"enemy_hp_frame_pixels={enemy_hp_frame_pixels}, "
            f"span={enemy_hp_frame_span:.1f}, min_span={min_enemy_hp_frame_span:.1f}",
            file=sys.stderr,
        )
        sys.exit(1)

    if deployable_teal_bbox is None or deployable_teal_pixels < min_deployable_teal_pixels:
        print(
            "player deployable trap marker is missing from the battle lane: "
            f"deployable_teal_pixels={deployable_teal_pixels}, min={min_deployable_teal_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if impact_cold_bbox is None or impact_cold_pixels < min_impact_cold_pixels:
        print(
            "cold skill impact cue is missing from the enemy hit lane: "
            f"impact_cold_pixels={impact_cold_pixels}, min={min_impact_cold_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if trajectory_cold_bbox is None or trajectory_cold_pixels < min_trajectory_cold_pixels:
        print(
            "cold projectile trajectory cue is missing from the mid-lane: "
            f"trajectory_cold_pixels={trajectory_cold_pixels}, min={min_trajectory_cold_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if motion_path and combatant_motion_pixels < min_combatant_motion_pixels:
        print(
            "combatant idle motion is static or too subtle between deterministic frames: "
            f"combatant_motion_pixels={combatant_motion_pixels}, min={min_combatant_motion_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if motion_path and player_combatant_motion_pixels < min_player_combatant_motion_pixels:
        print(
            "player-side combatant idle motion is static or too subtle between deterministic frames: "
            f"player_combatant_motion_pixels={player_combatant_motion_pixels}, "
            f"min={min_player_combatant_motion_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if motion_path and enemy_combatant_motion_pixels < min_enemy_combatant_motion_pixels:
        print(
            "enemy-side combatant idle motion is static or too subtle between deterministic frames: "
            f"enemy_combatant_motion_pixels={enemy_combatant_motion_pixels}, "
            f"min={min_enemy_combatant_motion_pixels}",
            file=sys.stderr,
        )
        sys.exit(1)

    if primary_centroid is None or support_centroid is None:
        print("could not measure primary/support hero centroids", file=sys.stderr)
        sys.exit(1)

    party_centroid_gap = primary_centroid - support_centroid
    if party_centroid_gap < min_party_centroid_gap:
        print(
            "party layout regressed: support heroes are not clearly to the left of the primary hero: "
            f"gap={party_centroid_gap:.1f}, min={min_party_centroid_gap:.1f}",
            file=sys.stderr,
        )
        sys.exit(1)

    def load_utility_pixels(utility_path, label):
        if not os.path.exists(utility_path):
            print(f"{label} utility screenshot does not exist: {utility_path}", file=sys.stderr)
            sys.exit(2)
        utility_image = Image.open(utility_path).convert("RGB")
        if utility_image.size != image.size:
            print(
                f"{label} utility screenshot size mismatch: base={image.size}, utility={utility_image.size}",
                file=sys.stderr,
            )
            sys.exit(1)
        return utility_image.load()

    def count_changed_utility_pixels(
        utility_path,
        label,
        predicate,
        x_start_ratio=0.28,
        x_end_ratio=0.58,
        y_start_ratio=0.22,
        y_end_ratio=0.62,
    ):
        utility_pixels = load_utility_pixels(utility_path, label)
        x_start = max(0, int(scene_left + scene_width * x_start_ratio))
        x_end = min(width, int(scene_left + scene_width * x_end_ratio))
        y_start = max(0, int(scene_top + scene_height * y_start_ratio))
        y_end = min(height, int(scene_top + scene_height * y_end_ratio))
        count = 0
        x_min = width
        x_max = -1
        y_min = height
        y_max = -1

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                red, green, blue = utility_pixels[x, y]
                base_red, base_green, base_blue = pixels[x, y]
                changed = abs(red - base_red) + abs(green - base_green) + abs(blue - base_blue) > 22
                if changed and predicate(red, green, blue):
                    count += 1
                    x_min = min(x_min, x)
                    x_max = max(x_max, x)
                    y_min = min(y_min, y)
                    y_max = max(y_max, y)

        if count:
            return count, (x_min, y_min, x_max, y_max)
        return count, None

    def load_comparison_pixels(comparison_path, label):
        if not comparison_path:
            return pixels
        if not os.path.exists(comparison_path):
            print(f"{label} comparison screenshot does not exist: {comparison_path}", file=sys.stderr)
            sys.exit(2)
        comparison_image = Image.open(comparison_path).convert("RGB")
        if comparison_image.size != image.size:
            print(
                f"{label} comparison screenshot size mismatch: base={image.size}, comparison={comparison_image.size}",
                file=sys.stderr,
            )
            sys.exit(1)
        return comparison_image.load()

    def count_changed_utility_pixels_against(
        utility_path,
        comparison_path,
        label,
        predicate,
        x_start_ratio=0.28,
        x_end_ratio=0.58,
        y_start_ratio=0.22,
        y_end_ratio=0.62,
    ):
        utility_pixels = load_utility_pixels(utility_path, label)
        comparison_pixels = load_comparison_pixels(comparison_path, label)
        x_start = max(0, int(scene_left + scene_width * x_start_ratio))
        x_end = min(width, int(scene_left + scene_width * x_end_ratio))
        y_start = max(0, int(scene_top + scene_height * y_start_ratio))
        y_end = min(height, int(scene_top + scene_height * y_end_ratio))
        count = 0
        x_min = width
        x_max = -1
        y_min = height
        y_max = -1

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                red, green, blue = utility_pixels[x, y]
                base_red, base_green, base_blue = comparison_pixels[x, y]
                changed = abs(red - base_red) + abs(green - base_green) + abs(blue - base_blue) > 22
                if changed and predicate(red, green, blue):
                    count += 1
                    x_min = min(x_min, x)
                    x_max = max(x_max, x)
                    y_min = min(y_min, y)
                    y_max = max(y_max, y)

        if count:
            return count, (x_min, y_min, x_max, y_max)
        return count, None

    melee_arc_path = os.environ.get("TBH_MELEE_ARC_SCREENSHOT_PATH", "")
    if melee_arc_path:
        melee_arc_pixels, _ = count_changed_utility_pixels(
            melee_arc_path,
            "melee-arc",
            is_charge_dash_light,
            x_start_ratio=0.38,
            x_end_ratio=0.68,
            y_start_ratio=0.34,
            y_end_ratio=0.76,
        )
        min_melee_arc_pixels = max(18, int(scene_width * 0.20))
        if melee_arc_pixels < min_melee_arc_pixels:
            print(
                "ordinary melee arc trajectory is missing from the mid/enemy lane: "
                f"melee_arc_pixels={melee_arc_pixels}, min={min_melee_arc_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    contact_pulse_baseline_path = os.environ.get("TBH_CONTACT_PULSE_BASELINE_SCREENSHOT_PATH", "")
    hero_contact_pulse_path = os.environ.get("TBH_HERO_CONTACT_PULSE_SCREENSHOT_PATH", "")
    if hero_contact_pulse_path:
        hero_contact_pulse_pixels, _ = count_changed_utility_pixels_against(
            hero_contact_pulse_path,
            contact_pulse_baseline_path,
            "hero-contact-pulse",
            is_hero_contact_pulse,
            x_start_ratio=0.54,
            x_end_ratio=0.78,
            y_start_ratio=0.66,
            y_end_ratio=0.82,
        )
        min_hero_contact_pulse_pixels = max(16, int(scene_width * 0.16))
        if hero_contact_pulse_pixels < min_hero_contact_pulse_pixels:
            print(
                "hero contact-pulse feedback is missing from the enemy hit lane: "
                f"hero_contact_pulse_pixels={hero_contact_pulse_pixels}, min={min_hero_contact_pulse_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    monster_contact_pulse_path = os.environ.get("TBH_MONSTER_CONTACT_PULSE_SCREENSHOT_PATH", "")
    if monster_contact_pulse_path:
        monster_contact_pulse_pixels, _ = count_changed_utility_pixels_against(
            monster_contact_pulse_path,
            contact_pulse_baseline_path,
            "monster-contact-pulse",
            is_monster_contact_pulse,
            x_start_ratio=0.22,
            x_end_ratio=0.46,
            y_start_ratio=0.66,
            y_end_ratio=0.82,
        )
        min_monster_contact_pulse_pixels = max(16, int(scene_width * 0.13))
        if monster_contact_pulse_pixels < min_monster_contact_pulse_pixels:
            print(
                "monster contact-pulse feedback is missing from the player hit lane: "
                f"monster_contact_pulse_pixels={monster_contact_pulse_pixels}, min={min_monster_contact_pulse_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    rapid_volley_path = os.environ.get("TBH_RAPID_VOLLEY_SCREENSHOT_PATH", "")
    if rapid_volley_path:
        rapid_volley_pixels, _ = count_changed_utility_pixels(
            rapid_volley_path,
            "rapid-volley",
            is_charge_dash_light,
            x_start_ratio=0.38,
            x_end_ratio=0.72,
            y_start_ratio=0.34,
            y_end_ratio=0.76,
        )
        min_rapid_volley_pixels = max(18, int(scene_width * 0.22))
        if rapid_volley_pixels < min_rapid_volley_pixels:
            print(
                "Rapid Fire volley trajectory is missing from the mid/enemy lane: "
                f"rapid_volley_pixels={rapid_volley_pixels}, min={min_rapid_volley_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    scatter_shot_path = os.environ.get("TBH_SCATTER_SHOT_SCREENSHOT_PATH", "")
    if scatter_shot_path:
        scatter_shot_pixels, _ = count_changed_utility_pixels(
            scatter_shot_path,
            "scatter-shot",
            is_charge_dash_light,
            x_start_ratio=0.38,
            x_end_ratio=0.72,
            y_start_ratio=0.34,
            y_end_ratio=0.76,
        )
        min_scatter_shot_pixels = max(18, int(scene_width * 0.20))
        if scatter_shot_pixels < min_scatter_shot_pixels:
            print(
                "Scatter Shot tracking-volley trajectory is missing from the mid/enemy lane: "
                f"scatter_shot_pixels={scatter_shot_pixels}, min={min_scatter_shot_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    arrow_rain_path = os.environ.get("TBH_ARROW_RAIN_SCREENSHOT_PATH", "")
    if arrow_rain_path:
        arrow_rain_pixels, _ = count_changed_utility_pixels(
            arrow_rain_path,
            "arrow-rain",
            is_charge_dash_light,
            x_start_ratio=0.38,
            x_end_ratio=0.72,
            y_start_ratio=0.30,
            y_end_ratio=0.76,
        )
        min_arrow_rain_pixels = max(18, int(scene_width * 0.24))
        if arrow_rain_pixels < min_arrow_rain_pixels:
            print(
                "Arrow Rain falling-arrow trajectory is missing from the mid/enemy lane: "
                f"arrow_rain_pixels={arrow_rain_pixels}, min={min_arrow_rain_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    piercing_arrow_path = os.environ.get("TBH_PIERCING_ARROW_SCREENSHOT_PATH", "")
    if piercing_arrow_path:
        piercing_arrow_pixels, _ = count_changed_utility_pixels(
            piercing_arrow_path,
            "piercing-arrow",
            is_charge_dash_light,
            x_start_ratio=0.38,
            x_end_ratio=0.72,
            y_start_ratio=0.34,
            y_end_ratio=0.76,
        )
        min_piercing_arrow_pixels = max(18, int(scene_width * 0.30))
        if piercing_arrow_pixels < min_piercing_arrow_pixels:
            print(
                "Piercing Arrow trajectory is missing from the mid/enemy lane: "
                f"piercing_arrow_pixels={piercing_arrow_pixels}, min={min_piercing_arrow_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    skewer_shot_path = os.environ.get("TBH_SKEWER_SHOT_SCREENSHOT_PATH", "")
    if skewer_shot_path:
        skewer_shot_pixels, _ = count_changed_utility_pixels(
            skewer_shot_path,
            "skewer-shot",
            is_leap_arc_gold,
            x_start_ratio=0.40,
            x_end_ratio=0.76,
            y_start_ratio=0.34,
            y_end_ratio=0.82,
        )
        min_skewer_shot_pixels = max(18, int(scene_width * 0.28))
        if skewer_shot_pixels < min_skewer_shot_pixels:
            print(
                "Skewer Shot lodged-arrow trajectory is missing from the mid/enemy lane: "
                f"skewer_shot_pixels={skewer_shot_pixels}, min={min_skewer_shot_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    explosive_bolt_path = os.environ.get("TBH_EXPLOSIVE_BOLT_SCREENSHOT_PATH", "")
    if explosive_bolt_path:
        damage_explosive_fire_pixels, _ = count_changed_utility_pixels(
            explosive_bolt_path,
            "explosive-bolt",
            is_impact_fire,
            x_start_ratio=0.38,
            x_end_ratio=0.76,
            y_start_ratio=0.30,
            y_end_ratio=0.90,
        )
        min_damage_explosive_fire_pixels = max(30, int(scene_width * 0.60))
        if damage_explosive_fire_pixels < min_damage_explosive_fire_pixels:
            print(
                "explosive bolt fire cue is missing from the mid/enemy lane: "
                f"damage_explosive_fire_pixels={damage_explosive_fire_pixels}, min={min_damage_explosive_fire_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    meteor_strike_path = os.environ.get("TBH_METEOR_STRIKE_SCREENSHOT_PATH", "")
    if meteor_strike_path:
        damage_meteor_fire_pixels, meteor_bbox = count_changed_utility_pixels(
            meteor_strike_path,
            "meteor-strike",
            is_impact_fire,
            x_start_ratio=0.44,
            x_end_ratio=0.78,
            y_start_ratio=0.10,
            y_end_ratio=0.90,
        )
        min_damage_meteor_fire_pixels = max(28, int(scene_width * 0.58))
        damage_meteor_vertical_span = 0 if meteor_bbox is None else meteor_bbox[3] - meteor_bbox[1] + 1
        min_damage_meteor_vertical_span = max(24, int(scene_width * 0.045))
        if (
            damage_meteor_fire_pixels < min_damage_meteor_fire_pixels
            or damage_meteor_vertical_span < min_damage_meteor_vertical_span
        ):
            print(
                "meteor fire cue is missing or no longer reads as a falling strike: "
                f"damage_meteor_fire_pixels={damage_meteor_fire_pixels}, min={min_damage_meteor_fire_pixels}, "
                f"vertical_span={damage_meteor_vertical_span}, min_span={min_damage_meteor_vertical_span}",
                file=sys.stderr,
            )
            sys.exit(1)

    lightning_strike_path = os.environ.get("TBH_LIGHTNING_STRIKE_SCREENSHOT_PATH", "")
    if lightning_strike_path:
        damage_lightning_pixels, _ = count_changed_utility_pixels(
            lightning_strike_path,
            "lightning-strike",
            is_impact_lightning,
            x_start_ratio=0.50,
            x_end_ratio=0.78,
            y_start_ratio=0.24,
            y_end_ratio=0.90,
        )
        min_damage_lightning_pixels = max(22, int(scene_width * 0.48))
        if damage_lightning_pixels < min_damage_lightning_pixels:
            print(
                "lightning impact cue is missing from the enemy hit lane: "
                f"damage_lightning_pixels={damage_lightning_pixels}, min={min_damage_lightning_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    shock_bolt_path = os.environ.get("TBH_SHOCK_BOLT_SCREENSHOT_PATH", "")
    if shock_bolt_path:
        damage_shock_bolt_pixels, _ = count_changed_utility_pixels(
            shock_bolt_path,
            "shock-bolt",
            is_impact_lightning,
            x_start_ratio=0.38,
            x_end_ratio=0.78,
            y_start_ratio=0.24,
            y_end_ratio=0.90,
        )
        min_damage_shock_bolt_pixels = max(22, int(scene_width * 0.42))
        if damage_shock_bolt_pixels < min_damage_shock_bolt_pixels:
            print(
                "Shock Bolt lodged-bolt cue is missing from the mid/enemy lane: "
                f"damage_shock_bolt_pixels={damage_shock_bolt_pixels}, min={min_damage_shock_bolt_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    trap_burst_path = os.environ.get("TBH_TRAP_BURST_SCREENSHOT_PATH", "")
    if trap_burst_path:
        damage_trap_teal_pixels, _ = count_changed_utility_pixels(
            trap_burst_path,
            "trap-burst",
            is_deployable_teal,
            x_start_ratio=0.48,
            x_end_ratio=0.78,
            y_start_ratio=0.28,
            y_end_ratio=0.90,
        )
        min_damage_trap_teal_pixels = max(16, int(scene_width * 0.29))
        if damage_trap_teal_pixels < min_damage_trap_teal_pixels:
            print(
                "charged trap burst cue is missing from the mid/enemy lane: "
                f"damage_trap_teal_pixels={damage_trap_teal_pixels}, min={min_damage_trap_teal_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    summon_projectile_path = os.environ.get("TBH_SUMMON_PROJECTILE_SCREENSHOT_PATH", "")
    if summon_projectile_path:
        damage_summon_fire_pixels, _ = count_changed_utility_pixels(
            summon_projectile_path,
            "summon-projectile",
            is_impact_fire,
            x_start_ratio=0.38,
            x_end_ratio=0.76,
            y_start_ratio=0.30,
            y_end_ratio=0.90,
        )
        min_damage_summon_fire_pixels = max(18, int(scene_width * 0.34))
        if damage_summon_fire_pixels < min_damage_summon_fire_pixels:
            print(
                "summon projectile cue is missing from the mid/enemy lane: "
                f"damage_summon_fire_pixels={damage_summon_fire_pixels}, min={min_damage_summon_fire_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    shock_current_path = os.environ.get("TBH_SHOCK_CURRENT_SCREENSHOT_PATH", "")
    if shock_current_path:
        damage_shock_current_pixels, _ = count_changed_utility_pixels(
            shock_current_path,
            "shock-current",
            is_impact_lightning,
            x_start_ratio=0.38,
            x_end_ratio=0.78,
            y_start_ratio=0.24,
            y_end_ratio=0.90,
        )
        min_damage_shock_current_pixels = max(24, int(scene_width * 0.49))
        if damage_shock_current_pixels < min_damage_shock_current_pixels:
            print(
                "shock-current cue is missing from the mid/enemy lane: "
                f"damage_shock_current_pixels={damage_shock_current_pixels}, min={min_damage_shock_current_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    shield_charge_path = os.environ.get("TBH_SHIELD_CHARGE_SCREENSHOT_PATH", "")
    if shield_charge_path:
        damage_shield_charge_pixels, _ = count_changed_utility_pixels(
            shield_charge_path,
            "shield-charge",
            is_charge_dash_light,
            x_start_ratio=0.30,
            x_end_ratio=0.68,
            y_start_ratio=0.38,
            y_end_ratio=0.82,
        )
        min_damage_shield_charge_pixels = max(18, int(scene_width * 0.34))
        if damage_shield_charge_pixels < min_damage_shield_charge_pixels:
            print(
                "Shield Charge dash trajectory is missing from the mid-lane: "
                f"damage_shield_charge_pixels={damage_shield_charge_pixels}, min={min_damage_shield_charge_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    slam_jump_path = os.environ.get("TBH_SLAM_JUMP_SCREENSHOT_PATH", "")
    if slam_jump_path:
        damage_slam_jump_pixels, slam_jump_bbox = count_changed_utility_pixels(
            slam_jump_path,
            "slam-jump",
            is_leap_arc_gold,
            x_start_ratio=0.34,
            x_end_ratio=0.74,
            y_start_ratio=0.18,
            y_end_ratio=0.78,
        )
        min_damage_slam_jump_pixels = max(20, int(scene_width * 0.39))
        slam_jump_vertical_span = 0 if slam_jump_bbox is None else slam_jump_bbox[3] - slam_jump_bbox[1] + 1
        min_slam_jump_vertical_span = max(12, int(scene_width * 0.03))
        if (
            damage_slam_jump_pixels < min_damage_slam_jump_pixels
            or slam_jump_vertical_span < min_slam_jump_vertical_span
        ):
            print(
                "Slam Jump leap trajectory is missing or too flat in the mid-lane: "
                f"damage_slam_jump_pixels={damage_slam_jump_pixels}, min={min_damage_slam_jump_pixels}, "
                f"vertical_span={slam_jump_vertical_span}, min_span={min_slam_jump_vertical_span}",
                file=sys.stderr,
            )
            sys.exit(1)

    earthquake_impact_path = os.environ.get("TBH_EARTHQUAKE_IMPACT_SCREENSHOT_PATH", "")
    if earthquake_impact_path:
        damage_earthquake_pixels, _ = count_changed_utility_pixels(
            earthquake_impact_path,
            "earthquake-impact",
            is_impact_earth,
            x_start_ratio=0.40,
            x_end_ratio=0.78,
            y_start_ratio=0.34,
            y_end_ratio=0.94,
        )
        min_damage_earthquake_pixels = max(20, int(scene_width * 0.36))
        if damage_earthquake_pixels < min_damage_earthquake_pixels:
            print(
                "earthquake impact cue is missing from the enemy hit lane: "
                f"damage_earthquake_pixels={damage_earthquake_pixels}, min={min_damage_earthquake_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    rock_explosion_path = os.environ.get("TBH_ROCK_EXPLOSION_SCREENSHOT_PATH", "")
    if rock_explosion_path:
        damage_rock_explosion_pixels, _ = count_changed_utility_pixels(
            rock_explosion_path,
            "ground-slam-rock-explosion",
            is_impact_rock_explosion,
            x_start_ratio=0.36,
            x_end_ratio=0.80,
            y_start_ratio=0.24,
            y_end_ratio=0.94,
        )
        min_damage_rock_explosion_pixels = max(22, int(scene_width * 0.43))
        if damage_rock_explosion_pixels < min_damage_rock_explosion_pixels:
            print(
                "Ground Slam rock explosion cue is missing from the enemy hit lane: "
                f"damage_rock_explosion_pixels={damage_rock_explosion_pixels}, "
                f"min={min_damage_rock_explosion_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    axe_spin_path = os.environ.get("TBH_AXE_SPIN_SCREENSHOT_PATH", "")
    if axe_spin_path:
        damage_axe_spin_pixels, _ = count_changed_utility_pixels(
            axe_spin_path,
            "axe-spin",
            is_axe_spin_gold,
            x_start_ratio=0.36,
            x_end_ratio=0.80,
            y_start_ratio=0.24,
            y_end_ratio=0.92,
        )
        min_damage_axe_spin_pixels = max(22, int(scene_width * 0.34))
        if damage_axe_spin_pixels < min_damage_axe_spin_pixels:
            print(
                "Axe Spin spinning slash cue is missing from the enemy hit lane: "
                f"damage_axe_spin_pixels={damage_axe_spin_pixels}, min={min_damage_axe_spin_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    axe_spin_bleed_path = os.environ.get("TBH_AXE_SPIN_BLEED_SCREENSHOT_PATH", "")
    if axe_spin_bleed_path:
        damage_axe_spin_bleed_pixels, _ = count_changed_utility_pixels(
            axe_spin_bleed_path,
            "axe-spin-bleed-follow-up",
            is_bleed_rend_red,
            x_start_ratio=0.36,
            x_end_ratio=0.80,
            y_start_ratio=0.24,
            y_end_ratio=0.92,
        )
        min_damage_axe_spin_bleed_pixels = max(18, int(scene_width * 0.24))
        if damage_axe_spin_bleed_pixels < min_damage_axe_spin_bleed_pixels:
            print(
                "Axe Spin bleed follow-up rend cue is missing from the enemy hit lane: "
                f"damage_axe_spin_bleed_pixels={damage_axe_spin_bleed_pixels}, "
                f"min={min_damage_axe_spin_bleed_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    shockwave_impact_path = os.environ.get("TBH_SHOCKWAVE_IMPACT_SCREENSHOT_PATH", "")
    if shockwave_impact_path:
        damage_shockwave_pixels, _ = count_changed_utility_pixels(
            shockwave_impact_path,
            "shockwave-impact",
            is_impact_shockwave,
            x_start_ratio=0.40,
            x_end_ratio=0.78,
            y_start_ratio=0.28,
            y_end_ratio=0.90,
        )
        min_damage_shockwave_pixels = max(22, int(scene_width * 0.39))
        if damage_shockwave_pixels < min_damage_shockwave_pixels:
            print(
                "shockwave impact cue is missing from the enemy hit lane: "
                f"damage_shockwave_pixels={damage_shockwave_pixels}, min={min_damage_shockwave_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    chaos_burst_path = os.environ.get("TBH_CHAOS_BURST_SCREENSHOT_PATH", "")
    if chaos_burst_path:
        damage_chaos_pixels, _ = count_changed_utility_pixels(
            chaos_burst_path,
            "chaos-burst",
            is_impact_chaos,
            x_start_ratio=0.38,
            x_end_ratio=0.78,
            y_start_ratio=0.24,
            y_end_ratio=0.90,
        )
        min_damage_chaos_pixels = max(18, int(scene_width * 0.34))
        if damage_chaos_pixels < min_damage_chaos_pixels:
            print(
                "chaos impact cue is missing from the mid/enemy lane: "
                f"damage_chaos_pixels={damage_chaos_pixels}, min={min_damage_chaos_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    def count_monster_incoming_pixels(path, label, predicate):
        return count_changed_utility_pixels(
            path,
            label,
            predicate,
            x_start_ratio=0.14,
            x_end_ratio=0.46,
            y_start_ratio=0.24,
            y_end_ratio=0.92,
        )

    min_monster_incoming_pixels = max(18, int(scene_width * 0.34))

    monster_fire_incoming_path = os.environ.get("TBH_MONSTER_FIRE_INCOMING_SCREENSHOT_PATH", "")
    if monster_fire_incoming_path:
        monster_fire_incoming_pixels, _ = count_monster_incoming_pixels(
            monster_fire_incoming_path,
            "monster-fire-incoming",
            is_impact_fire,
        )
        if monster_fire_incoming_pixels < min_monster_incoming_pixels:
            print(
                "monster fire incoming cue is missing from the player-side hit lane: "
                f"monster_fire_incoming_pixels={monster_fire_incoming_pixels}, "
                f"min={min_monster_incoming_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    monster_cold_incoming_path = os.environ.get("TBH_MONSTER_COLD_INCOMING_SCREENSHOT_PATH", "")
    if monster_cold_incoming_path:
        monster_cold_incoming_pixels, _ = count_monster_incoming_pixels(
            monster_cold_incoming_path,
            "monster-cold-incoming",
            is_impact_cold,
        )
        if monster_cold_incoming_pixels < min_monster_incoming_pixels:
            print(
                "monster cold incoming cue is missing from the player-side hit lane: "
                f"monster_cold_incoming_pixels={monster_cold_incoming_pixels}, "
                f"min={min_monster_incoming_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    monster_lightning_incoming_path = os.environ.get("TBH_MONSTER_LIGHTNING_INCOMING_SCREENSHOT_PATH", "")
    if monster_lightning_incoming_path:
        monster_lightning_incoming_pixels, _ = count_monster_incoming_pixels(
            monster_lightning_incoming_path,
            "monster-lightning-incoming",
            is_impact_lightning,
        )
        if monster_lightning_incoming_pixels < min_monster_incoming_pixels:
            print(
                "monster lightning incoming cue is missing from the player-side hit lane: "
                f"monster_lightning_incoming_pixels={monster_lightning_incoming_pixels}, "
                f"min={min_monster_incoming_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    monster_chaos_incoming_path = os.environ.get("TBH_MONSTER_CHAOS_INCOMING_SCREENSHOT_PATH", "")
    if monster_chaos_incoming_path:
        monster_chaos_incoming_pixels, _ = count_monster_incoming_pixels(
            monster_chaos_incoming_path,
            "monster-chaos-incoming",
            is_impact_chaos,
        )
        if monster_chaos_incoming_pixels < min_monster_incoming_pixels:
            print(
                "monster chaos incoming cue is missing from the player-side hit lane: "
                f"monster_chaos_incoming_pixels={monster_chaos_incoming_pixels}, "
                f"min={min_monster_incoming_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    heal_utility_path = os.environ.get("TBH_HEAL_UTILITY_SCREENSHOT_PATH", "")
    if heal_utility_path:
        utility_heal_pixels, _ = count_changed_utility_pixels(
            heal_utility_path,
            "heal",
            is_utility_heal_green,
        )
        min_utility_heal_pixels = max(20, int(scene_width * 0.18))
        if utility_heal_pixels < min_utility_heal_pixels:
            print(
                "heal utility cue is missing from the player utility lane: "
                f"utility_heal_pixels={utility_heal_pixels}, min={min_utility_heal_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    sanctuary_utility_path = os.environ.get("TBH_SANCTUARY_UTILITY_SCREENSHOT_PATH", "")
    if sanctuary_utility_path:
        utility_sanctuary_pixels, _ = count_changed_utility_pixels(
            sanctuary_utility_path,
            "sanctuary",
            is_utility_heal_green,
        )
        min_utility_sanctuary_pixels = max(18, int(scene_width * 0.16))
        if utility_sanctuary_pixels < min_utility_sanctuary_pixels:
            print(
                "Sanctuary utility cue is missing from the player utility lane: "
                f"utility_sanctuary_pixels={utility_sanctuary_pixels}, min={min_utility_sanctuary_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    resurrection_utility_path = os.environ.get("TBH_RESURRECTION_UTILITY_SCREENSHOT_PATH", "")
    if resurrection_utility_path:
        utility_resurrection_pixels, resurrection_bbox = count_changed_utility_pixels(
            resurrection_utility_path,
            "resurrection",
            is_utility_gold,
        )
        min_utility_resurrection_pixels = max(22, int(scene_width * 0.18))
        resurrection_vertical_span = 0 if resurrection_bbox is None else resurrection_bbox[3] - resurrection_bbox[1] + 1
        min_resurrection_vertical_span = max(20, int(scene_width * 0.04))
        if (
            utility_resurrection_pixels < min_utility_resurrection_pixels
            or resurrection_vertical_span < min_resurrection_vertical_span
        ):
            print(
                "resurrection utility cue is missing or no longer reads as a rising cue: "
                f"utility_resurrection_pixels={utility_resurrection_pixels}, min={min_utility_resurrection_pixels}, "
                f"vertical_span={resurrection_vertical_span}, min_span={min_resurrection_vertical_span}",
                file=sys.stderr,
            )
            sys.exit(1)

    utility_path = os.environ.get("TBH_UTILITY_SCREENSHOT_PATH", "")
    if utility_path:
        utility_shield_pixels, _ = count_changed_utility_pixels(
            utility_path,
            "shield",
            is_utility_shield_blue,
        )
        min_utility_shield_pixels = max(18, int(scene_width * 0.18))
        if utility_shield_pixels < min_utility_shield_pixels:
            print(
                "shield utility cue is missing from the player utility lane: "
                f"utility_shield_pixels={utility_shield_pixels}, min={min_utility_shield_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    wrath_of_heaven_utility_path = os.environ.get("TBH_WRATH_OF_HEAVEN_UTILITY_SCREENSHOT_PATH", "")
    if wrath_of_heaven_utility_path:
        utility_wrath_of_heaven_pixels, _ = count_changed_utility_pixels(
            wrath_of_heaven_utility_path,
            "wrath-of-heaven",
            is_impact_lightning,
        )
        min_utility_wrath_of_heaven_pixels = max(18, int(scene_width * 0.16))
        if utility_wrath_of_heaven_pixels < min_utility_wrath_of_heaven_pixels:
            print(
                "Wrath of Heaven utility cue is missing from the player utility lane: "
                f"utility_wrath_of_heaven_pixels={utility_wrath_of_heaven_pixels}, "
                f"min={min_utility_wrath_of_heaven_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    sacred_blade_utility_path = os.environ.get("TBH_SACRED_BLADE_UTILITY_SCREENSHOT_PATH", "")
    if sacred_blade_utility_path:
        utility_sacred_blade_pixels, _ = count_changed_utility_pixels(
            sacred_blade_utility_path,
            "sacred-blade",
            is_utility_gold,
        )
        utility_sacred_blade_white_pixels, _ = count_changed_utility_pixels(
            sacred_blade_utility_path,
            "sacred-blade",
            is_utility_bright_white,
        )
        min_utility_sacred_blade_pixels = max(18, int(scene_width * 0.18))
        min_utility_sacred_blade_white_pixels = max(6, int(scene_width * 0.04))
        if (
            utility_sacred_blade_pixels < min_utility_sacred_blade_pixels
            or utility_sacred_blade_white_pixels < min_utility_sacred_blade_white_pixels
        ):
            print(
                "sacred blade utility cue is missing from the player utility lane: "
                f"utility_sacred_blade_pixels={utility_sacred_blade_pixels}, min={min_utility_sacred_blade_pixels}, "
                f"white_pixels={utility_sacred_blade_white_pixels}, min_white={min_utility_sacred_blade_white_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    swift_surge_utility_path = os.environ.get("TBH_SWIFT_SURGE_UTILITY_SCREENSHOT_PATH", "")
    if swift_surge_utility_path:
        utility_swift_surge_pixels, _ = count_changed_utility_pixels(
            swift_surge_utility_path,
            "swift-surge",
            is_utility_shield_blue,
        )
        min_utility_swift_surge_pixels = max(18, int(scene_width * 0.18))
        if utility_swift_surge_pixels < min_utility_swift_surge_pixels:
            print(
                "Swift Surge utility cue is missing from the player utility lane: "
                f"utility_swift_surge_pixels={utility_swift_surge_pixels}, "
                f"min={min_utility_swift_surge_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    quick_loader_utility_path = os.environ.get("TBH_QUICK_LOADER_UTILITY_SCREENSHOT_PATH", "")
    if quick_loader_utility_path:
        utility_quick_loader_pixels, _ = count_changed_utility_pixels(
            quick_loader_utility_path,
            "quick-loader",
            is_utility_heal_green,
        )
        min_utility_quick_loader_pixels = max(18, int(scene_width * 0.18))
        if utility_quick_loader_pixels < min_utility_quick_loader_pixels:
            print(
                "Quick Loader utility cue is missing from the player utility lane: "
                f"utility_quick_loader_pixels={utility_quick_loader_pixels}, "
                f"min={min_utility_quick_loader_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    generals_cry_utility_path = os.environ.get("TBH_GENERALS_CRY_UTILITY_SCREENSHOT_PATH", "")
    if generals_cry_utility_path:
        utility_generals_cry_pixels, _ = count_changed_utility_pixels(
            generals_cry_utility_path,
            "generals-cry",
            is_utility_gold,
        )
        min_utility_generals_cry_pixels = max(18, int(scene_width * 0.18))
        if utility_generals_cry_pixels < min_utility_generals_cry_pixels:
            print(
                "General's Cry utility cue is missing from the player utility lane: "
                f"utility_generals_cry_pixels={utility_generals_cry_pixels}, "
                f"min={min_utility_generals_cry_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    bloodlust_utility_path = os.environ.get("TBH_BLOODLUST_UTILITY_SCREENSHOT_PATH", "")
    if bloodlust_utility_path:
        utility_bloodlust_pixels, _ = count_changed_utility_pixels(
            bloodlust_utility_path,
            "bloodlust",
            is_utility_blood_red,
        )
        min_utility_bloodlust_pixels = max(18, int(scene_width * 0.18))
        if utility_bloodlust_pixels < min_utility_bloodlust_pixels:
            print(
                "Bloodlust utility cue is missing from the player utility lane: "
                f"utility_bloodlust_pixels={utility_bloodlust_pixels}, min={min_utility_bloodlust_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    def count_floating_feedback_pixels(path, label, predicate):
        return count_changed_utility_pixels(
            path,
            label,
            predicate,
            x_start_ratio=0.30,
            x_end_ratio=0.70,
            y_start_ratio=0.00,
            y_end_ratio=0.16,
        )

    critical_floating_path = os.environ.get("TBH_CRITICAL_FLOATING_SCREENSHOT_PATH", "")
    if critical_floating_path:
        critical_floating_pixels, _ = count_floating_feedback_pixels(
            critical_floating_path,
            "critical-floating",
            is_critical_floating_orange,
        )
        min_critical_floating_pixels = max(24, int(scene_width * 0.03))
        if critical_floating_pixels < min_critical_floating_pixels:
            print(
                "critical floating feedback is missing from the battle text lane: "
                f"critical_floating_pixels={critical_floating_pixels}, min={min_critical_floating_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    dodge_floating_path = os.environ.get("TBH_DODGE_FLOATING_SCREENSHOT_PATH", "")
    if dodge_floating_path:
        dodge_floating_pixels, _ = count_floating_feedback_pixels(
            dodge_floating_path,
            "dodge-floating",
            is_dodge_floating_mint,
        )
        min_dodge_floating_pixels = max(24, int(scene_width * 0.025))
        if dodge_floating_pixels < min_dodge_floating_pixels:
            print(
                "dodge floating feedback is missing from the battle text lane: "
                f"dodge_floating_pixels={dodge_floating_pixels}, min={min_dodge_floating_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    block_floating_path = os.environ.get("TBH_BLOCK_FLOATING_SCREENSHOT_PATH", "")
    if block_floating_path:
        block_floating_pixels, _ = count_floating_feedback_pixels(
            block_floating_path,
            "block-floating",
            is_block_floating_blue,
        )
        min_block_floating_pixels = max(24, int(scene_width * 0.025))
        if block_floating_pixels < min_block_floating_pixels:
            print(
                "block floating feedback is missing from the battle text lane: "
                f"block_floating_pixels={block_floating_pixels}, min={min_block_floating_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    def count_finish_cue_pixels(path, label, predicate, x_start_ratio, x_end_ratio, y_start_ratio, y_end_ratio):
        if not os.path.exists(path):
            print(f"{label} screenshot does not exist: {path}", file=sys.stderr)
            sys.exit(1)

        cue_image = Image.open(path).convert("RGB")
        cue_width, cue_height = cue_image.size
        cue_pixels = cue_image.load()
        x_start = max(0, int(cue_width * x_start_ratio))
        x_end = min(cue_width, int(cue_width * x_end_ratio))
        y_start = max(0, int(cue_height * y_start_ratio))
        y_end = min(cue_height, int(cue_height * y_end_ratio))
        count = 0

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                red, green, blue = cue_pixels[x, y]
                if predicate(red, green, blue):
                    count += 1

        return count

    victory_finish_scene_path = os.environ.get("TBH_VICTORY_FINISH_SCENE_SCREENSHOT_PATH", "")
    if victory_finish_scene_path:
        victory_finish_gold_pixels = count_finish_cue_pixels(
            victory_finish_scene_path,
            "victory-finish-scene",
            is_utility_gold,
            0.48,
            0.70,
            0.30,
            0.50,
        )
        min_victory_finish_gold_pixels = max(120, int(scene_width * 0.36))
        if victory_finish_gold_pixels < min_victory_finish_gold_pixels:
            print(
                "victory finish cue is missing from the monster-side battle lane: "
                f"victory_finish_gold_pixels={victory_finish_gold_pixels}, min={min_victory_finish_gold_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

    defeat_finish_scene_path = os.environ.get("TBH_DEFEAT_FINISH_SCENE_SCREENSHOT_PATH", "")
    if defeat_finish_scene_path:
        defeat_finish_red_pixels = count_finish_cue_pixels(
            defeat_finish_scene_path,
            "defeat-finish-scene",
            is_utility_blood_red,
            0.18,
            0.42,
            0.32,
            0.54,
        )
        min_defeat_finish_red_pixels = max(120, int(scene_width * 0.28))
        if defeat_finish_red_pixels < min_defeat_finish_red_pixels:
            print(
                "defeat finish cue is missing from the player-side battle lane: "
                f"defeat_finish_red_pixels={defeat_finish_red_pixels}, min={min_defeat_finish_red_pixels}",
                file=sys.stderr,
            )
            sys.exit(1)

print(f"screenshot={path}")
print(f"image_size={width}x{height}")
print(f"mean_luma={mean_luma:.2f}")
print(f"non_black_pixels={non_black_ratio:.2%}")
print(
    "battle_ground_bbox="
    f"x:{min_x},y:{min_y},w:{band_width},h:{band_height},warm_pixels:{total_hits}"
)
print(f"estimated_scene_ratio_from_ground={estimated_scene_ratio:.2f}")
print(f"ground_height_to_width={ground_width_ratio:.3f}")
print(f"ground_width_to_image={ground_width_to_image_ratio:.3f}")
print(f"official_battlescene_ratio={official_ratio:.2f}")
if motion_path:
    print(f"local_motion_sample_time_seconds={os.environ.get('TBH_MOTION_SAMPLE_TIME_SECONDS', '')}")
    print(f"local_motion_pixels={local_motion_pixels}")
    print(f"local_motion_percent={local_motion_percent:.4f}")
    print(f"flame_motion_pixels={flame_motion_pixels}")
    print(f"flame_motion_percent={flame_motion_percent:.4f}")
if check_party_layout:
    print(f"primary_hero_pixels={primary_metrics[0]}")
    print(f"support_hero_pixels={support_metrics[0]}")
    print(f"primary_hero_steel_pixels={primary_steel_pixels}")
    print(f"party_centroid_gap={party_centroid_gap:.1f}")
    print(f"stage_pill_text_pixels={stage_pill_text_pixels}")
    print(f"stage_pill_dark_pixels={stage_pill_dark_pixels}")
    print(f"main_hp_pixels={main_hp_pixels}")
    print(f"support_hp_pixels={support_hp_pixels}")
    print(f"enemy_hp_frame_span={enemy_hp_frame_span:.1f}")
    print(f"deployable_teal_pixels={deployable_teal_pixels}")
    print(f"impact_cold_pixels={impact_cold_pixels}")
    print(f"trajectory_cold_pixels={trajectory_cold_pixels}")
    if motion_path:
        print(f"combatant_motion_pixels={combatant_motion_pixels}")
        print(f"combatant_motion_scene_percent={combatant_motion_scene_percent:.4f}")
        print(f"player_combatant_motion_pixels={player_combatant_motion_pixels}")
        print(f"player_combatant_motion_scene_percent={player_combatant_motion_scene_percent:.4f}")
        print(f"enemy_combatant_motion_pixels={enemy_combatant_motion_pixels}")
        print(f"enemy_combatant_motion_scene_percent={enemy_combatant_motion_scene_percent:.4f}")
    if os.environ.get("TBH_MELEE_ARC_SCREENSHOT_PATH", ""):
        print(f"melee_arc_pixels={melee_arc_pixels}")
    if os.environ.get("TBH_HERO_CONTACT_PULSE_SCREENSHOT_PATH", ""):
        print(f"hero_contact_pulse_pixels={hero_contact_pulse_pixels}")
    if os.environ.get("TBH_MONSTER_CONTACT_PULSE_SCREENSHOT_PATH", ""):
        print(f"monster_contact_pulse_pixels={monster_contact_pulse_pixels}")
    if os.environ.get("TBH_RAPID_VOLLEY_SCREENSHOT_PATH", ""):
        print(f"rapid_volley_pixels={rapid_volley_pixels}")
    if os.environ.get("TBH_SCATTER_SHOT_SCREENSHOT_PATH", ""):
        print(f"scatter_shot_pixels={scatter_shot_pixels}")
    if os.environ.get("TBH_ARROW_RAIN_SCREENSHOT_PATH", ""):
        print(f"arrow_rain_pixels={arrow_rain_pixels}")
    if os.environ.get("TBH_PIERCING_ARROW_SCREENSHOT_PATH", ""):
        print(f"piercing_arrow_pixels={piercing_arrow_pixels}")
    if os.environ.get("TBH_SKEWER_SHOT_SCREENSHOT_PATH", ""):
        print(f"skewer_shot_pixels={skewer_shot_pixels}")
    if os.environ.get("TBH_EXPLOSIVE_BOLT_SCREENSHOT_PATH", ""):
        print(f"damage_explosive_fire_pixels={damage_explosive_fire_pixels}")
    if os.environ.get("TBH_METEOR_STRIKE_SCREENSHOT_PATH", ""):
        print(f"damage_meteor_fire_pixels={damage_meteor_fire_pixels}")
        print(f"damage_meteor_vertical_span={damage_meteor_vertical_span}")
    if os.environ.get("TBH_LIGHTNING_STRIKE_SCREENSHOT_PATH", ""):
        print(f"damage_lightning_pixels={damage_lightning_pixels}")
    if os.environ.get("TBH_SHOCK_BOLT_SCREENSHOT_PATH", ""):
        print(f"damage_shock_bolt_pixels={damage_shock_bolt_pixels}")
    if os.environ.get("TBH_TRAP_BURST_SCREENSHOT_PATH", ""):
        print(f"damage_trap_teal_pixels={damage_trap_teal_pixels}")
    if os.environ.get("TBH_SUMMON_PROJECTILE_SCREENSHOT_PATH", ""):
        print(f"damage_summon_fire_pixels={damage_summon_fire_pixels}")
    if os.environ.get("TBH_SHOCK_CURRENT_SCREENSHOT_PATH", ""):
        print(f"damage_shock_current_pixels={damage_shock_current_pixels}")
    if os.environ.get("TBH_SHIELD_CHARGE_SCREENSHOT_PATH", ""):
        print(f"damage_shield_charge_pixels={damage_shield_charge_pixels}")
    if os.environ.get("TBH_SLAM_JUMP_SCREENSHOT_PATH", ""):
        print(f"damage_slam_jump_pixels={damage_slam_jump_pixels}")
    if os.environ.get("TBH_EARTHQUAKE_IMPACT_SCREENSHOT_PATH", ""):
        print(f"damage_earthquake_pixels={damage_earthquake_pixels}")
    if os.environ.get("TBH_ROCK_EXPLOSION_SCREENSHOT_PATH", ""):
        print(f"damage_rock_explosion_pixels={damage_rock_explosion_pixels}")
    if os.environ.get("TBH_AXE_SPIN_SCREENSHOT_PATH", ""):
        print(f"damage_axe_spin_pixels={damage_axe_spin_pixels}")
    if os.environ.get("TBH_AXE_SPIN_BLEED_SCREENSHOT_PATH", ""):
        print(f"damage_axe_spin_bleed_pixels={damage_axe_spin_bleed_pixels}")
    if os.environ.get("TBH_SHOCKWAVE_IMPACT_SCREENSHOT_PATH", ""):
        print(f"damage_shockwave_pixels={damage_shockwave_pixels}")
    if os.environ.get("TBH_CHAOS_BURST_SCREENSHOT_PATH", ""):
        print(f"damage_chaos_pixels={damage_chaos_pixels}")
    if os.environ.get("TBH_MONSTER_FIRE_INCOMING_SCREENSHOT_PATH", ""):
        print(f"monster_fire_incoming_pixels={monster_fire_incoming_pixels}")
    if os.environ.get("TBH_MONSTER_COLD_INCOMING_SCREENSHOT_PATH", ""):
        print(f"monster_cold_incoming_pixels={monster_cold_incoming_pixels}")
    if os.environ.get("TBH_MONSTER_LIGHTNING_INCOMING_SCREENSHOT_PATH", ""):
        print(f"monster_lightning_incoming_pixels={monster_lightning_incoming_pixels}")
    if os.environ.get("TBH_MONSTER_CHAOS_INCOMING_SCREENSHOT_PATH", ""):
        print(f"monster_chaos_incoming_pixels={monster_chaos_incoming_pixels}")
    if os.environ.get("TBH_ENEMY_STATUS_EFFECTS_SCREENSHOT_PATH", ""):
        print(f"enemy_status_chilled_pixels={enemy_status_chilled_pixels}")
        print(f"enemy_status_frozen_pixels={enemy_status_frozen_pixels}")
        print(f"enemy_status_stunned_pixels={enemy_status_stunned_pixels}")
        print(f"enemy_status_bleeding_pixels={enemy_status_bleeding_pixels}")
    if os.environ.get("TBH_HEAL_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_heal_pixels={utility_heal_pixels}")
    if os.environ.get("TBH_SANCTUARY_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_sanctuary_pixels={utility_sanctuary_pixels}")
    if os.environ.get("TBH_RESURRECTION_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_resurrection_pixels={utility_resurrection_pixels}")
    if os.environ.get("TBH_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_shield_pixels={utility_shield_pixels}")
    if os.environ.get("TBH_WRATH_OF_HEAVEN_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_wrath_of_heaven_pixels={utility_wrath_of_heaven_pixels}")
    if os.environ.get("TBH_SACRED_BLADE_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_sacred_blade_pixels={utility_sacred_blade_pixels}")
        print(f"utility_sacred_blade_white_pixels={utility_sacred_blade_white_pixels}")
    if os.environ.get("TBH_SWIFT_SURGE_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_swift_surge_pixels={utility_swift_surge_pixels}")
    if os.environ.get("TBH_QUICK_LOADER_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_quick_loader_pixels={utility_quick_loader_pixels}")
    if os.environ.get("TBH_GENERALS_CRY_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_generals_cry_pixels={utility_generals_cry_pixels}")
    if os.environ.get("TBH_BLOODLUST_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_bloodlust_pixels={utility_bloodlust_pixels}")
    if os.environ.get("TBH_CRITICAL_FLOATING_SCREENSHOT_PATH", ""):
        print(f"critical_floating_pixels={critical_floating_pixels}")
    if os.environ.get("TBH_DODGE_FLOATING_SCREENSHOT_PATH", ""):
        print(f"dodge_floating_pixels={dodge_floating_pixels}")
    if os.environ.get("TBH_BLOCK_FLOATING_SCREENSHOT_PATH", ""):
        print(f"block_floating_pixels={block_floating_pixels}")
    if os.environ.get("TBH_VICTORY_FINISH_SCENE_SCREENSHOT_PATH", ""):
        print(f"victory_finish_gold_pixels={victory_finish_gold_pixels}")
    if os.environ.get("TBH_DEFEAT_FINISH_SCENE_SCREENSHOT_PATH", ""):
        print(f"defeat_finish_red_pixels={defeat_finish_red_pixels}")
if status_row_path:
    print(f"status_row_non_dark_pixels={status_row_non_dark_pixels}")
    print(f"status_row_gold_pixels={status_row_gold_pixels}")
    print(f"status_row_teal_pixels={status_row_teal_pixels}")
    print(f"status_row_green_pixels={status_row_green_pixels}")
    print(f"status_row_light_pixels={status_row_light_pixels}")
if crowded_status_row_path:
    print(f"crowded_status_row_non_dark_pixels={crowded_status_row_non_dark_pixels}")
    print(f"crowded_status_row_light_pixels={crowded_status_row_light_pixels}")
    print(f"crowded_status_row_overflow_light_pixels={crowded_status_row_overflow_light_pixels}")
if battle_log_panel_path:
    print(f"battle_log_panel_non_dark_pixels={battle_log_panel_non_dark_pixels}")
    print(f"battle_log_panel_light_pixels={battle_log_panel_light_pixels}")
    print(f"battle_log_panel_title_light_pixels={battle_log_panel_title_light_pixels}")
    print(f"battle_log_panel_hero_blue_pixels={battle_log_panel_hero_blue_pixels}")
    print(f"battle_log_panel_support_purple_pixels={battle_log_panel_support_purple_pixels}")
    print(f"battle_log_panel_monster_red_pixels={battle_log_panel_monster_red_pixels}")
    print(f"battle_log_panel_critical_orange_pixels={battle_log_panel_critical_orange_pixels}")
if victory_reward_banner_path:
    print(f"victory_reward_banner_non_dark_pixels={victory_reward_banner_non_dark_pixels}")
    print(f"victory_reward_banner_light_pixels={victory_reward_banner_light_pixels}")
    print(f"victory_reward_banner_green_pixels={victory_reward_banner_green_pixels}")
    print(f"victory_reward_banner_gold_pixels={victory_reward_banner_gold_pixels}")
    print(f"victory_reward_banner_rarity_pixels={victory_reward_banner_rarity_pixels}")
    print(f"victory_reward_banner_icon_pixels={victory_reward_banner_icon_pixels}")
if victory_level_cap_banner_path:
    print(f"victory_level_cap_banner_non_dark_pixels={victory_level_cap_banner_non_dark_pixels}")
    print(f"victory_level_cap_banner_light_pixels={victory_level_cap_banner_light_pixels}")
    print(f"victory_level_cap_banner_green_pixels={victory_level_cap_banner_green_pixels}")
    print(f"victory_level_cap_banner_orange_pixels={victory_level_cap_banner_orange_pixels}")
if completion_settlement_path:
    print(f"completion_settlement_non_dark_pixels={completion_settlement_non_dark_pixels}")
    print(f"completion_settlement_light_pixels={completion_settlement_light_pixels}")
    print(f"completion_settlement_gold_pixels={completion_settlement_gold_pixels}")
    print(f"completion_settlement_accent_pixels={completion_settlement_accent_pixels}")
    print(f"completion_settlement_panel_pixels={completion_settlement_panel_pixels}")
if battle_tab_layout_path:
    print(f"battle_tab_layout_non_dark_pixels={battle_tab_layout_non_dark_pixels}")
    print(f"battle_tab_layout_content_non_dark_pixels={battle_tab_layout_content_non_dark_pixels}")
    print(f"battle_tab_layout_scene_warm_pixels={battle_tab_layout_scene_warm_pixels}")
    print(f"battle_tab_layout_bottom_non_dark_pixels={battle_tab_layout_bottom_non_dark_pixels}")
    print(f"battle_tab_layout_bottom_light_pixels={battle_tab_layout_bottom_light_pixels}")
    print(f"battle_tab_layout_bottom_accent_pixels={battle_tab_layout_bottom_accent_pixels}")
if inventory_panel_path:
    print(f"inventory_panel_non_dark_pixels={inventory_panel_non_dark_pixels}")
    print(f"inventory_panel_control_light_pixels={inventory_panel_control_light_pixels}")
    print(f"inventory_panel_grid_colored_pixels={inventory_panel_grid_colored_pixels}")
    print(f"inventory_panel_detail_non_dark_pixels={inventory_panel_detail_non_dark_pixels}")
    print(f"inventory_panel_delta_green_pixels={inventory_panel_delta_green_pixels}")
    print(f"inventory_panel_rarity_pixels={inventory_panel_rarity_pixels}")
if character_panel_path:
    print(f"character_panel_non_dark_pixels={character_panel_non_dark_pixels}")
    print(f"character_panel_hero_colored_pixels={character_panel_hero_colored_pixels}")
    print(f"character_panel_party_orange_pixels={character_panel_party_orange_pixels}")
    print(f"character_panel_skill_colored_pixels={character_panel_skill_colored_pixels}")
    print(f"character_panel_passive_icon_pixels={character_panel_passive_icon_pixels}")
    print(f"character_panel_equipment_rarity_pixels={character_panel_equipment_rarity_pixels}")
if chest_panel_path:
    print(f"chest_panel_non_dark_pixels={chest_panel_non_dark_pixels}")
    print(f"chest_panel_button_blue_pixels={chest_panel_button_blue_pixels}")
    print(f"chest_panel_auto_green_pixels={chest_panel_auto_green_pixels}")
    print(f"chest_panel_icon_colored_pixels={chest_panel_icon_colored_pixels}")
    print(f"chest_panel_rarity_pixels={chest_panel_rarity_pixels}")
if original_fidelity_panel_path:
    print(f"original_fidelity_panel_non_dark_pixels={original_fidelity_panel_non_dark_pixels}")
    print(f"original_fidelity_panel_pill_pixels={original_fidelity_panel_pill_pixels}")
    print(f"original_fidelity_panel_text_light_pixels={original_fidelity_panel_text_light_pixels}")
    print(f"original_fidelity_panel_status_green_pixels={original_fidelity_panel_status_green_pixels}")
    print(f"original_fidelity_panel_status_orange_pixels={original_fidelity_panel_status_orange_pixels}")
    print(f"original_fidelity_panel_status_gap_pixels={original_fidelity_panel_status_gap_pixels}")
if rune_evidence_panel_path:
    print(f"rune_evidence_panel_non_dark_pixels={rune_evidence_panel_non_dark_pixels}")
    print(f"rune_evidence_panel_pill_pixels={rune_evidence_panel_pill_pixels}")
    print(f"rune_evidence_panel_text_light_pixels={rune_evidence_panel_text_light_pixels}")
    print(f"rune_evidence_panel_orange_pixels={rune_evidence_panel_orange_pixels}")
    print(f"rune_evidence_panel_green_pixels={rune_evidence_panel_green_pixels}")
    print(f"rune_evidence_panel_blue_pixels={rune_evidence_panel_blue_pixels}")
if skill_evidence_panel_path:
    print(f"skill_evidence_panel_non_dark_pixels={skill_evidence_panel_non_dark_pixels}")
    print(f"skill_evidence_panel_pill_pixels={skill_evidence_panel_pill_pixels}")
    print(f"skill_evidence_panel_text_light_pixels={skill_evidence_panel_text_light_pixels}")
    print(f"skill_evidence_panel_orange_pixels={skill_evidence_panel_orange_pixels}")
    print(f"skill_evidence_panel_green_pixels={skill_evidence_panel_green_pixels}")
    print(f"skill_evidence_panel_blue_pixels={skill_evidence_panel_blue_pixels}")
    print(f"skill_evidence_panel_purple_pixels={skill_evidence_panel_purple_pixels}")
if passive_evidence_panel_path:
    print(f"passive_evidence_panel_non_dark_pixels={passive_evidence_panel_non_dark_pixels}")
    print(f"passive_evidence_panel_pill_pixels={passive_evidence_panel_pill_pixels}")
    print(f"passive_evidence_panel_text_light_pixels={passive_evidence_panel_text_light_pixels}")
    print(f"passive_evidence_panel_source_icon_pixels={passive_evidence_panel_source_icon_pixels}")
    print(f"passive_evidence_panel_missing_icon_pixels={passive_evidence_panel_missing_icon_pixels}")
    print(f"passive_evidence_panel_green_pixels={passive_evidence_panel_green_pixels}")
print("local battle scene screenshot audit passed")
PY
}

if [[ -n "$input_screenshot" || "$rendered_snapshot" == "1" ]]; then
  analyze_screenshot
  exit 0
fi

if ! pgrep -x "$app_name" >/dev/null 2>&1; then
  analyze_screenshot
  exit 0
fi

echo "Opening $app_name menu bar popover..."
click_status_item >/dev/null
sleep 0.4
screencapture -x "$screenshot_path"

if analyze_screenshot; then
  exit 0
fi

echo "First capture did not expose the battle strip; retrying once..." >&2
click_status_item >/dev/null
sleep 0.4
screencapture -x "$screenshot_path"
analyze_screenshot
