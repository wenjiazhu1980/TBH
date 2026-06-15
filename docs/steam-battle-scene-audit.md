# Steam Battle Scene Audit

Last reviewed: 2026-06-15

## Scope

This note records reproducible technical checks for the official `battlescene` media currently exposed by the `TBH: Task Bar Hero` Steam store page. It does not store official video, derived clips, or extracted frames in the repository.

Primary source:

- [Valve/Steam, 2026-06-14, Store page HTML for AppID 3678970: `https://store.steampowered.com/app/3678970/TBH_Task_Bar_Hero/`]
- [Valve/Steam CDN, 2026-06-14, `extras/battlescene` MP4/WebM extracted from the Store page]

Source limitation: these are official Steam/Steam-CDN sources, but they are one source family, not independent confirmations. Confidence is High for stream metadata and visible layout observations at review time; confidence is Medium for animation semantics because the source is a short promotional loop rather than instrumented gameplay capture.

## Reproduction

Run:

```bash
scripts/audit-steam-battle-scene.sh
```

Optional sampled frames for local inspection:

```bash
KEEP_FRAMES=1 scripts/audit-steam-battle-scene.sh
```

Local app screenshot audit:

```bash
scripts/audit-local-battle-scene.sh
```

Local battle-hero sprite audit:

```bash
scripts/audit-local-hero-sprites.sh
```

Deterministic local render audit without opening the menu-bar app:

```bash
RENDER_BATTLE_SCENE=1 scripts/audit-local-battle-scene.sh
```

Render a deterministic local scene PNG directly:

```bash
swift run --disable-sandbox TBH --render-battle-scene /tmp/tbh-rendered-battle-scene.png
```

Analyze an existing local screenshot without taking a new one:

```bash
SCREENSHOT_PATH=/tmp/tbh-battle-hero-art-check.png scripts/audit-local-battle-scene.sh
```

The script:

- Fetches the official Steam page into a temporary directory.
- Extracts the current `extras/battlescene` MP4/WebM URLs.
- Uses `ffprobe` to print stream metadata and counted frames.
- Uses `ffmpeg showinfo` to sample the timeline without writing frames by default.
- Extracts temporary sample frames and reports lower-ground platform geometry, including x/y ratios and platform width ratio.
- Deletes temporary files on exit unless `KEEP_FRAMES=1` is explicitly set.

The local screenshot script:

- Opens the running TBH menu-bar popover, captures a temporary screenshot, and deletes it by default.
- If `RENDER_BATTLE_SCENE=1` is set, or if no running TBH process is found, renders deterministic SwiftUI battle scene snapshots through `TBH --render-battle-scene` and analyzes those PNGs instead of depending on desktop capture permissions.
- Retries once because clicking the status item can close an already-open popover.
- Fails explicitly if `screencapture` returns a blank/black image.
- Detects the warm battle ground strip and estimates local scene ratio from the configured `0.263` lower-ground height ratio and `0.707` central-platform width ratio.
- Fails if the estimated local battle-strip ratio falls outside `3.75-4.65` or if the warm ground band exceeds `12%` of its detected width.
- For deterministic renders, also checks the battle-lane regression guard: the primary hero lane must contain enough foreground pixels, enough steel-gray Knight silhouette pixels, and a clear left-to-right centroid gap between the primary hero and support heroes. It also checks that the upper-left stage pill has visible text and a dark backing, that the primary/support HP bars are present, that the enemy-side top HP frame spans a stable width, and that deterministic cold skill trajectory and impact cues appear in the battle lane. `CHECK_PARTY_LAYOUT=1 SCREENSHOT_PATH=...` enables the same guard for a saved screenshot.
- For deterministic renders, also renders `playerStatusRow` and `playerStatusRowCrowded` fixtures through the same app snapshot path. The normal row verifies visible non-dark pixels, light text/icon pixels, gold blessing pixels, teal warding/trap pixels and green active/shield pixels; the crowded row verifies that the shared first-five plus overflow-count presentation remains visibly rendered. The DEBUG self-test also verifies the fixture's badge count/order and the shared first-five plus overflow-count logic used by the SwiftUI row.
- Supports `SCREENSHOT_PATH=...` so the same analysis can be run against a saved local screenshot when live screen capture is unavailable.
- Uses relative warm-band thresholds so both the deterministic `620x144` rendered PNG and larger desktop screenshots are accepted when their geometry matches the expected strip.

