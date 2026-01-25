#!/usr/bin/env bash
set -euo pipefail

# Gemini CLI runner: one-shot with file-based prompt input and model fallback.
# Vendored copy for project-local use.

PROMPT_FILE=""
OUT=""
MODEL=""
OUTPUT_FORMAT="text"

usage() {
  cat <<'EOF'
run_gemini.sh

Usage:
  run_gemini.sh --prompt-file PROMPT.txt --out OUT.txt

Options:
  --model MODEL           Optional (e.g. gemini-3.0-pro). If invalid, script falls back to default model.
  --output-format FORMAT  Default: text (choices depend on gemini CLI; typically text/json/stream-json)
  --prompt-file FILE      Required
  --out PATH              Required
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2;;
    --output-format) OUTPUT_FORMAT="$2"; shift 2;;
    --prompt-file) PROMPT_FILE="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

if [[ -z "${PROMPT_FILE}" || -z "${OUT}" ]]; then
  echo "Missing required args." >&2
  usage
  exit 2
fi
if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo "Prompt file not found: ${PROMPT_FILE}" >&2
  exit 2
fi
if ! command -v gemini >/dev/null 2>&1; then
  echo "gemini CLI not found in PATH" >&2
  exit 2
fi

PROMPT="$(cat "${PROMPT_FILE}")"

tmp_out="$(mktemp)"
trap 'rm -f "${tmp_out}"' EXIT

set +e
if [[ -n "${MODEL}" ]]; then
  gemini -m "${MODEL}" -o "${OUTPUT_FORMAT}" "${PROMPT}" >"${tmp_out}" 2>&1
  code=$?
else
  gemini -o "${OUTPUT_FORMAT}" "${PROMPT}" >"${tmp_out}" 2>&1
  code=$?
fi
set -e

if [[ $code -ne 0 && -n "${MODEL}" ]]; then
  # Fallback: omit -m in case the local CLI uses different model aliases.
  set +e
  gemini -o "${OUTPUT_FORMAT}" "${PROMPT}" >"${tmp_out}" 2>&1
  code=$?
  set -e
fi

if [[ $code -ne 0 ]]; then
  cat "${tmp_out}" >&2
  exit $code
fi

mkdir -p "$(dirname "${OUT}")"
mv "${tmp_out}" "${OUT}"
