# Pull request

## Summary

<!-- One or two sentences on what this PR changes and why. -->

## Type of change

- [ ] New skill
- [ ] New rule
- [ ] New hook
- [ ] New slash command or agent
- [ ] Fix or update to existing file
- [ ] Documentation

## Checklist

- [ ] Files are in the correct directory (`.claude/skills/`, `.claude/rules/`, `.claude/hooks/`, etc.)
- [ ] YAML frontmatter is valid (`name`, `description`, and any required fields)
- [ ] The trigger / `description` is specific enough for Claude to activate the file at the right time
- [ ] No hardcoded paths, IPs, hostnames, emails, or other personal data
- [ ] Anti-patterns section included (for skills)
- [ ] Tested with Claude Code — see notes below

## Test notes

<!-- Which prompt did you run, and what behavior did you observe? -->

**Prompt used:**

```
<!-- paste the exact prompt you gave Claude Code -->
```

**Observed behavior:**

<!-- Did Claude activate the skill / run the hook / pick up the rule as expected? -->

## Related issues

<!-- e.g. Closes #12, Refs #34 -->
