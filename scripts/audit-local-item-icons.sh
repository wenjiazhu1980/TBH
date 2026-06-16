#!/usr/bin/env bash
set -euo pipefail

sprite_dir="${SPRITE_DIR:-Sources/Resources/Extracted}"
item_swift="${ITEM_SWIFT:-Sources/Game/Inventory/Item.swift}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"
save_json="${SAVE_JSON:-$HOME/Library/Application Support/TBH/save.json}"
gear_manifest="${GEAR_MANIFEST:-Sources/Resources/Extracted/source_gear_icons.tsv}"
packaged_sprite_dir="${PACKAGED_SPRITE_DIR:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle/Extracted}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sprite_dir" "$item_swift" "$game_art_swift" "$save_json" "$gear_manifest" <<'PY'
import csv
import hashlib
import json
import re
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for item icon analysis: {exc}", file=sys.stderr)
    sys.exit(2)

sprite_dir = Path(sys.argv[1])
item_path = Path(sys.argv[2])
game_art_path = Path(sys.argv[3])
save_path = Path(sys.argv[4])
gear_manifest_path = Path(sys.argv[5])

for path in (sprite_dir, item_path, game_art_path, gear_manifest_path):
    if not path.exists():
        print(f"missing input: {path}", file=sys.stderr)
        sys.exit(2)

item_source = item_path.read_text(encoding="utf-8")
game_art_source = game_art_path.read_text(encoding="utf-8")

enum_match = re.search(
    r"enum\s+EquipmentType[^{]*\{(?P<body>.*?)\n\}",
    item_source,
    re.S,
)
if not enum_match:
    print(f"could not locate EquipmentType enum in {item_path}", file=sys.stderr)
    sys.exit(1)

equipment_type_matches = re.findall(
    r"^\s*case\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\"([^\"]+)\"",
    enum_match.group("body"),
    re.M,
)
equipment_types = [case_name for case_name, _ in equipment_type_matches]
equipment_raw_values = {
    raw_value: case_name
    for case_name, raw_value in equipment_type_matches
}
if len(equipment_types) != 20:
    print(
        f"expected 20 EquipmentType cases, found {len(equipment_types)}",
        file=sys.stderr,
    )
    sys.exit(1)

function_match = re.search(
    r"static\s+func\s+itemIconName\(for\s+equipmentType:\s*EquipmentType\)\s*->\s*String\s*\{(?P<body>.*?)\n\s*\}\n\n\s*static\s+func\s+itemIconName\(for\s+slot:",
    game_art_source,
    re.S,
)
if not function_match:
    print(
        f"could not locate GameArt.itemIconName(for equipmentType:) in {game_art_path}",
        file=sys.stderr,
    )
    sys.exit(1)

mapping = {}
for case_name, icon_name in re.findall(
    r"case\s+\.([A-Za-z_][A-Za-z0-9_]*):\s*return\s+\"(item_\d+_\d+)\"",
    function_match.group("body"),
):
    mapping[case_name] = icon_name

