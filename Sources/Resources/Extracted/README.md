# TBH 像素美术素材（内部测试用）

> ⚠️ 这些素材从 Steam 截图中提取，仅用于内部测试和原型开发，不得对外公开发布。

## 素材清单

### 英雄角色 (6个职业)
| 文件名 | 职业 | 尺寸 | 说明 |
|--------|------|------|------|
| hero_knight.png | 骑士 | 130x210 | 主要使用的战士职业 |
| hero_sorcerer.png | 法师 | 130x190 | |
| hero_hunter.png | 猎人 | 130x170 | |
| hero_priest.png | 牧师 | 140x190 | |
| hero_ranger.png | 游侠 | 120x170 | |
| hero_slayer.png | 刺客 | 140x200 | |

### 战斗精灵
| 文件名 | 类型 | 尺寸 | 说明 |
|--------|------|------|------|
| battle_knight.png | 英雄战斗姿态 | 140x280 | |
| battle_priest.png | 英雄战斗姿态 | 120x260 | |
| battle_ranger.png | 英雄战斗姿态 | 120x260 | |
| battle_sorcerer.png | 英雄战斗姿态 | 120x260 | |
| monster_skeleton_boss.png | 骷髅Boss | 360x360 | 清晰的骷髅战士 |
| monster_slime_red.png | 红色史莱姆 | 120x200 | 可用于所有史莱姆变体 |
| boss_demon.png | 恶魔Boss | 240x260 | |
| boss_golden.png | 黄金Boss | 240x240 | |

### 物品图标 (20个)
| 文件名 | 格式 | 说明 |
|--------|------|------|
| item_0_0.png ~ item_3_4.png | 76x76 | 4行5列网格，包含武器、护甲、饰品等 |

### 技能图标 (12个)
| 文件名 | 格式 | 说明 |
|--------|------|------|
| skill_0_0.png ~ skill_2_3.png | 70x70 | 3行4列技能网格 |

### 任务栏精灵
| 文件名 | 格式 | 说明 |
|--------|------|------|
| taskbar_hero_1~4.png | 32x32 | 任务栏小尺寸角色（已放大） |

### UI 元素
| 文件名 | 说明 |
|--------|------|
| campfire.png | 篝火动画帧 |
| logo_tbh.png | 游戏标题 Logo |
| achievement_1~4.png | 成就图标 (64x64) |

## 使用方法

### 在 Swift 中加载素材
```swift
// 直接从文件系统加载（开发阶段）
if let image = NSImage(contentsOfFile: "Resources/Assets.xcassets/Extracted/hero_knight.png") {
    // 使用 image
}

// 使用辅助方法
if let image = NSImage.loadExtracted(named: "hero_knight") {
    // 使用 image
}
```

### 在 SwiftUI 中显示像素精灵
```swift
PixelSprite(imageName: "hero_knight", size: CGSize(width: 64, height: 64))
```

## 替换为正式素材

当获得正式授权的像素美术后，替换以下文件：
1. 将新素材放入 `Resources/Assets.xcassets/` 对应目录
2. 更新 `PixelSprite.swift` 中的素材映射
3. 确保所有素材保持像素风格（禁用抗锯齿）

## 法律声明

这些素材来自 TBH: Task Bar Hero (Steam AppID: 3678970) 的公开截图，用于：
- 个人学习和研究
- 内部原型测试
- 不得用于商业发布

正式版本应使用原创或获得授权的素材。
