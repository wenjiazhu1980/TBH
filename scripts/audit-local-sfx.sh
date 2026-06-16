#!/usr/bin/env bash
set -euo pipefail

sfx_dir="${SFX_DIR:-Sources/Resources/Extracted/sfx}"
sfx_manifest="${SFX_MANIFEST:-$sfx_dir/sfx_manifest.tsv}"
game_audio_swift="${GAME_AUDIO_SWIFT:-Sources/App/GameAudio.swift}"
game_loop_swift="${GAME_LOOP_SWIFT:-Sources/Game/Engine/GameLoop.swift}"
battle_swift="${BATTLE_SWIFT:-Sources/Game/Combat/Battle.swift}"
packaged_sfx_dir="${PACKAGED_SFX_DIR:-dist/TBH.app/Contents/Resources/TBH-macOS_TBH.bundle/Extracted/sfx}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require_tool python3

python3 - "$sfx_dir" "$game_audio_swift" "$game_loop_swift" "$battle_swift" "$sfx_manifest" <<'PY'
import math
import re
import struct
import sys
import wave
import hashlib
from pathlib import Path

sfx_dir = Path(sys.argv[1])
game_audio_swift = Path(sys.argv[2])
game_loop_swift = Path(sys.argv[3])
battle_swift = Path(sys.argv[4])
sfx_manifest = Path(sys.argv[5])

if not sfx_dir.is_dir():
    print(f"SFX directory does not exist: {sfx_dir}", file=sys.stderr)
    sys.exit(2)

if not sfx_manifest.is_file():
    print(f"SFX manifest does not exist: {sfx_manifest}", file=sys.stderr)
    sys.exit(2)

if not game_audio_swift.is_file():
    print(f"GameAudio source does not exist: {game_audio_swift}", file=sys.stderr)
    sys.exit(2)

if not game_loop_swift.is_file():
    print(f"GameLoop source does not exist: {game_loop_swift}", file=sys.stderr)
    sys.exit(2)

if not battle_swift.is_file():
    print(f"Battle source does not exist: {battle_swift}", file=sys.stderr)
    sys.exit(2)

source = game_audio_swift.read_text(encoding="utf-8")
game_loop_source = game_loop_swift.read_text(encoding="utf-8")
battle_source = battle_swift.read_text(encoding="utf-8")

event_enum = re.search(r'enum\s+GameAudioEvent\s*:\s*String,\s*CaseIterable\s*\{(?P<body>.*?)\n\}', source, re.S)
if not event_enum:
    print(f"Could not locate GameAudioEvent enum in {game_audio_swift}", file=sys.stderr)
    sys.exit(2)

audio_events = re.findall(r'^\s*case\s+(\w+)\b', event_enum.group("body"), re.M)
if not audio_events:
    print(f"Could not derive GameAudioEvent cases from {game_audio_swift}", file=sys.stderr)
    sys.exit(2)

resource_pairs = re.findall(r'case\s+\.(\w+):\s+return\s+"(sfx_[^"]+)"', source)
resource_by_event = {event: resource for event, resource in resource_pairs}
expected = [resource_by_event.get(event) for event in audio_events if event in resource_by_event]
if not expected:
    print(f"Could not derive bundled SFX names from {game_audio_swift}", file=sys.stderr)
    sys.exit(2)

volume_block = re.search(r'var\s+volume:\s+Float\s*\{(?P<body>.*?)\n\s*var\s+minimumInterval', source, re.S)
if not volume_block:
    print(f"Could not locate GameAudioEvent.volume in {game_audio_swift}", file=sys.stderr)
    sys.exit(2)

volume_by_event = {}
for cases, volume in re.findall(r'case\s+([^:]+):\s+return\s+([0-9.]+)', volume_block.group("body")):
    for event in re.findall(r'\.(\w+)', cases):
        volume_by_event[event] = float(volume)

missing_volume_mapping = [event for event in audio_events if event not in volume_by_event]
volume_by_resource = {
    resource_by_event[event]: volume_by_event[event]
    for event in audio_events
    if event in resource_by_event and event in volume_by_event
}

interval_block = re.search(r'var\s+minimumInterval:\s+TimeInterval\s*\{(?P<body>.*?)\n\s*\}\n\}', source, re.S)
if not interval_block:
    print(f"Could not locate GameAudioEvent.minimumInterval in {game_audio_swift}", file=sys.stderr)
    sys.exit(2)

interval_by_event = {}
for cases, interval in re.findall(r'case\s+([^:]+):\s+return\s+([0-9.]+)', interval_block.group("body")):
    for event in re.findall(r'\.(\w+)', cases):
        interval_by_event[event] = float(interval)

missing_interval_mapping = [event for event in audio_events if event not in interval_by_event]

missing_resource_mapping = [event for event in audio_events if event not in resource_by_event]
unknown_resource_mapping = sorted(set(resource_by_event).difference(audio_events))
duplicates = sorted({name for name in expected if expected.count(name) > 1})
if duplicates:
    print(f"Duplicate bundled SFX names: {', '.join(duplicates)}", file=sys.stderr)
    sys.exit(1)