issues = []
expected_source_icons = {
    "item_0_0": ("sword", "https://taskbarhero.org/assets/tbhdb/game/gear/sword/SWORD_300001.png", "7a1b5a8b6e7c5e8ded4325c225a2f01cceaf7d9ceb934f17af6e6148f3dd0277"),
    "item_0_1": ("bow", "https://taskbarhero.org/assets/tbhdb/game/gear/bow/BOW_310001.png", "529ee505887f5bac462c79cef6a92476689b49c3e1d6e850bad35c41c3873d25"),
    "item_0_2": ("staff", "https://taskbarhero.org/assets/tbhdb/game/gear/staff/STAFF_320001.png", "32eed5fdaf8dc8295ed061ca19be8098f08259182be0aac37deddd1c2eaf3563"),
    "item_0_3": ("scepter", "https://taskbarhero.org/assets/tbhdb/game/gear/scepter/SCEPTER_330001.png", "fc02a28cd0173aac057c0e7a14b360ab66542144aef3e23f51ac14b41a044b61"),
    "item_0_4": ("crossbow", "https://taskbarhero.org/assets/tbhdb/game/gear/crossbow/CROSSBOW_340001.png", "144b96be849d11d7467efbef1fb71d6ca3cd8e2863b9ddacf143e2b03825400f"),
    "item_1_0": ("axe", "https://taskbarhero.org/assets/tbhdb/game/gear/axe/AXE_350001.png", "c9c73d20d93b27e3dc9047022ea8698c4f1b7fd0b558d335f55500aab3cc4812"),
    "item_1_1": ("shield", "https://taskbarhero.org/assets/tbhdb/game/gear/shield/SHIELD_400001.png", "4d8f265977397d2a342f96fe4ab7f4a9af0c1744195fb8ad5d9c82c88d36188b"),
    "item_1_2": ("arrow", "https://taskbarhero.org/assets/tbhdb/game/gear/arrow/ARROW_410001.png", "29cead4e9a32c87a990c41afab59266c30ca0800c876563795e0c03e54976a09"),
    "item_1_3": ("orb", "https://taskbarhero.org/assets/tbhdb/game/gear/orb/ORB_420001.png", "f724849ae568114e49007e8e571df80a98ab238e493e6cd4a2d2b61a4f9465fb"),
    "item_1_4": ("tome", "https://taskbarhero.org/assets/tbhdb/game/gear/tome/TOME_430001.png", "8f26b0c94010077bddca41513132ae6f1a90309988b081ec45ee917e7b66066a"),
    "item_2_0": ("bolt", "https://taskbarhero.org/assets/tbhdb/game/gear/bolt/BOLT_440001.png", "8208c500c99ac5ab3e4e8e7a4204625c08135e2bcfc9fe766b9492f97b0c4ffd"),
    "item_2_1": ("hatchet", "https://taskbarhero.org/assets/tbhdb/game/gear/hatchet/HATCHET_450001.png", "0d58b969bfa6a3e1c40072d0c7708706f4b1863afa233497772553e71249be43"),
    "item_2_2": ("helmet", "https://taskbarhero.org/assets/tbhdb/game/gear/helmet/HELMET_500001.png", "5ee6e1b5f1126fd18989080790ec49c74b80ff54db80d62ba0d97120e638f3ad"),
    "item_2_3": ("armor", "https://taskbarhero.org/assets/tbhdb/game/gear/armor/ARMOR_510001.png", "67a6df4183ac72579b9f7b05bc267cc5797713955551b8d5d381d9351be68872"),
    "item_2_4": ("gloves", "https://taskbarhero.org/assets/tbhdb/game/gear/gloves/GLOVES_520001.png", "5d67b75ee2914f356da9efe378d3963672e0d1a8de61c81c0b7b52f68cde8637"),
    "item_3_0": ("boots", "https://taskbarhero.org/assets/tbhdb/game/gear/boots/BOOTS_530001.png", "e076820b41801df8d5288de35ee1169ca28bb3372bb6e89fcf6259e633688e93"),
    "item_3_1": ("amulet", "https://taskbarhero.org/assets/tbhdb/game/gear/amulet/AMULET_600001.png", "7854e39a1a0c7a6aa615fbb5e16c32d0cfd839e17f6a0d3742bfc4d5c5bd8479"),
    "item_3_2": ("earring", "https://taskbarhero.org/assets/tbhdb/game/gear/earing/EARING_610001.png", "47d46e89fcb2058b1c1031e1d11f408fa887ed4e784950f9ee3f9d5dc70d95f4"),
    "item_3_3": ("ring", "https://taskbarhero.org/assets/tbhdb/game/gear/ring/RING_620001.png", "8440670093a75a36c80dbed2a70a5589beb2c00d08600d152bcbc9820b629cd4"),
    "item_3_4": ("bracer", "https://taskbarhero.org/assets/tbhdb/game/gear/bracer/BRACER_630001.png", "1ccbe94c1837a735a6e9b3e37a556303ae108be60c69d837692a059125248d03"),
}

