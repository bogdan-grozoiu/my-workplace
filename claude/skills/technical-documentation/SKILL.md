---
name: technical-documentation
description: Guidelines for writing technical documentation of Azure Infrastructure-as-Code projects. Use this skill whenever asked to create, read, edit, or update infrastructure documentation, especially when the source is a separate git repo with Terraform or Bicep. Emphasizes source-of-truth verification, concrete values, discrepancy flagging, and structured documentation with consistent formatting.
---

# Technical Documentation

Guidelines for creating consistent, verifiable infrastructure documentation grounded in actual code and configuration.

---

## Core Principle

**Consistency over creativity. Every claim traceable to a real file or value in the source repo.**

Most infrastructure documentation describes Azure resources deployed from Infrastructure-as-Code (Terraform, Bicep, etc.) in a separate git repository. That repo is your **source of truth** — read it before writing; never paraphrase from memory or assumption.

### Before You Start

**Always ask the user for the path to the repo on the local filesystem.** If you don't have access, request it. Do not proceed without the ability to verify values against the actual code.

---

## Documentation Structure

### 1. Overview and Metadata

Start with a short paragraph describing the workload and which repositories deliver it, followed by a **Key Characteristics** bullet list:

- Acronyms
- Region(s)
- Environments
- Delivery model (IaC framework, deployment method)

### 2. Repository Set Table

Include immediately after the overview:

| Repository | Purpose | Commit ID (as of writing) |
|------------|---------|-------------------------|
| [repo-name](https://github.com/org/repo) | What this repo deploys | abc1234 |
| ... | ... | ... |

- **Repo name should be a hyperlink** to the git URL (repo URL only—no branch/path pinning)
- **Commit ID** is the specific commit used when writing the documentation. Document changes against this snapshot.

### 3. Common Conventions Section

For anything shared across repos/components:

- **Naming conventions** (prefixes, suffixes, casing patterns)
- **Backend/state storage** (where Terraform state lives, how it's locked)
- **Provider versions** (pinned versions, ranges)
- **CI/CD approach** (which tool, pipeline triggering, approval gates)
- **Subscriptions** (dev, test, prod subscription IDs)

### 4. One Section Per Repo/Component

Go deep into implementation details:

- **Exact module names** (not generic descriptions)
- **Refs/versions** in backticks: `` ref=v2.0.1 ``
- **File paths** (where variables.tf, main.tf, outputs.tf live)
- **Variable names** (the actual Terraform/Bicep parameter names)
- **Resource names** (the actual Azure resource names deployed)
- **CIDR ranges, SKUs, scaling limits** (every concrete value from the code)

**Rule: Everything must be a real value from the repo.** If a detail can't be stated concretely, go find it instead of generalizing.

### 5. Use Tables for Enumerables

Tables work well for:

- Subnets (name, CIDR, purpose, NSG rules)
- Per-environment differences (dev vs. test vs. prod parameters)
- Subscriptions (name, ID, purpose)
- CI/CD pipelines (repo, pipeline file path, trigger, approval gates)

### 6. Flag Discrepancies

Create a **Technical Debt** section to note:

- Where the repo's own docs/naming disagree with what the code actually does
- Missing or outdated configuration
- Simplifications or known gaps

**Example:**  
"The repo's README still references an older naming convention; the live Terraform uses `resource_v2_` prefix instead."

**Never silently fix inconsistencies.**

### 7. Documentation Updates

When asked to update documentation:

1. **Diff the repo** to find what changed
2. **Don't assume** which sections to update
3. **Update the commit ID** in the Repository Set table
4. **Add a History entry** (see below)

### 8. Commit ID and History Tracking

At the top of the document, note the commit ID. When the repo has changed since then:

1. **Diff the repo** to find changes
2. **Update the affected sections**
3. **Update the History table** (add new entry if commit ID differs, or update existing entry if same commit)

Include a **History** section at the end:

| Date | Repositories (commit ID) | Change Description |
|------|-------------------------|-------------------|
| 2026-01-15 | repo-a (abc1234), repo-b (def5678) | Added networking section, updated CIDR ranges |
| 2026-01-20 | repo-a (abc1234), repo-b (def5678) | Corrected SKU values in Technical Debt section |

Update after every edit. If the same commit ID is referenced in a new edit, update the existing row's description rather than adding a duplicate.

### 9. Table of Contents

Include a TOC at the top with links to each section and subsection. Update the TOC after any edits.

### 10. Surgical Updates

If the user mentions `surgical` in the request:

- **Only modify the section relevant to the request**
- Do not make other improvements or corrections, even if you notice issues
- This preserves focused, minimal changes

---

## Example Structure

```
# [Workload Name] Infrastructure Documentation

**Document Type:** Infrastructure Design
**Source Repo:** [repo-url]
**Commit ID:** abc1234def567
**Last Updated:** 2026-01-20

## Table of Contents

- [Key Characteristics](#key-characteristics)
- [Repositories](#repositories)
- [Common Conventions](#common-conventions)
- [Network Architecture](#network-architecture)
- [Compute & Storage](#compute--storage)
- [Monitoring & Compliance](#monitoring--compliance)
- [Technical Debt](#technical-debt)
- [History](#history)

## Key Characteristics

- **Framework:** Terraform
- **Region:** eastus2
- **Environments:** dev, test, prod
- **State:** Remote (Azure Storage)

## Repositories

| Repo | Purpose | Commit |
|------|---------|--------|
| [infra-core](https://github.com/org/infra-core) | Base networking and shared services | abc1234 |

[... rest of document ...]

## Technical Debt

| Item | Impact | Status |
|------|--------|--------|
| NSG rules reference hardcoded IPs instead of service tags | Manual updates required for IP changes | Open |

## History

| Date | Repos | Change |
|------|-------|--------|
| 2026-01-15 | infra-core (abc1234) | Initial documentation |
```

---

## Workflow Checklist

Before starting:
- [ ] Ask for the repo path on the local filesystem
- [ ] Confirm the scope (single repo or multiple?)
- [ ] Understand the audience (ops, developers, auditors?)

While writing:
- [ ] Read the actual .tf / .bicep files (don't paraphrase)
- [ ] Extract concrete values: names, IDs, CIDRs, SKUs
- [ ] Note where docs conflict with code
- [ ] Include commit ID in the doc
- [ ] Test all hyperlinks

After writing:
- [ ] Update TOC
- [ ] Add History entry
- [ ] Verify all inline values match the repo
- [ ] Get user review before publishing
