#!/usr/bin/env bash
set -euo pipefail

sprite_dir="${SPRITE_DIR:-Sources/Resources/Extracted}"
rune_swift="${RUNE_SWIFT:-Sources/Game/Progress/RuneTree.swift}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"
packaged_sprite_dir="${PACKAGED_SPRITE_DIR:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle/Extracted}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sprite_dir" "$rune_swift" "$game_art_swift" <<'PY'
import hashlib
import re
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for Rune Tree icon analysis: {exc}", file=sys.stderr)
    sys.exit(2)

sprite_dir = Path(sys.argv[1])
rune_path = Path(sys.argv[2])
game_art_path = Path(sys.argv[3])

for path in (sprite_dir, rune_path, game_art_path):
    if not path.exists():
        print(f"missing input: {path}", file=sys.stderr)
        sys.exit(2)

rune_source = rune_path.read_text(encoding="utf-8")
game_art_source = game_art_path.read_text(encoding="utf-8")

issues = []

enum_match = re.search(
    r"enum\s+RuneTreeNode[^{]*\{(?P<body>.*?)\n\}",
    rune_source,
    re.S,
)
if not enum_match:
    print(f"could not locate RuneTreeNode enum in {rune_path}", file=sys.stderr)
    sys.exit(1)

runtime_nodes = re.findall(r"^\s*case\s+([A-Za-z_][A-Za-z0-9_]*)\s*$", enum_match.group("body"), re.M)
if len(runtime_nodes) != 15:
    issues.append(f"expected 15 runtime RuneTreeNode cases, got {len(runtime_nodes)}")

source_id_match = re.search(
    r"var\s+sourceRuneID:\s*String\s*\{(?P<body>.*?)\n\s*\}",
    rune_source,
    re.S,
)
if not source_id_match:
    print(f"could not locate RuneTreeNode.sourceRuneID in {rune_path}", file=sys.stderr)
    sys.exit(1)

runtime_source_ids = {}
for case_list, source_id in re.findall(r"case\s+([^:]+):\s*return\s+\"([^\"]+)\"", source_id_match.group("body")):
    for case_name in re.findall(r"\.([A-Za-z_][A-Za-z0-9_]*)", case_list):
        runtime_source_ids[case_name] = source_id

if set(runtime_source_ids) != set(runtime_nodes):
    missing = sorted(set(runtime_nodes) - set(runtime_source_ids))
    extra = sorted(set(runtime_source_ids) - set(runtime_nodes))
    issues.append(f"sourceRuneID mapping mismatch; missing={missing}, extra={extra}")

tsv_match = re.search(r'sourceRuneTSV = """\n(?P<body>.*?)\n\s*"""', rune_source, re.S)
if not tsv_match:
    print(f"could not locate sourceRuneTSV in {rune_path}", file=sys.stderr)
    sys.exit(1)

source_rows = []
for line in tsv_match.group("body").splitlines():
    parts = line.split("\t")
    if len(parts) != 7:
        issues.append(f"malformed source rune row: {line}")
        continue
    source_rows.append({
        "id": parts[0],
        "zh": parts[1],
        "en": parts[2],
        "max_level": parts[3],
        "previous": parts[4],
        "next": parts[5],
        "icon": parts[6],
    })

source_by_id = {row["id"]: row for row in source_rows}
source_icon_families = sorted({row["icon"] for row in source_rows})

distribution_match = re.search(
    r"expectedIconDistribution\s*=\s*\[(?P<body>.*?)\n\s*\]",
    rune_source,
    re.S,
)
if not distribution_match:
    print(f"could not locate SourceRuneCatalog.expectedIconDistribution in {rune_path}", file=sys.stderr)
    sys.exit(1)

expected_distribution = {
    icon: int(count)
    for icon, count in re.findall(r'"([^"]+)":\s*(\d+)', distribution_match.group("body"))
}
expected_icon_families = sorted(expected_distribution)
expected_icon_names = [f"source_rune_{icon}" for icon in expected_icon_families]

if len(source_rows) != 197:
    issues.append(f"expected 197 source Rune Tree rows, got {len(source_rows)}")
if source_icon_families != expected_icon_families:
    issues.append("source rune TSV icon families do not match expectedIconDistribution")
if sum(expected_distribution.values()) != len(source_rows):
    issues.append("expected Rune Tree icon distribution does not sum to source row count")

runtime_mapped_icons = {}
for node, source_id in runtime_source_ids.items():
    source_node = source_by_id.get(source_id)
    if source_node is None:
        issues.append(f"runtime node {node} references missing source rune id {source_id}")
        continue
    runtime_mapped_icons[node] = f"source_rune_{source_node['icon']}"

