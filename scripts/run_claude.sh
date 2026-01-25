#!/usr/bin/env bash
set -euo pipefail

# Claude CLI runner: one-shot (--print) with retries and file-based prompts.
# Vendored copy for project-local use.

MODEL="opus"
SYSTEM_PROMPT_FILE=""
PROMPT_FILE=""
OUT=""
MAX_RETRIES=6
SLEEP_SECS=10
TOOLS='""'

usage() {
  cat <<'EOF'
run_claude.sh

Usage:
  run_claude.sh --system-prompt-file SYS.txt --prompt-file PROMPT.txt --out OUT.txt

Options:
  --model MODEL            Default: opus
  --tools TOOLS            Default: "" (disable tools). Example: "default"
  --system-prompt-file F   Required
  --prompt-file F          Required
  --out PATH               Required (stdout+stderr captured)
  --max-retries N          Default: 6
  --sleep-secs SECONDS     Default: 10 (base; exponential backoff)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2;;
    --tools) TOOLS="$2"; shift 2;;
    --system-prompt-file) SYSTEM_PROMPT_FILE="$2"; shift 2;;
    --prompt-file) PROMPT_FILE="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --max-retries) MAX_RETRIES="$2"; shift 2;;
    --sleep-secs) SLEEP_SECS="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

if [[ -z "${SYSTEM_PROMPT_FILE}" || -z "${PROMPT_FILE}" || -z "${OUT}" ]]; then
  echo "Missing required args." >&2
  usage
  exit 2
fi
if [[ ! -f "${SYSTEM_PROMPT_FILE}" ]]; then
  echo "System prompt file not found: ${SYSTEM_PROMPT_FILE}" >&2
  exit 2
fi
if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo "Prompt file not found: ${PROMPT_FILE}" >&2
  exit 2
fi
if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found in PATH" >&2
  exit 2
fi

SYSTEM_PROMPT="$(cat "${SYSTEM_PROMPT_FILE}")"
PROMPT="$(cat "${PROMPT_FILE}")"

tmp_out="$(mktemp)"
trap 'rm -f "${tmp_out}"' EXIT

attempt=1
while true; do
  set +e
  # shellcheck disable=SC2086
  claude --print --no-session-persistence --model "${MODEL}" --tools ${TOOLS} \
    --system-prompt "${SYSTEM_PROMPT}" \
    "${PROMPT}" >"${tmp_out}" 2>&1
  code=$?
  set -e

  if [[ $code -eq 0 ]]; then
    mkdir -p "$(dirname "${OUT}")"
    mv "${tmp_out}" "${OUT}"
    exit 0
  fi

  if [[ $attempt -ge $MAX_RETRIES ]]; then
    echo "Claude failed after ${MAX_RETRIES} attempts (last exit ${code})." >&2
    cat "${tmp_out}" >&2
    exit $code
  fi

  sleep_for=$(( SLEEP_SECS * (2 ** (attempt - 1)) ))
  echo "Attempt ${attempt} failed (exit ${code}); retrying in ${sleep_for}s..." >&2
  sleep "${sleep_for}"
  attempt=$(( attempt + 1 ))
done
