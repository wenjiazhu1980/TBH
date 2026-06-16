#!/usr/bin/env bash
set -euo pipefail

app_name="${APP_NAME:-TBH}"
keep_screenshot="${KEEP_SCREENSHOT:-0}"
input_screenshot="${SCREENSHOT_PATH:-}"
render_snapshot="${RENDER_BATTLE_SCENE:-0}"
packaged_render="${PACKAGED_BATTLE_SCENE_RENDER:-0}"
packaged_tbh_binary="${PACKAGED_TBH_BINARY:-dist/TBH.app/Contents/MacOS/TBH}"
packaged_tbh_resource_bundle="${PACKAGED_TBH_RESOURCE_BUNDLE:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle}"
packaged_cli_binary=""
rendered_snapshot=0
tmpdir="$(mktemp -d)"
screenshot_path="$tmpdir/tbh-local-battle-scene.png"
motion_screenshot_path="$tmpdir/tbh-local-battle-scene-motion.png"
explosive_bolt_screenshot_path="$tmpdir/tbh-local-battle-scene-explosive-bolt.png"
meteor_strike_screenshot_path="$tmpdir/tbh-local-battle-scene-meteor-strike.png"
lightning_strike_screenshot_path="$tmpdir/tbh-local-battle-scene-lightning-strike.png"
trap_burst_screenshot_path="$tmpdir/tbh-local-battle-scene-trap-burst.png"
summon_projectile_screenshot_path="$tmpdir/tbh-local-battle-scene-summon-projectile.png"
shock_current_screenshot_path="$tmpdir/tbh-local-battle-scene-shock-current.png"
shield_charge_screenshot_path="$tmpdir/tbh-local-battle-scene-shield-charge.png"
slam_jump_screenshot_path="$tmpdir/tbh-local-battle-scene-slam-jump.png"
earthquake_impact_screenshot_path="$tmpdir/tbh-local-battle-scene-earthquake-impact.png"
rock_explosion_screenshot_path="$tmpdir/tbh-local-battle-scene-rock-explosion.png"
shockwave_impact_screenshot_path="$tmpdir/tbh-local-battle-scene-shockwave-impact.png"
chaos_burst_screenshot_path="$tmpdir/tbh-local-battle-scene-chaos-burst.png"
monster_fire_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-fire-incoming.png"
monster_cold_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-cold-incoming.png"
monster_lightning_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-lightning-incoming.png"
monster_chaos_incoming_screenshot_path="$tmpdir/tbh-local-battle-scene-monster-chaos-incoming.png"
heal_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-heal-utility.png"
resurrection_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-resurrection-utility.png"
shield_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-shield-utility.png"
sacred_blade_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-sacred-blade-utility.png"
swift_surge_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-swift-surge-utility.png"
quick_loader_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-quick-loader-utility.png"
generals_cry_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-generals-cry-utility.png"
bloodlust_utility_screenshot_path="$tmpdir/tbh-local-battle-scene-bloodlust-utility.png"
status_row_screenshot_path="$tmpdir/tbh-local-battle-status-row.png"
crowded_status_row_screenshot_path="$tmpdir/tbh-local-battle-status-row-crowded.png"

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
  render_battle_scene_snapshot_one "$screenshot_path" --render-battle-scene-time 0
  render_battle_scene_snapshot_one "$motion_screenshot_path" --render-battle-scene-time 0.25
  render_battle_scene_snapshot_one "$explosive_bolt_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture explosiveBolt
  render_battle_scene_snapshot_one "$meteor_strike_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture meteorStrike
  render_battle_scene_snapshot_one "$lightning_strike_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture lightningStrike
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
  render_battle_scene_snapshot_one "$heal_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture healUtility
  render_battle_scene_snapshot_one "$resurrection_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture resurrectionUtility
  render_battle_scene_snapshot_one "$shield_utility_screenshot_path" --render-battle-scene-time 0 \
    --render-battle-scene-fixture shieldUtility
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
  render_battle_scene_snapshot_one "$status_row_screenshot_path" \
    --render-battle-scene-fixture playerStatusRow
  render_battle_scene_snapshot_one "$crowded_status_row_screenshot_path" \
    --render-battle-scene-fixture playerStatusRowCrowded
  rendered_snapshot=1
}

