#!/usr/bin/env bash
# PostToolUse hook: auto-lint the edited file
# Triggered by .claude/settings.json on Edit|MultiEdit|Write.
#
# Claude Code passes hook context as JSON on stdin, NOT as env vars, so we
# parse tool_input.file_path ourselves. Non-blocking: any failure exits 0.

set -u

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
else
  # jq fallback — node is always available since Claude Code runs on it
  FILE=$(printf '%s' "$INPUT" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(JSON.parse(s).tool_input.file_path||"")}catch(e){}})' 2>/dev/null)
fi

[ -z "${FILE:-}" ] && exit 0

case "$FILE" in
  *.js|*.ts|*.jsx|*.tsx|*.mjs|*.cjs)
    cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
    npx --no-install eslint --fix "$FILE" >/dev/null 2>&1 || true
    ;;
esac

exit 0
