# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note:** Versions 0.1.0 through 0.5.0 were developed in an intensive single-day sprint
> and represent logical stages of the initial build, not separate calendar releases.
> Real iterative development begins with post-0.5.0 changes in [Unreleased].

## [Unreleased]

### Added

- **`session-wrap` core skill** — end-of-session workflow that analyses the session and proposes changes to the project's `.claude/` config as a reviewable checklist in `~/.claude/template-proposals/`. Two phases: `/wrap` generates proposals, `/wrap-apply` applies `[x]`-checked ones. Scope-limited to `.claude/**`, `CLAUDE.md`, `CLAUDE.local.md`, `CHANGELOG.md`. Never commits. Note: the previous `/wrap` command (session summariser, removed in an earlier release) is unrelated — this one has a different scope.
- **`/wrap` command** — triggers the proposal phase.
- **`/wrap-apply` command** — applies the checklist from a wrap file.
- **`scripts/wrap-dedup-check.sh`** — helper to flag proposals whose added lines already exist verbatim in the target file. Uses POSIX awk (mawk/gawk/busybox compatible). Copied into downstream projects by the CLI and synced from repo root by `cli/sync-templates.sh`.

## [1.1.4] - 2026-04-16

### Fixed
- Branch guard hook now correctly honors `ALLOW_MAIN_EDIT=true` bypass as documented in the README. The previous version unconditionally blocked edits on `main`/`master`.

## [1.1.3] — 2026-04-16

### Added

- **`last-verified: YYYY-MM-DD` frontmatter field** on every stack skill
  under `.claude/skills/stacks/`, plus `scripts/check-skill-freshness.py`
  wired into `make lint` and `.github/workflows/lint.yml` as an
  advisory (exit-0) GitHub Actions warning when the field is missing or
  older than 90 days.
- **Skill maintenance cadence policy** in `CONTRIBUTING.md`:
  "per major version of the underlying framework OR every 90 days,
  whichever comes first." The 90-day floor catches skills whose
  framework hasn't bumped a major but whose preview flags, deprecations,
  or "latest" recommendations have moved anyway.
- **"Settings permissions rationale" section** in `docs/MAINTAINERS.md`
  explaining why `.claude/settings.json` keeps broad git wildcards
  (`git checkout:*`, `git restore:*`, `git reset:*`) instead of
  enumerating every subcommand — the safety net is
  `dangerous-rm-guard.sh` plus the `deny` list, not the allow-list
  patterns.

### Fixed

- **Worktree + lockfile leak into the npm package.** Release 1.1.3
  was cut after `.claude/worktrees/condescending-lichterman` and
  `.claude/scheduled_tasks.lock` had silently accumulated on disk and
  been tracked by git. `sync-templates.sh` copied them into
  `cli/template-files/`, which ballooned the npm tarball from ~50 kB /
  43 files to ~468 kB / 158 files. The tag was never pushed and the
  publish was aborted. Fix: untrack both paths, add them to
  `.gitignore`, and extend `cli/sync-templates.sh` to `rm -rf` them
  after the `cp -r` so a stray worktree on a maintainer's disk can
  never ship again.
- **`_comment` key in `.claude/settings.json`.** JSON has no comment
  syntax; the key was an ad-hoc lint wart. Rationale moved to the
  new "Settings permissions rationale" section in
  `docs/MAINTAINERS.md`.

## [1.1.2] — 2026-04-16

### Added

- **`.claude/agents/architect.md`** — stack-agnostic architecture reviewer.
  Second default agent alongside `reviewer`, split by scope: `reviewer`
  catches code-level issues (banned patterns, security, error handling,
  test coverage, convention drift), `architect` catches shape-level ones
  (layering, separation of concerns, dependency direction, pattern
  consistency). Each agent's anti-patterns section explicitly delegates
  the other half back to its sibling so the checklists don't overlap and
  both stay under the 80-line ceiling. `docs/MAINTAINERS.md` documents
  the split.

### Removed

- **`RESEARCH.md`** — research notes behind the template's design decisions.
  Read-once reference material that had already been absorbed into `README.md`
  and `docs/MAINTAINERS.md`; keeping it in the repo just cost contributors a
  file to scan and required a dedicated exception in the CI secret-scan
  allowlist. Credibility sentences in `README.md` kept intact, just without
  the dangling `[RESEARCH.md]` link.
- **`.claude/commands/test.md` and `.claude/commands/wrap.md`** (plus their
  `cli/template-files/` mirrors). `/test` was a generic "run the project's
  test command and summarize" shell — strictly worse than Claude reading
  `package.json` / `Makefile` and running the actual command. `/wrap` was a
  session-wrap summariser that duplicated what `/commit` and PR descriptions
  already cover. Downstream users copying the template inherited both as
  dead weight.
- **`registry.yaml`** and its CI validator. The registry duplicated what a
  directory walk already proves: `lint.yml`'s frontmatter validator finds
  every `SKILL.md`, agent, command, and rule on disk and enforces required
  fields directly. The registry's only extra job was flagging files missing
  from the index — but the same drift now shows up as a lint failure the
  moment a new file lands without frontmatter, so the second source of truth
  was pure bookkeeping. Removing it deletes one class of CI failure
  (registry/filesystem mismatch) without losing any guarantee.

### Fixed

- Restored missing `## [1.1.1] — 2026-04-15` header in `CHANGELOG.md`
  (accidentally dropped while drafting the [Unreleased] section).

## [1.1.1] — 2026-04-15

