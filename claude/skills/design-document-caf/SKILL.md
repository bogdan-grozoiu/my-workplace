---
name: design-document-caf
description: Guidelines for creating combined HLD/LLD (High-Level/Low-Level Design) documents structured around the Microsoft Cloud Adoption Framework (CAF) and Well-Architected Framework pillars. Use this skill when asked to produce a design document for an Azure application or workload infrastructure deployed via Terraform or Bicep. Creates a single Markdown document combining architecture decisions, rationale, concrete resources, and CAF alignment.
---

# Design Document: HLD/LLD with Microsoft CAF

Process for creating a combined High-Level/Low-Level Design document grounded in Infrastructure-as-Code and aligned with Microsoft's Cloud Adoption Framework (CAF).

---

## Overview

This skill produces **one Markdown document** that combines:

- **HLD (High-Level Design):** architecture decisions, topology, rationale, and CAF/WAF alignment (prose)
- **LLD (Low-Level Design):** concrete resources, configurations, and values (tables/lists)

The document is structured by framework area (CAF design considerations + Well-Architected Framework pillars) with application-specific chapters.

### Key Difference from General Documentation

**Precedence:** This section defines document *structure*. For HLD/LLD design documents, use the framework chapters and appendices defined here—do NOT graft on the general documentation structure (numbered headers, Repository Set table, End-to-End Flow, etc.).

**Inherited from general documentation:** Only the behavioral rules (source-of-truth grounding, verify against code, flag discrepancies, honor `surgical`, commit ID tracking, History table).

---

## Pre-Writing Questionnaire

