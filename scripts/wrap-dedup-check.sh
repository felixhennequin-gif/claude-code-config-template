#!/usr/bin/env bash
# wrap-dedup-check.sh
# Usage: wrap-dedup-check.sh <wrap-file.md>
#
# Greps each proposal's target file for the proposed added lines. If a
# proposed "+ " line already exists verbatim in the target, prints a
# warning so the user can drop the duplicate before review.
#
# Not a substitute for human review — a rule phrased differently may
# still cover the same ground. This only catches verbatim duplicates.
#
# Portability: uses POSIX awk (mawk, busybox awk, gawk all work).

set -euo pipefail

WRAP_FILE="${1:-}"
if [[ -z "$WRAP_FILE" || ! -f "$WRAP_FILE" ]]; then
  echo "usage: $0 <wrap-file.md>" >&2
  exit 1
fi

awk '
  /^### \[.?\]/ { in_proposal = 1; target = ""; in_diff = 0; next }
  in_proposal && /^\*\*Target:\*\*/ {
    n = split($0, a, "`")
    if (n >= 3) target = a[2]
  }
  in_proposal && /^```diff/ { in_diff = 1; next }
  in_proposal && in_diff && /^```/ { in_diff = 0; in_proposal = 0; next }
  in_proposal && in_diff && /^\+[^+]/ {
    line = substr($0, 2)
    sub(/^[[:space:]]+/, "", line)
    if (length(line) > 10 && target != "") {
      printf "%s\t%s\n", target, line
    }
  }
' "$WRAP_FILE" | while IFS=$'\t' read -r target line; do
  if [[ -f "$target" ]] && grep -qF -- "$line" "$target" 2>/dev/null; then
    echo "DUPLICATE: $target already contains: $line"
  fi
done
