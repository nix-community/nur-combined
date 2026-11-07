---
name: technical-writing
description: Write prose a reader can act on — documentation, release notes, PR descriptions, specs, reports — in the repository's own style, defaulting to ASD-STE100 Simplified Technical English when it has none. Use whenever the deliverable is human-readable text; do not use for code, comments inside code, or chat answers.
---

# Technical Writing

## Trigger

Use when the output is text people will read later: documentation, release notes, PR or issue text, spec and plan prose, README edits, reports.

## Non-trigger

Do not activate for code, identifiers, commit subjects that follow the repository's own convention, or conversational replies.

## Rules

1. Name the reader and write at their level; say what they can do, not how the code does it, unless they are developers.
2. State only verified behavior. A name, guarantee, command, or example that was not checked against the repository does not go in.
3. The repository's existing prose style wins: match neighboring documents, headings, terminology, and link style before applying any default.
4. Where the repository sets no style and the text is English, write to [the STE rules](references/ste.md).
5. Code identifiers, commands, paths, and product names are technical names: keep the repository's exact spelling and formatting.
6. Read the result once as the named reader; cut every sentence they do not need.