render_battle_scene_snapshot_one() {
  local output_path="$1"
  shift

  if [[ "$packaged_render" == "1" ]]; then
    "$packaged_cli_binary" --render-battle-scene "$output_path" "$@" >/dev/null
  else
    env CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/clang-module-cache}" \
      swift run --disable-sandbox TBH --render-battle-scene "$output_path" "$@" >/dev/null
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
  if ! pgrep -x "$app_name" >/dev/null 2>&1; then
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
  local heal_utility_path="${HEAL_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    heal_utility_path="$heal_utility_screenshot_path"
  fi
  local resurrection_utility_path="${RESURRECTION_UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    resurrection_utility_path="$resurrection_utility_screenshot_path"
  fi
  local utility_path="${UTILITY_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    utility_path="$shield_utility_screenshot_path"
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
  local status_row_path="${STATUS_ROW_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    status_row_path="$status_row_screenshot_path"
  fi
  local crowded_status_row_path="${CROWDED_STATUS_ROW_SCREENSHOT_PATH:-}"
  if [[ "$rendered_snapshot" == "1" ]]; then
    crowded_status_row_path="$crowded_status_row_screenshot_path"
  fi
  TBH_CHECK_PARTY_LAYOUT="$check_party_layout" \
    TBH_MOTION_SCREENSHOT_PATH="$motion_path" \
    TBH_EXPLOSIVE_BOLT_SCREENSHOT_PATH="$explosive_bolt_path" \
    TBH_METEOR_STRIKE_SCREENSHOT_PATH="$meteor_strike_path" \
    TBH_LIGHTNING_STRIKE_SCREENSHOT_PATH="$lightning_strike_path" \
    TBH_TRAP_BURST_SCREENSHOT_PATH="$trap_burst_path" \
    TBH_SUMMON_PROJECTILE_SCREENSHOT_PATH="$summon_projectile_path" \
    TBH_SHOCK_CURRENT_SCREENSHOT_PATH="$shock_current_path" \
    TBH_SHIELD_CHARGE_SCREENSHOT_PATH="$shield_charge_path" \
    TBH_SLAM_JUMP_SCREENSHOT_PATH="$slam_jump_path" \
    TBH_EARTHQUAKE_IMPACT_SCREENSHOT_PATH="$earthquake_impact_path" \
    TBH_ROCK_EXPLOSION_SCREENSHOT_PATH="$rock_explosion_path" \
    TBH_SHOCKWAVE_IMPACT_SCREENSHOT_PATH="$shockwave_impact_path" \
    TBH_CHAOS_BURST_SCREENSHOT_PATH="$chaos_burst_path" \
    TBH_MONSTER_FIRE_INCOMING_SCREENSHOT_PATH="$monster_fire_incoming_path" \
    TBH_MONSTER_COLD_INCOMING_SCREENSHOT_PATH="$monster_cold_incoming_path" \
    TBH_MONSTER_LIGHTNING_INCOMING_SCREENSHOT_PATH="$monster_lightning_incoming_path" \
    TBH_MONSTER_CHAOS_INCOMING_SCREENSHOT_PATH="$monster_chaos_incoming_path" \
    TBH_HEAL_UTILITY_SCREENSHOT_PATH="$heal_utility_path" \
    TBH_RESURRECTION_UTILITY_SCREENSHOT_PATH="$resurrection_utility_path" \
    TBH_UTILITY_SCREENSHOT_PATH="$utility_path" \
    TBH_SACRED_BLADE_UTILITY_SCREENSHOT_PATH="$sacred_blade_utility_path" \
    TBH_SWIFT_SURGE_UTILITY_SCREENSHOT_PATH="$swift_surge_utility_path" \
    TBH_QUICK_LOADER_UTILITY_SCREENSHOT_PATH="$quick_loader_utility_path" \
    TBH_GENERALS_CRY_UTILITY_SCREENSHOT_PATH="$generals_cry_utility_path" \
    TBH_BLOODLUST_UTILITY_SCREENSHOT_PATH="$bloodlust_utility_path" \
    TBH_STATUS_ROW_SCREENSHOT_PATH="$status_row_path" \
    TBH_CROWDED_STATUS_ROW_SCREENSHOT_PATH="$crowded_status_row_path" \
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
    if band_width >= minimum_band_width and band_height >= 8 and min_y < height * 0.8:
        candidates.append((band_width * band_height, total_hits, min_x, min_y, max_x, max_y))