The local hero-sprite script:

- Checks all current `battle_hero_*` sprites for compact dimensions, alpha isolation, transparent edges, visible-pixel coverage and HP-bar green runs, and now reconstructs each expected `battle_hero_*` from its corresponding `official_hero_*` sprite to verify the documented identity-safe fallback provenance.
- Prints the legacy broad `battle_*` screenshot crops separately as reference-only contamination evidence instead of treating them as runtime resources.
- Fails when current runtime battle heroes look like oversized screenshot blocks, opaque UI crops, blank/mostly transparent files, or sprites containing embedded HP-bar green runs.

## Current Media Evidence

Extracted official URLs:

```text
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3678970/extras/8d14259cbca180cea4e366f03ffbce01.mp4?t=1780512075
https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/3678970/extras/8d14259cbca180cea4e366f03ffbce01.webm?t=1780512075
```

Current stream metadata:

```text
MP4: HEVC, yuv420p, 776x180, 30/1 fps, 6.133333s, 184 frames, no audio stream
WebM: VP9, yuv420p, 776x180, 30/1 fps, 6.133000s, 184 counted frames, no audio stream
Display aspect ratio: 194:45, about 4.31:1
```

Sampled timeline frames:

```text
0.0s, 0.5s, 2.0s, 3.0s, 5.5s, 6.1s
```

Sampled lower-ground platform geometry:

```text
0.5s: lower_ground_bbox=x:106,y:132,w:543,h:39, x_ratio=0.137-0.836, width_ratio=0.700, y_ratio=0.733-0.950
3.0s: lower_ground_bbox=x:106,y:132,w:543,h:39, x_ratio=0.137-0.836, width_ratio=0.700, y_ratio=0.733-0.950
5.5s: lower_ground_bbox=x:106,y:122,w:543,h:49, x_ratio=0.137-0.836, width_ratio=0.700, y_ratio=0.678-0.950
summary: width_ratio=0.700-0.700, x_start=0.137-0.137, x_end=0.836-0.836, y_start=0.678-0.733, y_end=0.950-0.950
```

Manual visual observations from sampled frames:

- The battle scene is a very wide strip, not a square or card-like arena.
- The top area is mostly dark empty sky/background.
- The active ground is a low warm lava/fire platform along the bottom, centered with dark side margins rather than filling the full video width.
- The stage pill appears at the upper-left of the active lane and reads `1-6` in the sampled loop.
- Combatants are grounded near the bottom line, with HP bars directly above units.
- The left side shows player-side combatants and the right side shows a small enemy-side object/target cluster.
- There is no central `VS` label, no decorative card frame, and no large vertical battlefield composition in the sampled frames.
- The loop contains visible flame/background animation and combatant movement/hit poses, but it does not expose exact attack rules or event timings by itself.

## App Implications

Current macOS app state:

- `BattleSceneView` uses a single horizontal arena, upper-left pill showing only the stage code, left party cluster, right enemy cluster, overhead HP bars, floating damage, metadata-driven skill trajectory and impact cues, source-checked Ranger arrow trails for `快速射击` / `散弹射击` / `箭雨` / `穿透之箭` / `穿刺射击`, source-checked Hunter bolt trails and impacts for `爆炸弩箭` / `寒霜弩箭` / `电击弩箭` / `电击弩箭电流`, source-checked movement trails for `盾牌冲锋` and `猛击跳跃`, a source-checked falling-meteor cue for `陨石打击`, source-checked ground/shockwave cues for `大地强击` and `粉碎强击冲击波`, and hit-triggered nudge/flash effects.
- The macOS popover battle scene now uses a compact `72` pt strip inside the expected `310` pt content width, giving an about `4.31:1` local presentation ratio that matches the official strip while constraining combatants to compact battle-sprite scale so the primary hero no longer crops into an oversized portrait-like figure.
- The battle strip now keeps a square, unframed scene edge with zero border line width, matching the sampled official media's lack of a decorative card frame.
- `BattleArenaBackdrop` now animates a low-rate pixel flame band across the warm platform strip, matching the official media's confirmed fire/background movement at a broad presentation level while keeping exact timing/keyframes unclaimed.
- Deployed heroes in the battle strip now use dedicated edge-transparent compact `battle_hero_*` figures. All six current `battle_hero_*` runtime files are generated from their corresponding `official_hero_*` sprites with connected portrait-frame/background pixels removed, preserving class identity as an identity-safe fallback after earlier partial screenshot trims could make battle-tab heroes read as the wrong class. `ss_04.jpg` still provides useful reference-only broad battle crops, but those `battle_*` resources contain HP bars, background, effects or UI fragments and are not used directly for deployed hero combatants. The primary hero is anchored on the left front lane and support heroes are arranged to the right, matching the official media's left-to-right party read more closely than the previous centered primary with a support figure on the far left. Release resource self-test now also rebuilds each expected `battle_hero_*` from raw `official_hero_*` samples, ignores only hidden RGB bytes behind fully transparent pixels, and rejects visible/alpha provenance drift, embedded HP-bar green runs, missing Knight color markers and fragmented Knight subjects.
- Scene HP numbers were removed from the arena layer, leaving compact HP bars above combatants because the official sampled frames show bars rather than numeric HP labels.
- Local wave and encounter counters were removed from the in-scene pill because the sampled official pill reads as a simple stage code (`1-6`); those counters remain available in the surrounding macOS header.
- The lower ground now uses a fixed `0.263` height ratio and `0.707` centered platform width ratio, preserving dark side margins and more dark negative space above the lane.
- `scripts/audit-local-battle-scene.sh` can now analyze local rendered screenshots without storing them in the repository. It fails blank/black captures, requires a detected warm ground strip, requires the estimated local strip ratio to stay inside `3.75-4.65`, rejects over-tall warm ground bands, and rejects ground platforms that drift away from the official short central platform width. Against the current deterministic local battle screenshot, it detected a `440x38` warm ground platform inside the `620x144` render, measured `ground_width_to_image=0.710`, and estimated the local battle strip at about `4.31:1`, matching the official `4.31:1` source ratio.
- `scripts/audit-local-hero-sprites.sh` reports all current `battle_hero_*` sprites as compact transparent runtime resources with clear edges, no HP-bar green runs, and `source=True` provenance checks against rebuilt `official_hero_*` frame-removal outputs. It also quantifies why the older broad `battle_*` crops remain reference-only: `battle_priest.png` and `battle_ranger.png` include `hp_run=40` green HP-bar segments, while `battle_knight.png` and `battle_sorcerer.png` are oversized fully opaque screenshot blocks.
- `TBH --render-battle-scene <path>` now renders deterministic `620x144` PNGs from the same SwiftUI `BattleSceneView` used by the app. The default snapshot fixture uses a static opening battle state plus a fixed `寒霜弩箭` damage log so the visual audit does not fluctuate when randomized combat damage hits support members. Additional damage fixtures `explosiveBolt`, `meteorStrike`, `lightningStrike`, `shieldCharge`, and `slamJump` render representative source-category logs for `爆炸弩箭`, `陨石打击`, `闪电术`, `盾牌冲锋`, and `猛击跳跃`, while `healUtility`, `resurrectionUtility`, `shieldUtility`, and `sacredBladeUtility` render representative non-damage logs for `治愈`, `复活`, `神盾领域`, and `神圣之刃`. Against the current deterministic render, `scripts/audit-local-battle-scene.sh` detects a `440x38` warm ground platform at `x=90`, with `warm_pixels=9581` and `ground_width_to_image=0.710`, estimates the local battle strip at about `4.31:1` matching the official `4.31:1` source ratio, measures `flame_motion_pixels=1942`, `primary_hero_pixels=4044`, `support_hero_pixels=9874`, `primary_hero_steel_pixels=1470`, and a `107.5px` primary-to-support party centroid gap. It also measures `stage_pill_text_pixels=99`, `stage_pill_dark_pixels=2116`, `main_hp_pixels=732`, `support_hp_pixels=185`, `enemy_hp_frame_span=69.0`, `deployable_teal_pixels=491`, `impact_cold_pixels=1993`, `trajectory_cold_pixels=1801`, `damage_explosive_fire_pixels=2931`, `damage_meteor_fire_pixels=2875`, `damage_meteor_vertical_span=88`, `damage_lightning_pixels=1685`, `damage_shield_charge_pixels=2400`, `damage_slam_jump_pixels=1391`, `utility_heal_pixels=261`, `utility_resurrection_pixels=584`, `utility_shield_pixels=1485`, `utility_sacred_blade_pixels=443`, and `utility_sacred_blade_white_pixels=300`, so the repeatable render audit now catches missing/drifting short central platform, upper-left platform pill, overhead HP-bar, deployable marker, cold projectile-trajectory, cold skill-impact, explosive-bolt fire, falling-meteor, lightning-impact, charge-dash trail, leap-arc trail, heal-pulse, resurrection-rise, shield-field, and sacred-blade utility-cue regressions in addition to party-layout regressions. The party guard still checks that support heroes stay to the right of the primary hero, while the newer platform-width and pill-position guards cover regressions that the old full-width-ground layout could not detect. This gives CI and local shell runs a repeatable visual audit path even when macOS desktop capture is unavailable.
- The deterministic render audit now also includes source-category fixtures for `trapBurst`, `summonProjectile`, `shockCurrent`, `earthquakeImpact`, and `shockwaveImpact`, mapped to `充能陷阱爆炸`, `弩炮塔`, `电击弩箭电流`, `大地强击`, and the derived `粉碎强击冲击波` log. The latest `RENDER_BATTLE_SCENE=1 scripts/audit-local-battle-scene.sh` run measured `damage_trap_teal_pixels=845`, `damage_summon_fire_pixels=1815`, `damage_shock_current_pixels=2239`, `damage_earthquake_pixels=1320`, and `damage_shockwave_pixels=4450`, so local CI-style checks now fail if those trap, summon-projectile, current, earthquake, or shockwave cues disappear from the deterministic battle strip. These are still compact source-category visual guards, not proof of exact original sprite art, keyframe timing, trigger placement, hit-frame geometry or projectile/rock entity behavior.
- The deterministic render audit now also includes a `playerStatusRow` fixture that renders the real bottom battle status row with source-checked Priest `力量祝福` / `守护祝福` continuous badges plus live `神盾领域` and `充能陷阱` counters. The latest local run measured `status_row_non_dark_pixels=9180`, `status_row_gold_pixels=200`, `status_row_teal_pixels=741`, `status_row_green_pixels=638`, and `status_row_light_pixels=916`, so local checks now fail if the compact status row becomes blank, loses readable text/icons, or drops the blessing/shield/trap color signals. `TBH --self-test` now also guards the status row's deterministic badge order, verifies that the `playerStatusRow` fixture resolves to `力量` / `守护` / `神盾` / `陷阱`, and checks the shared crowded-row rule that shows the first five badges before folding the remainder into `+N`. The new `playerStatusRowCrowded` render fixture activates all currently modeled player-side statuses through the DEBUG battle buff path; the local audit measured `crowded_status_row_non_dark_pixels=12473`, `crowded_status_row_light_pixels=895`, and `crowded_status_row_overflow_light_pixels=84`, so the render gate now catches regressions where crowded badge folding or the visible `+N` count disappears. This verifies local visibility and ordering for modeled status feedback, not exact original buff-bar layout, icon art, duration or stacking rules.
- Dedicated `BattleTrajectoryCue` cases now distinguish source-checked movement skills from ordinary melee: `盾牌冲锋` renders a charge-dash trail and `猛击跳跃` renders a leap-arc trail, while non-movement melee damage such as `穿透突刺` still avoids a movement trajectory. `BattleSceneSnapshot` now has dedicated `shieldCharge` and `slamJump` fixtures, and the local screenshot audit measured `damage_shield_charge_pixels=2400` and `damage_slam_jump_pixels=1391` in the latest deterministic render. These are compact visual feedback cues, not a claim that exact original charge/leap keyframes or travel timing have been recovered.
- Dedicated Ranger `BattleTrajectoryCue` cases now distinguish the checked arrow-skill descriptions from a single generic projectile: `快速射击` renders a multi-arrow volley, `散弹射击` renders a tracking-volley fan-out, `箭雨` renders falling arrows, `穿透之箭` renders a piercing shot, and `穿刺射击` renders a lodged-arrow hit. Exact original arrow count, projectile spacing, retargeting, travel timing and hit-frame placement remain unverified.
- Dedicated Hunter bolt cue cases now distinguish the checked bolt descriptions from the generic projectile/element fallbacks: `爆炸弩箭` renders an explosive bolt trail plus heavier fire explosion, `寒霜弩箭` renders a frost bolt plus cold explosion, `电击弩箭` renders a shock bolt/impact, and the derived `电击弩箭电流` log renders current arcs. Exact original bolt travel timing, explosion radius/placement, freeze keyframes, current duration/arc geometry and hit-frame placement remain unverified.
- `陨石打击` now renders a dedicated falling-meteor trajectory and heavier meteor-impact cue instead of sharing the generic range-field/fire-burst pair used by ordinary fire skills such as `火球术`. This follows the checked skill text that it summons a meteor, but exact meteor sprite art, fall timing, impact delay and hit-frame placement remain unverified.
- `大地强击` now renders a ground-rupture trajectory and earthquake-impact cue, while only the derived `粉碎强击冲击波` log renders a shockwave-ring trajectory and shockwave-impact cue. The primary `粉碎强击` hit remains an ordinary physical slash, so the visual distinction matches the currently modeled combat rider. Exact original rock entities, physical-AOE rock explosion triggers, shockwave radius and keyframe timing remain unverified.
- Non-damage logs now use separate `BattleUtilityCue` visuals instead of being forced through damage trajectory or impact effects: `治愈` shows a heal pulse, `圣域` shows a sanctuary pulse, `复活` and `不屈意志` show a rising revive cue, `神盾领域` shows a shield field, `神圣之刃` shows a sacred-blade glow, and other modeled buff logs show a compact aura. These cues align the macOS battle lane with the source-checked skill categories at a feedback level, but exact original heal, sanctuary, revive, shield-field and sacred-blade keyframes remain unverified.

Remaining fidelity gaps:

- The deterministic macOS render now matches the official battle-scene aspect ratio at about `4.31:1`; the menu-bar popover is still a constrained macOS translation, so exact crop, live desktop placement and taskbar-window parity remain unclaimed.
- Local screenshot analysis is available through `SCREENSHOT_PATH=...`, and deterministic rendering is available through `RENDER_BATTLE_SCENE=1` or `TBH --render-battle-scene`. Direct live `screencapture` can still return black images in the current shell/permission state, and the audit script reports that as a failure instead of treating it as a pass.
- Exact idle, attack, hit and death keyframes remain unverified.
- Exact flame/background frame timing remains unverified; the current animated flame band is a presentation-level substitute based on sampled official movement.
- Exact sprite scale, x/y lane anchors, HP bar dimensions and stage pill offsets still need frame-level comparison against stronger original captures before claiming parity; the current deterministic audit only guards local regressions against the visible official strip composition.
- This media has no audio stream, so it cannot prove battle SFX timing or mix.