expected_icon_names = {f"item_{row}_{col}" for row in range(4) for col in range(5)}
if set(expected_source_icons) != expected_icon_names:
    issues.append("expected source icon table must cover item_0_0 through item_3_4 exactly")

source_gear_tsv_match = re.search(
    r'private\s+static\s+let\s+sourceGearTypeTSV\s*=\s*"""\n(?P<body>.*?)\n\s*"""',
    item_source,
    re.S,
)
if not source_gear_tsv_match:
    print(f"could not locate sourceGearTypeTSV in {item_path}", file=sys.stderr)
    sys.exit(1)

expected_source_gear_icons = {}
for line in source_gear_tsv_match.group("body").splitlines():
    columns = line.split("\t")
    if len(columns) != 6:
        issues.append(f"malformed sourceGearTypeTSV line: {line}")
        continue
    slug, source_title, _, _, _, progressions = columns
    equipment_type = equipment_raw_values.get(source_title)
    if source_title == "Earing":
        equipment_type = "earring"
    if equipment_type is None:
        issues.append(f"unknown source gear type in TSV: {source_title}")
        continue
    for progression in progressions.split("|"):
        parts = progression.split(":", 2)
        if len(parts) != 3:
            issues.append(f"malformed source gear progression: {progression}")
            continue
        level_text, source_id, name = parts
        try:
            item_level = int(level_text)
        except ValueError:
            issues.append(f"invalid source gear level in progression: {progression}")
            continue
        icon_name = f"source_gear_{source_id}"
        expected_source_gear_icons[icon_name] = {
            "slug": slug,
            "type": source_title,
            "equipment_type": equipment_type,
            "itemLevel": item_level,
            "sourceID": source_id,
            "name": name,
        }

if len(expected_source_gear_icons) != 396:
    issues.append(f"expected 396 source gear icon contracts, found {len(expected_source_gear_icons)}")

source_gear_manifest_rows = {}
with gear_manifest_path.open(encoding="utf-8", newline="") as manifest_file:
    reader = csv.DictReader(manifest_file, delimiter="\t")
    expected_fields = [
        "iconName",
        "slug",
        "type",
        "itemLevel",
        "sourceID",
        "name",
        "sourceURL",
        "sha256",
        "bytes",
    ]
    if reader.fieldnames != expected_fields:
        issues.append(f"source gear manifest header mismatch: {reader.fieldnames}")
    for row in reader:
        source_gear_manifest_rows[row.get("iconName", "")] = row

if set(source_gear_manifest_rows) != set(expected_source_gear_icons):
    missing = sorted(set(expected_source_gear_icons) - set(source_gear_manifest_rows))
    extra = sorted(set(source_gear_manifest_rows) - set(expected_source_gear_icons))
    if missing:
        issues.append(f"source gear manifest missing icons: {','.join(missing[:8])}")
    if extra:
        issues.append(f"source gear manifest has unexpected icons: {','.join(extra[:8])}")

source_gear_by_equipment_type = {}
for icon_name, contract in expected_source_gear_icons.items():
    source_gear_by_equipment_type.setdefault(contract["equipment_type"], []).append(
        (contract["itemLevel"], icon_name)
    )
for equipment_type, entries in source_gear_by_equipment_type.items():
    entries.sort(key=lambda entry: entry[0])

def source_gear_icon_for(equipment_type, item_level):
    entries = source_gear_by_equipment_type.get(equipment_type, [])
    if not entries:
        return None
    clamped_level = max(1, item_level)
    selected = entries[0]
    for entry in entries:
        if entry[0] <= clamped_level:
            selected = entry
        else:
            break
    return selected[1]
for equipment_type in equipment_types:
    if equipment_type not in mapping:
        issues.append(f"missing icon mapping for EquipmentType.{equipment_type}")

unknown_mappings = sorted(set(mapping).difference(equipment_types))
for equipment_type in unknown_mappings:
    issues.append(f"mapping references unknown EquipmentType.{equipment_type}")

