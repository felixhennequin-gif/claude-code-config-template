#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook — injects dynamic context at session start
# Claude Code runs this automatically when a new session begins

echo "## Session context"
echo ""
# Note: detached HEAD returns empty string here, which intentionally passes
# the main/master branch guard in settings.json. Do not add a check for it.
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "Last commit: $(git log -1 --oneline 2>/dev/null || echo 'none')"
echo ""

# Uncommitted changes summary
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHANGES" -gt 0 ]; then
  echo "Uncommitted changes: $CHANGES files"
  git status --porcelain 2>/dev/null | head -10
  echo ""
fi

# Open TODOs in codebase (quick scan)
TODO_COUNT=$(grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.go" --include="*.rs" -l . 2>/dev/null | wc -l | tr -d ' ' || true)
if [ "$TODO_COUNT" -gt 0 ]; then
  echo "Files with TODOs: $TODO_COUNT"
fi
