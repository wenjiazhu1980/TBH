#!/usr/bin/env python3
"""
从 Steam 截图中提取 TBH 像素美术素材（仅用于内部测试）
"""
import os
from collections import Counter, deque
from PIL import Image

STEAM_DIR = "Resources/Assets.xcassets/steam_source"
OUTPUT_DIR = "Sources/Resources/Extracted"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def color_distance(left, right):
    """RGB 欧氏距离"""
    return sum((a - b) ** 2 for a, b in zip(left, right)) ** 0.5

def edge_background_palette(img):
    """从裁切四周采样，估计与角色相连的截图背景色。"""
    rgb = img.convert("RGB")
    w, h = rgb.size
    edge_pixels = []

    for x in range(w):
        edge_pixels.append(rgb.getpixel((x, 0)))
        edge_pixels.append(rgb.getpixel((x, h - 1)))
    for y in range(h):
        edge_pixels.append(rgb.getpixel((0, y)))
        edge_pixels.append(rgb.getpixel((w - 1, y)))

    counts = Counter(edge_pixels)
    corners = [
        rgb.getpixel((0, 0)),
        rgb.getpixel((w - 1, 0)),
        rgb.getpixel((0, h - 1)),
        rgb.getpixel((w - 1, h - 1)),
    ]
    palette = []

    for color in corners + [color for color, _ in counts.most_common(20)]:
        r, g, b = color
        brightness = (r + g + b) / 3
        spread = max(color) - min(color)
        brown_background = r >= g - 4 and g >= b - 8 and brightness < 100
        neutral_dark_background = spread <= 20 and 12 <= brightness < 88
        purple_dark_background = b >= g - 8 and abs(r - g) <= 20 and brightness < 82
        green_dark_background = g >= r - 12 and g >= b - 4 and brightness < 95
        saturated_red_foreground = r > g + 28 and r > b + 28

        if (
            brown_background or
            neutral_dark_background or
            purple_dark_background or
            green_dark_background
        ) and not saturated_red_foreground:
            if all(color_distance(color, existing) > 8 for existing in palette):
                palette.append(color)

    return palette

def remove_connected_edge_background(img, tolerance=28):
    """只透明化与裁切边缘连通的截图背景，保留角色内部暗色描边。"""
    rgba = img.convert("RGBA")
    rgb = img.convert("RGB")
    w, h = rgba.size
    pixels = rgba.load()
    palette = edge_background_palette(img)
    queue = deque()
    seen = set()

    def near_background(x, y):
        color = rgb.getpixel((x, y))
        return any(color_distance(color, sample) <= tolerance for sample in palette)

    for x in range(w):
        for y in (0, h - 1):
            if near_background(x, y):
                queue.append((x, y))
                seen.add((x, y))

    for y in range(h):
        for x in (0, w - 1):
            if (x, y) not in seen and near_background(x, y):
                queue.append((x, y))
                seen.add((x, y))

    while queue:
        x, y = queue.popleft()
        r, g, b, _ = pixels[x, y]
        pixels[x, y] = (r, g, b, 0)

        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and near_background(nx, ny):
                seen.add((nx, ny))
                queue.append((nx, ny))

    return rgba

def official_hero_portrait_background(r, g, b, a):
    """匹配 official_hero_* 头像框中与边缘连通的白底和深色外框。"""
    if a == 0:
        return True

    brightness = (r + g + b) / 3
    spread = max(r, g, b) - min(r, g, b)

    if r >= 230 and g >= 230 and b >= 230:
        return True

    if spread <= 28 and brightness <= 42:
        return True

    return spread <= 24 and 42 < brightness <= 90

def remove_connected_portrait_frame(img):
    """从完整 official_hero_* 小图中移除相连头像框，保留原始 30x44 画布。"""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()
    queue = deque()
    seen = set()

    def append_if_background(x, y):
        if (x, y) in seen:
            return
        if official_hero_portrait_background(*pixels[x, y]):
            seen.add((x, y))
            queue.append((x, y))

    for x in range(w):
        append_if_background(x, 0)
        append_if_background(x, h - 1)

    for y in range(h):
        append_if_background(0, y)
        append_if_background(w - 1, y)

    while queue:
        x, y = queue.popleft()
        r, g, b, _ = pixels[x, y]
        pixels[x, y] = (r, g, b, 0)

        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h:
                append_if_background(nx, ny)

    return rgba