if len(set(runtime_mapped_icons.values())) != 14:
    issues.append(
        "current runtime Rune Tree nodes should use fourteen source icon families, got "
        + str(sorted(set(runtime_mapped_icons.values())))
    )

runtime_modeled_source_ids = set(runtime_source_ids.values())
runtime_modeled_source_rows = [
    row for row in source_rows
    if row["id"] in runtime_modeled_source_ids
]
runtime_unmodeled_source_rows = [
    row for row in source_rows
    if row["id"] not in runtime_modeled_source_ids
]
runtime_modeled_icon_families = {
    row["icon"] for row in runtime_modeled_source_rows
}
runtime_unmodeled_icon_families = {
    row["icon"] for row in runtime_unmodeled_source_rows
}
runtime_unmodeled_only_icon_families = set(source_icon_families) - runtime_modeled_icon_families
runtime_shared_icon_families = runtime_modeled_icon_families & runtime_unmodeled_icon_families

if len(runtime_modeled_source_rows) != 15:
    issues.append(f"expected 15 runtime-modeled source Rune Tree rows, got {len(runtime_modeled_source_rows)}")
if len(runtime_unmodeled_source_rows) != 182:
    issues.append(f"expected 182 data-only source Rune Tree rows, got {len(runtime_unmodeled_source_rows)}")
if len(runtime_modeled_icon_families) != 14:
    issues.append(f"expected 14 runtime-modeled Rune Tree icon families, got {len(runtime_modeled_icon_families)}")
if len(runtime_unmodeled_only_icon_families) != 25:
    issues.append(f"expected 25 unmodeled-only Rune Tree icon families, got {len(runtime_unmodeled_only_icon_families)}")
if runtime_shared_icon_families != {
    "MaxAmountActBossChest",
    "MaxAmountNormalChest",
    "MaxAmountStageBossChest",
    "MaxInventorySlot",
    "OfflineRewardExpPercent",
    "OfflineRewardGoldPercent",
}:
    issues.append(
        "unexpected shared modeled/data-only Rune Tree icon families: "
        + ",".join(sorted(runtime_shared_icon_families))
    )

if "SourceRuneCatalog.iconNames" not in game_art_source:
    issues.append("GameArt.runeTreeIconNames must derive from SourceRuneCatalog.iconNames")
if "sourceRuneIconName(forIconFamily:" not in game_art_source:
    issues.append("GameArt must expose sourceRuneIconName(forIconFamily:) for auditable source icon mapping")
if re.search(r'return\s+"rune_[^"]+"', game_art_source):
    issues.append("GameArt still returns legacy rune_* artwork for runtime Rune Tree nodes")

resource_paths = sorted(sprite_dir.glob("source_rune_*.png"))
resource_names = sorted(path.stem for path in resource_paths)
if resource_names != expected_icon_names:
    missing = sorted(set(expected_icon_names) - set(resource_names))
    extra = sorted(set(resource_names) - set(expected_icon_names))
    issues.append(f"Rune Tree source icon resource mismatch; missing={missing}, extra={extra}")

allowed_duplicate_pixel_groups = {
    tuple(sorted([
        "source_rune_OpenAllTypeChestAllAtOnce",
        "source_rune_OpenOneTypeChestAllAtOnce",
    ])),
}

pixel_hashes = {}

print(f"sprite_dir={sprite_dir}")
print(f"rune_source={rune_path}")
print(f"game_art_source={game_art_path}\n")
print("runtime_node             source_id  icon")
print("-----------------------  ---------  ------------------------------------------")
for node in runtime_nodes:
    print(f"{node:<23}  {runtime_source_ids.get(node, 'missing'):<9}  {runtime_mapped_icons.get(node, 'missing')}")

print()
print("runtime_source_node_coverage")
print("----------------------------")
print(
    "status=explicit "
    f"runtime_source_nodes:{len(runtime_modeled_source_rows)}/{len(source_rows)} "
    f"data_only_source_nodes:{len(runtime_unmodeled_source_rows)} "
    f"runtime_icon_families:{len(runtime_modeled_icon_families)} "
    f"unmodeled_only_icon_families:{len(runtime_unmodeled_only_icon_families)} "
    f"shared_modeled_data_only:{','.join(sorted(runtime_shared_icon_families))}"
)