battle_event_enum = re.search(r'enum\s+BattleEvent\s*\{(?P<body>.*?)\n\}', battle_source, re.S)
if not battle_event_enum:
    print(f"Could not locate BattleEvent enum in {battle_swift}", file=sys.stderr)
    sys.exit(2)

battle_events = re.findall(r'^\s*case\s+(\w+)\b', battle_event_enum.group("body"), re.M)
mapper = re.search(
    r'static\s+func\s+audioEvent\(for\s+event:\s+BattleEvent\)\s*->\s*GameAudioEvent\s*\{(?P<body>.*?)\n\s*\}\n\n\s*private\s+func\s+handleBattleEvent',
    game_loop_source,
    re.S,
)
if not mapper:
    print(f"Could not locate GameEngine.audioEvent(for:) in {game_loop_swift}", file=sys.stderr)
    sys.exit(2)

mapper_body = mapper.group("body")
handler = re.search(
    r'private\s+func\s+handleBattleEvent\(_\s+event:\s+BattleEvent\)\s*\{(?P<body>.*?)\n\s*\}\n\n\s*// MARK: - Inventory',
    game_loop_source,
    re.S,
)
if not handler:
    print(f"Could not locate GameLoop.handleBattleEvent in {game_loop_swift}", file=sys.stderr)
    sys.exit(2)

handler_body = handler.group("body")
handler_uses_mapper = re.search(r'audio\.play\(Self\.audioEvent\(for:\s*event\)\)', handler_body) is not None

audio_play_arguments = re.findall(r'audio\.play\(([^)]*)\)', game_loop_source)
played_audio_references = [
    match.group(1)
    for arguments in audio_play_arguments
    if (match := re.fullmatch(r'\s*\.(\w+)\s*', arguments))
]
played_audio_references.extend(
    event
    for event in re.findall(r'\.(\w+)\b', mapper_body)
    if event in audio_events
)
played_events = set(played_audio_references).intersection(audio_events)

unrouted_audio_events = [event for event in audio_events if event not in played_events]
unknown_played_events = sorted(
    set(played_audio_references).difference(audio_events)
)

unhandled_battle_events = [
    event for event in battle_events
    if re.search(rf'case\s+\.{event}\b', mapper_body) is None
]

expected_battle_routes = {
    "heroAttack": {"heroAttack", "heroCriticalHit"},
    "heroSkill": {"skillCast", "heroCriticalHit"},
    "supportAttack": {"heroAttack", "heroCriticalHit"},
    "supportSkill": {"skillCast", "heroCriticalHit"},
    "heroDamaged": {"heroDamaged"},
    "battleWon": {"battleWon"},
    "battleLost": {"battleLost"},
}
route_issues = []
if not handler_uses_mapper:
    route_issues.append("handleBattleEvent: does not call GameEngine.audioEvent(for:)")
for event, expected_audio in expected_battle_routes.items():
    match = re.search(
        rf'case\s+\.{event}\b(?P<body>.*?)(?=\n\s*case\s+\.|\Z)',
        mapper_body,
        re.S,
    )
    if not match:
        route_issues.append(f"{event}: missing route body")
        continue
    routed = set(re.findall(r'\.(\w+)', match.group("body"))).intersection(audio_events)
    missing = expected_audio.difference(routed)
    if missing:
        route_issues.append(f"{event}: missing audio {', '.join(sorted(missing))}")

existing = sorted(path.stem for path in sfx_dir.glob("*.wav"))
missing = [name for name in expected if not (sfx_dir / f"{name}.wav").is_file()]
extra = [name for name in existing if name not in expected]

issues = []
rows = []
content_hashes = {}
file_hash_by_name = {}
file_bytes_by_name = {}
samples_by_name = {}
sample_rate_by_name = {}

