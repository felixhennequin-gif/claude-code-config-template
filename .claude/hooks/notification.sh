#!/usr/bin/env bash
# Notification hook — alerts user when Claude needs attention
# Cross-platform: tries Linux notify-send, then macOS osascript, then silent fallback

TITLE="Claude Code"
MSG="Waiting for your input"

if command -v notify-send >/dev/null 2>&1; then
  notify-send "$TITLE" "$MSG" 2>/dev/null
elif command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MSG\" with title \"$TITLE\"" 2>/dev/null
fi

# Always succeed — notifications are best-effort
exit 0
