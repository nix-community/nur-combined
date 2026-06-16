---
name: graphify
description: "Turn any folder of files into a navigable knowledge graph"
category: utility
complexity: standard
mcp-servers: [graphify]
personas: []
---

# graphify

Turn any folder of files into a navigable knowledge graph.

## Usage

```bash
/graphify [path] [--mode deep] [--update] [--mcp]
```

## Steps

Always follow the Graphify skill defined in `skills/graphify/SKILL.md`.
If no path argument is provided, use the current directory (`.`).
Use `graphify` CLI directly for queries and updates once the graph is built.
