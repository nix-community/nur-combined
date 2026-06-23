# create-agents-md - Work Plan

## TL;DR (For humans)

**What you'll get:** A concise `AGENTS.md` file at the root of your `nur-packages` repo that tells any future AI agent everything it needs to know to work here — your package list, the tricky Qt6/Qt5 split, how to build on your NixOS VM, patch patterns, what's stale and needs fixing.

**Why this approach:** The repo has a complex dual-Qt architecture (Qt6 via kdePackages + Qt5 via pinned old nixpkgs), NixOS-specific workarounds that are non-obvious, and several stale items. Without this file, agents waste time rediscovering the same hard-earned context.

**What it will NOT do:** Touch any package definition, config, CI, or flake files. No builds, no SSH into your VM. Pure documentation.

**Effort:** Short
**Risk:** Low - read-only operation, no code changes
**Decisions to sanity-check:** Whether to include the stale-item warnings (recommended: yes, they help future agents)

Your next move: **Approve or request changes**. After approval, execution writes AGENTS.md in ~5 minutes.

---

> TL;DR (machine): Short | Low | One file: AGENTS.md with package inventory, Qt strategy, patch patterns, update workflow, CI notes, stale-item warnings

## Scope
### Must have
- AGENTS.md at repo root covering: package table, Qt6/Qt5 split, patch patterns, dependency graph, SSH+VM build workflow, CI status, known stale items

### Must NOT have (guardrails, anti-slop, scope boundaries)
- No modifications to any .nix files, flake.lock, CI config, or other repo content
- No nix builds, no SSH execution
- No generic Nix/NixOS tutorials
- No exhaustive file tree listings
- No speculative/unverified claims

## Verification strategy
- Test decision: none (documentation-only; verified by reading output file)
- Evidence: .omo/evidence/task-1-create-agents-md.content (the AGENTS.md itself)

## Execution strategy
### Parallel execution waves
- Single wave: 1 todo (only one file to create)

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 1. Write AGENTS.md | — | — | — |

## Todos
- [ ] 1. Write AGENTS.md at repo root
  What to do / Must NOT do: Create `C:\Users\maorila\nur-packages\AGENTS.md` with the following sections (content derived from the draft findings):
  1. **Host environment** — SSH VM workflow (192.168.70.128, credentials maorila/maorila), Windows host constraint
  2. **Package overview table** — all 16 packages (skip example-package), type, Qt version, source
  3. **Architecture** — Qt strategy (Qt6 via kdePackages, Qt5 via pinned nixpkgs), common patch patterns (`/usr/` stripping), known workarounds (QApt stub, Python shebangs, KDecoration2/3)
  4. **Dependency graph** — Lingmo Qt6 inter-package deps
  5. **Updating packages** — step-by-step workflow via SSH, build commands, Lingmo-specific hash tips
  6. **CI status** — GitHub Actions workflow notes, placeholder values for nurRepo/cachixName
  7. **Stale/outdated items** — flake.lock age, lingmo-polkit-agent placeholder hash, lingmo-statusbar floating rev, CI placeholders, example-package template artifact
  Must NOT modify any other file.
  
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  
  References:
  - default.nix:1-48 — package exports
  - flake.nix:1-18 — flake config
  - flake.lock:1-27 — stale lock info
  - pkgs/*/default.nix — individual package definitions
  - .github/workflows/build.yml:1-76 — CI config
  - .github/dependabot.yml:1-10 — dep update config
  - ci.nix:1-56 — build logic
  - overlay.nix:1-15 — overlay entry
  - full draft: .omo/drafts/create-agents-md.md
  
  Acceptance criteria (agent-executable):
  - File `C:\Users\maorila\nur-packages\AGENTS.md` exists
  - File contains all 7 required sections
  - File mentions 192.168.70.128 and maorila credentials
  - File lists all 16 packages with correct Qt categorization
  - File does NOT contain any generic Nix tutorials or file trees
  
  QA scenarios: Read the file after writing and verify each section exists with correct content. Evidence: .omo/evidence/task-1-create-agents-md.content
  Commit: Y | `docs: add AGENTS.md with repo context for future agents`

## Final verification wave
- [ ] F1. Plan compliance audit — verify AGENTS.md matches scope in/out
- [ ] F2. Code quality review — verify no files other than AGENTS.md were modified
- [ ] F3. Real manual QA — read AGENTS.md and confirm all sections present
- [ ] F4. Scope fidelity — verify no stale/unverified claims

## Commit strategy
- Single commit: `docs: add AGENTS.md with repo context for future agents`

## Success criteria
- AGENTS.md exists at repo root
- All 7 sections populated from codebase evidence
- No other files modified
