# agent-ctrl configuration

**CLI:** [github.com/ahmet-cetinkaya/agent-ctrl](https://github.com/ahmet-cetinkaya/agent-ctrl)

My personal AI agent configuration hub — artifacts (rules, skills, commands, agents, MCP servers,
profiles) that define agent behavior across Claude Code and other platforms. Managed by the
[`agent-ctrl`](https://github.com/ahmet-cetinkaya/agent-ctrl) CLI.

## ❓ What is agent-ctrl?

`agent-ctrl` is a CLI tool for managing AI agent configurations using a standard directory-based
structure. This repo holds the artifacts; `agent-ctrl apply <platform>` syncs them into each
tool's native config directory (`~/.claude/`, `.cursor/`, etc.).

```bash
agent-ctrl apply claude       # sync to Claude Code (~/.claude/)
agent-ctrl apply cursor       # sync to Cursor (.cursor/)
agent-ctrl rule ls            # list / search artifacts
agent-ctrl skill ls
agent-ctrl agent ls
agent-ctrl mcp ls
agent-ctrl command ls
```

Credentials and platform API keys live in `.env` (git-ignored); referenced from MCP configs via
`${VAR}` substitution at apply time.

## 📁 Directory structure

```
agent-ctrl/
├── rules/                 # Behavioral guidelines (Markdown)
├── skills/                # Top-level capabilities (SKILL.md standard)
├── profiles/              # Stack-specific skills, agents, rules (52 stacks)
├── commands/
│   ├── ac/                # Personal /ac:* command hubs
│   ├── sc/                # SuperClaude /sc:* commands
│   ├── speckit/           # Spec Kit spec-driven commands
│   └── graphify.md, rtk.md
├── agents/                # Agent persona definitions (40+ agents)
├── mcps/                  # MCP server configurations
├── deploy/                # Self-hosted service deployments
└── .catalog/              # Remote catalog state (SkillsMP, Smithery)
```

## 🔌 MCP servers

MCP (Model Context Protocol) servers extend agents with external capabilities. Each lives in
`mcps/<name>.json` and is loaded by name from command frontmatter (`mcp-servers: [...]`).

| Server | Purpose |
|--------|---------|
| **serena** | LSP-based code navigation, symbol search, reflection tools (`think_about_*`), project activation |
| **graphify** | Codebase → knowledge graph; god-node detection, community structure, shortest paths |
| **context7** | Up-to-date library/framework documentation (React, Next.js, Pragma, Django, …) |
| **parallel-search** | Web search + fetch with LLM-optimized excerpts (replaces exa) |
| **sequential-thinking** | Multi-step reasoning chains for complex analysis |
| **github** | GitHub CLI MCP — repos, issues, PRs automation |
| **longhand** | Lossless session history — indexes `~/.claude/projects/*.jsonl` into SQLite + ChromaDB for verbatim recall |
| **morph** | Large-scale pattern-based code transformation |
| **token-optimizer** | Token analytics, caching, compression strategies |
| **codescene** | Code health analysis and technical debt detection |
| **evalview** | Evaluation harness visualization and dashboards |
| **devfleet** | Multi-agent fleet orchestration |
| **nexus** | Agentic workflow orchestration |
| **filesystem** | Sandboxed filesystem access |

### 🌐 External layer

- **OmniRoute** — LLM gateway/router in front of Claude Code: multi-provider fallback, prompt
  compression (RTK + Caveman), and built-in memory. This is where request routing and token
  compression happen, transparent to the agent.
- **RTK (Rust Token Killer)** — CLI proxy that token-optimizes dev operations (60–90% savings);
  auto-rewrites shell commands via a Claude Code hook.

## ⚡ Commands — `/ac:*`

Personal command hub. Eval-driven development workflow, run individually or orchestrated
end-to-end via `/ac:ship`.

**Typical feature workflow:**
```
/ac:index      → init & index repo (once)
/ac:research   → search-first: adopt vs build
/ac:explore    → gather minimal context
/ac:implement  → build it (or /ac:spec-implement for spec-driven)
/ac:verify     → 6-phase gate: build·type·lint·test·security·diff
/ac:review     → delegate to category reviewers
/ac:pr         → create the PR
/ac:pr-fix     → address review feedback
/ac:learn      → capture reusable patterns
```

| Command | Purpose |
|---------|---------|
| `/ac:ship` | End-to-end eval-driven feature flow orchestrating the full pipeline below |
| `/ac:brainstorm` | Discover and shape requirements from a vague idea via Socratic dialogue, then hand a concrete brief to `/ac:research` or `/ac:ship` |
| `/ac:research` | Research existing tools, libraries, and patterns before writing code (search-first) → Adopt/Extend/Compose/Build recommendation |
| `/ac:explore` | Progressively gather the minimal high-relevance context for a task (iterative-retrieval), then hand the curated file set to implementation |
| `/ac:implement` | Implement a feature, component, or fix directly — the standalone implement step of the ship chain |
| `/ac:verify` | Run the six-phase verification gate (build, type, lint, test, security, diff) and emit a READY/NOT READY report |
| `/ac:review` | Central code-review hub — no-argument multi-select across clean-code, security, performance, architecture, errors, types, simplify |
| `/ac:pr` | Pre-submission analysis + automated draft PR creation via GitHub CLI |
| `/ac:pr-fix` | Review and fix code review comments from the current branch's Pull Request |
| `/ac:learn` | Review the session and capture reusable patterns as atomic, confidence-scored instincts; offers to persist to memory or a profile skill |
| `/ac:explain` | Explain code, a concept, or system behavior with educational clarity |
| `/ac:doc` | Generate focused documentation for a component, function, API, or feature |
| `/ac:changelog` | Rewrite release notes into user-friendly language across CHANGELOG.md and platform-specific changelogs |
| `/ac:plan-estimate` | Estimate development effort/complexity for a task, feature, or project |
| `/ac:plan-validate` | Review and validate strategic plans with confidence assessment |
| `/ac:spec` | Spec-driven flow entry point — turns a feature description into a clarified specification, then hands off to `/ac:spec-plan` |
| `/ac:spec-plan` | Spec-driven planning stage — clarified spec → design artifacts, then hands off to `/ac:spec-tasks` |
| `/ac:spec-tasks` | Spec-driven task stage — generates ordered `tasks.md`, cross-checks spec/plan/tasks consistency |
| `/ac:spec-implement` | Spec-driven implementation stage — executes `tasks.md` phase by phase, then hands off to `/ac:verify` |
| `/ac:context` | Audit context-window token consumption across loaded agents, skills, MCP servers, and rules; report bloat and savings recommendations |
| `/ac:index` | Unified repository indexing, environment initialization, and knowledge graph generation |
| `/ac:help` | List all personal `/ac:*` commands |

## 🤖 Agents

40+ specialist agent personas in `agents/`, including: `architect`, `backend-architect`,
`frontend-architect`, `system-architect`, `devops-architect`, `code-reviewer`, `security-reviewer`,
`performance-engineer`, `tdd-guide`, `refactor-cleaner`, `planner`, `deep-research`,
`requirements-analyst`, `root-cause-analyst`, `technical-writer`, `socratic-mentor`, plus the
GAN harness family (`gan-planner`, `gan-generator`, `gan-evaluator`).

## 🧠 Skills

Top-level capabilities in `skills/` following the SKILL.md standard. Notable clusters:

- **Engineering process**: `agentic-engineering`, `ai-first-engineering`, `tdd-workflow`,
  `eval-harness`, `verification-loop`, `continuous-learning-v2`
- **Architecture**: `hexagonal-architecture`, `architecture-decision-records`, `blueprint`
- **Review**: `review-clean-code`, `review-architecture`, `review-performance`, `review-security`,
  `review-errors`, `review-types`, `review-simplify`
- **Research**: `deep-research`, `search-first`, `iterative-retrieval`, `repo-scan`
- **Autonomous**: `autonomous-agent-harness`, `autonomous-loops`, `continuous-agent-loop`,
  `ralphinho-rfc-pipeline`
- **Multi-agent**: `gan-style-harness`, `team-agent-orchestration`, `council`, `claude-devfleet`
- **Infrastructure**: `codebase-onboarding`, `production-audit`, `security-scan`,
  `latency-critical-systems`, `terminal-ops`

## 📦 Profiles

Stack-specific bundles under `profiles/<stack>/` — each can carry its own `skills/`, `agents/`,
`rules/`. 52 stacks available, including:

`angular`, `backend`, `blockchain`, `cpp`, `csharp`, `flutter`, `go`, `godot`, `harmonyos`,
`java`, `kotlin`, `nestjs`, `nextjs`, `nuxt`, `php`, `python`, `react`, `ruby`, `rust`, `swift`,
`typescript`, `vercel`, `vite`, `vue`, `supabase`, `clickhouse`, `cloudflare`, `devops`,
`ml`, `data`, `finance`, `healthcare`, `logistics`, `mcp`, `research`, and more.

## 📜 Rules

Behavioral guidelines in `rules/`, loaded into agent context:

- **agent-behavior** — core interaction rules (ask questions, no change-tracking comments)
- **clean-code** — Martin Fowler's complete Clean Code ruleset (C1–C5, E1–E2, F1–F4, G1–G36, N1–N7, T1–T9)
- **coding-style** — immutability-first, KISS/DRY/YAGNI, naming conventions
- **code-review** — mandatory review triggers, severity levels, security checklist
- **development-workflow** — research-first → plan → TDD → review → commit pipeline
- **git-workflow** — conventional commit format
- **semantic-commit** — `type(scope): subject` conventions
- **security** — mandatory security checks before commit
- **testing** — 80% coverage minimum, TDD workflow, AAA pattern
- **performance**, **patterns**, **hooks**, **agents**

## 🚀 Deploy

Self-hosted service deployments for infrastructure the agent config depends on.

## 🗂️ Catalog

Remote registry integration (SkillsMP, Smithery) tracked in `.catalog/state.json`:

```bash
agent-ctrl skill sync        # sync skills catalog
agent-ctrl skill search <q>
agent-ctrl skill add <id>
agent-ctrl mcp sync          # sync MCP catalog
agent-ctrl mcp search <q>
agent-ctrl mcp add <id>
```

## 🏁 Quick start

```bash
# 1. Clone and enter
git clone <this-repo> ~/Configs/agent-ctrl && cd ~/Configs/agent-ctrl

# 2. Copy credentials
cp .env.example .env && $EDITOR .env

# 3. Apply to your platform
agent-ctrl apply claude

# 4. Verify
agent-ctrl rule ls && agent-ctrl skill ls && agent-ctrl mcp ls
```

## 🔐 Environment

All secrets via `.env` (git-ignored, never committed). MCP configs reference variables with
`${VAR}` syntax, resolved at `agent-ctrl apply` time. See `.env.example` for the full list.

## 🙏 Acknowledgments

Built on top of, and inspired by, these open-source projects:

- [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) — `/sc:*`
  command patterns and multi-persona orchestration
- [OmniRoute](https://github.com/diegosouzapw/OmniRoute) — LLM gateway/router with prompt
  compression (RTK + Caveman) and built-in memory
- [ECC](https://github.com/affaan-m/ECC) — PRP-driven engineering context conventions
- [Spec Kit](https://github.com/github/spec-kit) — spec-driven development lifecycle
  (`speckit:*` commands)
- [Serena](https://github.com/oraios/serena) — LSP-based semantic code navigation
- [agent-ctrl](https://github.com/ahmet-cetinkaya/agent-ctrl) — the CLI that applies and
  manages all of the above
