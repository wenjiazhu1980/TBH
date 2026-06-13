#!/usr/bin/env python3
"""
从 Steam 截图中提取 TBH 像素美术素材（仅用于内部测试）
"""
import os
from PIL import Image

STEAM_DIR = "Resources/Assets.xcassets/steam_source"
OUTPUT_DIR = "Sources/Resources/Extracted"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def save_crop(img, name, box):
    """裁切并保存"""
    cropped = img.crop(box)
    path = os.path.join(OUTPUT_DIR, f"{name}.png")
    cropped.save(path, "PNG")
    print(f"  ✓ {name} ({cropped.width}x{cropped.height})")
    return cropped

# ============================================================
# 1. 英雄选择界面 (ss_05) — 提取6个职业角色
# ============================================================
print("\n=== 从 ss_05.jpg 提取英雄角色 ===")
ss05 = Image.open(os.path.join(STEAM_DIR, "ss_05.jpg"))
w, h = ss05.size
print(f"  图片尺寸: {w}x{h}")

# 角色在底部篝火周围，约在 y=350-480 区域
# 基于 960x540 的截图坐标（实际可能是 1920x1080 缩放）
# 从截图分析：
# - Slayer:   左侧 ~x=280-320, y=380-470
# - Priest:   左中 ~x=340-380, y=370-440
# - Ranger:   上中 ~x=390-430, y=340-410
# - Knight:   中右 ~x=500-540, y=350-440
# - Sorcerer: 右中 ~x=580-620, y=360-440
# - Hunter:   右侧 ~x=640-680, y=370-440

# 根据实际图片尺寸计算比例
scale = w / 960  # 假设截图基于 960 宽度设计

hero_crops = {
    "hero_slayer":   (270, 370, 340, 470),
    "hero_priest":   (330, 350, 400, 445),
    "hero_ranger":   (385, 330, 445, 415),
    "hero_knight":   (490, 340, 555, 445),
    "hero_sorcerer": (570, 350, 635, 445),
    "hero_hunter":   (635, 360, 700, 445),
}

for name, box in hero_crops.items():
    scaled_box = tuple(int(v * scale) for v in box)
    save_crop(ss05, name, scaled_box)

# 篝火动画帧
save_crop(ss05, "campfire", (int(440*scale), int(380*scale), int(520*scale), int(470*scale)))

# ============================================================
# 2. 战斗场景 (ss_04) — 提取角色和怪物精灵
# ============================================================
print("\n=== 从 ss_04.jpg 提取战斗精灵 ===")
ss04 = Image.open(os.path.join(STEAM_DIR, "ss_04.jpg"))
w, h = ss04.size
print(f"  图片尺寸: {w}x{h}")
scale = w / 960

# 战斗角色在底部，约 y=250-400 区域
# 从左到右：骷髅Boss、骑士、牧师、弓箭手、法师、红色小怪物
battle_crops = {
    "monster_skeleton_boss": (80, 180, 260, 360),
    "battle_knight":        (280, 230, 350, 370),
    "battle_priest":        (340, 240, 400, 370),
    "battle_ranger":        (400, 240, 460, 370),
    "battle_sorcerer":      (460, 240, 520, 370),
    "monster_slime_red":    (530, 260, 590, 360),
}

for name, box in battle_crops.items():
    scaled_box = tuple(int(v * scale) for v in box)
    save_crop(ss04, name, scaled_box)

# ============================================================
# 3. 物品图标 (ss_02) — 从装备栏网格提取
# ============================================================
print("\n=== 从 ss_02.jpg 提取物品图标 ===")
ss02 = Image.open(os.path.join(STEAM_DIR, "ss_02.jpg"))
w, h = ss02.size
print(f"  图片尺寸: {w}x{h}")
scale = w / 960

# 装备栏网格在中间区域，约 x=390-570, y=120-280
# 每个格子约 35x35 像素（基于 960 宽度）
grid_x_start = 390
grid_y_start = 120
cell_size = 38
cols = 5
rows = 4

item_count = 0
for row in range(rows):
    for col in range(cols):
        x1 = int((grid_x_start + col * cell_size) * scale)
        y1 = int((grid_y_start + row * cell_size) * scale)
        x2 = int((grid_x_start + (col + 1) * cell_size) * scale)
        y2 = int((grid_y_start + (row + 1) * cell_size) * scale)

        # 跳过空格子（检查是否主要是深色/空的）
        cell = ss02.crop((x1, y1, x2, y2))
        # 简单检查：如果平均亮度太低，可能是空格
        avg_brightness = sum(cell.convert("L").getdata()) / (cell.width * cell.height)
        if avg_brightness > 30:  # 非空格子
            save_crop(ss02, f"item_{row}_{col}", (x1, y1, x2, y2))
            item_count += 1

