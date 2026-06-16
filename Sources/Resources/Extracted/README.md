# TBH 像素美术素材（内部测试用）

> ⚠️ 这些素材从 Steam 截图中提取，仅用于内部测试和原型开发，不得对外公开发布。

## 素材清单

### 官方英雄角色（角色页使用）
| 文件名 | 职业 | 尺寸 | 说明 |
|--------|------|------|------|
| official_hero_knight.png | 骑士 | 30x44 | 角色页小图使用 |
| official_hero_ranger.png | 游侠 | 30x44 | 角色页小图使用 |
| official_hero_sorcerer.png | 法师 | 30x44 | 角色页小图使用 |
| official_hero_priest.png | 牧师 | 30x44 | 角色页小图使用 |
| official_hero_hunter.png | 猎人 | 30x44 | 角色页小图使用 |
| official_hero_slayer.png | 杀手 | 30x44 | 角色页小图使用 |

### 战斗页英雄主体（当前运行使用）
| 文件名 | 职业 | 尺寸 | 说明 |
|--------|------|------|------|
| battle_hero_knight.png | 骑士 | 30x44 RGBA | 从 `official_hero_knight.png` 去除连通头像框白底生成，保留官方白披风、红盾和钢灰盔甲轮廓 |
| battle_hero_ranger.png | 游侠 | 30x44 RGBA | 从 `official_hero_ranger.png` 去除连通头像框白底生成，保留官方金发、绿色服装和远程职业轮廓 |
| battle_hero_sorcerer.png | 法师 | 30x44 RGBA | 从 `official_hero_sorcerer.png` 去除连通头像框白底生成，保留官方紫色法师帽和法杖轮廓 |
| battle_hero_priest.png | 牧师 | 30x44 RGBA | 从 `official_hero_priest.png` 去除连通头像框白底生成，保留官方白色圣冠和蓝金服饰轮廓 |
| battle_hero_hunter.png | 猎人 | 30x44 RGBA | 从 `official_hero_hunter.png` 去除连通头像框白底生成，保留官方黑色兜帽和弩手轮廓 |
| battle_hero_slayer.png | 杀手 | 30x44 RGBA | 从 `official_hero_slayer.png` 去除连通头像框白底生成，保留官方棕发、浅蓝盔甲和短武器轮廓 |

当前可用战斗截图无法为六个职业提供一致、无遮挡、可验证的动作帧；过去从截图裁切生成的局部主体容易丢失帽子、武器或职业轮廓，直接复制角色页小图又会把白色头像框带入战斗 tab。运行时 `battle_hero_*` 因此改为对应 `official_hero_*` 去除连通头像框白底后的透明小精灵副本，优先保证主角身份正确且不显示头像卡片背景。`scripts/audit-local-hero-sprites.sh` 会重建这一步去框结果并逐像素比对当前 `battle_hero_*`，同时继续检查透明边缘和 HP 绿条污染；如果 `dist/TBH.app` 已存在，脚本还会复查 app 包内英雄精灵并比对源码载荷，避免实际运行包残留旧职业图。`ResourceSelfTest` 也会从原始 PNG 样本重建同一来源结果，并忽略仅存在于全透明像素背后的不可见 RGB 字节。后续若取得无遮挡战斗姿态资源，可继续替换对应 `battle_hero_*` 并同步 `GameArt.battleHeroPixelSize(for:)` 与该审计的来源约束。

### 旧英雄裁切参考（不用于运行时战斗页）
| 文件名 | 职业 | 尺寸 | 说明 |
|--------|------|------|------|
| hero_knight.png | 骑士 | 130x210 | 早期裁切参考，当前运行不使用 |
| hero_sorcerer.png | 法师 | 130x190 | 早期裁切参考，当前运行不使用 |
| hero_hunter.png | 猎人 | 130x170 | 早期裁切参考，当前运行不使用 |
| hero_priest.png | 牧师 | 140x190 | 早期裁切参考，当前运行不使用 |
| hero_ranger.png | 游侠 | 120x170 | 早期裁切参考，当前运行不使用 |
| hero_slayer.png | 杀手 | 140x200 | 早期裁切参考，当前运行不使用 |

