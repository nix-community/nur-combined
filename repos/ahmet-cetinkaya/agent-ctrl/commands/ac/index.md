---
name: ac:index
description: "Unified repository indexing, environment initialization, and knowledge graph generation."
category: special
complexity: standard
mcp-servers: [sequential-thinking, context7, serena, graphify]
personas: [architect, repo-index]
---

# /ac:index - Unified Initialization & Indexing

## Triggers

- When starting work on a new repository
- When the codebase has changed significantly and the index needs updating
- When a new agent needs to familiarize itself with the project structure

## Overview

This command serves as the single entry point for all project initialization and indexing.

## Execution Flow

When `/ac:index` is called, you must execute the following sub-tasks **in parallel** by spawning subagents or background tasks:

1. **Environment Initialization (`/init`)**
   - Run the agent's initialization mechanisms (e.g., `init`, `serena activate_project`, check `CLAUDE.md`/`AGENTS.md`).
   - Run `specify init . --ai <ai_agent>` (replacing `<ai_agent>` with the current agent name, e.g. `antigravity`, `claude`) to initialize spec-kit to the project.
   - Check and update `.gitignore` to ensure AI/agent configuration files and artifacts (e.g., `.agents/`, `.claude/`, `.specify/`, `CLAUDE.md`, `AGENTS.md`, `graphify-out/`, etc.) are ignored.
2. **Project Documentation (`/sc:index`)**
   - Execute the `/sc:index` command to generate comprehensive project documentation, API docs, and knowledge base structures.
3. **Knowledge Graph Generation (`/graphify`)**
   - Execute the `/graphify .` skill to build a structural knowledge graph. If previously run, use `/graphify . --update`.

### Synchronization & Synthesis

Once all parallel sub-tasks complete:

- Review the generated documentation from `sc:index` and the graph report from `graphify`.
- Produce a unified summary of the repository's current state and architecture for the user.

## Boundaries

- Do **not** manually crawl the entire repository; rely strictly on the parallel sub-tasks to gather context and index the code.
