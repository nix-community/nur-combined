# agent-ctrl configuration

This directory contains your agent-ctrl artifacts.
agent-ctrl is a CLI tool for managing AI agent configurations using a standard directory-based structure.
CLI tool repository: https://github.com/ahmet-cetinkaya/agent-ctrl

## Structure

- `rules/`: Behavioral rules in Markdown
- `skills/`: Skills using the SKILL.md standard
- `agents/`: Agent persona definitions
- `commands/`: Command prompt templates
- `.agent-ctrl/mcps/`: MCP server definitions
- `.agent-ctrl/.env`: SkillsMP and Smithery API credentials

## Next steps

1. Add your artifacts to the directories above.
2. Run `agent-ctrl rule ls`, `agent-ctrl skill ls`, or `agent-ctrl agent ls`.
3. Apply your configuration with `agent-ctrl apply <platform>`.
