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

### Combined HLD/LLD design documents (Microsoft CAF)

When asked to produce a **design document** (HLD/LLD) for a single application/solution landing zone workload, structured against the Microsoft Cloud Adoption Framework (CAF) and generated from the Infrastructure-as-Code in a repo, follow the process below. This produces ONE Markdown document combining High-Level and Low-Level Design.

**Precedence over the general documentation rules above.** For an HLD/LLD design document, THIS section is authoritative for document *structure* - use the header table, the single table of contents, the framework chapters, the appendices, and the Known gaps section defined here. Do NOT graft on the general section's structural elements (numbered `## 1.` headers, Repository Set table, End-to-End Flow, Deployment Pipelines table). There is exactly ONE TOC, defined by this section. From the general section, only inherit the *behavioral* rules - source-of-truth grounding, always ask for the repo path, flag discrepancies via the `Technical Debt` convention, never invent values, and honor `surgical` - PLUS the **History table** and **commit ID** conventions (include both, tracking this design doc against the source repo exactly as described above).

**Before starting, ask (don't assume):**

- **Output location and filename.** Never hardcode a path. Ask where the document should be written and what to name it (suggest a `<workload>-design.md` filename, and if the repo already has a documentation folder, offer to place it there). Confirm before writing.
- **Which repo is the source of truth.** Ask for the path on the local filesystem to the IaC repo (per the general rule above). It may be "this repository" or a separate one - confirm which.
- **Workload name / purpose** - the name plus one line on what it does.
- **What the repo deploys** - Terraform / Bicep / etc. Leave blank to auto-detect from the repo.
- **Framework emphasis** - default to the CAF *application* landing zone design areas plus the Well-Architected Framework pillars (Reliability, Security, Cost Optimization, Operational Excellence, Performance Efficiency) unless the user says otherwise.

**Platform assumption:** treat any shared platform landing zone (e.g. Connectivity + Management subscriptions: shared hub egress, central private DNS zones, Log Analytics / Event Hub, Key Vault) as EXTERNAL/given. Reference what the workload *consumes* from it - do not redocument the platform itself.

**Method:**

1. **Ground the structure in current Microsoft docs, not memory.** Use the Microsoft Docs MCP (`microsoft_docs_search` / `microsoft_docs_fetch`) if available to confirm the CAF *application* landing zone design considerations AND the current Well-Architected Framework pillar list before fixing the chapter list.
2. **Inventory EXACTLY what the repo deploys.** Read the `.tf`/`.bicep` files AND the variable/parameter files. For large repos, fan out parallel read-only exploration agents. Capture CONCRETE values - resource names, SKUs/tiers, CIDRs/subnets, scaling limits, retention, identities/roles, private endpoints, diagnostic settings - not just resource types. Note cross-stack/module dependencies and CI/CD (pipelines, state backend, workspaces).
3. **Produce one Markdown document** with: a header table (doc type, scope, source-of-truth, region(s), naming convention, state/automation), a table of contents, and one chapter per framework area. Add a workload-specific **Application architecture** chapter (real app components, data stores, ingress/egress, dependencies) and a **How the workload consumes the platform landing zone** chapter (DNS, firewall egress rules relied on, shared LAW/Key Vault, private endpoints, RBAC).

**Every chapter must have:**

- An **HLD part** as PROSE: the decisions, topology, rationale, and CAF/WAF alignment.
- An **LLD part** as tables/bullets: the concrete resources and config.
- A lead-in paragraph before any table or list. A chapter/section must NOT be only a table or only bullets - always surround them with narrative so it reads like a real HLD/LLD.

**Diagrams:** use Mermaid (renders in GitHub/VS Code). Include at least a **Solution architecture** figure using real resource names/IDs/CIDRs (the as-deployed view, NOT a generic reference diagram); a data-flow diagram if the workload moves data; and a dependency graph if there are multiple stacks/modules. Every diagram's scope must MATCH its section heading - if a figure shows the whole workload, don't file it under a narrowly-named subsection.

**Rules / tone (learned the hard way):**

- Ground every LLD value in the actual code. If a value isn't in the repo, say so - don't invent.
- Be honest about gaps: end with a **Known gaps / notes vs. best practice** section listing deliberate simplifications, open questions, and anything that diverges from the CAF/WAF ideal.
- Don't overstate properties. Don't call something DR/redundancy/HA unless the code actually implements failover - describe what it really is (e.g. "active regional coverage", "single instance"). Same for security claims.
- Flag naming/scope inconsistencies rather than smoothing them over (consistent with the `Technical Debt` rule above).
- Include appendices: IP/address usage, resource-group/naming index, cross-stack dependency map, and a module/version matrix.

**Before writing, confirm scope with the user:** briefly state the chapter list you'll use (from step 1) and the stacks you found (from step 2) so they can adjust before you generate the document.
