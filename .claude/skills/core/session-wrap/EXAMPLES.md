# session-wrap — examples

Three calibrated proposal blocks (categories A, C, D) and three counter-examples that must be filtered out. Calibration target: each proposal should be actionable by someone reading it cold.

---

## Good proposals

### Example 1 — Category A (friction observed)

```markdown
### [ ] Proposal 1 — Document Prisma 7 destructive-action consent flag

**Category:** A — friction observed
**Target:** `.claude/skills/stacks/prisma-patterns/SKILL.md`

**Why:** User reminded the agent 3× this session to pass `PRISMA_USER_CONSENT_FOR_DANGEROUS_AI_ACTION` when invoking `prisma migrate reset`. Not in the current skill.

**Diff:**

​```diff
--- a/.claude/skills/stacks/prisma-patterns/SKILL.md
+++ b/.claude/skills/stacks/prisma-patterns/SKILL.md
@@ -42,6 +42,14 @@ When modifying the schema:
 3. Re-run `prisma generate`
 4. Commit the migration file alongside the schema change

+### Destructive operations (Prisma 7+)
+
+Commands that drop data (`migrate reset`, `db push --force-reset`) require
+an explicit consent env var when invoked by an AI agent:
+
+    PRISMA_USER_CONSENT_FOR_DANGEROUS_AI_ACTION="<user's confirmation message>" \
+      npx prisma migrate reset --force
+
+Pass the user's literal confirmation message. Never fabricate one.
+
 ## Query patterns
​```

**CHANGELOG entry:**

​```markdown
### Changed
- prisma-patterns: document Prisma 7 destructive-action consent flag
​```
```

---

### Example 2 — Category C (reusable pattern)

```markdown
### [ ] Proposal 2 — Add /audit-from-browser command for Chrome-audit → roadmap → cascade flow

**Category:** C — reusable pattern
**Target:** `.claude/commands/audit-from-browser.md` (new file)

**Why:** Session validated the flow Chrome extension audit → structured report → code-review skill → cascade execution. Packaging it so the next frontend audit doesn't start from scratch.

**Diff:**

​```diff
--- /dev/null
+++ b/.claude/commands/audit-from-browser.md
@@ -0,0 +1,24 @@
+# Browser-driven audit workflow
+# Usage: /audit-from-browser
+
+Two-phase audit: live-browser inspection via Claude in Chrome, then triage into a
+batched roadmap executed by Claude Code.
+
+**Rule: user approves the report before triage.** Phase 2 never auto-triggers.
+
+## Steps
+
+1. User runs the audit in Chrome via the Claude extension. Expected output is a
+   markdown report with sections: Bloquants / Importants / Améliorations /
+   Ce qui marche bien / Annexes brutes.
+2. Invoke the `code-review` skill with the report as input. It triages findings
+   (P0/P1/P2/P3 × S/M/L), writes a batched roadmap, hands off to cascaded
+   execution (one branch per batch).
+
+## Never
+
+- Never skip report review. The report may have false positives.
+- Never run Phase 2 automatically.
+- If the report has zero 🔴 findings, ask the user whether to proceed or defer.
​```

**CHANGELOG entry:**

​```markdown
### Added
- /audit-from-browser command — packages the Chrome-audit → roadmap → cascade workflow
​```
```

---

### Example 3 — Category D (imperfect command/skill)

```markdown
### [ ] Proposal 3 — Clarify roadmap path convention in code-review skill

**Category:** D — imperfect command/skill
**Target:** `.claude/skills/core/code-review/SKILL.md`

**Why:** Session misfired once because `/tmp/roadmap.md` (absolute) collided with `tmp/roadmap.md` (project-relative). Skill hardcoded the absolute path without flagging the alternative.

**Diff:**

​```diff
--- a/.claude/skills/core/code-review/SKILL.md
+++ b/.claude/skills/core/code-review/SKILL.md
@@ -12,7 +12,13 @@ Three phases that apply to every incoming review.

 ## 2. Write the roadmap

-Group findings into batches. One batch = one branch + one PR. Then write everything to `/tmp/roadmap.md` and stop.
+Group findings into batches. One batch = one branch + one PR. Then write everything to the roadmap file and stop.
+
+**Roadmap path convention:**
+- Default: `/tmp/roadmap.md` (absolute, ephemeral, not versioned)
+- Override: if the project has a gitignored `tmp/` directory or sets `ROADMAP_PATH` in `CLAUDE.md`, use that
+- If both candidates exist, confirm with the user before writing
+- Phase 3 execution prompts must reference the same path — don't hardcode `/tmp/roadmap.md` if the roadmap lives elsewhere

 **Grouping rules**
​```

**CHANGELOG entry:**

​```markdown
### Fixed
- code-review: clarify roadmap path convention (absolute default, project-relative override)
​```
```

---

## Counter-examples — must be filtered out

### Too vague

```markdown
### [ ] Proposal — Improve error handling
**Why:** Error handling was inconsistent.
**Diff:** (none)
```

No target, no diff. Drop.

### Out of scope

```markdown
### [ ] Proposal — Refactor the auth controller
**Target:** `backend/src/controllers/auth.ts`
```

Code file. Drop — `/wrap` only touches `.claude/**`, `CLAUDE.md`, `CLAUDE.local.md`, `CHANGELOG.md`.

### Already exists

```markdown
### [ ] Proposal — Add a rule against `console.log` in production
**Target:** `.claude/rules/banned-patterns.md`
```

The current `banned-patterns.md` already contains this. Always diff against current state before writing. Drop.

### Business rule framed as reusable

```markdown
### [ ] Proposal — Add community membership gating rule to coding-principles
**Target:** `.claude/skills/core/coding-principles/SKILL.md`
```

Project-specific business rule. Reroute to `CLAUDE.md`, do not add to a shared skill.