print(f"  共提取 {item_count} 个物品图标")

# ============================================================
# 4. UI 元素 (ss_03) — 技能图标
# ============================================================
print("\n=== 从 ss_03.jpg 提取技能图标 ===")
ss03 = Image.open(os.path.join(STEAM_DIR, "ss_03.jpg"))
w, h = ss03.size
print(f"  图片尺寸: {w}x{h}")
scale = w / 960

# 技能树在左侧面板，约 x=170-310, y=220-340
skill_grid_x = 170
skill_grid_y = 220
skill_cell = 35

skill_count = 0
for row in range(3):
    for col in range(4):
        x1 = int((skill_grid_x + col * skill_cell) * scale)
        y1 = int((skill_grid_y + row * skill_cell) * scale)
        x2 = int((skill_grid_x + (col + 1) * skill_cell) * scale)
        y2 = int((skill_grid_y + (row + 1) * skill_cell) * scale)

        cell = ss03.crop((x1, y1, x2, y2))
        avg_brightness = sum(cell.convert("L").getdata()) / (cell.width * cell.height)
        if avg_brightness > 25:
            save_crop(ss03, f"skill_{row}_{col}", (x1, y1, x2, y2))
            skill_count += 1

print(f"  共提取 {skill_count} 个技能图标")

# ============================================================
# 5. 怪物精灵 (ss_07) — Boss 战
# ============================================================
print("\n=== 从 ss_07.jpg 提取 Boss 怪物 ===")
ss07 = Image.open(os.path.join(STEAM_DIR, "ss_07.jpg"))
w, h = ss07.size
print(f"  图片尺寸: {w}x{h}")
scale = w / 960

# Boss 在底部战斗区域
save_crop(ss07, "boss_demon", (int(300*scale), int(300*scale), int(420*scale), int(430*scale)))
save_crop(ss07, "boss_golden", (int(420*scale), int(310*scale), int(540*scale), int(430*scale)))

# ============================================================
# 6. 任务栏视图 (ss_01) — 提取小尺寸角色
# ============================================================
print("\n=== 从 ss_01.jpg 提取任务栏精灵 ===")
ss01 = Image.open(os.path.join(STEAM_DIR, "ss_01.jpg"))
w, h = ss01.size
print(f"  图片尺寸: {w}x{h}")
scale = w / 960

# 任务栏角色在底部约 y=480-520
taskbar_crops = {
    "taskbar_hero_1": (720, 475, 750, 510),
    "taskbar_hero_2": (750, 475, 780, 510),
    "taskbar_hero_3": (780, 475, 810, 510),
    "taskbar_hero_4": (810, 475, 840, 510),
}

for name, box in taskbar_crops.items():
    scaled_box = tuple(int(v * scale) for v in box)
    crop = ss01.crop(scaled_box)
    # 放大到 32x32 以便查看
    crop = crop.resize((32, 32), Image.NEAREST)
    path = os.path.join(OUTPUT_DIR, f"{name}.png")
    crop.save(path, "PNG")
    print(f"  ✓ {name} (32x32, from {crop.width}x{crop.height} original)")

# ============================================================
# 7. 从 header.jpg 提取 Logo 文字区域
# ============================================================
print("\n=== 从 header.jpg 提取标题 ===")
header = Image.open(os.path.join(STEAM_DIR, "header.jpg"))
w, h = header.size
print(f"  图片尺寸: {w}x{h}")
# header 是 460x215，标题 "TBH" 在中间
save_crop(header, "logo_tbh", (int(w*0.3), int(h*0.1), int(w*0.7), int(h*0.5)))

# ============================================================
# 8. 从成就图标提取
# ============================================================
print("\n=== 提取成就图标 ===")
for i in range(1, 5):
    ach = Image.open(os.path.join(STEAM_DIR, f"ach{i}.jpg"))
    # 成就图标通常 64x64 或 128x128
    ach_resized = ach.resize((64, 64), Image.NEAREST)
    path = os.path.join(OUTPUT_DIR, f"achievement_{i}.png")
    ach_resized.save(path, "PNG")
    print(f"  ✓ achievement_{i} (64x64)")

# ============================================================
# 汇总
# ============================================================
print("\n" + "="*50)
print("素材提取完成!")
print(f"输出目录: {OUTPUT_DIR}")
files = os.listdir(OUTPUT_DIR)
print(f"共提取 {len(files)} 个文件")
print("\n文件列表:")
for f in sorted(files):
    size = os.path.getsize(os.path.join(OUTPUT_DIR, f))
    print(f"  {f} ({size:,} bytes)")