mapped_icons = [mapping[equipment_type] for equipment_type in equipment_types if equipment_type in mapping]
if len(set(mapped_icons)) != len(equipment_types):
    duplicates = {}
    for equipment_type, icon_name in mapping.items():
        duplicates.setdefault(icon_name, []).append(equipment_type)
    repeated = [
        f"{icon_name}:{'/'.join(sorted(types))}"
        for icon_name, types in duplicates.items()
        if len(types) > 1
    ]
    issues.append("equipment type icons must be one-to-one, duplicates=" + ",".join(repeated))

resource_icons = sorted(path.stem for path in sprite_dir.glob("item_*.png"))
if len(resource_icons) != 20:
    issues.append(f"expected 20 item_*.png resources, found {len(resource_icons)}")

missing_resources = sorted(set(mapped_icons).difference(resource_icons))
extra_resources = sorted(set(resource_icons).difference(mapped_icons))
for icon_name in missing_resources:
    issues.append(f"mapped icon resource is missing: {icon_name}.png")
for icon_name in extra_resources:
    issues.append(f"unmapped item icon resource exists: {icon_name}.png")

def alpha_at(image, x, y):
    return image.getpixel((x, y))[3]

def connected_alpha_components(image, alpha_threshold=25):
    width, height = image.size
    pixels = image.load()
    visited = set()
    components = []

    for y in range(height):
        for x in range(width):
            if (x, y) in visited or pixels[x, y][3] <= alpha_threshold:
                continue

            stack = [(x, y)]
            visited.add((x, y))
            component_size = 0

            while stack:
                current_x, current_y = stack.pop()
                component_size += 1

                for next_y in range(max(0, current_y - 1), min(height, current_y + 2)):
                    for next_x in range(max(0, current_x - 1), min(width, current_x + 2)):
                        if (next_x, next_y) in visited:
                            continue
                        if pixels[next_x, next_y][3] <= alpha_threshold:
                            continue
                        visited.add((next_x, next_y))
                        stack.append((next_x, next_y))

            components.append(component_size)

    components.sort(reverse=True)
    return components

rows = []
source_gear_rows = []
fallback_rows = []
payload_hashes = {}
source_gear_payload_hashes = {}

for equipment_type in equipment_types:
    icon_name = mapping.get(equipment_type)
    if not icon_name:
        continue

    path = sprite_dir / f"{icon_name}.png"
    if not path.is_file():
        continue

    try:
        image = Image.open(path).convert("RGBA")
    except Exception as exc:
        issues.append(f"{icon_name}.png could not be decoded: {exc}")
        continue

    expected_source = expected_source_icons.get(icon_name)
    if expected_source is None:
        issues.append(f"{icon_name}.png has no pinned source asset contract")
        continue
    expected_equipment_type, source_url, expected_digest = expected_source
    if expected_equipment_type != equipment_type:
        issues.append(
            f"{icon_name}.png is pinned to {expected_equipment_type}, but GameArt maps it to {equipment_type}"
        )

    payload = path.read_bytes()
    file_digest = hashlib.sha256(payload).hexdigest()
    if file_digest != expected_digest:
        issues.append(
            f"{icon_name}.png does not match pinned source asset {source_url}; expected sha256 {expected_digest}, got {file_digest}"
        )

    width, height = image.size
    if (width, height) != (16, 16):
        issues.append(f"{icon_name}.png must keep source size 16x16, got {width}x{height}")
        continue

    corners = [
        alpha_at(image, 0, 0),
        alpha_at(image, width - 1, 0),
        alpha_at(image, 0, height - 1),
        alpha_at(image, width - 1, height - 1),
    ]
    opaque_pixels = sum(1 for pixel in image.getdata() if pixel[3] > 25)
    opaque_ratio = opaque_pixels / (width * height)
    if not (0.10 <= opaque_ratio <= 0.80):
        issues.append(
            f"{icon_name}.png has suspicious visible coverage {opaque_ratio:.3f}; likely blank or not the pinned source gear icon"
        )

    components = connected_alpha_components(image)
    largest_component_share = (components[0] / opaque_pixels) if opaque_pixels else 0.0
    if len(components) != 1 and largest_component_share < 0.92:
        issues.append(
            f"{icon_name}.png has {len(components)} visible fragments with largest share {largest_component_share:.3f}; likely a cropped inventory tile"
        )

    bbox = image.getbbox()
    if bbox is None:
        issues.append(f"{icon_name}.png is fully transparent")
        bbox_text = "none"
    else:
        bbox_text = f"{bbox[0]},{bbox[1]},{bbox[2]},{bbox[3]}"

    digest = hashlib.sha256(image.tobytes()).hexdigest()
    payload_hashes.setdefault(digest, []).append(icon_name)

    rows.append(
        (
            equipment_type,
            icon_name,
            source_url.rsplit("/", 1)[-1],
            f"{width}x{height}",
            opaque_pixels,
            opaque_ratio,
            bbox_text,
            len(components),
            largest_component_share,
            corners,
        )
    )

