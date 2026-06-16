#!/usr/bin/env bash
set -euo pipefail

workflow_dir="${WORKFLOW_DIR:-.github/workflows}"

python3 - "$workflow_dir" <<'PY'
import sys
from pathlib import Path

workflow_dir = Path(sys.argv[1])

workflow_files = [
    workflow_dir / "ci.yml",
    workflow_dir / "release.yml",
    workflow_dir / "nightly.yml",
]

required_audit_commands = [
    "swift run TBH --resource-self-test",
    "scripts/audit-local-workflow-fidelity-gates.sh",
    "scripts/audit-local-gameplay-fidelity.sh",
    "scripts/audit-local-app-icons.sh",
    "scripts/audit-local-item-icons.sh",
    "scripts/audit-local-rune-icons.sh",
    "scripts/audit-local-passive-skill-icons.sh",
    "scripts/audit-local-hero-sprites.sh",
    "scripts/audit-local-sfx.sh",
    "RENDER_BATTLE_SCENE=1 scripts/audit-local-battle-scene.sh",
]

package_command = "bash scripts/package-app.sh dist"

required_packaged_audit_commands = [
    "scripts/audit-local-app-icons.sh",
    "scripts/audit-local-item-icons.sh",
    "scripts/audit-local-rune-icons.sh",
    "scripts/audit-local-passive-skill-icons.sh",
    "scripts/audit-local-hero-sprites.sh",
    "scripts/audit-local-sfx.sh",
    "PACKAGED_BATTLE_SCENE_RENDER=1 RENDER_BATTLE_SCENE=1 scripts/audit-local-battle-scene.sh",
]

issues = []
rows = []

for workflow_file in workflow_files:
    if not workflow_file.is_file():
        issues.append(f"missing workflow file: {workflow_file}")
        continue

    source = workflow_file.read_text(encoding="utf-8")
    command_positions = {}
    for command in required_audit_commands:
        index = source.find(command)
        if index == -1:
            issues.append(f"{workflow_file}: missing required fidelity gate command `{command}`")
        command_positions[command] = index

    package_index = source.find(package_command)
    if package_index == -1:
        issues.append(f"{workflow_file}: missing package command `{package_command}`")

    packaged_positions = {}
    for command in required_packaged_audit_commands:
        index = source.find(command, package_index if package_index >= 0 else 0)
        if index == -1:
            issues.append(f"{workflow_file}: missing packaged fidelity gate command after package `{command}`")
        packaged_positions[command] = index

    present_positions = [
        position for position in command_positions.values()
        if position >= 0
    ]
    if present_positions and package_index >= 0 and package_index < max(present_positions):
        issues.append(f"{workflow_file}: package command runs before all fidelity gates finish")

    previous_command = None
    previous_index = -1
    for command in required_audit_commands:
        index = command_positions[command]
        if index < 0:
            continue
        if previous_index >= 0 and index < previous_index:
            issues.append(
                f"{workflow_file}: fidelity gate `{command}` appears before `{previous_command}`"
            )
        previous_command = command
        previous_index = index

    rows.append(
        (
            workflow_file.name,
            sum(1 for position in command_positions.values() if position >= 0),
            len(required_audit_commands),
            "yes" if package_index >= 0 else "no",
            sum(1 for position in packaged_positions.values() if position >= 0),
            len(required_packaged_audit_commands),
        )
    )

print(f"workflow_dir={workflow_dir}")
print()
print("workflow      gates  package  packaged")
print("------------  -----  -------  --------")
for name, present_count, required_count, has_package, packaged_count, packaged_required_count in rows:
    print(f"{name:<12}  {present_count:>2}/{required_count:<2}  {has_package:<7}  {packaged_count:>2}/{packaged_required_count:<2}")

if issues:
    print()
    for issue in issues:
        print(f"workflow_gate_issue={issue}", file=sys.stderr)
    sys.exit(1)

print()
print("local workflow fidelity gates audit passed")
PY
