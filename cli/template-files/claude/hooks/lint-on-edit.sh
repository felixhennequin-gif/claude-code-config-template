#!/usr/bin/env bash
# PostToolUse hook: auto-lint the edited file.
# Triggered by .claude/settings.json on Edit|MultiEdit|Write.
#
# Claude Code passes hook context as JSON on stdin, NOT as env vars, so we
# parse tool_input.file_path ourselves. We use awk (POSIX base utility) to
# stay stack-agnostic — no jq, no node, no python dependency.
#
# Non-blocking: any failure exits 0 so we never block a valid edit.

set -u

INPUT=$(cat)

# Extract a JSON string field by name from stdin-read input. Handles the
# common escape sequences (\" \\ \n \t \r) so file paths with spaces or
# unicode survive intact. Not a general JSON parser — good enough for
# Claude Code's well-formed hook payloads.
extract_json_string() {
  local key="$1" json="$2"
  printf '%s' "$json" | awk -v key="$key" '
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

FILE=$(extract_json_string file_path "$INPUT")

if [ -z "${FILE:-}" ]; then
  echo "warn: lint-on-edit received empty file_path, skipping" >&2
  exit 0
fi

# Run every formatter from the project root so config lookups (eslint.config.*,
# pyproject.toml, rustfmt.toml, etc.) resolve relative to the repo, not cwd.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

case "$FILE" in
  *.js|*.ts|*.jsx|*.tsx|*.mjs|*.cjs)
    if command -v npx >/dev/null 2>&1; then
      npx --no-install eslint --fix "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff check --fix "$FILE" >/dev/null 2>&1 || true
      ruff format "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.go)
    if command -v gofmt >/dev/null 2>&1; then
      gofmt -w "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
  *.rs)
    if command -v rustfmt >/dev/null 2>&1; then
      rustfmt "$FILE" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
