# Agents

This directory is empty by default — agents are project-specific.

Example agents for a Node.js/React/PostgreSQL stack are in `examples/agents/`.
Copy the ones relevant to your stack:

    cp examples/agents/reviewer.md .claude/agents/
    cp examples/agents/security-auditor.md .claude/agents/

Then edit the system prompt to match your actual project.