event_profiles = {
    "sfx_hero_attack": {
        "duration": (0.08, 0.16),
        "centroid": (1200, 3400),
        "zcr": (0.025, 0.090),
        "attack_ms_max": 40,
    },
    "sfx_hero_critical_hit": {
        "duration": (0.12, 0.22),
        "centroid": (1800, 5600),
        "zcr": (0.070, 0.170),
        "high_ratio_min": 0.16,
        "attack_ms_max": 40,
    },
    "sfx_skill_cast": {
        "duration": (0.18, 0.30),
        "centroid": (650, 2200),
        "low_ratio_min": 0.55,
        "attack_ms_min": 35,
    },
    "sfx_hero_damaged": {
        "duration": (0.10, 0.20),
        "centroid": (450, 1800),
        "low_ratio_min": 0.45,
        "attack_ms_max": 35,
    },
    "sfx_battle_won": {
        "duration": (0.25, 0.45),
        "centroid": (650, 2100),
        "low_ratio_min": 0.45,
    },
    "sfx_loot_found": {
        "duration": (0.15, 0.28),
        "centroid": (650, 2200),
        "zcr": (0.080, 0.180),
    },
    "sfx_battle_lost": {
        "duration": (0.24, 0.42),
        "centroid": (250, 1200),
        "low_ratio_min": 0.65,
    },
    "sfx_level_up": {
        "duration": (0.28, 0.48),
        "centroid": (600, 1800),
        "zcr": (0.080, 0.180),
        "low_ratio_min": 0.55,
    },
    "sfx_item_equipped": {
        "duration": (0.09, 0.18),
        "centroid": (300, 1400),
        "low_ratio_min": 0.70,
    },
    "sfx_item_consumed": {
        "duration": (0.12, 0.24),
        "centroid": (650, 2200),
        "zcr": (0.040, 0.150),
        "attack_ms_max": 45,
    },
    "sfx_preview": {
        "duration": (0.08, 0.16),
        "centroid": (900, 3000),
        "high_ratio_min": 0.04,
    },
}

volume_profiles = {
    "heroAttack": (0.32, 0.50),
    "heroCriticalHit": (0.32, 0.50),
    "skillCast": (0.32, 0.50),
    "heroDamaged": (0.32, 0.50),
    "lootFound": (0.28, 0.44),
    "itemEquipped": (0.28, 0.44),
    "itemConsumed": (0.28, 0.44),
    "preview": (0.28, 0.44),
    "battleWon": (0.36, 0.55),
    "battleLost": (0.36, 0.55),
    "levelUp": (0.36, 0.55),
}

volume_issues = []
for event in audio_events:
    volume = volume_by_event.get(event)
    profile = volume_profiles.get(event)
    if volume is None or profile is None:
        continue

    minimum, maximum = profile
    if not (minimum <= volume <= maximum):
        volume_issues.append(
            f"{event}: expected volume {minimum:.2f}-{maximum:.2f}, got {volume:.2f}"
        )

inventory_preview_volumes = [
    volume_by_event[event]
    for event in ["lootFound", "itemEquipped", "itemConsumed", "preview"]
    if event in volume_by_event
]
terminal_volumes = [
    volume_by_event[event]
    for event in ["battleWon", "battleLost", "levelUp"]
    if event in volume_by_event
]
if inventory_preview_volumes and terminal_volumes and min(terminal_volumes) < max(inventory_preview_volumes):
    volume_issues.append(
        "terminal/progression SFX should not be quieter than inventory/preview SFX"
    )

interval_profiles = {
    "heroAttack": (0.12, 0.25),
    "heroCriticalHit": (0.12, 0.25),
    "skillCast": (0.12, 0.28),
    "heroDamaged": (0.12, 0.25),
    "lootFound": (0.18, 0.35),
    "itemEquipped": (0.18, 0.35),
    "itemConsumed": (0.18, 0.35),
    "preview": (0.18, 0.35),
    "battleWon": (0.40, 0.80),
    "battleLost": (0.40, 0.80),
    "levelUp": (0.40, 0.80),
}

interval_issues = []
for event in audio_events:
    interval = interval_by_event.get(event)
    profile = interval_profiles.get(event)
    if interval is None or profile is None:
        continue

    minimum, maximum = profile
    if not (minimum <= interval <= maximum):
        interval_issues.append(
            f"{event}: expected minimumInterval {minimum:.2f}-{maximum:.2f}s, got {interval:.2f}s"
        )

combat_intervals = [
    interval_by_event[event]
    for event in ["heroAttack", "heroCriticalHit", "skillCast", "heroDamaged"]
    if event in interval_by_event
]
terminal_intervals = [
    interval_by_event[event]
    for event in ["battleWon", "battleLost", "levelUp"]
    if event in interval_by_event
]
if combat_intervals and terminal_intervals and min(terminal_intervals) <= max(combat_intervals):
    interval_issues.append(
        "terminal/progression SFX should be throttled longer than repeatable combat SFX"
    )

def dbfs(value: float) -> float:
    if value <= 0:
        return float("-inf")
    return 20 * math.log10(value)