Five review batches plus a backlog of earlier `[Unreleased]` fixes. The batches
come from a consolidated self-audit that flagged factual errors, internal
contradictions, over-promised features, and places where the project wasn't
following its own rules.

### Stack skills — factual errors (#40)

- `stacks/ci-cd-pipeline`: `actions/setup-node` was pinned to a 39-char SHA,
  which would fail the skill's own `action-pin-check.sh`. Replaced with the
  real 40-char SHA.
- `stacks/prisma-patterns`: version header claimed "5.x and 6.x" while the
  rest of the repo references Prisma 7. Updated to "6.x and 7.x" and
  corrected the omit-API note to reflect its Prisma 6.2 GA.
- `stacks/react-frontend`: the `use()` section recommended `useEffect` +
  `useState` as a fallback (outdated). Rewrote to spell out Promise-only
  semantics, the Suspense boundary requirement, and TanStack Query for
  ad-hoc fetching.

### Core skills — self-contradictions (#41)

- `core/code-review`: the "open PRs" prompt instructed Claude to run
  `gh pr merge`, directly contradicting `.claude/rules/git-workflow.md`.
  Rewritten to open PRs, print URLs, and stop.
- `core/coding-principles`: Rule 1's example disambiguated `formatUser`
  with a multi-line comment block — contradicting the skill's own guidance.
  Disambiguation moved into the identifier name itself.
- `core/error-handling`: Rule 4 was HTTP/Express-only despite the skill
  advertising itself as language-agnostic. Renamed to "outermost boundary",
  added a parallel FastAPI example, and listed the equivalent hooks for
  Flask/Django/Gin/Axum.

### Commands & routines — safety (#42)

- `.claude/commands/deploy.md` (+ CLI mirror): step 4 listed "SSH to the
  server, pull latest, install deps, run migrations, then restart the
  process manager" as a fallback — a catalogue of things Claude will
  confidently hallucinate for environments it cannot know. Replaced with
  a stop-and-ask gate when no project deploy script is found at the usual
  locations.
- Routines moved from `routines/` to `examples/routines/`, and the CLI no
  longer syncs them. Routines are a research preview with daily run caps
  and an unstable fire-endpoint contract — shipping them at the repo root
  and copying them into every CLI install overstated their maturity.
  `ROUTINES.md`, `registry.yaml`, `README.md`, `CLAUDE.md`, and the CI
  registry check all point at the new path; `ROUTINES.md` now frames the
  whole set as a speculative preview.
- `examples/routines/deploy-verify.md`: fabricated
  `anthropic-beta: experimental-cc-routine-2026-04-01` header and fake
  fire-endpoint URL replaced with a clearly-labelled placeholder that
  points at the upstream routines docs before anyone wires this into a
  CD pipeline.
- `examples/routines/bug-triage.md`: branch prefix `claude/fix-[n]` →
  `fix/issue-[n]`, aligning with the project's `fix/` convention and the
  `git-workflow` rule.

### Dogfood own rules (#43)

- Root `CLAUDE.md` trimmed from 176 lines to 63 so the repo meets the
  same `≤ 80 lines` ceiling it enforces on `template/CLAUDE.md` and
  every file in `examples/`. Claude Code working on this repo was
  tail-dropping its own context — the exact failure mode `RESEARCH.md`
  documents observing elsewhere. The dangerous-rm-guard smoke-test matrix
  and detailed CLI notes moved to a new `docs/HACKING.md`, which the root
  file now links to. Nothing load-bearing was removed.
- `template/CLAUDE.md` trimmed 84 → 72 lines. The standalone CI/CD
  section was folded into Automation with a pointer to the
  `ci-cd-pipeline` skill; the routines bullet was dropped to match the
  CLI no longer shipping them.
- `examples/README.md` now lists all five example `CLAUDE.md` files
  (express, next, fastapi, go, symfony); the "Node-only" framing was
  stale since v0.3.0 / v0.4.0 added the Python and Go examples.
- `README.md` stack-skills table now lists `stacks/symfony-api` and
  `stacks/ci-cd-pipeline`, which were already on disk and installable
  via the CLI but missing from the README's inventory.
- `examples/fastapi-backend.CLAUDE.md` and `examples/go-api.CLAUDE.md`
  shipped with a stale `# Project — [name]` header copied from the
  generic template. Aligned with the Node examples (`# FastAPI backend`,
  `# Go REST API`).
- `template/.claudeignore` (+ CLI mirror) gained Python/Go/Rust/PHP
  ignore patterns (`target/`, `.pytest_cache/`, `*.egg-info/`, `uv.lock`,
  `Cargo.lock`, `go.sum`, `composer.lock`, `*.test`, `*.out`). Non-Node
  projects previously leaked generated artefacts into Claude's context.
- New `docs/HACKING.md` — working-on-this-repo guide containing the
  `dangerous-rm-guard.sh` smoke-test matrix and CLI notes.

### Consistency sweep (#44)

- `cli/src/copy.js` + `cli/src/manifest.js`: replaced silent `catch {}`
  with logged catches so CLI failures surface instead of being swallowed.
- `.claude/hooks/lint-on-edit.sh` (+ CLI mirror): added `ruff format`
  after `ruff check --fix` for parity with the JS branch's format-and-fix
  pass; gated the JS branch on `command -v npx` so the hook stays
  non-blocking on Node-less machines.
- `examples/agents/reviewer.md`: dropped the "No merge commits — rebase
  workflow" line and replaced it with a stack/workflow-agnostic "follows
  the project's branching strategy".
