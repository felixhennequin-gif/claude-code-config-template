# Security Policy

## Reporting a vulnerability

If you discover a security issue in this template — particularly in a hook script, slash command, or `settings.json` entry that could cause Claude Code to execute unintended commands — **please do not open a public issue**.

Instead, email **security@example.com** with:

- A description of the issue
- The affected file(s)
- Steps to reproduce
- Your assessment of the impact

You should receive an acknowledgment within a few days.

## Scope

This repository is a configuration template for Claude Code. The attack surface is narrow but real:

- **Hook scripts** (`.claude/hooks/*.sh`) run automatically on tool events. A malicious or buggy hook can execute arbitrary shell commands with the user's privileges.
- **`settings.json` permissions** control which tools Claude can invoke without confirmation. Overly broad allow-lists can let the model run destructive commands silently.
- **Slash commands and skills** embed instructions that Claude follows. Prompt-injection-style content in these files can steer the assistant toward unsafe actions.

Issues in application code that a user writes on top of this template are out of scope — report those to the downstream project.

## Supported versions

Only the latest release on `master` receives security fixes.
