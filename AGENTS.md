# Repository Guidelines

## Project Structure & Module Organization

TBH is a Swift Package Manager macOS menu-bar game. `Package.swift` defines executable `TBH` and test target `TBHTests`. App entry points and runtime checks live in `Sources/App`, game logic in `Sources/Game`, persistence in `Sources/Persistence`, and SwiftUI panels/components in `Sources/UI`. Extracted art/audio resources live under `Sources/Resources/Extracted`; broader reference assets are under `Resources/Assets.xcassets`. Tests are in `Tests/GameTests`; audits and packaging scripts are in `scripts`.

## Build, Test, and Development Commands

Use SwiftPM from the repository root:

```bash
swift build --disable-sandbox --disable-index-store
swift run --disable-sandbox --disable-index-store TBH
swift run --disable-sandbox --disable-index-store TBH --self-test
scripts/audit-local-gameplay-fidelity.sh
RENDER_BATTLE_SCENE=1 scripts/audit-local-battle-scene.sh
scripts/package-app.sh
```

`swift build` compiles the app. `swift run TBH` launches it. `--self-test` runs the built-in debug suite. Audit scripts verify gameplay fidelity, rendered battle scenes, and packaged resources. `scripts/package-app.sh` stages `dist/TBH.app`.

## Coding Style & Naming Conventions

Use four-space indentation and Swift API naming: types in `UpperCamelCase`, functions/properties and enum cases in `lowerCamelCase`. Keep SwiftUI views small and grouped by feature panel. Prefer existing helpers such as `GamePacing`, `GameArt`, `SourceItemCatalog`, and `BattleSceneMetrics` over parallel constants. Keep comments brief and only for non-obvious mechanics or audit boundaries.

## Testing Guidelines

Add focused tests under `Tests/GameTests` for shared game logic. This target uses Swift Testing (`import Testing`), so it requires a compatible toolchain. Without Swift Testing, run `swift run ... TBH --self-test` and the relevant audit script. Update audit baselines only when the intended UI, asset, or gameplay contract changes.

## Reference Sources

Use these fidelity references when changing gameplay, art, UI, pacing, or item data:

- Steam: `https://store.steampowered.com/app/3678970/TBH_Task_Bar_Hero/`
- Wiki: `https://taskbarhero.wiki/`
- Wiki/data mirror: `https://tbh.city/`

Steam is primary for official positioning and media. Wiki sources help with mechanics, database rows, Rune costs, item tables, stages, monsters, and skills, but single-source facts stay unverified until cross-checked. Do not infer original-only behavior from placeholder art, generated SFX, or one promotional clip.

## Commit & Pull Request Guidelines

Recent history uses concise prefixes such as `fix(battle): ...`, `fix(tests): ...`, and plain imperative summaries. Keep commits scoped to one behavior change. PRs should describe the player-facing change, list commands run, note skipped tests or toolchain limits, and include screenshots for UI, icon, animation, or battle presentation changes.

## Agent-Specific Instructions

Do not reset or clean the worktree without explicit approval. Many generated and extracted assets are intentional; inspect before deleting. When editing UI dimensions, update `SelfTest`, `Tests/GameTests`, and the relevant `scripts/audit-local-*.sh` guards together.