def trim_transparent_padding(img, padding=1):
    """裁掉全透明边缘，再补少量透明留白，避免贴边渲染。"""
    rgba = img.convert("RGBA")
    bbox = rgba.getbbox()
    if bbox:
        rgba = rgba.crop(bbox)

    padded = Image.new("RGBA", (rgba.width + padding * 2, rgba.height + padding * 2), (255, 255, 255, 0))
    padded.alpha_composite(rgba, (padding, padding))
    return padded

def remove_tiny_alpha_components(img, min_area=2):
    """移除截图中不属于角色的小火星/文字碎片。"""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()
    seen = set()

    for y in range(h):
        for x in range(w):
            if (x, y) in seen or pixels[x, y][3] == 0:
                continue

            stack = [(x, y)]
            seen.add((x, y))
            component = []

            while stack:
                cx, cy = stack.pop()
                component.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen and pixels[nx, ny][3] != 0:
                        seen.add((nx, ny))
                        stack.append((nx, ny))

            if len(component) < min_area:
                for cx, cy in component:
                    r, g, b, _ = pixels[cx, cy]
                    pixels[cx, cy] = (r, g, b, 0)

    return rgba

def save_crop(img, name, box, remove_edge_background=False):
    """裁切并保存"""
    cropped = img.crop(box)
    if remove_edge_background:
        cropped = remove_connected_edge_background(cropped)
    path = os.path.join(OUTPUT_DIR, f"{name}.png")
    cropped.save(path, "PNG")
    print(f"  ✓ {name} ({cropped.width}x{cropped.height})")
    return cropped

def save_item_icon_from_inventory(img, name, box, canvas_size=32, padding=2):
    """从 ss_02 背包格内部提取装备图标，避免把格子边框和相邻 UI 裁进资源。"""
    cropped = img.crop(box).convert("RGBA")
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (255, 255, 255, 0))
    canvas.alpha_composite(cropped, (padding, padding))
    path = os.path.join(OUTPUT_DIR, f"{name}.png")
    canvas.save(path, "PNG")
    print(f"  ✓ {name} ({canvas.width}x{canvas.height})")
    return canvas

def save_battle_hero_from_official(hero_key):
    source = os.path.join(OUTPUT_DIR, f"official_hero_{hero_key}.png")
    if not os.path.exists(source):
        raise FileNotFoundError(f"missing required official_hero_{hero_key}.png")

    cleaned = remove_connected_portrait_frame(Image.open(source))
    path = os.path.join(OUTPUT_DIR, f"battle_hero_{hero_key}.png")
    cleaned.save(path, "PNG")
    print(f"  ✓ battle_hero_{hero_key} ({cleaned.width}x{cleaned.height})")
    return cleaned

def save_battle_knight_from_official():
    """Use the checked official Knight figure for the battle-lane sprite."""
    source = os.path.join(OUTPUT_DIR, "official_hero_knight.png")
    if not os.path.exists(source):
        raise FileNotFoundError("missing required official_hero_knight.png")

    cleaned = Image.open(source).convert("RGBA")
    path = os.path.join(OUTPUT_DIR, "battle_hero_knight.png")
    cleaned.save(path, "PNG")
    print(f"  ✓ battle_hero_knight ({cleaned.width}x{cleaned.height})")
    return cleaned

def save_battle_hero_from_selection(img, hero_key, box, source_scale=4, min_component_area=2):
    """从英雄选择截图的深色背景抠出战斗页小人，避免白底头像误删浅色盔甲。"""
    crop = img.crop(box)
    cleaned = remove_connected_edge_background(crop)
    downscaled = cleaned.resize(
        (
            max(1, round(cleaned.width / source_scale)),
            max(1, round(cleaned.height / source_scale))
        ),
        Image.NEAREST
    )
    downscaled = remove_tiny_alpha_components(downscaled, min_area=min_component_area)
    downscaled = trim_transparent_padding(downscaled)
    path = os.path.join(OUTPUT_DIR, f"battle_hero_{hero_key}.png")
    downscaled.save(path, "PNG")
    print(f"  ✓ battle_hero_{hero_key} ({downscaled.width}x{downscaled.height})")
    return downscaled

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
# 2.1 生成战斗页透明英雄主体
# ============================================================
print("\n=== 生成战斗页透明英雄主体 ===")

# 当前可用战斗截图无法为六个职业提供一致、无遮挡、可验证的动作帧。
# 战斗页先使用对应 official_hero_* 去掉头像框白底后的完整小精灵，
# 确保主角身份不会被截图裁切、去框误删或职业错位破坏。
for hero_key in ("knight", "ranger", "sorcerer", "priest", "hunter", "slayer"):
    save_battle_hero_from_official(hero_key)

