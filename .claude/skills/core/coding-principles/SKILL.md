---
name: coding-principles
description: Core behavioral rules for any coding task — think before coding, simplicity first, surgical changes, goal-driven execution. Activates on every feature, fix, refactor, or code edit, regardless of stack.
---

<!-- Adapted from Andrej Karpathy's observations on LLM coding pitfalls,
     via forrestchang/andrej-karpathy-skills. Credit to the original author. -->

# Coding principles

Four rules that apply to every code change, regardless of stack.

## 1. Think before coding

- State assumptions explicitly. If the request is ambiguous, name the ambiguity and ask — don't pick silently.
- Surface tradeoffs (performance vs. simplicity, safety vs. velocity) before implementing, not after.

**Test:** Could the user point at your diff and say "I didn't ask for that interpretation"? If yes, you assumed instead of asking.

Request: **"format the user"**. "Format" is ambiguous — it could mean a display
name for UI, a URL slug for routing, a serialized object for the API, or
something else. The right move is to ask the user which one they want *before*
writing code. If the answer is "display name" and you must proceed without a
reply, disambiguate in the function name — not in a comment block.

```js
// BAD — silent assumption baked into a generic name
function formatUser(user) {
  return `${user.firstName} ${user.lastName}`;
}

// GOOD — the name itself tells the caller which "format" this is.
// No comment needed; the ambiguity is resolved by the identifier.
function formatUserDisplayName(user) {
  return `${user.firstName} ${user.lastName}`;
}
```

## 2. Simplicity first

- Write the minimum code that solves the stated problem.
- No speculative flexibility, no abstractions for single-use code, no error handling for scenarios that can't happen.
- If 200 lines could be 50, rewrite it.

**Test:** Would a senior engineer reviewing this say it's overcomplicated? If yes, simplify before shipping.

```js
// BAD — factory + class for a one-liner problem
class StringTruncator {
  constructor(options = {}) {
    this.suffix = options.suffix ?? '…';
  }
  truncate(str, n) {
    return str.length <= n ? str : str.slice(0, n) + this.suffix;
  }
}
const truncator = new StringTruncator();

// GOOD — solves the problem, nothing more
function truncate(str, n) {
  return str.length <= n ? str : str.slice(0, n) + '…';
}
```

## 3. Surgical changes

- Touch only what the task requires. Don't "improve" adjacent code, comments, imports, or formatting on the way past.
- Match the existing style, even if you'd do it differently.
- Remove only the imports/variables your own changes orphaned. Pre-existing dead code: mention it, don't delete it unless asked.

**Test:** Can every changed line be traced back to a concrete user requirement? If not, revert the line.

```diff
// BAD — fixes the bug but also reformats imports, renames a variable,
// and adds a comment that wasn't asked for
- import { validate } from './utils'
+ import { validate, sanitize } from './utils'
  
- const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
+ // Email validation regex
+ const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

- export function isValidEmail(email) {
-   return emailRegex.test(email)
+ export function isValidEmail(email) {
+   return EMAIL_REGEX.test(email.trim())  // added .trim()
  }

// GOOD — one line changed, exactly what was asked
  export function isValidEmail(email) {
-   return emailRegex.test(email)
+   return emailRegex.test(email.trim())
  }
```

## 4. Goal-driven execution

Transform imperative tasks into verifiable goals before starting:

| Instead of...     | Transform to...                                              |
|-------------------|--------------------------------------------------------------|
| "Add validation"  | "Write tests for invalid input, then make them pass"         |
| "Fix the bug"     | "Write a failing test that reproduces it, then make it green"|
| "Refactor X"      | "Run the test suite before and after — must stay green"     |
| "Make it faster"  | "Define the baseline metric and the target, then measure"    |

**Test:** If the user walked away and came back, could they tell whether the task is done by running a single command? If not, sharpen the success criterion first.

```js
// BAD — imperative, no success criterion
"Add pagination to GET /items"

// GOOD — verifiable goal
"GET /items?page=2 returns items 21–40, page 3 returns 41–60.
Write a test that fails for both cases, then make it pass."
```
