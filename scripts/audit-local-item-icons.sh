#!/usr/bin/env bash
set -euo pipefail

sprite_dir="${SPRITE_DIR:-Sources/Resources/Extracted}"
item_swift="${ITEM_SWIFT:-Sources/Game/Inventory/Item.swift}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sprite_dir" "$item_swift" "$game_art_swift" <<'PY'
import hashlib
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

for path in (sprite_dir, item_path, game_art_path):
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

equipment_types = re.findall(
    r"^\s*case\s+([A-Za-z_][A-Za-z0-9_]*)\s*=",
    enum_match.group("body"),
    re.M,
)
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

rows = []
payload_hashes = {}

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

    width, height = image.size
    if (width, height) != (32, 32):
        issues.append(f"{icon_name}.png must be 32x32, got {width}x{height}")
        continue

    corners = [
        alpha_at(image, 0, 0),
        alpha_at(image, width - 1, 0),
        alpha_at(image, 0, height - 1),
        alpha_at(image, width - 1, height - 1),
    ]
    if any(alpha > 0 for alpha in corners):
        issues.append(f"{icon_name}.png has opaque corner pixels: {corners}")

    opaque_pixels = sum(1 for pixel in image.getdata() if pixel[3] > 25)
    opaque_ratio = opaque_pixels / (width * height)
    if not (0.08 <= opaque_ratio <= 0.70):
        issues.append(
            f"{icon_name}.png has suspicious visible coverage {opaque_ratio:.3f}; likely blank or a cropped UI tile"
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
            f"{width}x{height}",
            opaque_pixels,
            opaque_ratio,
            bbox_text,
            corners,
        )
    )

for digest, icon_names in payload_hashes.items():
    if len(icon_names) > 1:
        issues.append("duplicate item icon pixel payload: " + ",".join(sorted(icon_names)))

print(f"sprite_dir={sprite_dir}")
print(f"item_source={item_path}")
print(f"game_art_source={game_art_path}")
print()
print("equipment_type  icon      size   opaque  ratio   alpha_bbox     corners")
print("--------------  --------  -----  ------  ------  -------------  -----------")
for equipment_type, icon_name, size, opaque_pixels, opaque_ratio, bbox_text, corners in rows:
    print(
        f"{equipment_type:<14}  {icon_name:<8}  {size:<5}  {opaque_pixels:>6}  {opaque_ratio:>6.3f}  {bbox_text:<13}  {corners}"
    )

if rows:
    ratios = [row[4] for row in rows]
    print()
    print(
        "summary="
        f"equipment_types:{len(equipment_types)}, "
        f"mapped_icons:{len(set(mapped_icons))}, "
        f"resources:{len(resource_icons)}, "
        f"visible_ratio:{min(ratios):.3f}-{max(ratios):.3f}"
    )

if issues:
    print()
    for issue in issues:
        print(f"item_icon_issue={issue}", file=sys.stderr)
    sys.exit(1)

print("local item icon audit passed")
PY