# ============================================================
# 3. 物品图标 (ss_02) — 从背包网格提取
# ============================================================
print("\n=== 从 ss_02.jpg 提取物品图标 ===")
ss02 = Image.open(os.path.join(STEAM_DIR, "ss_02.jpg"))
w, h = ss02.size
print(f"  图片尺寸: {w}x{h}")

# ss_02 的装备栏区域包含英雄纸娃娃和边框，不适合直接作为背包图标。
# 干净的物品格在下方中央背包面板中，原始 1920x1080 截图坐标约为：
#   左上格 (752, 407)，格距 46px，3 行 x 7 列。
# 运行时仍保留 item_0_0...item_3_4 这 20 个类型级占位名，按可见背包格
# row-major 取前 20 个格内 28x28 主体，补透明边距到 32x32。
inventory_origin_x = int(752 * (w / 1920))
inventory_origin_y = int(407 * (h / 1080))
inventory_pitch_x = int(46 * (w / 1920))
inventory_pitch_y = int(46 * (h / 1080))
inner_offset_x = int(8 * (w / 1920))
inner_offset_y = int(8 * (h / 1080))
inner_size = int(28 * (w / 1920))
source_cols = 7
cols = 5
rows = 4

item_count = 0
for row in range(rows):
    for col in range(cols):
        source_index = row * cols + col
        source_row = source_index // source_cols
        source_col = source_index % source_cols
        x1 = inventory_origin_x + source_col * inventory_pitch_x + inner_offset_x
        y1 = inventory_origin_y + source_row * inventory_pitch_y + inner_offset_y
        x2 = x1 + inner_size
        y2 = y1 + inner_size

        save_item_icon_from_inventory(ss02, f"item_{row}_{col}", (x1, y1, x2, y2))
        item_count += 1

print(f"  共提取 {item_count} 个物品图标")

# ============================================================
# 4. UI 元素 (ss_06) — 技能/效果类别图标
# ============================================================
print("\n=== 从 ss_06.jpg 提取技能/效果类别图标 ===")
ss06 = Image.open(os.path.join(STEAM_DIR, "ss_06.jpg"))
w, h = ss06.size
print(f"  图片尺寸: {w}x{h}")

# 当前截图集中没有 36 个主动技能的逐技能图标页。ss_06 的 Rune Tree
# 节点图标来自原版界面且覆盖攻击、元素、召唤、治疗/防护等视觉类别，
# 因此先作为角色技能列表的类别图标；不要把它们声明成完整逐技能图标库。
skill_crops = {
    "skill_0_0": (1017, 367, 1057, 407),  # physical impact
    "skill_0_1": (1087, 507, 1127, 547),  # projectile slash
    "skill_0_2": (1227, 367, 1267, 407),  # fire/range damage
    "skill_0_3": (947, 297, 987, 337),    # blessing/heal
    "skill_1_0": (1087, 227, 1127, 267),  # summon/trap utility
    "skill_1_1": (1017, 297, 1057, 337),  # ranged projectile
    "skill_1_2": (947, 437, 987, 477),    # blade/burst
    "skill_1_3": (1227, 507, 1267, 547),  # rapid attack
    "skill_2_0": (737, 507, 777, 547),    # cold field
    "skill_2_1": (807, 507, 847, 547),    # cold orb
    "skill_2_2": (947, 507, 987, 547),    # lightning
    "skill_2_3": (1017, 507, 1057, 547),  # guard/shield
}

for name, box in skill_crops.items():
    save_crop(ss06, name, box)

print(f"  共提取 {len(skill_crops)} 个技能/效果类别图标")

# ============================================================
# 4.1 UI 元素 (ss_06) — 当前建模符文节点图标
# ============================================================
print("\n=== 从 ss_06.jpg 提取符文树节点图标 ===")

# 这些图标只覆盖当前代码已建模的 RuneTreeNode 子集。完整 197 节点
# 树、精确节点图标和坐标仍需更完整的原版资源或逐节点截图。
rune_crops = {
    "rune_party_slot": (877, 367, 917, 407),
    "rune_active_skill_slot": (877, 647, 917, 687),
    "rune_inventory_capacity": (1017, 367, 1057, 407),
    "rune_offline_rewards": (1297, 507, 1337, 547),
    "rune_offline_gold": (1017, 647, 1057, 687),
    "rune_offline_xp": (737, 507, 777, 547),
}

for name, box in rune_crops.items():
    save_crop(ss06, name, box)

print(f"  共提取 {len(rune_crops)} 个符文树节点图标")

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
