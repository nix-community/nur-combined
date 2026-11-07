# Design Artifacts

A plan derived from a spec keeps durable design knowledge beside the spec, where it is committed and archived with the change. The plan stays the execution contract and references these files instead of copying them. A plan without a spec writes none of them.

```text
specs/changes/<NNNN>-<slug>/
├── SPEC.md          # what and why (/ac:spec)
├── research.md      # decisions that needed research (/ac:plan)
├── data-model.md    # entity design (/ac:plan)
└── contracts/       # exposed interfaces (/ac:plan)
```

Each file is written only when its condition holds; a missing file means the condition did not hold. Spec approval does not cover these files: they belong to the plan and are approved with it.

## `research.md`

Write when planning actually researched an open question — an unknown, a dependency choice, or an integration pattern. Defaults adopted without research stay under the plan's Decisions.

One entry per question:

```markdown
## R1 — <question>

- **Decision:** what was chosen.
- **Rationale:** why, tied to `FR-###`, `SC-###`, or a constraint.
- **Alternatives considered:** each option and why it lost.
- **Sources:** links or repository paths that support the decision.
```

## `data-model.md`

Write when the spec's Key entities carry real structure: more than one entity, validation rules, or state transitions. A single plain entity stays in the plan's Context.

Per entity: its fields with meaning and constraints, identity and uniqueness, relationships, validation rules each traced to a `FR-###`, and state transitions (states, triggering events, guards). Describe types conceptually unless the plan has decided the storage.

## `contracts/`

Write when the change adds or alters an interface that other systems or users consume: a public library API, a CLI, an HTTP or RPC endpoint, an event or message, a file format. Skip purely internal changes.

One file per interface, in the format natural for it — OpenAPI or JSON Schema for HTTP, a command synopsis with flags and exit codes for a CLI, type signatures for a library, a schema for events or files. Every operation traces to the `FR-###` it serves, and a breaking change says so explicitly.

## Rules

- The plan's Context names each written artifact; tasks and acceptance criteria cite the entry, entity, or contract they implement.
- When implementation changes a design decision, the executing session updates the artifact and records the reason under the spec's Deviations, asking the user before a requirement-affecting change.
- The artifacts move to `archive/` with the change on ship. A new change that alters a contract writes its own `contracts/` entry rather than editing an archived one.