if not candidates:
    print("could not locate the warm battle ground strip in the screenshot", file=sys.stderr)
    sys.exit(1)

_, total_hits, min_x, min_y, max_x, max_y = max(candidates)
band_width = max_x - min_x + 1
band_height = max_y - min_y + 1

official_ratio = 776 / 180
ground_ratio = 0.263
ground_platform_width_ratio = 0.90
ground_platform_side_inset_ratio = (1 - ground_platform_width_ratio) / 2
estimated_scene_width = band_width / ground_platform_width_ratio
estimated_scene_ratio = estimated_scene_width / (band_height / ground_ratio)
ground_width_ratio = band_height / band_width
ground_width_to_image_ratio = band_width / width

min_local_ratio = 3.75
max_local_ratio = 4.65
max_ground_width_ratio = 0.12

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
damage_explosive_fire_pixels = 0
damage_meteor_fire_pixels = 0
damage_meteor_vertical_span = 0
damage_lightning_pixels = 0
damage_trap_teal_pixels = 0
damage_summon_fire_pixels = 0
damage_shock_current_pixels = 0
damage_shield_charge_pixels = 0
damage_slam_jump_pixels = 0
damage_earthquake_pixels = 0
damage_rock_explosion_pixels = 0
damage_shockwave_pixels = 0
damage_chaos_pixels = 0
monster_fire_incoming_pixels = 0
monster_cold_incoming_pixels = 0
monster_lightning_incoming_pixels = 0
monster_chaos_incoming_pixels = 0
utility_heal_pixels = 0
utility_resurrection_pixels = 0
utility_shield_pixels = 0
utility_sacred_blade_pixels = 0
utility_sacred_blade_white_pixels = 0
utility_swift_surge_pixels = 0
utility_quick_loader_pixels = 0
utility_generals_cry_pixels = 0
utility_bloodlust_pixels = 0
status_row_non_dark_pixels = 0
status_row_gold_pixels = 0
status_row_teal_pixels = 0
status_row_green_pixels = 0
status_row_light_pixels = 0
crowded_status_row_non_dark_pixels = 0
crowded_status_row_light_pixels = 0
crowded_status_row_overflow_light_pixels = 0

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

    min_status_non_dark_pixels = max(800, int(status_width * status_height * 0.12))
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
        int(crowded_status_width * crowded_status_height * 0.18),
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

