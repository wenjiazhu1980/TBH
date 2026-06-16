#!/usr/bin/env bash
set -euo pipefail

sprite_dir="${SPRITE_DIR:-Sources/Resources/Extracted}"
packaged_sprite_dir="${PACKAGED_SPRITE_DIR:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle/Extracted}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sprite_dir" <<'PY'
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for hero sprite analysis: {exc}", file=sys.stderr)
    sys.exit(2)

sprite_dir = Path(sys.argv[1])
if not sprite_dir.is_dir():
    print(f"sprite directory does not exist: {sprite_dir}", file=sys.stderr)
    sys.exit(2)

hero_names = [
    "battle_hero_hunter",
    "battle_hero_knight",
    "battle_hero_priest",
    "battle_hero_ranger",
    "battle_hero_slayer",
    "battle_hero_sorcerer",
]
hero_keys = [
    "hunter",
    "knight",
    "priest",
    "ranger",
    "slayer",
    "sorcerer",
]
legacy_reference_names = [
    "battle_knight",
    "battle_priest",
    "battle_ranger",
    "battle_sorcerer",
]


def load_rgba(name):
    path = sprite_dir / f"{name}.png"
    if not path.is_file():
        print(f"missing sprite: {path}", file=sys.stderr)
        sys.exit(1)
    return path, Image.open(path).convert("RGBA")


def hp_bar_green(pixel):
    red, green, blue, alpha = pixel
    return (
        alpha > 24
        and green >= 150
        and red <= 120
        and blue <= 120
        and green > red * 1.3
        and green > blue * 1.3
    )


def portrait_frame_white(pixel):
    red, green, blue, alpha = pixel
    return alpha > 24 and red >= 230 and green >= 230 and blue >= 230


def official_hero_portrait_background(pixel):
    red, green, blue, alpha = pixel
    if alpha == 0:
        return True

    brightness = (red + green + blue) / 3
    spread = max(red, green, blue) - min(red, green, blue)

    if red >= 230 and green >= 230 and blue >= 230:
        return True

    if spread <= 28 and brightness <= 42:
        return True

    return spread <= 24 and 42 < brightness <= 90


def remove_connected_portrait_frame(image):
    """Rebuild the expected battle_hero_* provenance from official_hero_* art."""
    rgba = image.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()
    queue = []
    seen = set()

    def append_if_background(x, y):
        if (x, y) in seen:
            return
        if official_hero_portrait_background(pixels[x, y]):
            seen.add((x, y))
            queue.append((x, y))

    for x in range(width):
        append_if_background(x, 0)
        append_if_background(x, height - 1)

    for y in range(height):
        append_if_background(0, y)
        append_if_background(width - 1, y)

    while queue:
        x, y = queue.pop(0)
        red, green, blue, _ = pixels[x, y]
        pixels[x, y] = (red, green, blue, 0)

        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < width and 0 <= ny < height:
                append_if_background(nx, ny)

    return rgba


def matches_official_source(hero_key, battle_image):
    _, official_image = load_rgba(f"official_hero_{hero_key}")
    expected = remove_connected_portrait_frame(official_image)
    return (
        expected.size == battle_image.size
        and list(expected.getdata()) == list(battle_image.getdata())
    )


def sprite_metrics(image):
    width, height = image.size
    alpha = image.getchannel("A")
    opaque_pixels = sum(1 for value in alpha.getdata() if value > 0)
    opaque_positions = {
        (x, y)
        for y in range(height)
        for x in range(width)
        if image.getpixel((x, y))[3] > 24
    }
    corner_alpha = [
        image.getpixel((0, 0))[3],
        image.getpixel((width - 1, 0))[3],
        image.getpixel((0, height - 1))[3],
        image.getpixel((width - 1, height - 1))[3],
    ]

    transparent_edge_pixels = 0
    edge_pixels = width * 2 + height * 2
    for x in range(width):
        if image.getpixel((x, 0))[3] == 0:
            transparent_edge_pixels += 1
        if image.getpixel((x, height - 1))[3] == 0:
            transparent_edge_pixels += 1
    for y in range(height):
        if image.getpixel((0, y))[3] == 0:
            transparent_edge_pixels += 1
        if image.getpixel((width - 1, y))[3] == 0:
            transparent_edge_pixels += 1

    hp_green_pixels = 0
    longest_hp_green_run = 0
    portrait_white_pixels = 0
    longest_portrait_white_run = 0
    for y in range(height):
        current_hp_green_run = 0
        current_portrait_white_run = 0
        for x in range(width):
            if hp_bar_green(image.getpixel((x, y))):
                hp_green_pixels += 1
                current_hp_green_run += 1
                longest_hp_green_run = max(longest_hp_green_run, current_hp_green_run)
            else:
                current_hp_green_run = 0

            if portrait_frame_white(image.getpixel((x, y))):
                portrait_white_pixels += 1
                current_portrait_white_run += 1
                longest_portrait_white_run = max(
                    longest_portrait_white_run,
                    current_portrait_white_run,
                )
            else:
                current_portrait_white_run = 0

    seen = set()
    largest_component = 0
    for position in list(opaque_positions):
        if position in seen:
            continue

        stack = [position]
        seen.add(position)
        component_size = 0

        while stack:
            x, y = stack.pop()
            component_size += 1
            for neighbor in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if neighbor in opaque_positions and neighbor not in seen:
                    seen.add(neighbor)
                    stack.append(neighbor)

        largest_component = max(largest_component, component_size)

    return {
        "width": width,
        "height": height,
        "opaque_pixels": opaque_pixels,
        "opaque_ratio": opaque_pixels / max(width * height, 1),
        "largest_component_ratio": largest_component / max(opaque_pixels, 1),
        "all_corners_transparent": all(value == 0 for value in corner_alpha),
        "edge_alpha_clear": transparent_edge_pixels == edge_pixels,
        "hp_green_pixels": hp_green_pixels,
        "hp_green_run": longest_hp_green_run,
        "portrait_white_pixels": portrait_white_pixels,
        "portrait_white_run": longest_portrait_white_run,
        "bbox": alpha.getbbox(),
    }