### 旧战斗裁切参考（不用于运行时英雄）
| 文件名 | 类型 | 尺寸 | 说明 |
|--------|------|------|------|
| battle_knight.png | 旧英雄战斗裁切 | 140x280 | 含背景/UI 碎片，当前运行不使用 |
| battle_priest.png | 旧英雄战斗裁切 | 120x260 | 含背景/UI 碎片，当前运行不使用 |
| battle_ranger.png | 旧英雄战斗裁切 | 120x260 | 含背景/UI 碎片，当前运行不使用 |
| battle_sorcerer.png | 旧英雄战斗裁切 | 120x260 | 含背景/UI 碎片，当前运行不使用 |

### 战斗怪物精灵
| 文件名 | 类型 | 尺寸 | 说明 |
|--------|------|------|------|
| monster_skeleton_boss.png | 骷髅Boss旧裁片 | 360x360 | 旧参考素材，包含完整背景，不得用于运行时战斗怪物 |
| monster_slime_red.png | 红色史莱姆旧裁片 | 120x200 | 旧参考素材，包含战斗背景和相邻角色碎片，不得用于运行时战斗怪物 |
| boss_demon.png | 恶魔Boss | 240x260 | |
| boss_golden.png | 黄金Boss | 240x240 | |

### 关卡怪物图像
| 文件名 | 怪物 |
|--------|------|
| stage_monster_assassin_goblin.png | 哥布林盗贼 |
| stage_monster_shaman_goblin.png | 哥布林萨满 |
| stage_monster_basic_orc.png | 兽人 |
| stage_monster_armored_orc.png | 兽人战士 |
| stage_monster_elite_orc.png | 精英兽人 |
| stage_monster_skeleton.png | 骷髅 |
| stage_monster_armored_skeleton.png | 骷髅战士 |
| stage_monster_skeleton_archer.png | 骷髅弓箭手 |
| stage_monster_skeleton_king.png | 骷髅王 |
| stage_monster_berserker_rat.png | 鼠族狂战士 |
| stage_monster_warrior_rat.png | 鼠族战士 |
| stage_monster_cobra.png | 眼镜蛇 |
| stage_monster_poison_insect.png | 毒虫 |
| stage_monster_homunculus.png | 人造人 |
| stage_monster_ghoul.png | 食尸鬼 |
| stage_monster_zombie_rat.png | 瘟疫鼠 |
| stage_monster_spear_kobolt.png | 狗头人卫兵 |
| stage_monster_small_mummy.png | 木乃伊 |
| stage_monster_sibuna.png | 沙漠的支配者 |
| stage_monster_voidcaller.png | 执政官莫尔卡 |

关卡怪物资源的打包契约：
- `ResourceSelfTest` 会遍历 `StageDefinition.all`、全部难度和每个 encounter，从真实运行期 `spawnMonster` 结果验证战斗图映射
- 自测必须采样到当前挖掘表中的 49 个关卡怪物名称，避免新怪物只进入数据表但没有进入美术映射
- 每个 `GameArt.battleMonsterSpriteName(for:)` 结果都必须能从打包资源加载
- 任何运行时关卡怪物不得回落到 `monster_slime_red`、`monster_skeleton_boss`、`boss_golden` 或 `boss_demon` 这类旧全截图裁片；史莱姆战斗图使用透明的 `official_monster_slime`
- 非史莱姆关卡怪物不得回落到 `official_monster_slime`
- 三个 Act Boss 必须分别映射到 `stage_monster_skeleton_king`、`stage_monster_sibuna`、`stage_monster_voidcaller`

