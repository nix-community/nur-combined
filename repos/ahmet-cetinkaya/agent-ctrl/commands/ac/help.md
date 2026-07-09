---
name: ac:help
description: "List all personal /ac: commands grouped by category with one-line descriptions and the typical feature workflow chain."
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /ac:help - Personal Command Reference

## Triggers

- When you forget which `/ac:` command does what
- When onboarding to this command set
- When choosing the right command for a task

## Overview

This command prints a categorized reference of every personal `/ac:` command. It is a
static reference: when commands are added or removed under `commands/ac/`, update the
lists below to match.

## Execution

Print the reference below verbatim (adapt formatting to the surface). Do **not** crawl the
repository; this is a static listing.

---

## Commands by Category

### 🚀 Orchestration

| Command | Description |
|---|---|
| `/ac:ship` | End-to-end eval-driven feature flow: define completion criteria, research, implement, verify, review. Chains the other `/ac:`, `/sc:*`, and `/ecc:*` commands. |

### 📋 Workflow

| Command | Description |
|---|---|
| `/ac:brainstorm` | Shape a vague idea into a concrete requirements brief via Socratic dialogue (hub over `/sc:brainstorm`). |
| `/ac:research` | Research existing tools, libraries, and patterns before writing code (search-first). Outputs an Adopt/Extend/Compose/Build recommendation. |
| `/ac:explore` | Progressively gather the minimal high-relevance context for a task (iterative-retrieval), then hand the curated file set to implementation. |
| `/ac:implement` | Implement a feature, component, or fix directly (hub over `/sc:implement`). The standalone implement step; use `/ac:spec-implement` for the spec-driven path. |
| `/ac:explain` | Explain code, a concept, or system behavior with educational clarity (hub over `/sc:explain`). |
| `/ac:doc` | Generate focused documentation for a component, function, API, or feature (hub over `/sc:document`). |
| `/ac:verify` | Run the six-phase verification gate (build, type, lint, test, security, diff) and emit a READY/NOT READY report. |
| `/ac:learn` | Review the session and capture reusable patterns as atomic, confidence-scored instincts; offer to persist to memory or a profile skill. |
| `/ac:pr` | Run pre-submission analysis and automate Pull Request creation via GitHub CLI. |
| `/ac:pr-fix` | Review and fix code review comments from the current branch's Pull Request. |
| `/ac:changelog` | Rewrite release notes into user-friendly language across CHANGELOG.md and platform changelogs (Fastlane, etc.). |

### 🔍 Review

| Command | Description |
|---|---|
| `/ac:review` | Central code-review hub. With no `--area`, asks (multi-select) which areas to run, then invokes the matching review skills and consolidates one report. |

**Review areas** (each backed by a skill, run via `/ac:review`): `clean-code`
(8 aspects: comments·environments·functions·naming·architecture·hygiene·logic·tests),
`security`, `performance`, `architecture`, `errors`, `types`, `simplify`. Pass
`--area <a> <b>` to skip the prompt; omit it to pick interactively.

### 🗺️ Planning

| Command | Description |
|---|---|
| `/ac:plan-estimate` | Estimate development effort/complexity for a task, feature, or project (hub over `/sc:estimate`). |
| `/ac:plan-validate` | Review and validate strategic plans with confidence assessment (red-team). |

### 🧩 Spec-Driven

Hubs over the bundled `speckit:*` commands. Run in order; each hands off to the next.

| Command | Description | Core → optional |
|---|---|---|
| `/ac:spec` | Turn a feature description into a clarified `spec.md`. | `specify` → `clarify` (opt. `constitution` first) |
| `/ac:spec-plan` | Generate design artifacts from the spec. | `plan` (opt. `checklist`) |
| `/ac:spec-tasks` | Generate an ordered `tasks.md`, then consistency-check. | `tasks` → `analyze` (opt. `taskstoissues`) |
| `/ac:spec-implement` | Execute `tasks.md` phase by phase, then verify. | `implement` (opt. `converge` loop) |

All ten `speckit:*` commands are wired in: the four hubs run the core stages and pull in the
optional ones (`constitution`, `checklist`, `taskstoissues`, `converge`) where they fit.
Requires a Spec Kit-initialized project (`.specify/`); run `/ac:index` first if absent.

### 🧭 Utility

| Command | Description |
|---|---|
| `/ac:context` | Audit context-window token consumption across loaded agents, skills, MCP servers, and rules; report bloat and prioritized savings. |
| `/ac:help` | This reference — list all `/ac:` commands by category. |

### ⚙️ Special

| Command | Description |
|---|---|
| `/ac:index` | Unified repository indexing, environment initialization, and knowledge graph generation. |

---

## Typical Feature Workflow

The personal commands chain into one eval-driven path. `/ac:ship` orchestrates the whole
chain; the individual steps are:

```text
/ac:index           → initialize & index the repo (once per repo)
   ↓
/ac:research        → search-first: adopt vs build
   ↓
/ac:explore         → gather minimal context for the task
   ↓
/ac:implement       → build it (or /ac:spec-implement for the spec-driven path)
   ↓
/ac:verify          → six-phase gate: build·type·lint·test·security·diff
   ↓
/ac:review          → delegate to category reviewers
   ↓
/ac:pr              → create the PR
   ↓
/ac:pr-fix          → address review feedback
   ↓
/ac:learn           → capture reusable patterns as instincts
```

## Boundaries

- This is a **static** reference. Keep the tables in sync when `commands/ac/` changes.
- Do **not** scan the filesystem to build the list at runtime.
