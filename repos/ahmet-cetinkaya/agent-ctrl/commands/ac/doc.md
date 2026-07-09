---
name: ac:doc
description: "Generate focused documentation for a component, function, API, or feature. Minimal hub over /sc:document; complements /ac:index (repo-wide) with targeted docs."
category: workflow
complexity: standard
mcp-servers: []
personas: [technical-writer]
---

# `/ac:doc` - Focused Documentation

Minimal hub. Delegates to **`/sc:document`** to generate documentation for a specific
target (component, function, API, or feature) — distinct from `/ac:index`, which builds
repo-wide documentation.

## Usage

```bash
/ac:doc [target]   # e.g., a file, function, module, or feature name
```

## Workflow

1. **Analyze** — examine the target's structure, interfaces, and behavior.
2. **Generate** — produce the docs (inline / external / API reference / guide).
3. **Integrate** — match the project's existing documentation style and cross-references.

## Delegation

- Runs **`/sc:document`** for the actual generation.
- For repo-wide docs/knowledge base, use **`/ac:index`** instead.
- After large doc changes, **`/ac:review:clean-code:comments`** (via `/ac:review`) checks
  comment quality.

## Output

The generated documentation for the target, in the requested format.