### 装备图标
| 文件名 | 格式 | 说明 |
|--------|------|------|
| source_gear_300001.png ~ source_gear_631191.png | 396 个，16x16 RGBA | 从 `taskbarhero.org` gear 类型页每个基础等级行公开暴露的装备图标资源直接下载；清单见 `source_gear_icons.tsv`；不得自行重绘或用语义占位图替代 |
| item_0_0.png ~ item_3_4.png | 20 个，16x16 RGBA | 从 `taskbarhero.org` gear 类型页首个公开装备图标资源直接下载；仅作为装备类型/兜底图标；不得自行重绘或用语义占位图替代 |

运行时装备类型兜底图标映射：
| 装备类型 | 图标 | 来源资源 |
|--------|------|----------|
| Sword | item_0_0 | `/assets/tbhdb/game/gear/sword/SWORD_300001.png` |
| Bow | item_0_1 | `/assets/tbhdb/game/gear/bow/BOW_310001.png` |
| Staff | item_0_2 | `/assets/tbhdb/game/gear/staff/STAFF_320001.png` |
| Scepter | item_0_3 | `/assets/tbhdb/game/gear/scepter/SCEPTER_330001.png` |
| Crossbow | item_0_4 | `/assets/tbhdb/game/gear/crossbow/CROSSBOW_340001.png` |
| Axe | item_1_0 | `/assets/tbhdb/game/gear/axe/AXE_350001.png` |
| Shield | item_1_1 | `/assets/tbhdb/game/gear/shield/SHIELD_400001.png` |
| Arrow | item_1_2 | `/assets/tbhdb/game/gear/arrow/ARROW_410001.png` |
| Orb | item_1_3 | `/assets/tbhdb/game/gear/orb/ORB_420001.png` |
| Tome | item_1_4 | `/assets/tbhdb/game/gear/tome/TOME_430001.png` |
| Bolt | item_2_0 | `/assets/tbhdb/game/gear/bolt/BOLT_440001.png` |
| Hatchet | item_2_1 | `/assets/tbhdb/game/gear/hatchet/HATCHET_450001.png` |
| Helmet | item_2_2 | `/assets/tbhdb/game/gear/helmet/HELMET_500001.png` |
| Armor | item_2_3 | `/assets/tbhdb/game/gear/armor/ARMOR_510001.png` |
| Gloves | item_2_4 | `/assets/tbhdb/game/gear/gloves/GLOVES_520001.png` |
| Boots | item_3_0 | `/assets/tbhdb/game/gear/boots/BOOTS_530001.png` |
| Amulet | item_3_1 | `/assets/tbhdb/game/gear/amulet/AMULET_600001.png` |
| Earring | item_3_2 | `/assets/tbhdb/game/gear/earing/EARING_610001.png` |
| Ring | item_3_3 | `/assets/tbhdb/game/gear/ring/RING_620001.png` |
| Bracer | item_3_4 | `/assets/tbhdb/game/gear/bracer/BRACER_630001.png` |