**Before starting, ask (don't assume) these questions:**

### Location & Filename
- **Where should the document be written?** (local path, repo folder)
- **Suggested filename:** `<workload>-design.md` (e.g., `api-gateway-design.md`)
- **Confirm before proceeding.**

### Source of Truth
- **Which repo is the IaC source?** (path on local filesystem)
  - May be "this repository" or a separate one—confirm which.
  - Ask for the **local filesystem path** (not a URL).

### Scope & Emphasis
- **Workload name + one-line purpose.** (e.g., "Customer Portal: Web app + backend APIs serving 10M users")
- **What does the repo deploy?** (Terraform, Bicep, CloudFormation, etc. Leave blank to auto-detect.)
- **Framework emphasis?** (Default: CAF *application* landing zone design areas + Well-Architected Framework pillars—Reliability, Security, Cost Optimization, Operational Excellence, Performance Efficiency. User can customize.)

### Platform Assumption
Treat any **shared platform landing zone** (e.g., Connectivity + Management subscriptions with shared hub, private DNS, Log Analytics, Key Vault) as **EXTERNAL/given**. Reference what the workload *consumes* from it—do not redocument the platform itself.

---

## Process

### Step 1: Ground the Structure in Current Framework Docs

Before fixing the chapter list:

- **Confirm the current CAF *application* landing zone design considerations** (Governance, Security, Cost, Operations, Reliability, Network architecture, etc.)
- **Confirm the current Well-Architected Framework pillars** (usually: Reliability, Security, Cost Optimization, Operational Excellence, Performance Efficiency)

If you have access to Microsoft Docs MCP, use it to verify current guidance. Otherwise, state your assumptions clearly.

### Step 2: Inventory What the Repo Actually Deploys

Read the `.tf` / `.bicep` files AND the variable/parameter files:

- **Concrete values only:** resource names, SKUs/tiers, CIDR ranges, subnets, scaling limits, retention policies, identity/RBAC assignments, private endpoints, diagnostic settings
- **Cross-stack dependencies:** which modules depend on which; shared state or variable references
- **CI/CD:** pipeline files, triggers, state backend, workspaces, approval gates
- **For large repos:** parallelize read-only exploration—don't try to read everything sequentially

**Capture everything as real values.** If you can't find a value, note it as a gap—don't invent.

### Step 3: Outline the Document Structure

Before writing, present to the user:

- **Chapter list** you'll use (based on Step 1 framework)
- **Stacks/modules found** (based on Step 2 inventory)
- **Gaps or assumptions** you've made

Let the user adjust before you generate the full document.

---

## Document Structure

### Header Table

At the very top:

| Field | Value |
|-------|-------|
| **Document Type** | Infrastructure Design (HLD/LLD) |
| **Scope** | [Workload name] |
| **Source Repo** | [repo-url] (commit: abc1234) |
| **Region(s)** | [e.g., eastus2] |
| **Naming Convention** | [pattern, e.g., `<env>-<component>-<resource-type>`] |
| **State/Automation** | [e.g., Terraform Remote State in Azure Storage] |

### Single Table of Contents

One TOC covering all chapters and subsections, with links. Update after any edits.

### Framework Chapters

One chapter per framework area. Each chapter has:

#### HLD Part (Prose)
- Architecture decisions and topology
- Rationale (why this design, not alternatives)
- CAF/WAF alignment (which principle does this satisfy)
- Dependencies on the platform landing zone (if any)

#### LLD Part (Tables/Concrete Details)
- Real resource names, IDs, SKUs, CIDRs
- Configuration details (scaling, retention, identities, endpoints)
- Always preceded by a lead-in paragraph

**Rule: Never make a section that's only a table or only bullet points.** Surround all tables/lists with narrative so it reads like a cohesive design document.

---

## Workload-Specific Chapters

Add chapters specific to your workload:

### Application Architecture
Describe the application components, data stores, ingress/egress, and how they interact:

- **Real app components** (e.g., "API Gateway" → actual resource name in Azure)
- **Data stores** (databases, caches, queues—actual SKUs, retention)
- **Ingress/egress** (public endpoints, DNS, WAF rules)
- **Dependencies** (external APIs, third-party services)

Include a **Solution Architecture Mermaid diagram** with real resource names/IDs/CIDRs—the as-deployed view, not a generic reference diagram.

### How the Workload Consumes the Platform Landing Zone

Document what the workload *relies on* from shared platform infrastructure:

- **Shared DNS zones** (which domains are registered in the platform)
- **Firewall egress rules** (if applicable)
- **Shared Log Analytics workspace** (if logs are aggregated)
- **Shared Key Vault** (for secrets)
- **Private endpoints** (which ones cross the boundary)
- **RBAC/Identity** (managed identities, service principals assigned roles from platform)

---

## Diagrams (Mermaid)

Include at least:

1. **Solution Architecture Diagram**
   - Real resource names, Azure resource types, region
   - CIDR ranges and subnet mappings
   - The as-deployed view (not generic)
   - Scope must match the section heading (if the diagram shows the whole workload, don't file it under a subsection)

2. **Data Flow Diagram** (if the workload moves data)
   - Sources → processing → destinations
   - Real names

3. **Dependency Graph** (if multiple stacks/modules)
   - Which modules/repos depend on which
   - Shared resources

---

## Rules & Tone

- **Ground every LLD value in the actual code.** If it's not in the repo, say so.
- **Be honest about gaps:** section called `Known Gaps / Notes vs. Best Practice` listing:
  - Deliberate simplifications
  - Open questions
  - Any divergence from CAF/WAF ideal
- **Don't overstate properties.** Don't claim "HA" unless failover is implemented; describe what it really is (e.g., "multi-region active-active" or "active with manual failover").
- **Flag inconsistencies** (naming disagreement between docs and code)—don't smooth them over.
- **Include commit ID** of the repo at the time of writing; update on changes via diff.

---

## Appendices

Add after the main chapters:

1. **IP Address Usage** — CIDR allocation, subnet mapping, private address space
2. **Resource Group / Naming Index** — All resources, grouped by resource group
3. **Cross-Stack Dependency Map** — Which module outputs feed which inputs
4. **Module/Version Matrix** — Terraform modules or Bicep versions, pinned refs, commit/tag

---

## Technical Debt Section

**Always include** near the end (before appendices):

| Item | Impact | Priority | Status |
|------|--------|----------|--------|
| Single instance of VM (no redundancy) | No automatic failover | Medium | Open—waiting for HA requirement |
| Hardcoded IP in NSG rule | Manual update needed if IP changes | Low | Backlog—consider service tags |

Flag deliberate omissions or gaps that diverge from best practice.

---

## Known Gaps / Notes vs. Best Practice

Before the appendices, a prose section describing:

- Deliberate simplifications (e.g., "single instance to minimize cost")
- Open questions (e.g., "RTO/RPO requirements TBD—recommend 1hr/4hr")
- Gaps vs. CAF/WAF (e.g., "Cost analysis not yet implemented")
- Monitoring gaps (e.g., "alerts defined for CPU only; recommend adding memory, disk I/O")

---

## History Table

At the very end, track changes:

| Date | Repos (Commit ID) | Change Description |
|------|-------------------|-------------------|
| 2026-01-15 | repo-a (abc1234), repo-b (def5678) | Initial HLD/LLD document created |
| 2026-01-20 | repo-a (abc1234) | Added data flow diagram; clarified dependency on platform DNS |

Update after every edit. If the same commit ID is referenced in a new edit, update the existing row rather than creating a duplicate.

---

## Workflow Checklist

**Before writing:**
- [ ] Ask all pre-writing questionnaire questions
- [ ] Get local filesystem paths
- [ ] Confirm filename and location
- [ ] Ground framework structure in current docs

**During writing:**
- [ ] Read actual .tf / .bicep files
- [ ] Extract concrete values only
- [ ] Use Mermaid for diagrams with real resource names
- [ ] Write HLD + LLD for each chapter (prose + tables)
- [ ] Include one lead-in paragraph per section

**Before finalizing:**
- [ ] Update TOC
- [ ] Include commit ID in header
- [ ] Add History entry
- [ ] Complete appendices
- [ ] Add Known Gaps section
- [ ] Verify all values trace to the repo
- [ ] Get user review

**For updates (surgical or otherwise):**
- [ ] Diff the repo to find changes
- [ ] Update only affected sections
- [ ] Update commit ID and History table
- [ ] Don't assume what changed—verify via diff
