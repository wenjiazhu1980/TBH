# TBH 构建指南

## 环境矩阵

| 环境 | swift build | swift run TBH --self-test | swift test | 打包 .app |
|------|:---:|:---:|:---:|:---:|
| 本机（仅 Command Line Tools） | ✅ | ✅ | ❌ 无测试框架 | ✅ |
| 远程 Mac（完整 Xcode） | ✅ | ✅ | ✅ | ✅ |
| GitHub Actions（macos-latest） | ✅ | ✅ | ✅ | ✅ + artifact |

本机 CLT 不含 XCTest / swift-testing，因此 `swift test` 无法运行——这正是远程构建存在的原因。

## 本地开发

```bash
swift build                  # 编译
swift run TBH                # 运行（菜单栏应用）
swift run TBH --self-test    # 零依赖自检（DEBUG 构建内置，核心逻辑断言）
swift run TBH --resource-self-test   # 打包资源 / 图标 / 音效自检
scripts/audit-local-workflow-fidelity-gates.sh
scripts/audit-local-gameplay-fidelity.sh
scripts/audit-local-app-icons.sh
scripts/audit-local-item-icons.sh
scripts/audit-local-rune-icons.sh
scripts/audit-local-passive-skill-icons.sh
scripts/audit-local-hero-sprites.sh
scripts/audit-local-sfx.sh
RENDER_BATTLE_SCENE=1 scripts/audit-local-battle-scene.sh
./scripts/package-app.sh     # 打包 dist/TBH.app（release + ad-hoc 签名）
```

## 远程构建（SSH 到另一台 Mac）

要求：远程 Mac 装有完整 Xcode，本机可免密 SSH。

```bash
export TBH_REMOTE_HOST=user@buildmac.local   # 一次性配置
./scripts/remote-build.sh build              # 远程编译
./scripts/remote-build.sh test               # 远程跑完整 swift-testing 套件 + self-test
./scripts/remote-build.sh package            # 远程打包并取回 dist/TBH.app
```

源码经 rsync 同步（排除 .build、素材原图等），产物自动取回本地。

## CI 远程构建（GitHub Actions）

`.github/workflows/ci.yml` 已配置：push 到 main / tag / PR / 手动触发时，在 macOS runner 上
build → swift test（完整套件）→ self-test → resource-self-test → workflow 质量门一致性审计 → 本地玩法/应用图标/装备图标/符文树图标/被动技能图标/英雄精灵/音效复核脚本 → 打包 TBH.app 并上传 artifact。

`release.yml` 和 `nightly.yml` 也会运行同一组本地 fidelity audits；`nightly.yml` 还会在 clean build 后对 deterministic SwiftUI 战斗场景渲染做像素级回归检查。

启用步骤（本仓库尚未初始化 git）：

```bash
git init && git add . && git commit -m "init"
git remote add origin <你的仓库地址>
git push -u origin main
```

推送后在仓库 Actions 页即可下载 TBH-app artifact。

## 测试体系

- `Tests/GameTests/`（swift-testing）：完整测试套件，**在远程/CI 运行**。
- `Sources/App/SelfTest.swift`（`--self-test`）：零框架依赖的核心断言子集，**本地可运行**，
  用于本地红绿循环；`#if DEBUG` 包裹，release 构建不包含。
- `Sources/App/ResourceSelfTest.swift`（`--resource-self-test`）：release-safe 资源自检，覆盖打包图片、音效、运行时资源映射。
- `scripts/audit-local-*.sh`：本地/CI 复核脚本，覆盖 workflow 质量门一致性、玩法来源覆盖率、应用/菜单栏图标、装备和宝箱图标清洁度、符文树源图标覆盖、被动技能源图标、音效技术指标、英雄精灵和战斗场景渲染。`audit-local-app-icons.sh`、`audit-local-item-icons.sh`、`audit-local-rune-icons.sh`、`audit-local-passive-skill-icons.sh` 与 `audit-local-hero-sprites.sh` 需要 Python Pillow。

## 素材管线

`python3 extract_assets.py` 从 `Resources/Assets.xcassets/steam_source/` 的截图裁切像素素材，
输出到 `Sources/Resources/Extracted/`（SPM 资源目录，经 `Bundle.module` 加载）。