装备图标资源的打包契约：
- `GameArt.itemIconName(for item:)` 必须优先使用 `Item.equipmentType + itemLevel` 选择 `SourceItemCatalog` 中最近的官方基础等级进度图标，即 `source_gear_<ID>`；只有缺少来源进度时才回退到对应 `item_*` 类型图标，未知非装备才回退到 `official_item_*` 通用图标
- `source_gear_icons.tsv` 固定记录 396 个来源页基础等级图标的 `iconName`、类型、itemLevel、sourceID、名称、官方 URL、SHA-256 和字节数；审计以这份清单为官方来源契约，不允许本地重绘图标通过检查
- 20 个 `EquipmentType` 必须一一映射到独立的来源页 `item_*` 资源，避免退化成少数槽位级通用图标或本地重绘占位图
- `official_item_*` 通用兜底图标也必须是透明独立图标；`official_item_box` 不得使用含相邻格、边框或背景块的旧背包 UI 裁片
- `ResourceSelfTest` 会验证这些运行时装备图标能从打包资源加载，并保持来源页尺寸 `16x16`、RGBA/alpha 通道和合理可见像素占比
- `scripts/audit-local-item-icons.sh` 会从 Swift 源码解析 `EquipmentType` 与 `GameArt.itemIconName(for:)` 映射，并独立检查 20 张 `item_*` 图标的一一对应、来源 URL、`16x16` 尺寸、固定 SHA-256 载荷、可见像素占比、可见像素连通性和重复像素载荷；同时按 `source_gear_icons.tsv` 检查 396 张 `source_gear_*` 图标的官方 URL、SHA-256、字节数、尺寸、可见像素范围和重复载荷，避免整块背包 UI 裁片、相邻装备碎片或本地重绘占位图混入运行时图标；如果本机存在 `~/Library/Application Support/TBH/save.json`，脚本还会读取真实背包和已装备物品，确认当前存档里的装备最终解析到存在的 `source_gear_*` 或 `item_*` 来源页资源；如果 `dist/TBH.app` 已存在，脚本还会复查 app 包内图标并比对源码载荷，避免实际运行包残留旧裁片或旧自绘图标
- 掉落装备名称和合成预览使用 `SourceItemCatalog` 中对应装备类型和 itemLevel 的最近来源基础等级进度，例如 Lv.12 Scepter 显示为来源 Lv.10 `Blessed Scepter` 并在描述中保留来源装备 ID `330003`
- 这仍是 396 个基础等级图标和基础等级名映射，不等同于原版 5,760 件物品的完整逐件图标库、逐稀有度/词缀名称、逐变体图标或完整原版 stat roll

### 来源页材料与关卡宝箱图标
| 文件名 | 数量 | 格式 | 说明 |
|--------|------|------|------|
| source_material_110001.png ~ source_material_190004.png | 115 | 16x16 RGBA | 对应 `/items/` 材料表的 `Item_<ID>.png`，覆盖 Decoration、Engraving、Inscription、Crafting、Offering、Soul Stone |
| source_stage_chest_910011.png | 1 | 64x64 RGBA | Normal Monster Box 家族图标 |
| source_stage_chest_920011.png | 1 | 64x64 RGBA | Stage Boss Box 家族图标 |
| source_stage_chest_930011.png | 1 | 64x64 RGBA | Act Boss Box 家族图标 |

来源页物品图标资源的打包契约：
- `SourceItemCatalog.allMaterials` 的每一行都必须映射到对应的 `source_material_<ID>` 图标
- `SoulStoneKind` 必须通过 `GameArt.soulStoneIconName(for:)` 使用 `source_material_190001` 到 `source_material_190004`
- `SourceItemCatalog.allStageChests` 的 59 个关卡宝箱源表行必须复用来源页暴露的 3 个箱子家族图标
- 设置页箱子列表必须通过 `GameArt.chestIconName(for:)` 使用来源页箱子图标，而不是单一 `official_item_box`
- `ResourceSelfTest` 会验证 115 个材料图标能从打包资源加载并保持 16x16，也会验证 3 个箱子图标保持 64x64、透明背景、透明角、合理可见像素占比和无外边缘污染

### 技能/效果类别图标 (12个)
| 文件名 | 格式 | 说明 |
|--------|------|------|
| skill_0_0.png ~ skill_2_3.png | 40x40 | 从 `ss_06.jpg` Rune Tree 节点裁切，用于角色技能列表的类别图标 |

当前截图集中没有 36 个主动技能的逐技能图标页。这 12 张图标来自原版 Rune Tree UI，运行时按 `SkillDelivery` 和 `SkillDamageElement` 复用为技能/效果类别图标：物理冲击、投射物、火焰、祝福/治疗、召唤/陷阱、快速攻击、冰冷、闪电、防护等。它们不能声明为完整原版逐技能图标库。

技能图标资源的打包契约：
- `GameArt.skillIconName(for:)` 必须让 36 个当前建模主动技能都解析到 `skill_*` 资源
- 映射至少保留 8 个不同图标，避免全部技能退化成一个通用符号
- 每个 `GameArt.skillIconNames` 中的图标都必须能从打包资源加载，并保持 `40x40`
- `ResourceSelfTest` 会检查图标色彩复杂度，避免 `ss_03.jpg` 背景纹理块再次被当作技能图标混入运行时

