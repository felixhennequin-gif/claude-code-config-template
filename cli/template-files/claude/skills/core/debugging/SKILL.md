---
name: debugging
description: Structured debugging workflow. Activates when fixing bugs, investigating errors, troubleshooting test failures, or when a previous fix attempt failed.
---

# Debugging

Five rules for turning "something is broken" into a fix a reviewer can trace end-to-end. The default failure mode is trying random fixes in a loop — every rule below exists to prevent that.

## 1. Reproduce first

Before touching any code, write a failing test or nail down the minimal repro steps. If you can't reproduce it, say so and ask for more context. Don't guess-fix. A fix you can't verify isn't a fix.

## 2. Read the full error

Read the complete error message and the full stack trace. Identify the exact file and line. Don't skim the first frame and stop. The useful signal is usually three or four frames down.

## 3. Trace to the root cause

Follow the error backward. The symptom is where the error *appears*; the root cause is where the bad data or state *originated*. Fix at the root, not at the symptom.

- ❌ BAD: error says `Cannot read property 'name' of undefined` on line 42 → add `if (!user) return null` on line 41.
- ✅ GOOD: trace back and find that `getUserById` silently returns `undefined` when the ID is missing instead of throwing. Fix the service layer so the bad state never reaches line 42.

## 4. One change at a time

Make one fix. Run the test. Observe. Don't stack three speculative changes — if the tests pass, you won't know which one did it; if they fail, you won't know which one broke something else.

## 5. Three-strike rule

If three consecutive fix attempts fail, STOP. Summarise: what you tried, what you learned from each failure, what you now believe the real problem is. Ask the user before continuing. Looping is a signal that your mental model is wrong — more attempts will not fix a wrong model.

## Anti-patterns

- ❌ Adding null / undefined checks at the symptom instead of fixing the source of the null
- ❌ "Shotgun debugging" — changing multiple things at once and hoping
- ❌ Guessing from the error message without reading the stack trace
- ❌ Re-running the same fix with minor variations hoping for a different result
- ❌ "Fixing" a failing test by weakening its assertion instead of fixing the code

## The senior engineer test

Could a reviewer look at your fix and trace a straight line from the error → the root cause → your change? If the line has a gap, you skipped a step. Go back and close it before shipping.
