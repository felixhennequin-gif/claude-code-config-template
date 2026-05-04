#!/usr/bin/env bash
# action-pin-check.sh — flag GitHub Actions references that are not pinned to a full SHA.
#
# Usage:
#   action-pin-check.sh <path-to-workflow.yml> [more-workflows...]
#
# Parses `uses:` lines and verifies the ref after the `@` is a 40-character
# hex SHA. Anything else (tag, branch, short SHA) fails. Local actions
# (./path) and reusable workflow calls (./.github/workflows/foo.yml) are
# skipped. Exits 0 if everything is pinned, 1 if anything is loose, 2 on
# usage errors.

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "usage: action-pin-check.sh <workflow.yml> [more...]" >&2
  exit 2
fi

fail=0

for file in "$@"; do
  if [ ! -f "$file" ]; then
    echo "error: $file does not exist" >&2
    fail=1
    continue
  fi

  # Extract every `uses:` reference (ignoring commented lines).
  while IFS= read -r line; do
    # Strip leading whitespace, the `uses:` keyword, and any trailing comment.
    ref=$(printf '%s\n' "$line" \
      | sed -E 's/^\s*uses:\s*//; s/\s*#.*$//' \
      | tr -d '"'"'")

    [ -z "$ref" ] && continue

    # Skip local actions and reusable workflow calls.
    case "$ref" in
      ./*) continue ;;
    esac

    # Must contain `@`
    if [[ "$ref" != *"@"* ]]; then
      echo "::error file=$file::unpinned reference (no @): $ref"
      fail=1
      continue
    fi

    version=${ref##*@}

    # Full SHA = 40 hex characters.
    if [[ ! "$version" =~ ^[0-9a-f]{40}$ ]]; then
      echo "::error file=$file::not pinned to full SHA: $ref"
      fail=1
    fi
  done < <(grep -nE '^\s*uses:\s*' "$file" | grep -v '^\s*#' | cut -d: -f3-)
done

if [ "$fail" -eq 0 ]; then
  echo "OK: all action references are SHA-pinned"
fi

exit "$fail"