for icon_name, manifest_row in sorted(source_gear_manifest_rows.items()):
    expected = expected_source_gear_icons.get(icon_name)
    if expected is None:
        continue

    for field in ("slug", "type", "sourceID", "name"):
        if manifest_row.get(field) != str(expected[field]):
            issues.append(
                f"{icon_name} manifest {field} mismatch: expected {expected[field]!r}, got {manifest_row.get(field)!r}"
            )
    if manifest_row.get("itemLevel") != str(expected["itemLevel"]):
        issues.append(
            f"{icon_name} manifest itemLevel mismatch: expected {expected['itemLevel']}, got {manifest_row.get('itemLevel')!r}"
        )

    source_url = manifest_row.get("sourceURL", "")
    if not source_url.startswith("https://taskbarhero.org/assets/tbhdb/game/gear/"):
        issues.append(f"{icon_name} has unexpected source URL: {source_url}")

    path = sprite_dir / f"{icon_name}.png"
    if not path.is_file():
        issues.append(f"source gear icon resource is missing: {icon_name}.png")
        continue

    payload = path.read_bytes()
    file_digest = hashlib.sha256(payload).hexdigest()
    expected_digest = manifest_row.get("sha256", "")
    if file_digest != expected_digest:
        issues.append(
            f"{icon_name}.png does not match pinned source asset {source_url}; expected sha256 {expected_digest}, got {file_digest}"
        )
    if manifest_row.get("bytes") != str(len(payload)):
        issues.append(
            f"{icon_name}.png byte count mismatch: manifest {manifest_row.get('bytes')}, actual {len(payload)}"
        )

    try:
        image = Image.open(path).convert("RGBA")
    except Exception as exc:
        issues.append(f"{icon_name}.png could not be decoded: {exc}")
        continue

    width, height = image.size
    if (width, height) != (16, 16):
        issues.append(f"{icon_name}.png must keep source size 16x16, got {width}x{height}")
        continue

    opaque_pixels = sum(1 for pixel in image.getdata() if pixel[3] > 25)
    opaque_ratio = opaque_pixels / (width * height)
    if not (0.10 <= opaque_ratio <= 0.90):
        issues.append(
            f"{icon_name}.png has suspicious visible coverage {opaque_ratio:.3f}; likely blank or not the pinned source gear progression icon"
        )

    components = connected_alpha_components(image)
    largest_component_share = (components[0] / opaque_pixels) if opaque_pixels else 0.0
    if len(components) != 1 and largest_component_share < 0.85:
        issues.append(
            f"{icon_name}.png has {len(components)} visible fragments with largest share {largest_component_share:.3f}; likely not a single source gear icon"
        )

    source_gear_payload_hashes.setdefault(file_digest, []).append(icon_name)
    source_gear_rows.append(
        (
            icon_name,
            manifest_row.get("slug", ""),
            manifest_row.get("sourceID", ""),
            manifest_row.get("itemLevel", ""),
            manifest_row.get("sourceURL", "").rsplit("/", 1)[-1],
            f"{width}x{height}",
            opaque_pixels,
            opaque_ratio,
        )
    )

