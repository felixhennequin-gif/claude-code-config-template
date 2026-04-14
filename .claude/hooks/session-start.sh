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

CLAUDE_LOCAL="${CLAUDE_PROJECT_DIR:-.}/CLAUDE.local.md"
if [ ! -f "$CLAUDE_LOCAL" ]; then
  echo "Note: CLAUDE.local.md not found. Copy CLAUDE.local.md.example to CLAUDE.local.md and fill it in for personal context."
  echo ""
fi

# Uncommitted changes summary
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHANGES" -gt 0 ]; then
  echo "Uncommitted changes: $CHANGES files"
  git status --porcelain 2>/dev/null | head -10
  echo ""
fi

# Open TODOs in codebase (quick scan)
TODO_COUNT=$(git grep -l "TODO\|FIXME\|HACK\|XXX" -- "*.ts" "*.tsx" "*.js" "*.jsx" "*.py" "*.go" "*.rs" 2>/dev/null | wc -l | tr -d ' ' || true)
if [ "$TODO_COUNT" -gt 0 ]; then
  echo "Files with TODOs: $TODO_COUNT"
fi