for name in expected:
    path = sfx_dir / f"{name}.wav"
    if not path.is_file():
        continue

    file_data = path.read_bytes()
    file_hash_by_name[name] = hashlib.sha256(file_data).hexdigest()
    file_bytes_by_name[name] = len(file_data)

    with wave.open(str(path), "rb") as wav:
        channels = wav.getnchannels()
        sample_width = wav.getsampwidth()
        sample_rate = wav.getframerate()
        frames = wav.getnframes()
        raw = wav.readframes(frames)

    content_hash = hashlib.sha256(raw).hexdigest()
    content_hashes.setdefault(content_hash, []).append(name)

    duration = frames / sample_rate if sample_rate else 0
    sample_count = len(raw) // sample_width if sample_width else 0

    if sample_width == 2:
        samples = struct.unpack("<" + "h" * sample_count, raw)
        full_scale = 32768.0
    else:
        samples = ()
        full_scale = 1.0

    if samples:
        peak = max(abs(sample) for sample in samples) / full_scale
        rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples)) / full_scale
        samples_by_name[name] = [sample / full_scale for sample in samples]
        sample_rate_by_name[name] = sample_rate
    else:
        peak = 0
        rms = 0

    peak_db = dbfs(peak)
    rms_db = dbfs(rms)
    absolute_samples = [abs(sample) / full_scale for sample in samples]
    if peak > 0:
        attack_time = next(
            (index / sample_rate for index, value in enumerate(absolute_samples) if value >= peak * 0.90),
            duration,
        )
        last_tenth_peak_time = max(
            (index for index, value in enumerate(absolute_samples) if value >= peak * 0.10),
            default=0,
        ) / sample_rate
    else:
        attack_time = duration
        last_tenth_peak_time = 0

    window_size = max(1, int(sample_rate * 0.010)) if sample_rate else 1
    envelope = []
    for offset in range(0, len(samples), window_size):
        chunk = samples[offset:offset + window_size]
        if not chunk:
            continue
        envelope.append(math.sqrt(sum(sample * sample for sample in chunk) / len(chunk)) / full_scale)

    max_envelope = max(envelope) if envelope else 0
    active_duration = (
        sum(1 for value in envelope if value >= max_envelope * 0.15) * 0.010
        if max_envelope > 0
        else 0
    )
    zero_crossings = sum(
        1 for before, after in zip(samples, samples[1:])
        if (before < 0 <= after) or (before > 0 >= after)
    )
    zero_crossing_rate = zero_crossings / max(1, len(samples) - 1)

    spectrum_frequencies = [300, 600, 900, 1200, 1800, 2400, 3200, 4200, 5600, 7200, 9000]
    spectral_samples = [sample / full_scale for sample in samples[:max(1, min(len(samples), int(sample_rate * 0.18)))]]
    spectral_powers = []
    for frequency in spectrum_frequencies:
        real = 0.0
        imaginary = 0.0
        step = 2 * math.pi * frequency / sample_rate if sample_rate else 0.0
        for index, sample in enumerate(spectral_samples):
            real += sample * math.cos(step * index)
            imaginary -= sample * math.sin(step * index)
        spectral_powers.append(real * real + imaginary * imaginary)

    spectral_power_total = sum(spectral_powers)
    spectral_centroid = (
        sum(frequency * power for frequency, power in zip(spectrum_frequencies, spectral_powers)) / spectral_power_total
        if spectral_power_total > 0
        else 0
    )
    high_ratio = (
        sum(power for frequency, power in zip(spectrum_frequencies, spectral_powers) if frequency >= 3200) / spectral_power_total
        if spectral_power_total > 0
        else 0
    )
    low_ratio = (
        sum(power for frequency, power in zip(spectrum_frequencies, spectral_powers) if frequency <= 900) / spectral_power_total
        if spectral_power_total > 0
        else 0
    )

    row_issues = []
    if channels != 1:
        row_issues.append(f"expected mono, got {channels} channels")
    if sample_width != 2:
        row_issues.append(f"expected 16-bit PCM, got {sample_width * 8}-bit samples")
    if sample_rate != 22050:
        row_issues.append(f"expected 22050 Hz, got {sample_rate} Hz")
    if not (0.05 <= duration <= 0.75):
        row_issues.append(f"expected duration 0.05-0.75s, got {duration:.3f}s")
    if not (-18.0 <= peak_db <= -3.0):
        row_issues.append(f"expected peak between -18 and -3 dBFS, got {peak_db:.1f} dBFS")
    if not (-28.0 <= rms_db <= -8.0):
        row_issues.append(f"expected RMS between -28 and -8 dBFS, got {rms_db:.1f} dBFS")
    if active_duration < min(duration * 0.55, 0.08):
        row_issues.append(f"expected non-trivial envelope activity, got active_duration={active_duration:.3f}s")

    profile = event_profiles.get(name)
    if profile is None:
        row_issues.append("missing event-specific SFX profile")
    else:
        if "duration" in profile:
            minimum, maximum = profile["duration"]
            if not (minimum <= duration <= maximum):
                row_issues.append(f"expected profile duration {minimum:.2f}-{maximum:.2f}s, got {duration:.3f}s")
        if "centroid" in profile:
            minimum, maximum = profile["centroid"]
            if not (minimum <= spectral_centroid <= maximum):
                row_issues.append(
                    f"expected profile spectral centroid {minimum:.0f}-{maximum:.0f}Hz, got {spectral_centroid:.0f}Hz"
                )
        if "zcr" in profile:
            minimum, maximum = profile["zcr"]
            if not (minimum <= zero_crossing_rate <= maximum):
                row_issues.append(
                    f"expected profile zero-crossing rate {minimum:.3f}-{maximum:.3f}, got {zero_crossing_rate:.3f}"
                )
        if "attack_ms_min" in profile and attack_time * 1000 < profile["attack_ms_min"]:
            row_issues.append(
                f"expected slower onset at least {profile['attack_ms_min']:.0f}ms, got {attack_time * 1000:.1f}ms"
            )
        if "attack_ms_max" in profile and attack_time * 1000 > profile["attack_ms_max"]:
            row_issues.append(
                f"expected fast onset at most {profile['attack_ms_max']:.0f}ms, got {attack_time * 1000:.1f}ms"
            )
        if "high_ratio_min" in profile and high_ratio < profile["high_ratio_min"]:
            row_issues.append(
                f"expected high-frequency ratio >= {profile['high_ratio_min']:.2f}, got {high_ratio:.2f}"
            )
        if "low_ratio_min" in profile and low_ratio < profile["low_ratio_min"]:
            row_issues.append(
                f"expected low-frequency ratio >= {profile['low_ratio_min']:.2f}, got {low_ratio:.2f}"
            )

    if row_issues:
        issues.append((name, row_issues))

    rows.append(
        {
            "name": name,
            "duration": duration,
            "channels": channels,
            "sample_width": sample_width,
            "sample_rate": sample_rate,
            "rms_db": rms_db,
            "peak_db": peak_db,
            "attack_ms": attack_time * 1000,
            "last_tenth_peak": last_tenth_peak_time,
            "active_duration": active_duration,
            "zero_crossing_rate": zero_crossing_rate,
            "spectral_centroid": spectral_centroid,
            "high_ratio": high_ratio,
            "low_ratio": low_ratio,
            "sha256": file_hash_by_name[name],
            "bytes": file_bytes_by_name[name],
        }
    )