resource_source_gear_icons = sorted(path.stem for path in sprite_dir.glob("source_gear_*.png"))
missing_source_gear_resources = sorted(set(source_gear_manifest_rows).difference(resource_source_gear_icons))
extra_source_gear_resources = sorted(set(resource_source_gear_icons).difference(source_gear_manifest_rows))
for icon_name in missing_source_gear_resources[:12]:
    issues.append(f"manifest source gear icon is missing: {icon_name}.png")
if len(missing_source_gear_resources) > 12:
    issues.append(f"manifest source gear icons missing: +{len(missing_source_gear_resources) - 12} more")
for icon_name in extra_source_gear_resources[:12]:
    issues.append(f"unmapped source gear icon resource exists: {icon_name}.png")
if len(extra_source_gear_resources) > 12:
    issues.append(f"unmapped source gear icon resources exist: +{len(extra_source_gear_resources) - 12} more")

for digest, icon_names in source_gear_payload_hashes.items():
    if len(icon_names) > 1:
        issues.append("duplicate source gear icon file payload: " + ",".join(sorted(icon_names)[:8]))

clean_item_like_specs = {
    "official_item_weapon": (16, 16),
    "official_item_armor": (16, 16),
    "official_item_helmet": (16, 16),
    "official_item_boots": (16, 16),
    "official_item_accessory": (16, 16),
    "official_item_material": (16, 16),
    "official_item_gem": (16, 16),
    "official_item_box": (32, 32),
    "source_stage_chest_910011": (64, 64),
    "source_stage_chest_920011": (64, 64),
    "source_stage_chest_930011": (64, 64),
}

for icon_name, expected_size in clean_item_like_specs.items():
    path = sprite_dir / f"{icon_name}.png"
    if not path.is_file():
        issues.append(f"fallback item-like resource is missing: {icon_name}.png")
        continue

    try:
        image = Image.open(path).convert("RGBA")
    except Exception as exc:
        issues.append(f"{icon_name}.png could not be decoded: {exc}")
        continue

    width, height = image.size
    if (width, height) != expected_size:
        issues.append(
            f"{icon_name}.png must be {expected_size[0]}x{expected_size[1]}, got {width}x{height}"
        )
        continue

    corners = [
        alpha_at(image, 0, 0),
        alpha_at(image, width - 1, 0),
        alpha_at(image, 0, height - 1),
        alpha_at(image, width - 1, height - 1),
    ]
    if any(alpha > 0 for alpha in corners):
        issues.append(f"{icon_name}.png has opaque corner pixels: {corners}")

    pixels = list(image.getdata())
    opaque_pixels = sum(1 for pixel in pixels if pixel[3] > 25)
    opaque_ratio = opaque_pixels / (width * height)
    if not (0.04 <= opaque_ratio <= 0.70):
        issues.append(
            f"{icon_name}.png has suspicious visible coverage {opaque_ratio:.3f}; likely blank or a cropped UI tile"
        )

    edge_pixels = 0
    for x in range(width):
        if alpha_at(image, x, 0) > 25:
            edge_pixels += 1
        if alpha_at(image, x, height - 1) > 25:
            edge_pixels += 1
    for y in range(1, height - 1):
        if alpha_at(image, 0, y) > 25:
            edge_pixels += 1
        if alpha_at(image, width - 1, y) > 25:
            edge_pixels += 1
    if edge_pixels:
        issues.append(
            f"{icon_name}.png has {edge_pixels} visible pixels touching the canvas edge; likely includes grid lines or adjacent item fragments"
        )

    fallback_rows.append(
        (
            icon_name,
            f"{width}x{height}",
            opaque_pixels,
            opaque_ratio,
            edge_pixels,
            corners,
        )
    )

for digest, icon_names in payload_hashes.items():
    if len(icon_names) > 1:
        issues.append("duplicate item icon pixel payload: " + ",".join(sorted(icon_names)))