def is_current_sprite_valid(metrics):
    width = metrics["width"]
    height = metrics["height"]
    return (
        18 <= width <= 40
        and 24 <= height <= 48
        and metrics["all_corners_transparent"]
        and metrics["edge_alpha_clear"]
        and metrics["opaque_pixels"] >= 120
        and 0.15 <= metrics["opaque_ratio"] <= 0.75
        and metrics["hp_green_run"] < max(8, width // 3)
        and metrics["portrait_white_run"] < max(8, width // 3)
    )


def has_valid_class_specific_shape(name, metrics):
    if name == "battle_hero_knight":
        return metrics["largest_component_ratio"] >= 0.50
    return True


failures = []

print(f"sprite_dir={sprite_dir}")
print("")
print("current battle hero sprites")
print("name                    size    opaque  ratio   component  edge_clear  source  hp_green  hp_run  white_px  white_run  bbox")
print("----------------------  ------  ------  ------  ---------  ----------  ------  --------  ------  --------  ---------  ----------------")

for hero_key, name in zip(hero_keys, hero_names):
    path, image = load_rgba(name)
    metrics = sprite_metrics(image)
    source_match = matches_official_source(hero_key, image)
    valid = (
        is_current_sprite_valid(metrics)
        and has_valid_class_specific_shape(name, metrics)
        and source_match
    )
    if not valid:
        failures.append(name)
    print(
        f"{path.name:<22}  "
        f"{metrics['width']:>2}x{metrics['height']:<3}  "
        f"{metrics['opaque_pixels']:>6}  "
        f"{metrics['opaque_ratio']:.3f}   "
        f"{metrics['largest_component_ratio']:.3f}      "
        f"{str(metrics['edge_alpha_clear']):<10}  "
        f"{str(source_match):<6}  "
        f"{metrics['hp_green_pixels']:>8}  "
        f"{metrics['hp_green_run']:>6}  "
        f"{metrics['portrait_white_pixels']:>8}  "
        f"{metrics['portrait_white_run']:>9}  "
        f"{metrics['bbox']}"
    )

print("")
print("legacy broad battle crops (reference only)")
print("name                    size      opaque_ratio  alpha_bbox             hp_green  hp_run  white_run  contaminated")
print("----------------------  --------  ------------  ---------------------  --------  ------  ---------  ------------")

for name in legacy_reference_names:
    path = sprite_dir / f"{name}.png"
    if not path.is_file():
        continue
    _, image = load_rgba(name)
    metrics = sprite_metrics(image)
    contaminated = (
        metrics["width"] > 40
        or metrics["height"] > 48
        or not metrics["edge_alpha_clear"]
        or metrics["opaque_ratio"] > 0.90
        or metrics["hp_green_run"] >= max(8, metrics["width"] // 12)
        or metrics["portrait_white_run"] >= max(8, metrics["width"] // 12)
    )
    print(
        f"{path.name:<22}  "
        f"{metrics['width']:>3}x{metrics['height']:<4}  "
        f"{metrics['opaque_ratio']:.3f}         "
        f"{str(metrics['bbox']):<21}  "
        f"{metrics['hp_green_pixels']:>8}  "
        f"{metrics['hp_green_run']:>6}  "
        f"{metrics['portrait_white_run']:>9}  "
        f"{str(contaminated):<12}"
    )

if failures:
    print(
        "invalid current battle hero sprites: " + ", ".join(failures),
        file=sys.stderr,
    )
    sys.exit(1)

print("")
print("local hero sprite audit passed")
PY

if [[ "${AUDIT_LOCAL_HERO_SPRITES_SKIP_PACKAGED:-0}" != "1" &&
      -d "$packaged_sprite_dir" &&
      "$sprite_dir" != "$packaged_sprite_dir" ]]; then
  echo
  echo "packaged_app_hero_sprite_audit"
  echo "-------------------------------"
  SPRITE_DIR="$packaged_sprite_dir" \
    AUDIT_LOCAL_HERO_SPRITES_SKIP_PACKAGED=1 \
    "$0"

  python3 - "$sprite_dir" "$packaged_sprite_dir" <<'PY'
import hashlib
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
packaged_dir = Path(sys.argv[2])

prefixes = ("battle_hero_", "official_hero_")
names = sorted(
    path.name
    for path in source_dir.glob("*.png")
    if path.name.startswith(prefixes)
)

issues = []
for name in names:
    source_path = source_dir / name
    packaged_path = packaged_dir / name
    if not packaged_path.is_file():
        issues.append(f"packaged app missing hero sprite: {name}")
        continue

    if hashlib.sha256(source_path.read_bytes()).hexdigest() != hashlib.sha256(packaged_path.read_bytes()).hexdigest():
        issues.append(f"packaged app hero sprite differs from source: {name}")

extra_packaged = sorted(
    path.name
    for path in packaged_dir.glob("*.png")
    if path.name.startswith(prefixes) and path.name not in names
)
for name in extra_packaged:
    issues.append(f"packaged app has unexpected hero sprite: {name}")

if issues:
    print("packaged app hero sprite payload issues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print(f"packaged_app_hero_sprite_payload_match=checked sprites:{len(names)}")
PY
fi
