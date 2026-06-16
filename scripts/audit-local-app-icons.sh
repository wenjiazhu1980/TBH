#!/usr/bin/env bash
set -euo pipefail

sprite_dir="${SPRITE_DIR:-Sources/Resources/Extracted}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"
menu_bar_icon_swift="${MENU_BAR_ICON_SWIFT:-Sources/UI/MenuBar/MenuBarIcon.swift}"
package_script="${PACKAGE_SCRIPT:-scripts/package-app.sh}"
packaged_sprite_dir="${PACKAGED_SPRITE_DIR:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle/Extracted}"
packaged_icon_file="${PACKAGED_ICON_FILE:-dist/TBH.app/Contents/Resources/TBH.icns}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sprite_dir" "$game_art_swift" "$menu_bar_icon_swift" "$package_script" <<'PY'
import re
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for app icon analysis: {exc}", file=sys.stderr)
    sys.exit(2)

sprite_dir = Path(sys.argv[1])
game_art_path = Path(sys.argv[2])
menu_bar_icon_path = Path(sys.argv[3])
package_script_path = Path(sys.argv[4])

for path in (sprite_dir, game_art_path, menu_bar_icon_path, package_script_path):
    if not path.exists():
        print(f"missing input: {path}", file=sys.stderr)
        sys.exit(2)

game_art_source = game_art_path.read_text(encoding="utf-8")
menu_bar_icon_source = menu_bar_icon_path.read_text(encoding="utf-8")
package_script_source = package_script_path.read_text(encoding="utf-8")

issues = []

if 'static let appIconName = "app_icon"' not in game_art_source:
    issues.append("GameArt.appIconName must point to app_icon")
if 'ICON_FILE="TBH.icns"' not in package_script_source:
    issues.append("package-app.sh must install TBH.icns as the app icon")
if "<string>TBH</string>" not in package_script_source:
    issues.append("package-app.sh Info.plist must reference TBH as CFBundleIconFile")

icon_side_match = re.search(r"nativeIconSide:\s*CGFloat\s*=\s*([0-9.]+)", menu_bar_icon_source)
label_height_match = re.search(r"nativeLabelHeight:\s*CGFloat\s*=\s*([0-9.]+)", menu_bar_icon_source)
if not icon_side_match:
    issues.append("MenuBarIcon must keep an explicit nativeIconSide layout constant")
    icon_side = None
else:
    icon_side = float(icon_side_match.group(1))
    if icon_side != 14:
        issues.append(f"MenuBarIcon nativeIconSide must stay at 14pt, got {icon_side:g}")

if not label_height_match:
    issues.append("MenuBarIcon must keep an explicit nativeLabelHeight layout constant")
    label_height = None
else:
    label_height = float(label_height_match.group(1))
    if label_height != 18:
        issues.append(f"MenuBarIcon nativeLabelHeight must stay at 18pt, got {label_height:g}")

for required_snippet in [
    ".menuBarIconSized(to: Self.nativeIconSide)",
    ".frame(width: Self.nativeIconSide, height: Self.nativeIconSide)",
    ".frame(height: Self.nativeLabelHeight)",
    ".fixedSize()",
]:
    if required_snippet not in menu_bar_icon_source:
        issues.append(f"MenuBarIcon is missing layout guard: {required_snippet}")

def rgba_metrics(path):
    try:
        image = Image.open(path).convert("RGBA")
    except Exception as exc:
        issues.append(f"{path.name} could not be decoded: {exc}")
        return None
    width, height = image.size
    pixels = list(image.getdata())
    opaque = sum(1 for _, _, _, alpha in pixels if alpha > 24)
    colors = {(red, green, blue) for red, green, blue, alpha in pixels if alpha > 24}
    saturated = sum(
        1
        for red, green, blue, alpha in pixels
        if alpha > 24 and max(red, green, blue) - min(red, green, blue) >= 48 and max(red, green, blue) >= 80
    )
    dark = sum(
        1
        for red, green, blue, alpha in pixels
        if alpha > 24 and red <= 40 and green <= 45 and blue <= 55
    )
    bright = sum(
        1
        for red, green, blue, alpha in pixels
        if alpha > 24 and red >= 180 and green >= 140 and blue <= 90
    )
    return {
        "path": path,
        "size": (width, height),
        "opaque": opaque,
        "ratio": opaque / float(width * height),
        "colors": len(colors),
        "saturated": saturated,
        "dark": dark,
        "bright": bright,
        "bbox": image.getchannel("A").getbbox(),
    }

