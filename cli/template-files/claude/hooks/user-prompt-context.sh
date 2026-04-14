#!/usr/bin/env bash
# UserPromptSubmit hook — inject task context at every prompt.
#
# This hook runs before Claude processes every user prompt. Anything it writes
# to stdout is prepended to that prompt as additional context. Use it for
# ambient information Claude should always have: current issue, uncommitted
# file count, target branch, on-call rota, etc.
#
# Wire it up by adding this block to .claude/settings.json → "hooks":
#
#   "UserPromptSubmit": [
#     {
#       "hooks": [
#         {
#           "type": "command",
#           "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/user-prompt-context.sh",
#           "timeout": 3
#         }
#       ]
#     }
#   ]
#
# Non-blocking: any failure exits 0 so Claude still sees the prompt.

set -u

# Example 1 — inject the current open GitHub issue assigned to you
# ISSUE=$(gh issue list --assignee @me --limit 1 --json number,title --jq '.[0] | "#\(.number) \(.title)"' 2>/dev/null)
# [ -n "${ISSUE:-}" ] && echo "Current issue: $ISSUE"

# Example 2 — warn if the working tree has many uncommitted files
# CHANGES=$(git -C "${CLAUDE_PROJECT_DIR:-.}" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
# [ "${CHANGES:-0}" -gt 5 ] && echo "Note: $CHANGES uncommitted files — consider committing before large changes."

# Example 3 — surface the current branch when it isn't the default
# BRANCH=$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null)
# case "$BRANCH" in
#   main|master|"") ;;
#   *) echo "On branch: $BRANCH" ;;
# esac

exit 0