slot_defaults = {
    "武器": "Sword",
    "副手": "Shield",
    "头盔": "Helmet",
    "护甲": "Armor",
    "手套": "Gloves",
    "靴子": "Boots",
    "护符": "Amulet",
    "耳环": "Earring",
    "戒指": "Ring",
    "饰品": "Ring",
    "护腕": "Bracer",
}

save_icon_rows = []
save_icon_legacy_defaults = 0

def collect_saved_items(data):
    saved = []
    inventory_items = data.get("inventory", {}).get("items", [])
    if isinstance(inventory_items, list):
        for index, item in enumerate(inventory_items):
            if isinstance(item, dict):
                saved.append((f"inventory[{index}]", item))

    equipment = data.get("hero", {}).get("equipment", {})
    if isinstance(equipment, dict):
        for slot_name, item in sorted(equipment.items()):
            if isinstance(item, dict):
                saved.append((f"hero.equipment.{slot_name}", item))

    return saved

if save_path.is_file():
    try:
        save_data = json.loads(save_path.read_text(encoding="utf-8"))
        saved_items = collect_saved_items(save_data)
    except Exception as exc:
        issues.append(f"could not read save item icon audit input {save_path}: {exc}")
        saved_items = []

    for location, item in saved_items:
        slot = item.get("slot")
        equipment_type_raw = item.get("equipmentType")
        if equipment_type_raw is None and slot is None:
            continue

        if equipment_type_raw is None:
            equipment_type_raw = slot_defaults.get(slot)
            save_icon_legacy_defaults += 1

        case_name = equipment_raw_values.get(equipment_type_raw)
        if case_name is None:
            issues.append(
                f"{location} has unknown equipmentType={equipment_type_raw!r} slot={slot!r}"
            )
            continue

        try:
            item_level = int(item.get("itemLevel", 1))
        except Exception:
            item_level = 1

        icon_name = source_gear_icon_for(case_name, item_level) or mapping.get(case_name)
        if icon_name is None:
            issues.append(
                f"{location} equipmentType={equipment_type_raw} has no GameArt item icon mapping"
            )
            continue

        if not icon_name.startswith(("item_", "source_gear_")):
            issues.append(
                f"{location} equipmentType={equipment_type_raw} resolved to non-source gear icon {icon_name}"
            )

        if not (sprite_dir / f"{icon_name}.png").is_file():
            issues.append(
                f"{location} equipmentType={equipment_type_raw} resolved to missing icon {icon_name}.png"
            )

        save_icon_rows.append(
            (
                location,
                item.get("name", ""),
                slot,
                equipment_type_raw,
                icon_name,
            )
        )

print(f"sprite_dir={sprite_dir}")
print(f"item_source={item_path}")
print(f"game_art_source={game_art_path}")
print(f"save_json={save_path if save_path.is_file() else 'not found'}")
print()
print("equipment_type  icon      source_file           size   opaque  ratio   alpha_bbox     comps  largest  corners")
print("--------------  --------  --------------------  -----  ------  ------  -------------  -----  -------  -----------")
for equipment_type, icon_name, source_file, size, opaque_pixels, opaque_ratio, bbox_text, component_count, largest_share, corners in rows:
    print(
        f"{equipment_type:<14}  {icon_name:<8}  {source_file:<20}  {size:<5}  {opaque_pixels:>6}  {opaque_ratio:>6.3f}  {bbox_text:<13}  {component_count:>5}  {largest_share:>7.3f}  {corners}"
    )

print()
print("source_gear_progression_icon_audit")
print("----------------------------------")
if source_gear_rows:
    source_gear_ratios = [row[7] for row in source_gear_rows]
    source_gear_slugs = sorted({row[1] for row in source_gear_rows})
    print(
        "status=checked "
        f"icons:{len(source_gear_rows)} "
        f"slugs:{len(source_gear_slugs)} "
        f"visible_ratio:{min(source_gear_ratios):.3f}-{max(source_gear_ratios):.3f} "
        f"sample:{';'.join(f'{row[2]}->{row[4]}' for row in source_gear_rows[:5])}"
    )