duplicate_audio_payloads = [
    names for names in content_hashes.values()
    if len(names) > 1
]
for names in duplicate_audio_payloads:
    issues.append(("duplicate_audio_payload", [f"identical WAV payload reused by {', '.join(sorted(names))}"]))

rows_by_name = {row["name"]: row for row in rows}
manifest_issues = []
manifest_header = [
    "resourceName",
    "event",
    "provenance",
    "officialAudio",
    "sampleRate",
    "channels",
    "bitDepth",
    "durationSeconds",
    "sha256",
    "bytes",
    "note",
]
manifest_lines = [line for line in sfx_manifest.read_text(encoding="utf-8").splitlines() if line.strip()]
manifest_rows = []
if not manifest_lines:
    manifest_issues.append("SFX manifest is empty")
else:
    header = manifest_lines[0].split("\t")
    if header != manifest_header:
        manifest_issues.append("SFX manifest header does not match the expected provenance schema")
    for line_number, line in enumerate(manifest_lines[1:], start=2):
        columns = line.split("\t")
        if len(columns) != len(manifest_header):
            manifest_issues.append(f"line {line_number}: expected {len(manifest_header)} tab-separated columns, got {len(columns)}")
            continue
        manifest_rows.append(dict(zip(manifest_header, columns)))

manifest_by_resource = {row["resourceName"]: row for row in manifest_rows}
manifest_resources = set(manifest_by_resource)
expected_resources = set(expected)
for resource in sorted(expected_resources - manifest_resources):
    manifest_issues.append(f"{resource}: missing from SFX manifest")
for resource in sorted(manifest_resources - expected_resources):
    manifest_issues.append(f"{resource}: manifest row is not referenced by GameAudioEvent")

event_by_resource = {resource: event for event, resource in resource_by_event.items()}
for resource in sorted(expected_resources & manifest_resources):
    manifest = manifest_by_resource[resource]
    row = rows_by_name.get(resource)
    if row is None:
        continue

    expected_event = event_by_resource.get(resource)
    if manifest["event"] != expected_event:
        manifest_issues.append(f"{resource}: manifest event {manifest['event']} does not match GameAudioEvent {expected_event}")
    if manifest["provenance"] != "generated_substitute":
        manifest_issues.append(f"{resource}: provenance must stay generated_substitute until official isolated SFX are available")
    if manifest["officialAudio"] != "false":
        manifest_issues.append(f"{resource}: officialAudio must be false for local substitute SFX")
    if "not extracted from original TBH" not in manifest["note"]:
        manifest_issues.append(f"{resource}: note must explicitly say the cue is not extracted from original TBH")

    numeric_checks = [
        ("sampleRate", str(row["sample_rate"])),
        ("channels", str(row["channels"])),
        ("bitDepth", str(row["sample_width"] * 8)),
        ("durationSeconds", f"{row['duration']:.3f}"),
        ("sha256", row["sha256"]),
        ("bytes", str(row["bytes"])),
    ]
    for key, expected_value in numeric_checks:
        if manifest[key] != expected_value:
            manifest_issues.append(f"{resource}: manifest {key}={manifest[key]} does not match payload {expected_value}")

relationship_issues = []