### 被动技能源图标（27 个）
| 文件名 | 格式 | 说明 |
|--------|------|------|
| source_passive_*.png | 16x16 / 32x32 RGBA | 从 `taskbarhero.org/en/skills/` 的被动技能表 `<img class="db-icon">` 直接下载 |

当前源页的 108 个被动技能行中，104 行暴露了源图标，合并为 27 个图标族，其中 16 个图标族是 `16x16`，11 个图标族是 `32x32`。`ElementalDodgeChance` 复用 `source_passive_DodgeChance`，`SkillDurationIncrease` 映射到 `source_passive_Duration`，`IncreaseAreaOfEffectDamage` 映射到 `source_passive_AreaOfEffectDamage`。当前源页没有为 `IncreaseProjectileDamage` 与 `SkillHealIncrease` 暴露图片，因此这 4 行被动技能在代码中保持“无源图标”状态，不用其他图标伪装为原图。当前源页还暴露了一组不同文件名但像素相同的图标：`CastSpeed`、`DamageAbsorption`、`MaxDodgeChance`、`MaxHp`、`MovementSpeed`，审计脚本把这组作为显式源站复用处理。

被动技能图标资源的打包契约：
- `GameArt.passiveSkillIconName(for:)` 必须让当前源页有图的 104 个被动行解析到 `source_passive_*`
- `GameArt.passiveSkillIconNames` 必须覆盖当前源页暴露的 27 个唯一被动图标族
- 每个 `source_passive_*` 图标都必须能从打包资源加载，并保持当前源页尺寸（`16x16` 或 `32x32`）
- `ResourceSelfTest` 和 `scripts/audit-local-passive-skill-icons.sh` 会检查 104/108 映射、27 个图标族、当前源页缺图 stat、源尺寸、透明通道与非预期重复像素；如果 `dist/TBH.app` 已存在，脚本还会复查 app 包内 `source_passive_*` 图标并比对源码载荷，避免实际运行包残留旧被动技能图标

### 符文树节点图标（39 个源图标族）
| 文件名 | 格式 | 说明 |
|--------|------|------|
| source_rune_*.png | 16x16 RGBA | 从 `taskbarhero.org/zh/runes/` 暴露的 `/assets/tbhdb/game/runes/<IconFamily>.png` 路径下载 |

当前 `SourceRuneCatalog` 以数据形式保留了完整原版 Rune Tree 的 197 个节点、195 条 `Next` 连线、11 条稀疏 `Previous` 引用及其精确映射、39 个图标族、图标族分布、`MaxLevel` 分布 `1:62, 2:1, 3:43, 5:89, 10:2`，以及 `Next` 出度分布 `0:79, 1:63, 2:35, 3:18, 4:2`。`source_rune_*` 现在覆盖这 39 个图标族；当前代码建模 15 个可执行符文节点，这些节点的设置页图标会从对应源节点的图标族自动派生：`UnlockArrangeSlotCount`、`UnlockSkillSlotCount`、`MaxInventorySlot`、`OpenOneTypeChestAllAtOnce`、`OpenAllTypeChestAllAtOnce`、`UnlockAutoOpenNormalChest`、`UnlockAutoOpenStageBossChest`、`UnlockAutoOpenActBossChest`、`MaxAmountNormalChest`、`MaxAmountStageBossChest`、`MaxAmountActBossChest`、`UnlockOfflineReward`、`OfflineRewardGoldPercent`、`OfflineRewardExpPercent`。旧的 `rune_*` 截图裁片仍留在资源目录作为历史参考，不再作为当前建模符文的首选映射依据。

