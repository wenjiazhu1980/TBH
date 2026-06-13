# TBH: Task Bar Hero — macOS Edition

macOS 菜单栏放置 RPG：英雄常驻菜单栏自动战斗、刷怪、掉宝、升级，关掉电脑也有离线收益喵。

```
swift run TBH                # 运行（菜单栏出现像素英雄）
swift run TBH --self-test    # 本地零依赖自检
```

- 构建 / 测试 / 远程构建 / CI / 打包：见 [BUILDING.md](BUILDING.md)
- 技术栈：Swift 5.9+ / SwiftUI `MenuBarExtra` / SPM，无第三方依赖
- 测试：swift-testing（`Tests/GameTests`，远程或 CI 运行）+ 内置 self-test（本地）

## 目录结构

```
Sources/
  App/            入口、生命周期、SelfTest
  Game/
    Engine/       GameEngine（游戏循环/存档/装备/重置）、进度与统计、离线收益
    Character/    英雄、技能
    Combat/       战斗、怪物、伤害计算
    Inventory/    物品、背包、掉落表
    Progress/     章节、难度
  UI/             MenuBar 图标与弹窗、战斗/背包/角色/设置面板、像素精灵渲染
  Persistence/    JSON 存档（Application Support/TBH/save.json）
  Resources/
    Extracted/    像素素材（extract_assets.py 生成，Bundle.module 加载）
Tests/GameTests/  swift-testing 测试套件
scripts/          package-app.sh（打包 .app）、remote-build.sh（SSH 远程构建）
```

## 玩法循环

每秒一个 tick：英雄与怪物按速度轮流出手 → 胜利获得经验/金币/掉落并推进进度
（每章 25 杀，三章一轮，通关提升难度）→ 失败半血复活。每 30 秒自动存档，退出兜底存档，
离线时按当前章节效率折算收益（封顶 24 小时）。
