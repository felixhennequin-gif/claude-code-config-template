#!/bin/bash
# Hook: auto-lint after edit
# Called by .claude/settings.json PostToolUse on Edit|MultiEdit|Write
#
# Runs ESLint --fix on the edited file silently.
# Exits 0 even on failure (non-blocking).

FILE="$CLAUDE_FILE_PATH"

if [ -z "$FILE" ]; then
  exit 0
fi

# Only lint JS/TS/JSX/TSX files
case "$FILE" in
  *.js|*.ts|*.jsx|*.tsx)
    cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
    npx eslint --fix "$FILE" 2>/dev/null || true
    ;;
esac

exit 0
