# contexts

Behavior-mode primers — short Markdown files that bias how the agent works during a session.
Load one to shift between building, investigating, and reviewing. They set posture and tool
preference, not project facts.

These are loaded manually (paste or reference the file); they are not auto-wired into any hook.

## Modes

| File | Mode | Posture |
|------|------|---------|
| `dev.md` | Development | Write code first, working over perfect, run tests, atomic commits. |
| `research.md` | Research | Read widely before concluding, ask clarifying questions, findings before recommendations. |
| `review.md` | Code review | Read thoroughly, rank findings by severity, suggest fixes, check security. |

## Adding a mode

Create `<mode>.md` with three sections that keep the files comparable:

```markdown
# <Name> Context

Mode: <one line>
Focus: <one line>

## Behavior
- <posture bullets>

## Tools to favor
- <which tools fit this mode>
```

Keep them short — a primer, not a manual. Anything project-specific belongs in the project's
own docs or memory, not a context primer.