def require_relationship(condition, message):
    if not condition:
        relationship_issues.append(message)

if "sfx_hero_attack" in rows_by_name and "sfx_hero_critical_hit" in rows_by_name:
    attack = rows_by_name["sfx_hero_attack"]
    critical = rows_by_name["sfx_hero_critical_hit"]
    require_relationship(
        critical["duration"] > attack["duration"],
        "critical hit SFX should be longer than basic attack SFX",
    )
    require_relationship(
        critical["high_ratio"] >= attack["high_ratio"] + 0.12,
        "critical hit SFX should carry clearly more high-frequency energy than basic attack SFX",
    )
    require_relationship(
        critical["zero_crossing_rate"] > attack["zero_crossing_rate"],
        "critical hit SFX should be more transient/noisy than basic attack SFX",
    )

if "sfx_skill_cast" in rows_by_name and "sfx_hero_attack" in rows_by_name:
    skill = rows_by_name["sfx_skill_cast"]
    attack = rows_by_name["sfx_hero_attack"]
    require_relationship(
        skill["duration"] > attack["duration"],
        "skill-cast SFX should be longer than basic attack SFX",
    )
    require_relationship(
        skill["attack_ms"] > attack["attack_ms"] * 2,
        "skill-cast SFX should have a slower onset than basic attack SFX",
    )

if "sfx_battle_won" in rows_by_name and "sfx_battle_lost" in rows_by_name:
    won = rows_by_name["sfx_battle_won"]
    lost = rows_by_name["sfx_battle_lost"]
    require_relationship(
        lost["spectral_centroid"] < won["spectral_centroid"],
        "battle-lost SFX should be lower-pitched than battle-won SFX",
    )

if "sfx_level_up" in rows_by_name and "sfx_preview" in rows_by_name:
    level_up = rows_by_name["sfx_level_up"]
    preview = rows_by_name["sfx_preview"]
    require_relationship(
        level_up["duration"] > preview["duration"] * 2,
        "level-up SFX should read as a longer progression cue than preview SFX",
    )

if "sfx_item_consumed" in rows_by_name and "sfx_item_equipped" in rows_by_name:
    consumed = rows_by_name["sfx_item_consumed"]
    equipped = rows_by_name["sfx_item_equipped"]
    require_relationship(
        consumed["duration"] >= equipped["duration"],
        "item-consumed SFX should be at least as long as item-equipped SFX",
    )
    require_relationship(
        consumed["spectral_centroid"] > equipped["spectral_centroid"],
        "item-consumed SFX should sound more magical/transformative than item-equipped SFX",
    )

sequence_issues = []
sequence_rows = []
sequence_definitions = {
    "combat_burst": [
        ("sfx_hero_attack", 0.00),
        ("sfx_hero_critical_hit", 0.13),
        ("sfx_skill_cast", 0.34),
        ("sfx_hero_damaged", 0.64),
    ],
    "reward_chain": [
        ("sfx_battle_won", 0.00),
        ("sfx_loot_found", 0.34),
        ("sfx_item_equipped", 0.62),
        ("sfx_item_consumed", 0.82),
        ("sfx_level_up", 1.08),
        ("sfx_preview", 1.52),
    ],
    "defeat_chain": [
        ("sfx_hero_damaged", 0.00),
        ("sfx_battle_lost", 0.22),
    ],
}

def render_sequence_mix(label, events):
    missing_sequence_assets = [
        name for name, _ in events
        if name not in samples_by_name or name not in volume_by_resource
    ]
    if missing_sequence_assets:
        sequence_issues.append(f"{label}: missing sequence assets {', '.join(missing_sequence_assets)}")
        return

    sample_rates = {sample_rate_by_name[name] for name, _ in events}
    if len(sample_rates) != 1:
        sequence_issues.append(f"{label}: mixed sample rates {', '.join(str(rate) for rate in sorted(sample_rates))}")
        return

    sample_rate = sample_rates.pop()
    length = max(
        int((offset + len(samples_by_name[name]) / sample_rate) * sample_rate) + 1
        for name, offset in events
    )
    mix = [0.0] * length
    for name, offset in events:
        start = int(offset * sample_rate)
        gain = volume_by_resource[name]
        for index, sample in enumerate(samples_by_name[name]):
            mix[start + index] += sample * gain

    peak = max(abs(sample) for sample in mix) if mix else 0.0
    rms = math.sqrt(sum(sample * sample for sample in mix) / len(mix)) if mix else 0.0
    peak_db = dbfs(peak)
    rms_db = dbfs(rms)
    duration = len(mix) / sample_rate if sample_rate else 0.0

    sequence_rows.append(
        {
            "label": label,
            "duration": duration,
            "rms_db": rms_db,
            "peak_db": peak_db,
            "peak": peak,
            "events": len(events),
        }
    )

    if peak >= 0.98:
        sequence_issues.append(f"{label}: sequence mix is clipping or too hot, peak={peak_db:.1f} dBFS")
    if peak_db < -24.0:
        sequence_issues.append(f"{label}: sequence mix peak is too weak, peak={peak_db:.1f} dBFS")
    if not (-30.0 <= rms_db <= -16.0):
        sequence_issues.append(f"{label}: sequence mix RMS outside -30..-16 dBFS, rms={rms_db:.1f} dBFS")

