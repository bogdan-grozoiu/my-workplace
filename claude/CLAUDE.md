# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Git commands usage
- Don't do git add/commit/push for the user. If you need to make a change to the repo, ask the user to do it.
- Don't ask the user to perform git diff or git log to find information. If you need to know something about the repo, perform the git commands yourself and provide the output to the user, only if explicitly asked to do so.

## How to write documentation

**Consistency over creativity. Every claim traceable to a real file or value in the source repo.**

Most documentation describes Azure infrastructure deployed from a separate git repo (Infrastructure as Code). Treat that repo as the source of truth - read it before writing, don't paraphrase from memory or assumption. Ask questions if you can't find a concrete answer.
Always require the user to provide you with the path to the repo on the local filesystem. If you don't have access to the repo, ask for it.

Match this structure and level of detail:

- **Headers:** numbered and not bold - `## 1. Title`, `### 1.1 Subtitle` - with `---` separating major sections.
- **Overview first:** a short paragraph on what the workload is and which repo(s) deliver it, followed by a **Key Characteristics** bullet list (acronyms, region, environments, delivery model).
- **Repository Set table** right after the overview: repo name, purpose, commit ID (as of writing). The repo name should also be a hyperlink to the git URL (repo URL only - no branch/path pinning).
- **Common conventions section** for anything shared across repos/components: naming convention, backend/state, provider versions, CI/CD, subscriptions.
- **One section per repo/component**, going deep: exact module names, refs/versions (`ref=v2.0.1`), file paths, variable names, resource names, CIDR ranges, SKUs - everything in backticks, everything a real value from the repo. If a detail can't be stated concretely, go find it instead of generalizing.
- **Tables for anything enumerable or compared** across environments (subnets, per-env parameter differences, subscriptions, pipelines).
- **Flag discrepancies, don't silently fix them** - if the repo's own docs/naming disagree with what the code actually does, call it out (e.g. "the repo's CLAUDE.md still references an older layout; the live code is X"). The section name shall be called `Technical Debt` and the table shall be called `Technical Debt`.
- **Documentation update requests** if requested to update the documentation, **diff the repo** to find changes and update the docs accordingly. Don't assume what changed.
- **Commit ID** include in the documentation the commit id used when generating the documentation, and if the repo has changed since then, **diff the repo** to find changes and update the docs accordingly. Don't assume what changed.
- **Close with an End-to-End Flow** (numbered steps tying the repos/components together) and a **Deployment Pipelines table** (repo, pipeline files, environment chain).
- **TOC:** Include a table of contents at the top, with links to each section and subsection. Update the TOC after any edits. If the user asks you to add a new section, add it to the TOC, as well.
- **Hystory** - Include a history secction at the end of the document, with a table of changes made to the documentation, including the date, repositories referenced by this documentation, including their commit ID at the time of writing the documentation, and description of the change. Update the history after any edits. If the same commit ID is referenced in a new edit, do not add a new entry to the history table, but update the description of the change in the existing entry.
- **Surgical** - if the user mentions `surgical` in the request, only make changes to the section of the documentation that is relevant to the request. Do not make any other changes to the documentation, even if you notice other issues or improvements that could be made.
- 