- Root `CLAUDE.md`: fixed an inaccurate gotcha about the git allowlist —
  `checkout`/`restore` wildcards DO exist (kept for rebase ergonomics);
  the note now points at `.claude/rules/git-workflow.md` as the
  enforcement layer.
- `ROUTINES.md`: resolved a leftover `[[ROUTINES_DOCS_URL]]` placeholder.
- `CHANGELOG.md`: translated the 0.9.4 Fixed/Added entries from French
  to English so the project history reads consistently for downstream
  users.

### Prior `[Unreleased]` backlog

Work that had accumulated in `[Unreleased]` before the five batches, now
released with them:

- **Added** — root `.claudeignore` (previously untracked). Reduces session
  noise when Claude Code works *on this repo*; complements the downstream
  `template/.claudeignore`.
- **Changed** — `.claude/settings.json` (+ CLI mirror): `PreToolUse` and
  `PostToolUse` matchers now include `NotebookEdit` alongside
  `Edit|MultiEdit|Write`. Previously both the `main`/`master` branch guard
  and the auto-lint hook silently skipped `.ipynb` edits, leaving
  notebook-heavy projects (data science, ML) unprotected.
- **Fixed** — `.claude/hooks/lint-on-edit.sh` (+ CLI mirror): replaced
  `npx --no eslint --fix` with `npx --no-install eslint --fix`. `--no` is
  not a documented npx flag; the hook's v0.1.0 intent was the
  `--no-install` guard, which keeps it offline-safe and fast by refusing
  to auto-install eslint when the project hasn't declared it. A prior
  edit had truncated the flag and the error was silently swallowed by
  `2>&1 || true`.
- **Fixed** — `.claude/hooks/lint-on-edit.sh` (+ CLI mirror): hoisted
  `cd "${CLAUDE_PROJECT_DIR:-.}"` above the `case` so Python/Go/Rust
  branches also run from the project root. Previously only the JS branch
  did the `cd`, so `ruff`/`gofmt`/`rustfmt` config lookups resolved
  against whatever directory Claude Code happened to be running in.
- **Fixed** — `.claude/skills/core/testing/SKILL.md`: removed a
  self-referential "See rule 3 above" sentence inside rule 3 itself.
- **Fixed** — `.github/workflows/lint.yml`: dogfooded the `ci-cd-pipeline`
  skill the repo ships — pinned `actions/checkout@v4` to a commit SHA,
  added a top-level `permissions: contents: read` block for least-privilege
  `GITHUB_TOKEN`, and added a `concurrency` block keyed on
  `${{ github.workflow }}-${{ github.ref }}` with `cancel-in-progress:
  true` so rapid pushes stop stacking redundant runs. Also removed the
  redundant `sudo apt-get install -y shellcheck` step — shellcheck is
  preinstalled on `ubuntu-latest` runners.
- **Fixed** — `.github/workflows/lint.yml`: branch-guard smoke test used
  an exact-string `jq` match on the `Edit|MultiEdit|Write` matcher, which
  broke after the matcher gained `NotebookEdit`. Switched to
  `contains("Write")` so the test keeps finding the hook regardless of
  future matcher additions.

## [0.9.7] — 2026-04-14

### Fixed
- `.claude/skills/core/code-review/SKILL.md` (+ `cli/template-files/` mirror) —
  added an anti-pattern against classifying "file X is committed / leaking
  into git" findings without first running the project's list-tracked-files
  check (`git ls-files`, `git check-ignore -v`). Filesystem tools like
  `find`/`ls` show on-disk files, not tracked files — a file can exist
  locally while already being ignored. Caught during a self-audit where a
  P1 "untrack `.template-manifest.json`" finding turned out to be a no-op
  because the path was already in `.gitignore`.
- `.claude/skills/core/code-review/SKILL.md` — genericised so the skill installs
  untouched on any downstream repo, per the `core/` vs `stacks/` split in
  `CLAUDE.md`. Removed repo-specific references to `cli/template-files/`,
  `cli/sync-templates.sh`, `audit.md`, and the `.claude/settings.json` /
  `.claude/hooks/*.sh` validation snippets. The GOOD batch example, the
  execute prompt's sync/validation step, and the "never edit mirrored files"
  anti-pattern are now phrased in stack-neutral terms. Dropped the HTML comment
  referencing the v0.9.5 origin session.

### Added
- `.claude/skills/core/code-review/SKILL.md` — new guidance: a tiebreaker for
  when file proximity and severity ordering conflict (file proximity wins),
  batch-size targets (3–7 items, ≤~200 LOC of diff), an explicit "run the
  project's test suite" instruction in the execute prompt, an extra disagreement
  criterion for findings that are correct in the abstract but out of the
  project's stated scope, and an anti-pattern reminding reviewers to cross-check
  batches against other skills/rules/agents (the incident that motivated this
  was the past `reviewer` vs `express-api` try/catch contradiction). The PR
  prompt now notes its `gh` CLI assumption and uses `<default-branch>` instead
  of hard-coding `master`.

## [0.9.6] — 2026-04-14