for label, events in sequence_definitions.items():
    render_sequence_mix(label, events)

print(f"source={game_audio_swift}")
print(f"game_loop={game_loop_swift}")
print(f"battle_source={battle_swift}")
print(f"sfx_dir={sfx_dir}")
print(f"sfx_manifest={sfx_manifest}")
print(f"expected_events={len(audio_events)}")
print(f"battle_event_routes={len(battle_events)}")
print()
print("name                         dur_s  ch  hz     bits  rms_dbfs  peak_dbfs  atk_ms  zcr    centroid  hi    lo")
print("---------------------------  -----  --  -----  ----  --------  ---------  ------  -----  --------  ----  ----")
for row in rows:
    print(
        f"{row['name']:<27}  "
        f"{row['duration']:>5.3f}  "
        f"{row['channels']:>2}  "
        f"{row['sample_rate']:>5}  "
        f"{row['sample_width'] * 8:>4}  "
        f"{row['rms_db']:>8.1f}  "
        f"{row['peak_db']:>9.1f}  "
        f"{row['attack_ms']:>6.1f}  "
        f"{row['zero_crossing_rate']:>5.3f}  "
        f"{row['spectral_centroid']:>8.0f}  "
        f"{row['high_ratio']:>4.2f}  "
        f"{row['low_ratio']:>4.2f}"
    )

if rows:
    durations = [row["duration"] for row in rows]
    rms_values = [row["rms_db"] for row in rows]
    peak_values = [row["peak_db"] for row in rows]
    centroids = [row["spectral_centroid"] for row in rows]
    print()
    print(
        "summary="
        f"duration:{min(durations):.3f}-{max(durations):.3f}s, "
        f"rms:{min(rms_values):.1f}..{max(rms_values):.1f}dBFS, "
        f"peak:{min(peak_values):.1f}..{max(peak_values):.1f}dBFS, "
        f"centroid:{min(centroids):.0f}..{max(centroids):.0f}Hz"
    )
    print("trailer_reference=RMS about -16.4 dB, integrated loudness about -15.3 LUFS, true peak 0.0 dBFS")
    print("event_profile_checks=duration,envelope,onset,zero_crossing,spectral_centroid,high_low_ratio,duplicate_payloads")
    print("sfx_manifest_checks=event_mapping,generated_substitute_provenance,official_audio_false,format,duration,sha256,bytes")

if sequence_rows:
    print()
    print("sequence_mix                events  dur_s  rms_dbfs  peak_dbfs")
    print("--------------------------  ------  -----  --------  ---------")
    for row in sequence_rows:
        print(
            f"{row['label']:<26}  "
            f"{row['events']:>6}  "
            f"{row['duration']:>5.3f}  "
            f"{row['rms_db']:>8.1f}  "
            f"{row['peak_db']:>9.1f}"
        )
    print("sequence_mix_checks=runtime_volume,combat_burst,reward_chain,defeat_chain,peak_headroom,rms_energy")

if volume_by_event:
    volume_values = [volume_by_event[event] for event in audio_events if event in volume_by_event]
    print()
    print(
        "volume_range="
        f"{min(volume_values):.2f}-{max(volume_values):.2f}"
    )
    print(
        "volumes="
        + ",".join(f"{event}:{volume_by_event[event]:.2f}" for event in audio_events if event in volume_by_event)
    )
    print("runtime_volume_checks=event_mapping,event_profile_ranges,terminal_vs_inventory_level")

if interval_by_event:
    interval_values = [interval_by_event[event] for event in audio_events if event in interval_by_event]
    print()
    print(
        "minimum_interval_range="
        f"{min(interval_values):.2f}-{max(interval_values):.2f}s"
    )
    print(
        "minimum_intervals="
        + ",".join(f"{event}:{interval_by_event[event]:.2f}" for event in audio_events if event in interval_by_event)
    )
    print("runtime_throttle_checks=event_mapping,event_profile_ranges,combat_vs_terminal_spacing")

if missing:
    print(f"missing={', '.join(missing)}", file=sys.stderr)
if extra:
    print(f"extra_unreferenced={', '.join(extra)}", file=sys.stderr)
if missing_resource_mapping:
    print(f"missing_resource_mapping={', '.join(missing_resource_mapping)}", file=sys.stderr)
if missing_volume_mapping:
    print(f"missing_volume_mapping={', '.join(missing_volume_mapping)}", file=sys.stderr)
if missing_interval_mapping:
    print(f"missing_interval_mapping={', '.join(missing_interval_mapping)}", file=sys.stderr)
