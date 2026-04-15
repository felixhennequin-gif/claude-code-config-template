#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook for Bash — blocks a small, explicit list of classically
# dangerous commands. The name is deliberately narrow: this is NOT a
# comprehensive safety net. It catches famous footguns (`rm -rf /`,
# `git push --force`, `dd if=`, `mkfs.*`, accidental `npm publish`) and
# nothing else. It does NOT block:
#   - curl … | bash / wget … | sh (supply-chain vectors)
#   - writes to ~/.ssh, ~/.bashrc, ~/.profile
#   - docker system prune -af --volumes
#   - yarn / pnpm / cargo / twine publishes
# If you need broader coverage, add patterns yourself and extend the smoke
# tests in .github/workflows/lint.yml — do not assume this hook already
# protects against the command you're about to run.
#
# Reads tool input from stdin (JSON with "command" field).
# Fail-closed: if the payload can't be parsed, block the call.

INPUT=$(cat)

# Extract a JSON string field from $INPUT. Uses awk (POSIX base utility) so
# the hook stays stack-agnostic — no jq, no node, no python. Handles the
# common escape sequences (\" \\ \n \t \r). Not a full JSON parser; good
# enough for Claude Code's well-formed hook payloads.
extract_json_string() {
  local key="$1"
  printf '%s' "$INPUT" | awk -v key="$key" '
    { buf = buf $0 "\n" }
    END {
      pat = "\"" key "\"[[:space:]]*:[[:space:]]*\""
      if (match(buf, pat)) {
        s = substr(buf, RSTART + RLENGTH)
        out = ""
        i = 1
        n = length(s)
        while (i <= n) {
          c = substr(s, i, 1)
          if (c == "\\" && i < n) {
            nc = substr(s, i + 1, 1)
            if (nc == "n") out = out "\n"
            else if (nc == "t") out = out "\t"
            else if (nc == "r") out = out "\r"
            else out = out nc
            i += 2
          } else if (c == "\"") {
            print out
            exit
          } else {
            out = out c
            i += 1
          }
        }
      }
    }
  '
}

COMMAND=$(extract_json_string command)

if [ -z "$COMMAND" ]; then
  echo "BLOCKED: dangerous-rm-guard hook could not parse command from stdin (fail-closed)." >&2
  echo "reason: A safety hook that cannot read its input must block. Check the JSON payload format." >&2
  exit 2
fi

# Literal-substring patterns — unambiguous, no prefix/suffix problems.
LITERAL_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "> /dev/sda"
  "mkfs."
  "dd if="
  ":(){:|:&};:"
)

for PATTERN in "${LITERAL_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$PATTERN"; then
    echo "BLOCKED: command matches dangerous pattern '$PATTERN'" >&2
    echo "reason: This command is blocked by the dangerous-rm-guard hook. If you really need to run it, do so manually outside Claude Code." >&2
    exit 2
  fi
done

# Regex patterns — surgical matches that avoid false positives.
# rm -rf . as the entire target (not "rm -rf ./dist" or "rm -rf .cache")
if echo "$COMMAND" | grep -qE '(^|[[:space:]])rm[[:space:]]+-[rRf]+[[:space:]]+\.([[:space:]]|$)'; then
  echo "BLOCKED: command matches dangerous pattern 'rm -rf .'" >&2
  echo "reason: This command is blocked by the dangerous-rm-guard hook. If you really need to run it, do so manually outside Claude Code." >&2
  exit 2
fi

# git push --force (but NOT --force-with-lease) and git push -f
if echo "$COMMAND" | grep -qE '(^|[[:space:]])git[[:space:]]+push[[:space:]].*(--force($|[[:space:]])|--force[^-]|-f($|[[:space:]]))'; then
  echo "BLOCKED: command matches dangerous pattern 'git push --force / -f'" >&2
  echo "reason: Use --force-with-lease instead. Blocked by the dangerous-rm-guard hook." >&2
  exit 2
fi

# npm publish (but NOT npm publish --dry-run)
if echo "$COMMAND" | grep -qE '(^|[[:space:]])npm[[:space:]]+publish($|[[:space:]])'; then
  if ! echo "$COMMAND" | grep -qE '(^|[[:space:]])npm[[:space:]]+publish[[:space:]].*--dry-run'; then
    echo "BLOCKED: command matches dangerous pattern 'npm publish'" >&2
    echo "reason: Blocked by the dangerous-rm-guard hook. Use --dry-run to preview." >&2
    exit 2
  fi
fi

exit 0
