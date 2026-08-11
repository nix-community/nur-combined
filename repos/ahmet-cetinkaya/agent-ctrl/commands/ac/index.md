---
name: ac:index
description: "Unified repository indexing, environment initialization, and Codegraph graph initialization."
category: special
complexity: standard
mcp-servers: [sequential-thinking, serena, codegraph]
personas: [architect, repo-index]
---

# /ac:index - Unified Initialization, Indexing & Codegraph Setup

## Triggers

- When starting work on a new repository
- When the codebase has changed significantly and the index needs updating
- When a new agent needs to familiarize itself with the project structure

## Overview

This command serves as the single entry point for project indexing, environment initialization,
and Codegraph graph initialization.

## Execution Flow

When `/ac:index` is called, you must execute the following sub-tasks **in parallel** by spawning subagents or background tasks. Apply the **`parallel-execution-optimizer`** skill to schedule these concurrently without losing correctness:

1. **Environment Initialization (`/init`)**
   - Run the agent's initialization mechanisms (e.g., `init`, `serena activate_project`, check `CLAUDE.md`/`AGENTS.md`).
   - Run `specify init . --ai <ai_agent>` (replacing `<ai_agent>` with the current agent name, e.g. `antigravity`, `claude`) to initialize spec-kit to the project.
   - Run `codegraph init` once per project to build the Codegraph code graph (`.codegraph/`). Skip it if `.codegraph/` already exists; run `codegraph sync` after source changes.
   - Check and update `.gitignore` to ensure AI/agent configuration files and artifacts (e.g., `.agents/`, `.claude/`, `.codegraph/`, `.specify/`, `CLAUDE.md`, `AGENTS.md`, etc.) are ignored.
2. **Project Documentation (`/sc:index`)**
   - Execute the `/sc:index` command to generate comprehensive project documentation, API docs, and knowledge base structures.

### Synchronization & Synthesis

Once all parallel sub-tasks complete:

- Review the generated documentation from `sc:index`.
- Produce a unified summary of the repository's current state and architecture for the user.
- Apply the **`codebase-onboarding`** skill to synthesize an architecture map, key entry points, conventions, and a starter `CLAUDE.md`/`AGENTS.md` from these artifacts.

## Boundaries

- Do **not** manually crawl the entire repository; rely strictly on the parallel sub-tasks to gather context and index the code.
