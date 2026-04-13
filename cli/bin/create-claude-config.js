#!/usr/bin/env node

if (process.argv.includes('--help') || process.argv.includes('-h')) {
  console.log(`
  Usage: npx create-claude-config

  Interactive CLI to scaffold a Claude Code config for any project.

  Copies CLAUDE.md, .claude/ (skills, hooks, commands, rules),
  and sets up .gitignore entries.

  Options:
    --help, -h    Show this help message

  More info: https://github.com/felixhennequin-gif/claude-code-config-template
  `);
  process.exit(0);
}

import('../src/index.js').then(({ run }) => {
  run().catch((err) => {
    console.error('Error:', err.message);
    process.exit(1);
  });
});