Backfilled — `v0.9.6` was tagged but never got its own CHANGELOG section.
This entry summarises the 11 commits between `v0.9.5` and `v0.9.6` (PRs #16–#26).

### Added
- `.claude/skills/core/code-review/SKILL.md` (PR #26) — core skill for acting
  on an external code review: three phases (analyse → roadmap → execute),
  severity/effort triage table, `/tmp/roadmap.md` output contract, and
  execution/PR prompts.
- `.claude/skills/core/git-workflow/SKILL.md` (PR #25) — language-agnostic
  branching, Conventional Commits, rebase-vs-merge, PR, and merge-conflict
  conventions. Defers to `CONTRIBUTING.md` when a project specifies otherwise.

### Fixed
- `ci-cd-pipeline` skill (PR #22) — recategorised from `core/` to `stacks/`,
  since its YAML snippets are GitHub Actions / GitLab CI-specific and not
  universal.
- `ci-cd-pipeline` skill (PR #16) — translated from French to English for
  downstream compatibility.
- `.claude/hooks/bash-safety.sh` (PR #21) — renamed to `dangerous-rm-guard.sh`
  to reflect the hook's narrow scope (famous footguns only, not a
  comprehensive safety net). Header comment documents the non-coverage.
- `prisma-patterns` skill (PR #20) — corrected claims about unreleased
  Prisma features.
- `.github/workflows/lint.yml` (PR #19) — added CI smoke test for the
  `settings.json` PreToolUse branch-guard one-liner, with a stubbed
  `$TEST_BRANCH` so the case-statement classifier can be exercised
  independently of the runner's actual git state.
- `.claude/commands/audit.md` + `.claude/hooks/lint-on-edit.sh` (PR #18) —
  audit secret-scan now includes plain `.env` files (not just `*.env*`);
  lint hook warns on empty `file_path` payloads instead of silently
  exiting 0.
- `testing` + `wrap` (PR #17) — resolved a coverage self-contradiction
  in `testing/SKILL.md` and added an 80-line pruning rule to `wrap.md`
  so `CLAUDE.md` growth is bounded.
- Core skills (PR #23) — added Python examples to `testing` and
  `error-handling` so the `core/` category is genuinely language-agnostic.

### Changed
- P2 quick wins (PR #24) — cross-references added between `debugging` and
  `error-handling`, CI try/catch-convention check added to
  `.github/workflows/lint.yml` (prevents future `reviewer` vs `express-api`
  drift), and a Windows-portability note added where `/tmp` paths appear.

## [0.9.5] — 2026-04-14

### Added
- Re-release of the `ci-cd-pipeline` core skill on npm. The 0.9.4 git tag and
  npm publish were cut before PR #12 / #13 / #14 landed, so the npm 0.9.4
  tarball did not contain `.claude/skills/core/ci-cd-pipeline/SKILL.md`, the
  `## CI/CD conventions` block in `template/CLAUDE.md`, or the updated
  `.claude/skills/core/README.md` entry. 0.9.5 is a content-only re-cut of
  0.9.4 so the npm package matches master.

## [0.9.4] — 2026-04-14

### Fixed
- `symfony-api/SKILL.md` — full rewrite from scratch with stock Symfony 5.4+ conventions
  only. Removed all project-specific references: `LegacyHttpClient`, dual entity manager
  `primary`/`secondary`, `CronJob` entity, `#[AsCronTask]`, `EasyAdmin 3.5`.
- `examples/symfony-api.CLAUDE.md` — full anonymization. Removed Lexik/Gesdinet,
  EasyAdmin, dual EM, mailcatcher. Replaced with generic Symfony conventions.
- `.claude/rules/` — frontmatter fixed: `globs:` (Cursor convention) replaced with
  `paths:` (native Claude Code syntax).
- `CONTRIBUTING.md` + `RESEARCH.md` + `examples/agents/` + `lint.yml` — contradiction
  resolved on the `tools:` field in agents: optional (not mandatory), aligned across
  all four sources. CI updated to validate `examples/agents/` instead of `.claude/agents/`
  (empty by default).
- `.claude/commands/wrap.md` — removed the contradictory auto-commit option. The
  workflow now has two options: stage only (default) or skip.
- `.claude/skills/stacks/react-frontend/SKILL.md` — `use()` paragraph rewritten. The
  Suspense boundary vs ad-hoc data fetching distinction is now explicit.
- `.claude/skills/core/testing/SKILL.md` — merged with `rules/test-files.md`. Removed
  AAA / naming / test.skip / isolation duplicates. One source of truth.
- `.claude/skills/core/error-handling/SKILL.md` — added rule 4: error classification
  at the HTTP boundary. Single mapping in error middleware, status codes in the
  service layer flagged as an anti-pattern.
- `.claude/settings.json` — `Bash(git:*)` replaced with an explicit allowlist of 12
  git commands. `git reset --hard` and `git clean -fd` intentionally excluded.
- `.claude/commands/deploy.md` — step 5 "Verify" replaced with commands Claude can
  actually run (`curl`, `pm2 logs --lines 50`). Removed the "tail logs 30 seconds"
  step that isn't possible without a persistent agent.
- `.claude/hooks/lint-on-edit.sh` — added Python (`ruff`), Go (`gofmt`), and Rust
  (`rustfmt`) branches. Each branch checks tool availability before running.
- `.claude/hooks/session-start.sh` — detects missing `CLAUDE.local.md` at session
  start and prints a warning.
- `RESEARCH.md` — removed unverifiable statistics (`~15%`, `~55 repos`). Reworded as
  observational notes rather than a formal study.
- `docs/VALIDATION.md` — title and framing fixed. "Real-world validation" →
  "Validation checklist & smoke test results". Author disclaimer added.
- `README.md` — `root CLAUDE.md vs template/CLAUDE.md` callout moved to the top
  (right after the badges). ASCII tree moved to the bottom. `settings.json`
  precedence section added.

### Added
- `.claude/skills/core/ci-cd-pipeline/SKILL.md` — GitHub Actions and GitLab CI patterns:
  job structure, artifact passing, OIDC authentication, DAG with `needs`, security
  checklist (SHA pinning, least privilege, scoped secrets), and anti-patterns to flag
  in existing workflows. `template/CLAUDE.md` gains a `## CI/CD conventions` block
  referencing the skill.
- `.claude/hooks/user-prompt-context.sh` — commented example of a `UserPromptSubmit`
  hook for injecting context on every prompt.
- `.github/workflows/lint.yml` — "Smoke-test bash-safety hook" step: verifies the
  PASS and BLOCK cases documented in `CLAUDE.md` on every CI run.
- `cli/src/copy.js` — `symfony-api` added to `getSkipPaths` and `STACK_PERMISSIONS`
  (`Bash(composer:*)`, `Bash(php:*)`). Dual CLI bug fixed.

## [0.9.2] — 2026-04-14

### Added
- `.claude/skills/stacks/symfony-api/SKILL.md` — Symfony 5.4+ stack skill
  (constructor injection, PHP 8 attributes, multi-EM isolation, cron in DB,
  PHPStan level 6)
- `examples/symfony-api.CLAUDE.md` — anonymized Symfony example
- README.md comparison table — midudev/autoskills added
- `.claude/skills/core/testing/SKILL.md` — testing strategy core skill

## [0.9.1] — 2026-04-14

### Added
- `.claude/skills/core/testing/SKILL.md` — testing strategy skill: what to
  test, success criterion before implementing, coverage as a floor, when not
  to write tests. Complements rules/test-files.md with task-description-based
  activation.
- README.md — midudev/autoskills added to the comparison table

## [0.9.0] — 2026-04-14

### Added
- `.claude/commands/wrap.md` — `/wrap` slash command for end-of-session CLAUDE.md updates. Summarizes git diff, updates only changed sections, proposes a commit. Replaces the missing SessionEnd hook.
- `examples/agents/fastapi-reviewer.md` — FastAPI/Python example agent (Security, Async patterns, Pydantic v2, Architecture, Alembic checklist).
- `.claude/skills/core/coding-principles/SKILL.md` — BAD/GOOD code examples for all 4 rules (think before coding, simplicity, surgical changes, goal-driven execution).
- `template/settings.local.json.example` — user-level permissions override template (gitignored, install-only, mirrors `CLAUDE.local.md.example` pattern).
- `README.md` — `settings.local.json` documentation under global config section.

### Changed
- `audit.md` — secrets scan rewritten: targeted `grep -rE` on assignment patterns instead of keyword grep; excludes `.example`/`.test`/`.spec` and `process.env` refs.
- `express-api/SKILL.md` — removed dead `app.del()` anti-pattern.
- `react-frontend/SKILL.md` — hooks return style marked as team preference, not a framework rule.
- `examples/express-api.CLAUDE.md` — path drift fix: `lib/prisma.js` → `src/lib/prisma.js` in Gotchas section.
- `examples/agents/reviewer.md` — Conventional commits moved from Code quality to new Git hygiene section.
- `examples/agents/security-auditor.md` — password hashing: argon2id as primary recommendation, bcrypt >= 12 as fallback, MD5/SHA-1/unsalted banned.

### Fixed
- `error-handling/SKILL.md` — contradiction between Rule 1 example (log+rethrow) and anti-patterns (log once at boundary); Rule 1 now shows rethrow only.
- `session-start.sh` — `grep -r` replaced with `git grep` (respects `.gitignore`, no hang on large projects).
- `.github/workflows/lint.yml` — IPv4 regex false-positived on version strings; now filtered via `grep -Ev`.
- `cli/sync-templates.sh` + CI — `settings.local.json` sync failure resolved via option C (`.example` pattern, consistent with `CLAUDE.local.md.example`).

## [0.8.2] — 2026-04-14

### Fixed
- `.claude/skills/core/error-handling/SKILL.md` + CLI copy: Rule 1 "GOOD" example no longer contradicts the anti-patterns section. The example now shows rethrow without logging, with a comment clarifying that logging happens once at the top boundary (not at every intermediate layer).
- `.claude/hooks/session-start.sh` + CLI copy: TODO scan now uses `git grep` instead of `grep -r`. The previous implementation did not respect `.gitignore` and could hang on large projects (walking `node_modules`, `dist`, etc.). `git grep` respects `.gitignore` for free.
- `.github/workflows/lint.yml`: the secret-scan IPv4 check no longer false-positives on version strings. The `grep -nHE` match is now piped through `grep -Ev` to filter lines containing `version`, `v0.x`, `v1.x`, or quoted four-segment version strings like `"1.2.3.4"`.

## [0.8.0] — 2026-04-13

### Added
- `--update` flag for the CLI — `npx create-claude-code-config --update [dir]` updates template files in an existing project. Files the user has customized are detected via a SHA-256 manifest (`.claude/.template-manifest.json`) written at install time and left untouched. `settings.json` and `CLAUDE.local.md.example` are always excluded from auto-update.

## [0.7.0] — 2026-04-13

### Added
- `.claude/skills/core/error-handling/SKILL.md` — universal error handling patterns (fail loudly, fix at root, typed errors). Activates when writing error handling code in any language.
- `template/CLAUDE.md` and `cli/template-files/CLAUDE.md`: new `## Off-limits` section — placeholder for files and directories Claude should never modify (generated files, migrations, vendor directories).

### Changed
- `README.md`: dual-CLAUDE.md callout moved before `## Why` — now visible before any install instructions.
- `README.md`: "test results from real projects" replaced with accurate "validation template — fill it after testing" to match actual VALIDATION.md content.
- `README.md`: "No dependencies, no CLI, no lock-in" contradiction resolved — now reads "No framework, no lock-in — clone or use the CLI, the files are yours either way."
- `.claude/skills/stacks/prisma-patterns/SKILL.md` + CLI copy: `@default(cuid())` replaced with ulid/uuid(7) recommendation and cuid maintenance-mode note.
- `.claude/skills/stacks/prisma-patterns/SKILL.md` + CLI copy: added `omit` pattern for sensitive fields (Prisma 5.13+/7).
- `.claude/hooks/session-start.sh` + CLI copy: added comment documenting intentional detached HEAD behavior — prevents contributors from "fixing" it.
- `RESEARCH.md`: added observation date header (March–April 2026).
- `cli/bin/create-claude-code-config.js`: renamed from `create-claude-config.js` to match package name.
- `cli/src/index.js`: banner updated from `create-claude-config` to `create-claude-code-config`.
- `.claude/skills/core/README.md`: added `error-handling` to the skill list.

## [0.6.0] — 2026-04-13

### Added
- `.claude/skills/core/debugging/SKILL.md` — second core behavioral skill enforcing a structured debugging workflow (reproduce → read → trace → one-change → three-strike rule). Activates on bugs, errors, and failed test investigations.
- `.claude/hooks/notification.sh` + `Notification` event registration — desktop notification when Claude needs attention during long autonomous tasks. Cross-platform (notify-send / osascript / silent fallback).
- `template/.claudeignore` — stack-agnostic ignore list for `node_modules`, build output, lockfiles, and other noise. The single highest-ROI token-saving measure. The CLI now copies it alongside `CLAUDE.md`.
- `docs/VALIDATION.md` — placeholder for real-world validation results (token deltas, hook catches, skill activations) to replace credibility-by-claim with credibility-by-measurement.
- CI: "Check CLI template sync" step in `.github/workflows/lint.yml` — runs `cli/sync-templates.sh` and fails if `cli/template-files/` drifts from source. Prevents silent CLI/template divergence.
- `prisma-patterns`: `typedSql` guidance (Prisma 7+) — prefer `$queryRawTyped()` with `.sql` files over `$queryRaw` template literals for type-safe raw SQL.

### Changed
- `.claude/rules/test-files.md`: replaced hardcoded Vitest/Supertest/Testing Library framework list with stack-agnostic guidance ("use the project's existing runner — check `package.json`/`Makefile`/`pyproject.toml`"). Test conventions now ship unchanged for Python, Go, Rust, etc.
- `react-frontend`: React Compiler bullet is now conditional on detecting `babel-plugin-react-compiler` or the Vite `reactCompiler` plugin, instead of recommending it unconditionally (it's still experimental in React 19).
- `docs/CONTEXT-BUDGET.md`: replaced the unverifiable "How to measure" section with "How to estimate" — three concrete techniques (file size × 0.25, `wc -w`, ccusage before/after) the user can actually run. Added `.claudeignore` ROI callout.
- `RESEARCH.md`: dropped the "~55 repos" framing throughout and added a collapsible list of the 15 actually-verified repos. Credibility now matches evidence.
- `README.md`: directory tree updated for `.claudeignore`, `VALIDATION.md`, and the `Notification` event. Permissions table documents the stack-agnostic default and how the CLI injects stack permissions.
- `CHANGELOG.md`: added sprint-velocity note explaining that v0.1.0–v0.5.0 were logical stages of a single-day initial build, not separate calendar releases.

### Removed
- `fastapi-backend` skill (`.claude/skills/stacks/fastapi-backend/`) — quality was below the template bar (0 code examples, missing modern patterns like `lifespan` and `Annotated[]` DI). Kept `examples/fastapi-backend.CLAUDE.md` as a reference; contributions welcome for a rewrite that matches the Express/React skills.

### Fixed
- `bash-safety.sh`: replaced literal-substring matching with surgical regex so `rm -rf ./dist`, `git push --force-with-lease`, and `npm publish --dry-run` no longer false-positive. Hook now fails closed on empty/unparseable stdin instead of silently passing.
- `.claude/settings.json`: stripped Node-specific entries from `permissions.allow` and the redundant `Bash(rm -rf:*)` deny entry. Template now ships truly stack-agnostic permissions. README documents how to add stack-specific entries; the CLI injects them automatically based on selected stacks.

## [0.5.0] — 2026-04-13

### Added
- **`create-claude-code-config` CLI** — interactive scaffolding tool
  - `npx create-claude-code-config` to scaffold a Claude Code config
  - Prompts for project directory + stack selection (Express, Prisma, React, FastAPI)
  - Copies CLAUDE.md, .claude/ (hooks, commands, rules, skills), CLAUDE.local.md
  - Removes unselected stack skills automatically
  - Updates .gitignore with personal file entries
  - Ships template files embedded — no runtime git clone
- `cli/sync-templates.sh` script to keep CLI templates in sync with repo

### Changed
- README: installation now offers CLI (Option A) and manual (Option B)
- README: directory tree updated with `cli/`
- Root CLAUDE.md: added CLI section with contributor guidance

## [0.4.0] — 2026-04-13

### Fixed (v0.3.1)
- `stacks/README.md`: added fastapi-backend, removed from wanted list
- `examples/agents/`: moved HTML comment after frontmatter (runtime parsing fix)
- `session-start.sh`: fixed pipefail crash on repos with zero TODOs
- `CONTRIBUTING.md`: fixed skill path references, removed `allowed-tools` from example
- `deploy.md`: replaced hardcoded paths with placeholder variables
- `test-files.md`: added `name:` field for consistency
- `express-api` + `prisma-patterns`: removed `allowed-tools` (consistent with v0.2.0)
- README: added note about editing stack-specific permissions

### Added
- "What this changes vs bare Claude Code" comparison table in README
- "Compared to alternatives" section in README with competitive positioning
- `examples/agents/README.md` explaining the example agents
- `examples/go-api.CLAUDE.md` — Go/Chi/sqlc example (3rd stack coverage)
- Starter gotchas in `template/CLAUDE.md` (no longer fully commented out)

### Changed
- README: directory tree updated with Go example
- "Missing your stack?" list updated (removed Go and FastAPI)

## [0.3.0] — 2026-04-13

### Fixed (v0.2.1 scope)
- README: directory tree now matches actual v0.2.0+ structure (was still showing v0.1.x layout)
- Fixed git remote URL (was pointing to the old `ai-config-template.git` name)
- Cleaned up stale feature branches (`feat/v0.2.0`, `fix/ci-frontmatter`)
- Verified no remaining "production-ready" references in non-historic tracked files

### Added
- **Python/FastAPI support** — new stack skill at `.claude/skills/stacks/fastapi-backend/SKILL.md` (SQLAlchemy 2.x async, Alembic, Pydantic v2 conventions) and example config at `examples/fastapi-backend.CLAUDE.md`.
- **Context budget guide** (`docs/CONTEXT-BUDGET.md`) — per-component token estimates, three budget profiles (minimal/standard/full), and rules of thumb for pruning skills.
- **Banned-patterns rule** (`.claude/rules/banned-patterns.md`) — universal + JS/TS + Python anti-patterns, scoped via `globs:` to the matching file types.
- **"Adding a new stack" section in CONTRIBUTING.md** — three-step recipe (skill → example → optional agent) and the 80-line rule.
- Principle #7 in README: "Know your token budget" with a pointer to `docs/CONTEXT-BUDGET.md`.

### Changed
- **RESEARCH.md rewritten in full** — replaced the "55 repos with star counts" credibility padding with six concrete findings, each tied to a template decision (CLAUDE.md length, skills beat inline, hooks underused, agents need project context, core/stacks split, repo rot), an anti-patterns-avoided list, and a focused sources table.
- README: added FastAPI to the stack skills table, removed FastAPI from the "contributions welcome" list.
- Root `CLAUDE.md`: directory tree and rules listing updated for `banned-patterns.md`, `fastapi-backend`, and `docs/`.

## [0.2.0] — 2026-04-13

### Changed

- **BREAKING**: Skills restructured — `coding-principles` moved to `.claude/skills/core/coding-principles/`. Core-vs-stacks split is now reflected on disk, so downstream users can prune `stacks/` wholesale without touching universal behavioral rules.
- **BREAKING**: Default agents moved to `examples/agents/` — they were Node/React/PostgreSQL-specific and contradicted the "any project" positioning. `.claude/agents/` is now empty by default with a README explaining how to copy them back.
- README: dropped "production-ready" framing, restructured for action-first flow (install snippet first, principles up top, then directory tree).
- `.claude/settings.json`: `PreToolUse` branch guard now blocks edits on both `main` AND `master`.
- `coding-principles` SKILL: removed the `allowed-tools: Read, Grep, Glob` frontmatter (contradicted its purpose as a behavioral skill for code edits) and cut generic advice already covered by Claude's training. Now 47 lines.
- `react-frontend` SKILL: fixed the incorrect "no Zustand unless > 5 contexts" rule (Context re-renders every consumer on every update — Zustand's selectors are the right tool for high-frequency shared state). Added a React 19 section (`use()`, `useActionState`, `useFormStatus`, Server Components boundary, React Compiler).
- `.claude/commands/audit.md` and `test.md`: replaced hardcoded `backend/`, `frontend/`, `prisma/schema.prisma`, and `npm test -- --coverage` paths with configurable placeholder variables and stack-agnostic instructions.

### Added

- `.claude/hooks/session-start.sh` + `SessionStart` hook registration — injects branch, last commit, uncommitted changes, and TODO count at session start.
- `.claude/hooks/bash-safety.sh` + `PreToolUse` Bash matcher — blocks `rm -rf /`, `rm -rf ~`, `git push --force`, `npm publish`, `mkfs.`, `dd if=`, fork-bomb, etc. Merged alongside the existing main-branch guard, not overwriting it.
- MCP integration section in README (pointer + example `.mcp.json`, explanation of why it's not shipped by default).
- `.claude/skills/core/README.md`, `.claude/skills/stacks/README.md`, and `.claude/agents/README.md` — each explains the directory's purpose and how to prune or extend it.

### Removed

- Default `.claude/agents/reviewer.md` and `.claude/agents/security-auditor.md` (moved to `examples/agents/` with a "Node.js/React/PostgreSQL example — edit for your stack" comment at the top).
- Generic advice from `coding-principles` that duplicated Claude's training (e.g. "state assumptions", explicit scope section).
- `allowed-tools` frontmatter from `coding-principles` and `react-frontend` SKILL files.

## [0.1.2] — 2026-04-13

### Changed

- **Template repositioned as stack-agnostic.** README one-liner now describes the project as "Production-ready AI config template for Claude Code — agents, skills, hooks, and commands for any project." instead of "Node.js / React / PostgreSQL".
- `template/CLAUDE.md` rewritten with stack placeholders (`[your language]`, `[your framework]`, etc.) so it's fillable for Node, Python, Go, Rust, Ruby, PHP, JVM, or anything else. Section structure (Stack, Structure, Commands, Conventions, Git workflow, Gotchas, References) is unchanged — only the Node/Express/Prisma/React anchors were removed.
- `.claude/skills/` reorganized: universal skills stay at the top level (`coding-principles/`), stack-specific skills moved under `.claude/skills/stacks/` (`prisma-patterns/`, `express-api/`, `react-frontend/`). Downstream users can delete `stacks/` wholesale or prune individually. History preserved via `git mv`.
- Install snippet split into "Quick start — core (always)" and "Add stack skills (optional)". README now lists the available stack skills in a table with their trigger conditions and links to each `SKILL.md`.
- Root `CLAUDE.md` now describes the core-vs-stacks split as a load-bearing repo convention so future contributions don't leak stack-specific content back into the core.
- `examples/README.md` explicitly invites examples for Python, Ruby, Go, Rust, PHP, JVM, and alt-JS frameworks — the only examples that currently ship are Node-flavored (Express, Next.js).
- Path references updated in `coding-principles/SKILL.md` and `.github/ISSUE_TEMPLATE/bug_report.md` to match the new `skills/stacks/` layout.

## [0.1.1] — 2026-04-13

### Added

- `.claude/skills/core/coding-principles/SKILL.md` — stack-agnostic behavioral skill condensing Andrej Karpathy's four coding principles (think before coding, simplicity first, surgical changes, goal-driven execution) into actionable rules with concrete "senior engineer" tests. Adapted from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills). Triggers on every coding task and cross-references the stack-specific skills.

## [0.1.0] — 2026-04-13

Initial public release of the template.

### Added

#### Project context

- Root `CLAUDE.md` — describes this template repo itself (loaded when Claude Code works *on* the template)
- `template/CLAUDE.md` — downstream-facing project context file users copy into their own projects (stack, structure, commands, conventions, git workflow, gotchas) — deliberately under ~80 lines
- `template/CLAUDE.local.md.example` — tracked personal-override template that clones actually receive; users copy it to the gitignored `CLAUDE.local.md`

#### `.claude/` runtime configuration

- `.claude/settings.json` — `PreToolUse` guard blocking edits on `main`, `PostToolUse` auto-lint hook, and a scoped `permissions.allow` / `permissions.deny` list
- `.claude/hooks/lint-on-edit.sh` — parses `tool_input.file_path` from stdin (with a `jq` → `node` fallback) and runs `npx --no-install eslint --fix` on JS/TS files; non-blocking (always exits 0)
- `.claude/agents/reviewer.md` — code review subagent (`tools: Read, Grep, Glob`, `model: sonnet`)
- `.claude/agents/security-auditor.md` — security audit subagent scoped to `Read, Grep, Glob, Bash(npm audit:*)`
- `.claude/commands/deploy.md` — `/deploy` slash command (server-agnostic deployment workflow)
- `.claude/commands/audit.md` — `/audit` slash command (full quality audit)
- `.claude/commands/test.md` — `/test` slash command (tests + coverage)
- `.claude/skills/prisma-patterns/SKILL.md` — Prisma 7 conventions
- `.claude/skills/express-api/SKILL.md` — Express 5 patterns
- `.claude/skills/react-frontend/SKILL.md` — React 19 + Vite + Tailwind v4 patterns
- `.claude/rules/test-files.md` — test file conventions scoped via `globs:` to `**/*.test.*`, `**/*.spec.*`, `**/tests/**`, `**/__tests__/**`

#### Examples

- `examples/README.md` — index, usage instructions, and contribution notes
- `examples/express-api.CLAUDE.md` — Express 5 + Prisma 7 + PostgreSQL REST API template
- `examples/nextjs-fullstack.CLAUDE.md` — Next.js 15 App Router + Prisma 7 + Tailwind v4 template

#### Community infrastructure

- `README.md` — landing page with install snippet, principles, and contributing section
- `CONTRIBUTING.md` — contribution guide with quality bar for skills, agents, commands, and examples
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1
- `SECURITY.md` — vulnerability reporting policy
- `CHANGELOG.md` — this file
- `LICENSE` — MIT
- `RESEARCH.md` — raw research data from ~55 open-source repos behind the template's design
- `.github/ISSUE_TEMPLATE/{bug_report,feature_request,new_skill}.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/FUNDING.yml`
- `.github/workflows/lint.yml` — CI: JSON validation for `settings.json`, `shellcheck -S error` on hook scripts, required-field frontmatter check on skills / agents / rules, and a baseline secret scan (hardcoded IPv4, secret-looking env assignments, PEM private-key headers)

[Unreleased]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v1.1.3...HEAD
[1.1.3]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.7...v1.1.1
[0.9.7]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.6...v0.9.7
[0.9.6]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.5...v0.9.6
[0.9.5]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.4...v0.9.5
[0.9.4]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.3...v0.9.4
[0.9.3]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.2...v0.9.3
[0.9.2]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.8.2...v0.9.0
[0.8.2]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.8.0...v0.8.2
[0.8.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/felixhennequin-gif/claude-code-config-template/releases/tag/v0.1.0
