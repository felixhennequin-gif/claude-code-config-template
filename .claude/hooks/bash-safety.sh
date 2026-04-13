#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook for Bash — blocks dangerous commands
# Reads tool input from stdin (JSON with "command" field)
# Fail-closed: if the payload can't be parsed, block the call.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || echo "$INPUT" | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    try { const j=JSON.parse(d); console.log((j.tool_input && j.tool_input.command) || j.command || ''); } catch { console.log(''); }
  });
" 2>/dev/null)

if [ -z "$COMMAND" ]; then
  echo "BLOCKED: bash-safety hook could not parse command from stdin (fail-closed)." >&2
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
    echo "reason: This command is blocked by the bash-safety hook. If you really need to run it, do so manually outside Claude Code." >&2
    exit 2
  fi
done

# Regex patterns — surgical matches that avoid false positives.
# rm -rf . as the entire target (not "rm -rf ./dist" or "rm -rf .cache")
if echo "$COMMAND" | grep -qE '(^|[[:space:]])rm[[:space:]]+-[rRf]+[[:space:]]+\.([[:space:]]|$)'; then
  echo "BLOCKED: command matches dangerous pattern 'rm -rf .'" >&2
  echo "reason: This command is blocked by the bash-safety hook. If you really need to run it, do so manually outside Claude Code." >&2
  exit 2
fi

# git push --force (but NOT --force-with-lease) and git push -f
if echo "$COMMAND" | grep -qE '(^|[[:space:]])git[[:space:]]+push[[:space:]].*(--force($|[[:space:]])|--force[^-]|-f($|[[:space:]]))'; then
  echo "BLOCKED: command matches dangerous pattern 'git push --force / -f'" >&2
  echo "reason: Use --force-with-lease instead. Blocked by the bash-safety hook." >&2
  exit 2
fi

# npm publish (but NOT npm publish --dry-run)
if echo "$COMMAND" | grep -qE '(^|[[:space:]])npm[[:space:]]+publish($|[[:space:]])'; then
  if ! echo "$COMMAND" | grep -qE '(^|[[:space:]])npm[[:space:]]+publish[[:space:]].*--dry-run'; then
    echo "BLOCKED: command matches dangerous pattern 'npm publish'" >&2
    echo "reason: Blocked by the bash-safety hook. Use --dry-run to preview." >&2
    exit 2
  fi
fi

exit 0