if check_party_layout:
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

    primary_pixels, primary_centroid = collect_region(0.13, 0.43, 0.20, 0.96, is_foreground_pixel)
    support_pixels, support_centroid = collect_region(0.30, 0.63, 0.25, 0.96, is_foreground_pixel)
    primary_steel_pixels, _ = collect_region(0.16, 0.36, 0.20, 0.95, is_steel_knight_pixel)
    stage_pill_text_pixels, stage_pill_text_centroid, _ = collect_region_bbox(
        0.06, 0.15, 0.30, 0.52, is_stage_text_pixel
    )
    stage_pill_dark_pixels, _, _ = collect_region_bbox(
        0.06, 0.15, 0.30, 0.52, is_stage_pill_dark_pixel
    )
    main_hp_pixels, _, main_hp_bbox = collect_region_bbox(0.18, 0.40, 0.22, 0.36, is_hp_green)
    support_hp_pixels, _, _ = collect_region_bbox(0.32, 0.55, 0.10, 0.40, is_hp_green)
    enemy_hp_frame_pixels, _, enemy_hp_frame_bbox = collect_region_bbox(
        0.72, 0.98, 0.22, 0.36, is_hp_frame_gray
    )
    deployable_teal_pixels, _, deployable_teal_bbox = collect_region_bbox(
        0.37, 0.58, 0.64, 0.98, is_deployable_teal
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
    min_primary_steel_pixels = max(120, int(scene_width * scene_height * 0.012))
    min_party_centroid_gap = scene_width * 0.12
    min_stage_pill_text_pixels = 24
    min_stage_pill_dark_pixels = max(180, int(scene_width * scene_height * 0.0065))
    min_main_hp_pixels = max(80, int(scene_width * scene_height * 0.0045))
    min_support_hp_pixels = max(60, int(scene_width * scene_height * 0.0015))
    min_enemy_hp_frame_span = scene_width * 0.09
    min_deployable_teal_pixels = max(10, int(scene_width * scene_height * 0.0004))
    min_impact_cold_pixels = max(24, int(scene_width * scene_height * 0.001))
    min_trajectory_cold_pixels = max(18, int(scene_width * scene_height * 0.0008))

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
        and scene_top + scene_height * 0.38 <= stage_text_y <= scene_top + scene_height * 0.50
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
        print("could not locate enemy HP frame bounds", file=sys.stderr)
        sys.exit(1)

    enemy_hp_frame_span = enemy_hp_frame_bbox[2] - enemy_hp_frame_bbox[0] + 1
    if enemy_hp_frame_pixels < 6 or enemy_hp_frame_span < min_enemy_hp_frame_span:
        print(
            "enemy top HP frame is missing or too narrow: "
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

    if primary_centroid is None or support_centroid is None:
        print("could not measure primary/support hero centroids", file=sys.stderr)
        sys.exit(1)

    party_centroid_gap = support_centroid - primary_centroid
    if party_centroid_gap < min_party_centroid_gap:
        print(
            "party layout regressed: support heroes are not clearly to the right of the primary hero: "
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
        min_damage_explosive_fire_pixels = max(30, int(scene_width * scene_height * 0.0013))
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
        min_damage_meteor_fire_pixels = max(28, int(scene_width * scene_height * 0.0012))
        damage_meteor_vertical_span = 0 if meteor_bbox is None else meteor_bbox[3] - meteor_bbox[1] + 1
        min_damage_meteor_vertical_span = max(24, int(scene_height * 0.16))
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
        min_damage_lightning_pixels = max(22, int(scene_width * scene_height * 0.0009))
        if damage_lightning_pixels < min_damage_lightning_pixels:
            print(
                "lightning impact cue is missing from the enemy hit lane: "
                f"damage_lightning_pixels={damage_lightning_pixels}, min={min_damage_lightning_pixels}",
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
        min_damage_trap_teal_pixels = max(16, int(scene_width * scene_height * 0.0006))
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
        min_damage_summon_fire_pixels = max(18, int(scene_width * scene_height * 0.0007))
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
        min_damage_shock_current_pixels = max(24, int(scene_width * scene_height * 0.001))
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
        min_damage_shield_charge_pixels = max(18, int(scene_width * scene_height * 0.0007))
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
        min_damage_slam_jump_pixels = max(20, int(scene_width * scene_height * 0.0008))
        slam_jump_vertical_span = 0 if slam_jump_bbox is None else slam_jump_bbox[3] - slam_jump_bbox[1] + 1
        min_slam_jump_vertical_span = max(12, int(scene_height * 0.08))
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
        min_damage_earthquake_pixels = max(20, int(scene_width * scene_height * 0.0008))
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
        min_damage_rock_explosion_pixels = max(22, int(scene_width * scene_height * 0.0009))
        if damage_rock_explosion_pixels < min_damage_rock_explosion_pixels:
            print(
                "Ground Slam rock explosion cue is missing from the enemy hit lane: "
                f"damage_rock_explosion_pixels={damage_rock_explosion_pixels}, "
                f"min={min_damage_rock_explosion_pixels}",
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
        min_damage_shockwave_pixels = max(22, int(scene_width * scene_height * 0.0008))
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
        min_damage_chaos_pixels = max(18, int(scene_width * scene_height * 0.0007))
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

    min_monster_incoming_pixels = max(18, int(scene_width * scene_height * 0.0007))

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
        min_utility_heal_pixels = max(20, int(scene_width * scene_height * 0.0009))
        if utility_heal_pixels < min_utility_heal_pixels:
            print(
                "heal utility cue is missing from the player utility lane: "
                f"utility_heal_pixels={utility_heal_pixels}, min={min_utility_heal_pixels}",
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
        min_utility_resurrection_pixels = max(22, int(scene_width * scene_height * 0.0009))
        resurrection_vertical_span = 0 if resurrection_bbox is None else resurrection_bbox[3] - resurrection_bbox[1] + 1
        min_resurrection_vertical_span = max(20, int(scene_height * 0.14))
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
        min_utility_shield_pixels = max(18, int(scene_width * scene_height * 0.0008))
        if utility_shield_pixels < min_utility_shield_pixels:
            print(
                "shield utility cue is missing from the player utility lane: "
                f"utility_shield_pixels={utility_shield_pixels}, min={min_utility_shield_pixels}",
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
            x_start_ratio=0.39,
            x_end_ratio=0.58,
            y_start_ratio=0.18,
            y_end_ratio=0.46,
        )
        min_utility_sacred_blade_pixels = max(18, int(scene_width * scene_height * 0.00075))
        min_utility_sacred_blade_white_pixels = max(6, int(scene_width * scene_height * 0.00018))
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
        min_utility_swift_surge_pixels = max(18, int(scene_width * scene_height * 0.00075))
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
        min_utility_quick_loader_pixels = max(18, int(scene_width * scene_height * 0.00075))
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
        min_utility_generals_cry_pixels = max(18, int(scene_width * scene_height * 0.00075))
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
        min_utility_bloodlust_pixels = max(18, int(scene_width * scene_height * 0.00075))
        if utility_bloodlust_pixels < min_utility_bloodlust_pixels:
            print(
                "Bloodlust utility cue is missing from the player utility lane: "
                f"utility_bloodlust_pixels={utility_bloodlust_pixels}, min={min_utility_bloodlust_pixels}",
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
    print(f"flame_motion_pixels={flame_motion_pixels}")
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
    if os.environ.get("TBH_EXPLOSIVE_BOLT_SCREENSHOT_PATH", ""):
        print(f"damage_explosive_fire_pixels={damage_explosive_fire_pixels}")
    if os.environ.get("TBH_METEOR_STRIKE_SCREENSHOT_PATH", ""):
        print(f"damage_meteor_fire_pixels={damage_meteor_fire_pixels}")
        print(f"damage_meteor_vertical_span={damage_meteor_vertical_span}")
    if os.environ.get("TBH_LIGHTNING_STRIKE_SCREENSHOT_PATH", ""):
        print(f"damage_lightning_pixels={damage_lightning_pixels}")
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
    if os.environ.get("TBH_HEAL_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_heal_pixels={utility_heal_pixels}")
    if os.environ.get("TBH_RESURRECTION_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_resurrection_pixels={utility_resurrection_pixels}")
    if os.environ.get("TBH_UTILITY_SCREENSHOT_PATH", ""):
        print(f"utility_shield_pixels={utility_shield_pixels}")
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
print("local battle scene screenshot audit passed")
PY
}

if [[ -n "$input_screenshot" || "$render_snapshot" == "1" ]]; then
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
