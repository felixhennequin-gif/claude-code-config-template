#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook for Bash — blocks dangerous commands
# Reads tool input from stdin (JSON with "command" field)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null || echo "$INPUT" | node -e "
  let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
    try { const j=JSON.parse(d); console.log((j.tool_input && j.tool_input.command) || j.command || ''); } catch { console.log(''); }
  });
" 2>/dev/null)

# Block patterns (literal substrings — matched via grep -F)
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf ."
  "git push --force"
  "git push -f "
  "npm publish"
  "npx publish"
  "> /dev/sda"
  "mkfs."
  "dd if="
  ":(){:|:&};:"
)

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$PATTERN"; then
    echo "BLOCKED: command matches dangerous pattern '$PATTERN'" >&2
    echo "reason: This command is blocked by the bash-safety hook. If you really need to run it, do so manually outside Claude Code." >&2
    exit 2
  fi
done

exit 0
