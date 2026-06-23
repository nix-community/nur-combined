---
slug: create-agents-md
status: drafting
intent: clear
pending-action: write .omo/plans/create-agents-md.md
approach: Write AGENTS.md with repo-specific guidance for NUR packages maintained by teformel — covers package inventory, Qt6/Qt5 split architecture, patch patterns, dependency graph, update workflow, CI status, and known stale items.
---

# Draft: create-agents-md

## Components (topology ledger)
| id | outcome | status | evidence path |
|----|---------|--------|---------------|
| 1 | AGENTS.md file created | active | draft + plan files |
| 2 | Repo structure documented | active | read of all nix files |
| 3 | Update/ssh workflow documented | active | user message + pkg analysis |
| 4 | CI/outdated-items noted | active | .github/workflows/build.yml, flake.lock |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|------------|----------------|-----------|-------------|
| User wants AGENTS.md created from scratch | Create new file at repo root | No existing AGENTS.md/CLAUDE.md/opencode.json found | Yes |
| User maintains all packages here | Include all 16 packages (skip example-package) | default.nix exports exclude example-package | Yes |
| User wants SSH VM workflow documented | Document 192.168.70.128 connection | User explicitly provided VM credentials | Yes |

## Findings (cited - path:lines)

**Repo structure** (default.nix:1-48):
- NUR repository template with 14 Lingmo OS packages + 2 standalone packages
- Qt6 packages use `pkgs.kdePackages`; Qt5/KF5 packages use pinned nixpkgs `600b15aea1` (2024-04-07)
- flake.nix:4 — nixpkgs input is `nixpkgs-unstable`

**Package details:**
- `clash-party` (pkgs/clash-party/default.nix:30-71): version 1.9.6, .deb fetch, electron-style app
- `ww-manager` (pkgs/ww-manager/default.nix:1-47): Python CLI, hatchling build, version 2.1.10
- Lingmo Qt6 (10 pkgs): lib_lingmo, lingmoui, lingmo-core, lingmo-settings, lingmo-dock, lingmo-launcher, lingmo-filemanager, lingmo-kwin-plugins, lingmo-polkit-agent, lingmo-sddm-theme, lingmo-statusbar
- Lingmo Qt5 (3 pkgs): lingmo-desktop, lingmo-daemon, lingmo-screenlocker

**Stale items:**
- flake.lock:5 — lastModified is 2024-04-07 (very stale)
- lingmo-polkit-agent/default.nix:12 — hash is placeholder `AAAA...`
- lingmo-statusbar/default.nix:10 — `rev = "main"` (floating, not pinned)
- .github/workflows/build.yml:24,36 — nurRepo and cachixName still have placeholder values
- .github/workflows/build.yml:63-70 — evaluation check uses `nix-env` which may not work on newer Nix

## Decisions (with rationale)

1. **AGENTS.md goes at repo root** — standard location, no existing instruction files.
2. **Include known stale-item warnings** — essential for future agents to fix these.
3. **Document Qt6/Qt5 split prominently** — most critical architecture decision that is not obvious from filenames.
4. **Include SSH workflow** — user explicitly stated Windows host cannot run nix; VM is the build environment.

## Scope IN

- AGENTS.md file at repo root with:
  - Package inventory table
  - Qt strategy (Qt6 via kdePackages, Qt5 via pinned nixpkgs)
  - Patch pattern examples
  - Dependency graph for Lingmo packages
  - Update workflow (SSH into VM, nix build commands)
  - CI status notes
  - Known stale/incomplete items

## Scope OUT (Must NOT have)

- No modification to any .nix file, flake.lock, or CI config
- No execution of builds or SSH into VM
- No rewriting of existing package definitions
- No generic Nix/NixOS tutorial content
- No exhaustive file tree listing
- No speculative claims about package behavior

## Open questions

None — all findings verified from codebase.

## Approval gate
status: awaiting-approval
<!-- When exploration is exhausted and unknowns are answered, set status: awaiting-approval. -->
<!-- That durable record is the loop guard: on a later turn read it and resume at the gate instead of re-running exploration. -->
