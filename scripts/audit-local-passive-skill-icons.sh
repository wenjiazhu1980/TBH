#!/usr/bin/env bash
set -euo pipefail

sprite_dir="${SPRITE_DIR:-Sources/Resources/Extracted}"
skills_swift="${SKILLS_SWIFT:-Sources/Game/Character/Skills.swift}"
game_art_swift="${GAME_ART_SWIFT:-Sources/UI/Components/GameArt.swift}"
packaged_sprite_dir="${PACKAGED_SPRITE_DIR:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle/Extracted}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sprite_dir" "$skills_swift" "$game_art_swift" <<'PY'
import hashlib
import re
import sys
from pathlib import Path

try:
    from PIL import Image
except Exception as exc:
    print(f"Pillow is required for passive skill icon analysis: {exc}", file=sys.stderr)
    sys.exit(2)

sprite_dir = Path(sys.argv[1])
skills_path = Path(sys.argv[2])
game_art_path = Path(sys.argv[3])

for path in (sprite_dir, skills_path, game_art_path):
    if not path.exists():
        print(f"missing input: {path}", file=sys.stderr)
        sys.exit(2)

skills_source = skills_path.read_text(encoding="utf-8")
game_art_source = game_art_path.read_text(encoding="utf-8")

block_match = re.search(r'passiveSkillTSV = """\n(?P<body>.*?)\n\s*"""', skills_source, re.S)
if not block_match:
    print("could not locate passiveSkillTSV", file=sys.stderr)
    sys.exit(2)

rows = []
for line in block_match.group("body").splitlines():
    parts = line.split("\t")
    if len(parts) != 5:
        print(f"malformed passive row: {line}", file=sys.stderr)
        sys.exit(2)
    rows.append({
        "id": parts[0],
        "name": parts[1],
        "stat": parts[2],
        "type": parts[3],
        "value": parts[4],
    })

stat_to_icon = {
    "AddHpPerHit": "source_passive_AddHpPerHit",
    "AddHpPerKill": "source_passive_AddHpPerKill",
    "AllElementalResistance": "source_passive_AllElementalResistance",
    "AreaOfEffect": "source_passive_AreaOfEffect",
    "Armor": "source_passive_Armor",
    "AttackDamage": "source_passive_AttackDamage",
    "AttackSpeed": "source_passive_AttackSpeed",
    "BlockChance": "source_passive_BlockChance",
    "CastSpeed": "source_passive_CastSpeed",
    "ColdDamagePercent": "source_passive_ColdDamagePercent",
    "CooldownReduction": "source_passive_CooldownReduction",
    "CriticalChance": "source_passive_CriticalChance",
    "CriticalDamage": "source_passive_CriticalDamage",
    "DamageAbsorption": "source_passive_DamageAbsorption",
    "DamageReduction": "source_passive_DamageReduction",
    "DodgeChance": "source_passive_DodgeChance",
    "ElementalDodgeChance": "source_passive_DodgeChance",
    "FireDamagePercent": "source_passive_FireDamagePercent",
    "HpLeech": "source_passive_HpLeech",
    "HpRegenPerSec": "source_passive_HpRegenPerSec",
    "IncreaseAreaOfEffectDamage": "source_passive_AreaOfEffectDamage",
    "LightningDamagePercent": "source_passive_LightningDamagePercent",
    "MaxDodgeChance": "source_passive_MaxDodgeChance",
    "MaxHp": "source_passive_MaxHp",
    "MovementSpeed": "source_passive_MovementSpeed",
    "PhysicalDamagePercent": "source_passive_PhysicalDamagePercent",
    "SkillDurationIncrease": "source_passive_Duration",
    "SkillRangeExpansion": "source_passive_SkillRangeExpansion",
}
expected_missing_stats = {"IncreaseProjectileDamage", "SkillHealIncrease"}
expected_icons = sorted(set(stat_to_icon.values()))
expected_32x32_icons = {
    "source_passive_Armor",
    "source_passive_AttackDamage",
    "source_passive_AttackSpeed",
    "source_passive_CastSpeed",
    "source_passive_CooldownReduction",
    "source_passive_CriticalChance",
    "source_passive_CriticalDamage",
    "source_passive_DamageAbsorption",
    "source_passive_MaxDodgeChance",
    "source_passive_MaxHp",
    "source_passive_MovementSpeed",
}
allowed_duplicate_pixel_groups = {
    tuple(sorted([
        "source_passive_CastSpeed",
        "source_passive_DamageAbsorption",
        "source_passive_MaxDodgeChance",
        "source_passive_MaxHp",
        "source_passive_MovementSpeed",
    ])),
}

issues = []
if len(rows) != 108:
    issues.append(f"expected 108 passive rows, got {len(rows)}")

stats = {row["stat"] for row in rows}
mapped_rows = [row for row in rows if row["stat"] in stat_to_icon]
missing_stats = {row["stat"] for row in rows if row["stat"] not in stat_to_icon}

if len(stats) != 30:
    issues.append(f"expected 30 passive stat names, got {len(stats)}")
if len(mapped_rows) != 104:
    issues.append(f"expected 104 source-icon mapped passive rows, got {len(mapped_rows)}")
if missing_stats != expected_missing_stats:
    issues.append(f"unexpected passive stats without source icons: {','.join(sorted(missing_stats))}")

game_art_icons = sorted(set(re.findall(r'"(source_passive_[A-Za-z0-9]+)"', game_art_source)))
if game_art_icons != expected_icons:
    issues.append("GameArt source_passive_* icon list does not match expected current source icons")