if unknown_resource_mapping:
    print(f"unknown_resource_mapping={', '.join(unknown_resource_mapping)}", file=sys.stderr)
if unrouted_audio_events:
    print(f"unrouted_audio_events={', '.join(unrouted_audio_events)}", file=sys.stderr)
if unknown_played_events:
    print(f"unknown_played_audio_events={', '.join(unknown_played_events)}", file=sys.stderr)
if unhandled_battle_events:
    print(f"unhandled_battle_events={', '.join(unhandled_battle_events)}", file=sys.stderr)
for issue in route_issues:
    print(f"battle_route_issue={issue}", file=sys.stderr)
for issue in relationship_issues:
    print(f"sfx_relationship_issue={issue}", file=sys.stderr)
for issue in sequence_issues:
    print(f"sfx_sequence_issue={issue}", file=sys.stderr)
for issue in volume_issues:
    print(f"sfx_volume_issue={issue}", file=sys.stderr)
for issue in interval_issues:
    print(f"sfx_interval_issue={issue}", file=sys.stderr)
for issue in manifest_issues:
    print(f"sfx_manifest_issue={issue}", file=sys.stderr)
for name, row_issues in issues:
    for issue in row_issues:
        print(f"{name}: {issue}", file=sys.stderr)

if (
    missing
    or extra
    or missing_resource_mapping
    or missing_volume_mapping
    or missing_interval_mapping
    or unknown_resource_mapping
    or unrouted_audio_events
    or unknown_played_events
    or unhandled_battle_events
    or route_issues
    or relationship_issues
    or sequence_issues
    or volume_issues
    or interval_issues
    or manifest_issues
    or issues
):
    sys.exit(1)

print("local SFX audit passed")
PY

if [[ "${AUDIT_LOCAL_SFX_SKIP_PACKAGED:-0}" != "1" &&
      -d "$packaged_sfx_dir" &&
      "$sfx_dir" != "$packaged_sfx_dir" ]]; then
  echo
  echo "packaged_app_sfx_audit"
  echo "----------------------"
  SFX_DIR="$packaged_sfx_dir" \
    SFX_MANIFEST="$packaged_sfx_dir/sfx_manifest.tsv" \
    GAME_AUDIO_SWIFT="$game_audio_swift" \
    GAME_LOOP_SWIFT="$game_loop_swift" \
    BATTLE_SWIFT="$battle_swift" \
    AUDIT_LOCAL_SFX_SKIP_PACKAGED=1 \
    "$0"

  python3 - "$sfx_dir" "$packaged_sfx_dir" "$game_audio_swift" "$sfx_manifest" "$packaged_sfx_dir/sfx_manifest.tsv" <<'PY'
import hashlib
import re
import sys
from pathlib import Path

source_dir = Path(sys.argv[1])
packaged_dir = Path(sys.argv[2])
game_audio_path = Path(sys.argv[3])
source_manifest = Path(sys.argv[4])
packaged_manifest = Path(sys.argv[5])

source = game_audio_path.read_text(encoding="utf-8")
event_enum = re.search(r'enum\s+GameAudioEvent\s*:\s*String,\s*CaseIterable\s*\{(?P<body>.*?)\n\}', source, re.S)
if not event_enum:
    print(f"Could not locate GameAudioEvent enum in {game_audio_path}", file=sys.stderr)
    sys.exit(2)

audio_events = re.findall(r'^\s*case\s+(\w+)\b', event_enum.group("body"), re.M)
resource_pairs = re.findall(r'case\s+\.(\w+):\s+return\s+"(sfx_[^"]+)"', source)
resource_by_event = {event: resource for event, resource in resource_pairs}
expected = sorted(
    f"{resource_by_event[event]}.wav"
    for event in audio_events
    if event in resource_by_event
)

issues = []

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for name in expected:
    source_path = source_dir / name
    packaged_path = packaged_dir / name
    if not source_path.is_file():
        issues.append(f"source SFX resource missing: {name}")
        continue
    if not packaged_path.is_file():
        issues.append(f"packaged app SFX resource missing: {name}")
        continue
    if digest(source_path) != digest(packaged_path):
        issues.append(f"packaged app SFX resource differs from source: {name}")

extra_packaged = sorted(path.name for path in packaged_dir.glob("*.wav") if path.name not in expected)
for name in extra_packaged:
    issues.append(f"packaged app has unexpected SFX resource: {name}")

if not source_manifest.is_file():
    issues.append(f"source SFX manifest missing: {source_manifest}")
elif not packaged_manifest.is_file():
    issues.append(f"packaged app SFX manifest missing: {packaged_manifest}")
elif digest(source_manifest) != digest(packaged_manifest):
    issues.append("packaged app SFX manifest differs from source manifest")

if issues:
    print("packaged app SFX payload issues:")
    for issue in issues:
        print(f"- {issue}")
    sys.exit(1)

print(f"packaged_app_sfx_payload_match=checked wavs:{len(expected)} manifest:1")
PY
fi
