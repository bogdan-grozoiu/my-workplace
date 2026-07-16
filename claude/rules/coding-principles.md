---
name: coding-principles
description: Core behavioral guidelines for all coding and implementation work. Use this skill whenever the user asks for code, implementation, refactoring, debugging, or architectural advice. Emphasizes explicit thinking over assumptions, minimum viable code, surgical changes, and goal-driven verification loops.
---

# Coding Principles

A set of behavioral guidelines to reduce common LLM coding mistakes by prioritizing clarity, simplicity, and verification over speed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- **State assumptions explicitly.** If uncertain, ask for clarification.
- **Present multiple interpretations** if they exist — don't pick silently.
- **Suggest simpler approaches** if they're available. Push back when warranted.
- **Name confusion.** If something is unclear, stop and ask. Clarification upfront saves rework.

**Example:**
- ❌ "I'll build a REST API with role-based access control, caching, and a queue for async jobs."
- ✅ "I see you need a notification system. Before I code: Do you want synchronous (immediate response) or async (queued) delivery? For authentication, should I use the existing auth, or add a new layer? Should I add caching from the start, or verify it's a bottleneck first?"

---

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- **No features beyond what was asked.** If the ask doesn't mention caching, don't add it.
- **No abstractions for single-use code.** No generic wrappers for one function.
- **No "flexibility" or "configurability" that wasn't requested.** Hard-code constants if it simplifies the code.
- **No error handling for impossible scenarios.** Handle real edge cases; skip the "what if the sun explodes" cases.
- **If you write 200 lines and it could be 50, rewrite it.**

Test yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

---

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- **Don't "improve" adjacent code.** No reformatting, no style tweaks in unrelated sections.
- **Don't refactor things that aren't broken.** Leave working code as-is.
- **Match existing style,** even if you'd do it differently.
- **If you spot unrelated dead code,** mention it — don't delete it without asking.

When your changes create orphans:

- **Remove imports/variables/functions that YOUR changes made unused.**
- **Don't remove pre-existing dead code** unless explicitly asked.

**The test:** Every changed line should trace directly to the user's request.

---

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after; diff to show what changed"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

**Strong success criteria** let you loop independently. Weak criteria ("make it work") require constant clarification.

Strong: "The function should accept a comma-separated string, parse it into a list, validate that each item is a valid email, and return a list of validated emails or raise an error naming the first invalid one."

Weak: "Parse and validate emails."

---

## Application

Use these principles for:
- Writing new code
- Refactoring or fixing bugs
- Making architectural decisions
- Reviewing or improving existing code

If a task asks for speed over correctness, acknowledge the tradeoff and adjust — but flag it explicitly.