app_icon = rgba_metrics(sprite_dir / "app_icon.png")
if app_icon:
    if app_icon["size"] != (180, 180):
        issues.append(f"app_icon.png must remain 180x180, got {app_icon['size'][0]}x{app_icon['size'][1]}")
    if app_icon["opaque"] != 180 * 180:
        issues.append(f"app_icon.png should remain a fully opaque launch/menu source tile, got opaque={app_icon['opaque']}")
    if app_icon["colors"] < 12:
        issues.append(f"app_icon.png has too few colors for current pixel art: {app_icon['colors']}")
    if app_icon["saturated"] < 3000:
        issues.append(f"app_icon.png is losing the warm pixel-art foreground: saturated={app_icon['saturated']}")
    if not (0.45 <= app_icon["dark"] / float(180 * 180) <= 0.85):
        issues.append("app_icon.png no longer has the expected dark menu-bar-safe backing ratio")

logo = rgba_metrics(sprite_dir / "logo_tbh.png")
if logo:
    if logo["size"] != (184, 86):
        issues.append(f"logo_tbh.png must remain 184x86, got {logo['size'][0]}x{logo['size'][1]}")
    if logo["colors"] < 1000:
        issues.append(f"logo_tbh.png has too few colors for title art: {logo['colors']}")

campfire = rgba_metrics(sprite_dir / "campfire.png")
if campfire:
    if campfire["size"] != (160, 180):
        issues.append(f"campfire.png must remain 160x180, got {campfire['size'][0]}x{campfire['size'][1]}")
    if campfire["colors"] < 1000:
        issues.append(f"campfire.png has too few colors for current campfire art: {campfire['colors']}")
    if campfire["saturated"] < 3000:
        issues.append(f"campfire.png is losing warm flame pixels: saturated={campfire['saturated']}")

achievement_metrics = []
for index in range(1, 5):
    metrics = rgba_metrics(sprite_dir / f"achievement_{index}.png")
    if not metrics:
        continue
    achievement_metrics.append(metrics)
    if metrics["size"] != (64, 64):
        issues.append(f"achievement_{index}.png must remain 64x64, got {metrics['size'][0]}x{metrics['size'][1]}")
    if metrics["colors"] < 100:
        issues.append(f"achievement_{index}.png has too few colors for readable achievement art: {metrics['colors']}")
    if metrics["saturated"] < 1000:
        issues.append(f"achievement_{index}.png has too few saturated pixels for current achievement art: {metrics['saturated']}")

taskbar_metrics = []
for index in range(1, 5):
    metrics = rgba_metrics(sprite_dir / f"taskbar_hero_{index}.png")
    if not metrics:
        continue
    taskbar_metrics.append(metrics)
    if metrics["size"] != (32, 32):
        issues.append(f"taskbar_hero_{index}.png must remain 32x32, got {metrics['size'][0]}x{metrics['size'][1]}")
    if metrics["colors"] < 20:
        issues.append(f"taskbar_hero_{index}.png has too few colors for a readable tiny sprite: {metrics['colors']}")

icns_path = sprite_dir / "TBH.icns"
try:
    data = icns_path.read_bytes()
except Exception as exc:
    issues.append(f"TBH.icns could not be read: {exc}")
    data = b""

icns_chunks = []
if data:
    if not data.startswith(b"icns") or len(data) < 8:
        issues.append("TBH.icns must start with an icns header")
    else:
        declared_size = int.from_bytes(data[4:8], "big")
        if declared_size != len(data):
            issues.append(f"TBH.icns declared size mismatch: declared={declared_size}, actual={len(data)}")
        offset = 8
        while offset + 8 <= len(data):
            chunk_type = data[offset:offset + 4].decode("latin1")
            chunk_size = int.from_bytes(data[offset + 4:offset + 8], "big")
            if chunk_size < 8 or offset + chunk_size > len(data):
                issues.append(f"TBH.icns has invalid chunk {chunk_type} size {chunk_size}")
                break
            icns_chunks.append((chunk_type, chunk_size))
            offset += chunk_size

