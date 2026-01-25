#!/usr/bin/env bash
set -euo pipefail

# Thin wrapper: delegate argument parsing to the skill implementation so that calls like
# `bash scripts/run_autopilot.sh . --once --mode assist` work as expected.
bash ~/.codex/skills/research-team/scripts/bin/run_autopilot.sh "$@"