`扩张符文：背包容量 +10` 已接入运行时背包容量；两个 `开启符文` 已接入同类箱子批量开启和全部箱子一键开启；三个 `发条符文` 已分别接入 Normal Monster Box、Stage Boss Box 和 Act Boss Box 家族自动开启；`收纳符文` / `MaxAmountNormalChest`、`金库符文` / `MaxAmountStageBossChest`、`无限符文` / `MaxAmountActBossChest` 已接入对应箱子家族的本地容量上限，并按保守脚手架各增加 `+1`。这些箱子容量符文只证明来源页存在对应容量图标族和节点类别；精确成本、路径、叠加规则、真实容量增量、自动开启计时和完整原版路径仍按未核对处理。精确逐节点坐标、成本、效果、自动开启计时和扩容数值仍需要更完整的授权资源或逐节点截图。

符文树图标资源的打包契约：
- `GameArt.runeTreeIconName(for:)` 必须让所有当前 `RuneTreeNode` 都解析到 `source_rune_*` 资源
- 当前 15 个节点必须保留 14 个不同源图标族，其中第 2/3 编队位共用 `source_rune_UnlockArrangeSlotCount`
- `GameArt.runeTreeIconNames` 必须覆盖 `SourceRuneCatalog` 当前记录的 39 个图标族
- 每个 `source_rune_*` 图标都必须能从打包资源加载，并保持当前源页尺寸 `16x16`
- `ResourceSelfTest` 和 `scripts/audit-local-rune-icons.sh` 会检查这些图标的尺寸、源图标族覆盖、当前运行态节点映射、色彩复杂度和非预期重复像素，避免背景纹理块或旧截图裁片混入设置页符文树 UI；如果 `dist/TBH.app` 已存在，脚本还会复查 app 包内 39 个 `source_rune_*` 图标并比对源码载荷，避免实际运行包残留旧符文图标

### 任务栏精灵
| 文件名 | 格式 | 说明 |
|--------|------|------|
| taskbar_hero_1~4.png | 32x32 | 任务栏小尺寸角色（已放大） |

### 应用与菜单栏图标
| 文件名 | 格式 | 说明 |
|--------|------|------|
| app_icon.png | 180x180 RGBA | SwiftUI 菜单栏状态项的像素源图，运行时缩到原生菜单栏尺寸显示 |
| TBH.icns | macOS icns | 打包脚本复制到 `TBH.app/Contents/Resources/TBH.icns`，由 `CFBundleIconFile=TBH` 作为 Finder/启动图标 |

应用图标资源的打包契约：
- `GameArt.appIconName` 必须指向 `app_icon`
- `MenuBarIcon.nativeIconSide` 和 `MenuBarIcon.nativeLabelHeight` 必须把图标布局限制在原生菜单栏范围内，当前为 `14x14` 点，整行高度 `18` 点；`ResourceSelfTest` 和 `scripts/audit-local-app-icons.sh` 都会守住这两个精确值，避免菜单栏图标过大或黑条回归
- `package-app.sh` 必须安装 `TBH.icns` 并在 `Info.plist` 中声明 `CFBundleIconFile=TBH`
- `ResourceSelfTest` 会把 `app_icon.png`、`campfire.png`、`logo_tbh.png`、`achievement_1~4.png` 和 `taskbar_hero_1~4.png` 纳入 release 必需 PNG 清单，并检查这些品牌/菜单栏素材的尺寸、全不透明像素、色彩复杂度、饱和像素信号和 `app_icon.png` 的深色菜单栏安全底色比例；同一自检也会解析 `TBH.icns` 头、声明大小和必需 icns chunk，避免打包图标结构损坏
- `scripts/audit-local-app-icons.sh` 会检查 `app_icon.png`、`TBH.icns`、`campfire.png`、`logo_tbh.png`、`achievement_1~4.png` 和 `taskbar_hero_1~4.png` 的尺寸、像素复杂度、icns chunk 覆盖以及菜单栏图标静态布局约束，避免启动图标缺失、菜单栏图标过大或退化成黑条；如果 `dist/TBH.app` 已存在，脚本还会复查 app 包内 `Extracted` 资源和顶层 Finder 图标 `Contents/Resources/TBH.icns`，并比对源码载荷，避免实际运行包残留旧图标