else:
    print("status=empty")

print()
print("fallback_item_like_icon  size   opaque  ratio   edge  corners")
print("-----------------------  -----  ------  ------  ----  -----------")
for icon_name, size, opaque_pixels, opaque_ratio, edge_pixels, corners in fallback_rows:
    print(
        f"{icon_name:<23}  {size:<5}  {opaque_pixels:>6}  {opaque_ratio:>6.3f}  {edge_pixels:>4}  {corners}"
    )

if rows:
    ratios = [row[5] for row in rows]
    print()
    print(
        "summary="
        f"equipment_types:{len(equipment_types)}, "
        f"mapped_icons:{len(set(mapped_icons))}, "
        f"resources:{len(resource_icons)}, "
        f"pinned_source_icons:{len(expected_source_icons)}, "
        f"source_gear_icons:{len(source_gear_rows)}, "
        f"visible_ratio:{min(ratios):.3f}-{max(ratios):.3f}, "
        f"fallback_item_like:{len(fallback_rows)}"
    )

print()
print("save_item_icon_audit")
print("--------------------")
if not save_path.is_file():
    print("status=skipped reason=save_json_not_found")
else:
    unique_save_icons = sorted({row[4] for row in save_icon_rows if row[4]})
    samples = "; ".join(
        f"{location}:{name or '-'}->{icon_name}"
        for location, name, _, _, icon_name in save_icon_rows[:8]
    )
    if len(save_icon_rows) > 8:
        samples += f"; +{len(save_icon_rows) - 8} more"
    print(
        "status=checked "
        f"items:{len(save_icon_rows)} "
        f"unique_icons:{len(unique_save_icons)} "
        f"legacy_defaults:{save_icon_legacy_defaults} "
        f"icons:{','.join(unique_save_icons)}"
    )
    if samples:
        print(f"samples={samples}")

if issues:
    print()
    for issue in issues:
        print(f"item_icon_issue={issue}", file=sys.stderr)
    sys.exit(1)

print("local item icon audit passed")
PY

if [[ "${AUDIT_LOCAL_ITEM_ICONS_SKIP_PACKAGED:-0}" != "1" &&
      -d "$packaged_sprite_dir" &&
      "$sprite_dir" != "$packaged_sprite_dir" ]]; then
  echo
  echo "packaged_app_item_icon_audit"
  echo "----------------------------"
  SPRITE_DIR="$packaged_sprite_dir" \
    ITEM_SWIFT="$item_swift" \
    GAME_ART_SWIFT="$game_art_swift" \
    SAVE_JSON="$save_json" \
    GEAR_MANIFEST="$gear_manifest" \
    AUDIT_LOCAL_ITEM_ICONS_SKIP_PACKAGED=1 \
    "$0"

  python3 - "$sprite_dir" "$packaged_sprite_dir" <<'PY'
import hashlib
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
packaged_dir = Path(sys.argv[2])

names = sorted(
    path.name
    for path in source_dir.glob("*.png")
    if path.name.startswith(("item_", "official_item_", "source_stage_chest_", "source_gear_"))
)

issues = []
for name in names:
    source_path = source_dir / name
    packaged_path = packaged_dir / name
    if not packaged_path.is_file():
        issues.append(f"packaged app missing icon resource: {name}")
        continue

    source_digest = hashlib.sha256(source_path.read_bytes()).hexdigest()
    packaged_digest = hashlib.sha256(packaged_path.read_bytes()).hexdigest()
    if source_digest != packaged_digest:
        issues.append(f"packaged app icon differs from source resource: {name}")

extra_packaged = sorted(
    path.name
    for path in packaged_dir.glob("*.png")
    if path.name.startswith(("item_", "official_item_", "source_stage_chest_", "source_gear_")) and path.name not in names
)
for name in extra_packaged:
    issues.append(f"packaged app has unexpected item-like icon resource: {name}")

if issues:
    print("packaged app icon payload issues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print(f"packaged_app_payload_match=checked icons:{len(names)}")
PY
fi