required_icns_chunks = {"icp4", "icp5", "icp6", "ic07", "ic08", "ic09", "ic10"}
present_icns_chunks = {chunk for chunk, _ in icns_chunks}
missing_chunks = sorted(required_icns_chunks - present_icns_chunks)
if missing_chunks:
    issues.append(f"TBH.icns is missing expected app icon chunks: {','.join(missing_chunks)}")

print(f"sprite_dir={sprite_dir}")
print(f"game_art_source={game_art_path}")
print(f"menu_bar_icon_source={menu_bar_icon_path}")
print(f"package_script={package_script_path}\n")

print("asset                 size     opaque  ratio   colors  saturated  dark")
print("--------------------  -------  ------  ------  ------  ---------  ------")
for metrics in [app_icon, logo, campfire] + achievement_metrics + taskbar_metrics:
    if not metrics:
        continue
    width, height = metrics["size"]
    print(
        f"{metrics['path'].name:<20}  {width}x{height:<4}  {metrics['opaque']:>6}  "
        f"{metrics['ratio']:>6.3f}  {metrics['colors']:>6}  {metrics['saturated']:>9}  {metrics['dark']:>6}"
    )

print()
print("icns_chunks=" + ",".join(f"{chunk}:{size}" for chunk, size in icns_chunks))
print(
    "summary="
    f"menu_bar_icon_side:{icon_side if icon_side is not None else 'missing'}, "
    f"menu_bar_label_height:{label_height if label_height is not None else 'missing'}, "
    f"icns_chunks:{len(icns_chunks)}"
)

if issues:
    print("\nissues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print("local app icon audit passed")
PY

if [[ "${AUDIT_LOCAL_APP_ICONS_SKIP_PACKAGED:-0}" != "1" &&
      -d "$packaged_sprite_dir" &&
      "$sprite_dir" != "$packaged_sprite_dir" ]]; then
  echo
  echo "packaged_app_icon_audit"
  echo "------------------------"
  SPRITE_DIR="$packaged_sprite_dir" \
    GAME_ART_SWIFT="$game_art_swift" \
    MENU_BAR_ICON_SWIFT="$menu_bar_icon_swift" \
    PACKAGE_SCRIPT="$package_script" \
    AUDIT_LOCAL_APP_ICONS_SKIP_PACKAGED=1 \
    "$0"

  python3 - "$sprite_dir" "$packaged_sprite_dir" "$packaged_icon_file" <<'PY'
import hashlib
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
packaged_dir = Path(sys.argv[2])
packaged_icon_file = Path(sys.argv[3])

resource_names = [
    "app_icon.png",
    "logo_tbh.png",
    "campfire.png",
    "achievement_1.png",
    "achievement_2.png",
    "achievement_3.png",
    "achievement_4.png",
    "taskbar_hero_1.png",
    "taskbar_hero_2.png",
    "taskbar_hero_3.png",
    "taskbar_hero_4.png",
    "TBH.icns",
]

issues = []

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for name in resource_names:
    source_path = source_dir / name
    packaged_path = packaged_dir / name
    if not source_path.is_file():
        issues.append(f"source app icon resource missing: {name}")
        continue
    if not packaged_path.is_file():
        issues.append(f"packaged app icon resource missing from bundle: {name}")
        continue
    if digest(source_path) != digest(packaged_path):
        issues.append(f"packaged bundle app icon resource differs from source: {name}")

source_icns = source_dir / "TBH.icns"
if not packaged_icon_file.is_file():
    issues.append(f"packaged Finder app icon missing: {packaged_icon_file}")
elif source_icns.is_file() and digest(source_icns) != digest(packaged_icon_file):
    issues.append("packaged Finder app icon TBH.icns differs from source Extracted/TBH.icns")

if issues:
    print("packaged app icon payload issues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print(
    "packaged_app_icon_payload_match="
    f"checked bundle_resources:{len(resource_names)} finder_icon:yes"
)
PY
fi
