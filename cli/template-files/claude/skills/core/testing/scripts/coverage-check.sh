#!/usr/bin/env bash
# coverage-check.sh — enforce a coverage floor.
#
# Usage:
#   <coverage-tool> | coverage-check.sh <min-percent>
#
# Accepts one argument: the minimum coverage percentage (integer 0-100).
# Reads coverage output from stdin and detects the first percentage value
# it can recognize from any of: Istanbul/c8, pytest-cov, go cover.
# Exits 0 if coverage >= threshold, 1 otherwise, 2 on usage errors.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: coverage-check.sh <min-percent>" >&2
  exit 2
fi

threshold=$1

if ! [[ "$threshold" =~ ^[0-9]+$ ]] || [ "$threshold" -gt 100 ]; then
  echo "error: threshold must be an integer 0-100 (got: $threshold)" >&2
  exit 2
fi

input=$(cat)

if [ -z "$input" ]; then
  echo "error: no coverage output received on stdin" >&2
  exit 2
fi

# Try each format in turn. Stop at the first match.
pct=""

# 1. Istanbul / c8 — "All files ... | 87.5 | ..."
if [ -z "$pct" ]; then
  pct=$(printf '%s\n' "$input" \
    | grep -E '^All files' \
    | head -1 \
    | awk -F'|' '{gsub(/ /,"",$2); print $2}')
fi

# 2. pytest-cov — "TOTAL      123    45    63%"
if [ -z "$pct" ]; then
  pct=$(printf '%s\n' "$input" \
    | grep -E '^TOTAL' \
    | head -1 \
    | awk '{gsub(/%/,"",$NF); print $NF}')
fi

# 3. go cover — "coverage: 72.4% of statements"
if [ -z "$pct" ]; then
  pct=$(printf '%s\n' "$input" \
    | grep -Eo 'coverage: [0-9]+(\.[0-9]+)?%' \
    | head -1 \
    | awk '{gsub(/%/,"",$2); print $2}')
fi

if [ -z "$pct" ]; then
  echo "error: could not parse coverage percentage from stdin" >&2
  echo "       supported formats: Istanbul/c8, pytest-cov, go cover" >&2
  exit 2
fi

# Compare as integer (truncate fractional part).
pct_int=${pct%.*}

if [ "$pct_int" -lt "$threshold" ]; then
  echo "FAIL: coverage ${pct}% is below threshold ${threshold}%" >&2
  exit 1
fi

echo "OK: coverage ${pct}% meets threshold ${threshold}%"
exit 0
