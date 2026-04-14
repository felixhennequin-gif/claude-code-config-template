#!/usr/bin/env bash
set -euo pipefail

# Sync template files from repo root into cli/template-files/
# Run this after any change to .claude/, template/, or rules

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TARGET="$SCRIPT_DIR/template-files"

echo "Syncing template files..."

# Clean and recreate
rm -rf "$TARGET/claude"
mkdir -p "$TARGET/claude"

# Copy root templates
cp "$REPO_ROOT/template/CLAUDE.md" "$TARGET/CLAUDE.md"
cp "$REPO_ROOT/template/CLAUDE.local.md.example" "$TARGET/CLAUDE.local.md.example"
cp "$REPO_ROOT/template/.claudeignore" "$TARGET/.claudeignore"

# Copy .claude/ contents (without dot prefix)
cp -r "$REPO_ROOT/.claude/"* "$TARGET/claude/"

# settings.local.json is gitignored and personal. Scrub any stray local copy
# and ship the clean example — the CLI renames it to settings.local.json on install.
rm -f "$TARGET/claude/settings.local.json"
cp "$REPO_ROOT/template/settings.local.json.example" "$TARGET/claude/settings.local.json.example"

echo "Done. Verify with: ls -R $TARGET"