print()
print("source_icon_family                    rows  size   opaque  colors  saturated")
print("------------------------------------  ----  -----  ------  ------  ---------")
for icon_family in expected_icon_families:
    icon_name = f"source_rune_{icon_family}"
    path = sprite_dir / f"{icon_name}.png"
    if not path.exists():
        continue
    try:
        image = Image.open(path).convert("RGBA")
    except Exception as exc:
        issues.append(f"{icon_name}.png could not be decoded: {exc}")
        continue

    width, height = image.size
    pixels = list(image.getdata())
    opaque = sum(1 for _, _, _, alpha in pixels if alpha > 24)
    colors = set()
    saturated = 0
    for red, green, blue, alpha in pixels:
        if alpha <= 24:
            continue
        colors.add((red, green, blue))
        if max(red, green, blue) - min(red, green, blue) >= 48 and max(red, green, blue) >= 80:
            saturated += 1

    if (width, height) != (16, 16):
        issues.append(f"{icon_name}.png must be 16x16, got {width}x{height}")
    if opaque != 256:
        issues.append(f"{icon_name}.png should preserve the current opaque 16x16 source tile, got opaque={opaque}")
    if len(colors) < 30:
        issues.append(f"{icon_name}.png has too few visible colors for current source Rune art: {len(colors)}")
    if saturated < 40:
        issues.append(f"{icon_name}.png has too few saturated pixels for current source Rune art: {saturated}")

    digest = hashlib.sha256(image.tobytes()).hexdigest()
    pixel_hashes.setdefault(digest, []).append(icon_name)

    print(f"{icon_family:<36}  {expected_distribution[icon_family]:>4}  {width}x{height:<2}  {opaque:>6}  {len(colors):>6}  {saturated:>9}")

duplicates = [
    sorted(names)
    for names in pixel_hashes.values()
    if len(names) > 1 and tuple(sorted(names)) not in allowed_duplicate_pixel_groups
]
if duplicates:
    issues.append(
        "unexpected duplicate Rune Tree icon pixel payloads: "
        + "; ".join(",".join(names) for names in duplicates)
    )

print()
print(
    "summary="
    f"source_rows:{len(source_rows)}, source_icon_families:{len(expected_icon_families)}, "
    f"runtime_nodes:{len(runtime_nodes)}, runtime_icon_families:{len(set(runtime_mapped_icons.values()))}"
)

if issues:
    print("\nissues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print("local Rune Tree icon audit passed")
PY

if [[ "${AUDIT_LOCAL_RUNE_ICONS_SKIP_PACKAGED:-0}" != "1" &&
      -d "$packaged_sprite_dir" &&
      "$sprite_dir" != "$packaged_sprite_dir" ]]; then
  echo
  echo "packaged_app_rune_icon_audit"
  echo "-----------------------------"
  SPRITE_DIR="$packaged_sprite_dir" \
    RUNE_SWIFT="$rune_swift" \
    GAME_ART_SWIFT="$game_art_swift" \
    AUDIT_LOCAL_RUNE_ICONS_SKIP_PACKAGED=1 \
    "$0"

  python3 - "$sprite_dir" "$packaged_sprite_dir" "$rune_swift" <<'PY'
import hashlib
import re
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
packaged_dir = Path(sys.argv[2])
rune_path = Path(sys.argv[3])

rune_source = rune_path.read_text(encoding="utf-8")
distribution_match = re.search(
    r"expectedIconDistribution\s*=\s*\[(?P<body>.*?)\n\s*\]",
    rune_source,
    re.S,
)
if not distribution_match:
    print(f"could not locate SourceRuneCatalog.expectedIconDistribution in {rune_path}", file=sys.stderr)
    sys.exit(2)

expected = sorted(
    f"source_rune_{icon}.png"
    for icon, _ in re.findall(r'"([^"]+)":\s*(\d+)', distribution_match.group("body"))
)

issues = []

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for name in expected:
    source_path = source_dir / name
    packaged_path = packaged_dir / name
    if not source_path.is_file():
        issues.append(f"source Rune icon missing: {name}")
        continue
    if not packaged_path.is_file():
        issues.append(f"packaged app Rune icon missing: {name}")
        continue
    if digest(source_path) != digest(packaged_path):
        issues.append(f"packaged app Rune icon differs from source: {name}")

extra_packaged = sorted(
    path.name
    for path in packaged_dir.glob("source_rune_*.png")
    if path.name not in expected
)
for name in extra_packaged:
    issues.append(f"packaged app has unexpected Rune icon resource: {name}")

if issues:
    print("packaged app Rune icon payload issues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print(f"packaged_app_rune_icon_payload_match=checked icons:{len(expected)}")
PY
fi