resource_paths = sorted(sprite_dir.glob("source_passive_*.png"))
resource_names = sorted(path.stem for path in resource_paths)
if resource_names != expected_icons:
    missing = sorted(set(expected_icons) - set(resource_names))
    extra = sorted(set(resource_names) - set(expected_icons))
    issues.append(f"passive icon resource mismatch; missing={missing}, extra={extra}")

print(f"sprite_dir={sprite_dir}")
print(f"skills_source={skills_path}")
print(f"game_art_source={game_art_path}\n")
print("passive_stat                  icon                                  size   opaque  ratio   alpha_bbox     corners")
print("----------------------------  ------------------------------------  -----  ------  ------  -------------  -----------")

pixel_hashes = {}
for icon in expected_icons:
    path = sprite_dir / f"{icon}.png"
    if not path.exists():
        continue
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
        width, height = rgba.size
        alpha = rgba.getchannel("A")
        bbox = alpha.getbbox()
        opaque = sum(1 for value in alpha.getdata() if value > 24)
        ratio = opaque / float(width * height)
        corners = [
            alpha.getpixel((0, 0)),
            alpha.getpixel((width - 1, 0)),
            alpha.getpixel((0, height - 1)),
            alpha.getpixel((width - 1, height - 1)),
        ]
        digest = hashlib.sha256(rgba.tobytes()).hexdigest()
        pixel_hashes.setdefault(digest, []).append(icon)

    expected_size = (32, 32) if icon in expected_32x32_icons else (16, 16)
    if (width, height) != expected_size:
        issues.append(f"{icon} must be {expected_size[0]}x{expected_size[1]}, got {width}x{height}")
    if opaque <= 0:
        issues.append(f"{icon} is blank")
    if ratio > 0.95:
        issues.append(f"{icon} looks like an opaque UI tile, visible ratio {ratio:.3f}")

    stats_for_icon = sorted(stat for stat, mapped_icon in stat_to_icon.items() if mapped_icon == icon)
    label = ",".join(stats_for_icon)
    bbox_text = "none" if bbox is None else ",".join(str(value) for value in bbox)
    print(f"{label[:28]:<28}  {icon:<36}  {width}x{height:<2}  {opaque:>6}  {ratio:>6.3f}  {bbox_text:<13}  {corners}")

duplicates = [
    icons
    for icons in pixel_hashes.values()
    if len(icons) > 1 and tuple(sorted(icons)) not in allowed_duplicate_pixel_groups
]
if duplicates:
    issues.append("duplicate passive icon pixel payloads: " + "; ".join(",".join(group) for group in duplicates))

print()
print(
    "summary="
    f"passive_rows:{len(rows)}, stats:{len(stats)}, mapped_rows:{len(mapped_rows)}, "
    f"source_icon_families:{len(expected_icons)}, missing_source_icon_stats:{','.join(sorted(missing_stats))}"
)

if issues:
    print("\nissues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print("local passive skill icon audit passed")
PY

if [[ "${AUDIT_LOCAL_PASSIVE_SKILL_ICONS_SKIP_PACKAGED:-0}" != "1" &&
      -d "$packaged_sprite_dir" &&
      "$sprite_dir" != "$packaged_sprite_dir" ]]; then
  echo
  echo "packaged_app_passive_skill_icon_audit"
  echo "--------------------------------------"
  SPRITE_DIR="$packaged_sprite_dir" \
    SKILLS_SWIFT="$skills_swift" \
    GAME_ART_SWIFT="$game_art_swift" \
    AUDIT_LOCAL_PASSIVE_SKILL_ICONS_SKIP_PACKAGED=1 \
    "$0"

  python3 - "$sprite_dir" "$packaged_sprite_dir" "$skills_swift" "$game_art_swift" <<'PY'
import hashlib
import re
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
packaged_dir = Path(sys.argv[2])
skills_path = Path(sys.argv[3])
game_art_path = Path(sys.argv[4])

skills_source = skills_path.read_text(encoding="utf-8")
game_art_source = game_art_path.read_text(encoding="utf-8")
if 'passiveSkillTSV = """' not in skills_source:
    print(f"could not locate passiveSkillTSV in {skills_path}", file=sys.stderr)
    sys.exit(2)

expected = sorted(set(re.findall(r'"(source_passive_[A-Za-z0-9]+)"', game_art_source)))
if not expected:
    print(f"could not derive expected source_passive_* icons from {game_art_path}", file=sys.stderr)
    sys.exit(2)

issues = []
for stem in expected:
    name = f"{stem}.png"
    source_path = source_dir / name
    packaged_path = packaged_dir / name
    if not source_path.is_file():
        issues.append(f"source passive icon missing: {name}")
        continue
    if not packaged_path.is_file():
        issues.append(f"packaged app passive icon missing: {name}")
        continue
    if hashlib.sha256(source_path.read_bytes()).hexdigest() != hashlib.sha256(packaged_path.read_bytes()).hexdigest():
        issues.append(f"packaged app passive icon differs from source: {name}")

extra_packaged = sorted(
    path.stem
    for path in packaged_dir.glob("source_passive_*.png")
    if path.stem not in expected
)
for stem in extra_packaged:
    issues.append(f"packaged app has unexpected passive icon resource: {stem}.png")

if issues:
    print("packaged app passive icon payload issues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print(f"packaged_app_passive_skill_icon_payload_match=checked icons:{len(expected)}")
PY
fi