### UI 元素
| 文件名 | 说明 |
|--------|------|
| campfire.png | 篝火动画帧 |
| logo_tbh.png | 游戏标题 Logo |
| achievement_1~4.png | 成就图标 (64x64) |

### 音效 SFX（原创生成）
| 文件名 | 事件 |
|--------|------|
| sfx/sfx_hero_attack.wav | 普通攻击 |
| sfx/sfx_hero_critical_hit.wav | 暴击 |
| sfx/sfx_skill_cast.wav | 技能释放 |
| sfx/sfx_hero_damaged.wav | 受伤 |
| sfx/sfx_battle_won.wav | 胜利 |
| sfx/sfx_loot_found.wav | 掉落 |
| sfx/sfx_battle_lost.wav | 失败 |
| sfx/sfx_level_up.wav | 升级 |
| sfx/sfx_item_equipped.wav | 装备物品 |
| sfx/sfx_item_consumed.wav | Cube 注入 / 炼金消耗物品 |
| sfx/sfx_preview.wav | 设置页预览 |
| sfx/sfx_manifest.tsv | 音效来源与 payload 校验清单 |

这些 WAV 是程序合成的短促像素风音效，不是从 Steam 视频或游戏客户端提取的原始音频。`sfx/sfx_manifest.tsv` 必须把每个事件标记为 `generated_substitute` 且 `officialAudio=false`，并记录格式、时长、SHA-256 与字节数。

当前打包契约：
- 格式：16-bit PCM WAV
- 声道：mono
- 采样率：22050 Hz
- 时长：约 0.11s 到 0.36s，资源自测要求处于 0.05s 到 0.75s
- 覆盖：`ResourceSelfTest` 从 `GameAudioEvent` 自动派生必需清单，并验证每个事件音效可由 `NSSound` 播放、可由 `AVAudioFile` 解析、符合 mono / 22050 Hz / 时长 / RMS / 峰值约束
- 发布包：`scripts/audit-local-sfx.sh` 会验证源码 `sfx/` 目录和 `dist/TBH.app` 包内 `Extracted/sfx` 的 WAV 载荷及 `sfx_manifest.tsv` 一致，避免实际运行包残留旧音效、缺失新事件音效或丢失替代音来源声明
- 运行时：`SelfTest` 断言 `BattleEvent` 到 `GameAudioEvent` 的路由，并用注入式录音音频对象验证预览、装备、Cube 注入、炼金、开箱、合成、离线升级、静音抑制和重新开启音效行为

战斗页英雄资源的打包契约：
- 文件名必须通过 `GameArt.battleHeroSpriteName(for:)` 映射到对应职业的 `battle_hero_*`，例如骑士只能映射到 `battle_hero_knight`
- 尺寸必须与 `GameArt.battleHeroPixelSize(for:)` 登记值一致，并保持紧凑，当前发布自测允许 `18...40px` 宽、`24...48px` 高
- 战斗页显示必须使用登记像素尺寸等比缩放，不能把所有职业塞进同一个通用显示框导致形象比例漂移
- 必须包含 alpha 通道、四角透明、完整透明外圈
- 可见角色像素必须足够，且不能填满整张图，避免空白透明图、白底头像框或大截图裁切混入战斗页
- 当前身份安全 fallback 必须能由对应 `official_hero_*` 经连通头像框/背景去除重建得到；可见像素和 alpha 遮罩不得漂移
- 不得包含成行 HP 条绿像素，避免 `battle_*` 截图裁切中的血条/UI 片段被误当作英雄主体
- 不得包含连续白色头像框背景长条，避免角色页头像卡片误进入战斗 tab

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

`sfx/` 下的 WAV 为原创生成音效，不包含从官方媒体提取的音频片段。

正式版本应使用原创或获得授权的素材。
