# agent-ctrl configuration

This directory contains your agent-ctrl artifacts.
agent-ctrl is a CLI tool for managing AI agent configurations using a standard directory-based structure.
CLI tool repository: https://github.com/ahmet-cetinkaya/agent-ctrl

This repository is the working configuration surface for my coding agents: shared rules,
skills, commands, agents, and MCP definitions that can be applied to supported platforms with
`agent-ctrl apply`.

## Structure

- `rules/`: Behavioral rules in Markdown
- `skills/`: Skills using the SKILL.md standard
- `agents/`: Agent persona definitions
- `commands/`: Command prompt templates
- `.agent-ctrl/mcps/`: MCP server definitions
- `.agent-ctrl/.env`: SkillsMP and Smithery API credentials

## Prerequisites

The `/ac:*` commands declare a `codegraph` MCP server for graph-backed source exploration,
call-path navigation, and impact analysis. Install it once:

```bash
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
```

Then initialize each project you work in with `codegraph init` (`/ac:index` does this for
you). Add `.codegraph/` to the project's `.gitignore`.

## Next steps

1. Add your artifacts to the directories above.
2. Run `agent-ctrl rule ls`, `agent-ctrl skill ls`, or `agent-ctrl agent ls`.
3. Apply your configuration with `agent-ctrl apply <platform>`.

## Acknowledgments

This setup is built with, adapted from, or inspired by these projects:

- [agent-ctrl](https://github.com/ahmet-cetinkaya/agent-ctrl) — the CLI that manages and
  applies this configuration across agent platforms.
- [Ponytail](https://github.com/DietrichGebert/ponytail) — the minimal-engineering decision
  ladder behind `rules/minimal-engineering.md`.
- [Spec Kit](https://github.com/github/spec-kit) — spec-driven development workflows and the
  `speckit:*` command family.
- [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) — structured
  command, persona, and workflow patterns.
- [Everything Claude Code](https://github.com/affaan-m/ECC) — cross-harness agent workflows,
  review patterns, and skill organization ideas.
- [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) — planning,
  review, simplification, and learning loops for agentic engineering work.
- [Codegraph](https://github.com/colbymchenry/codegraph) — the code knowledge graph and MCP
  server behind source exploration, call-path navigation, and impact analysis.
