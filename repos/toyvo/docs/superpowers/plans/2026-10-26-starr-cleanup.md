# Starr Container Cleanup Implementation Plan

**Goal:** Container module describes the qBittorrent-only reality; all retired-service code deleted.

**Architecture:** Deletion-only edits to `modules/nixos/containers/starr.nix` + nas config comments + homelab upstreams comments.

**Tech Stack:** NixOS containers, nix fmt, eval + toplevel build validation.

**Spec:** `docs/superpowers/specs/2026-10-26-starr-cleanup-design.md`

## Global Constraints

- qBittorrent behavior byte-identical (ports, serverConfig, mounts, units).
- POOL state dirs untouched. NAT masquerade stays.
- `nix fmt` before commit; validation is eval + nas toplevel build; switch + checks manual.
- `rg disabledServices` must be empty repo-wide at the end.

## Review Focus

- Orphaned references (option removed but still referenced) — expect eval to fail loudly; test in Task 1 pins it.
- qBittorrent block accidentally altered — expect its rendered config unchanged; test in Task 1 pins it (diff serverConfig eval before/after).
- Stale comments claiming retired services exist — expect none; test in Task 2 pins it.

---

### Task 1: delete retired code from starr.nix + nas config

**Files:**
- Modify: `modules/nixos/containers/starr.nix`, `configurations/nixos/nas/configuration.nix`.

**Interfaces:**
- Consumes: current module + nas starr section.
- Produces: qBittorrent-only container module; no `disabledServices` anywhere.

- [ ] **Step 1: Snapshot qBittorrent rendered config (before)**

  Run: `nix eval --json ...containers.starr.config.services.qbittorrent.serverConfig` — save output to ledger. This is the byte-identical bar.
  Expected: recorded.

- [ ] **Step 2: Delete retired blocks**

  starr.nix: remove `ports.{bazarr,flaresolverr,lidarr,prowlarr,radarr,readarr,sonarr}`, `disabledServices` option, retired bindMounts (keep `/mnt`, protonvpn key, `/var/lib/qBittorrent`), retired UID pins + groups + prowlarr special-case + DynamicUser force, retired `services.*` blocks; collapse `services = lib.mkMerge [...]` to a plain `{ qbittorrent = {...}; }`; fix the NAT comment (no longer mentions prowlarr/flaresolverr); update enable description.
  nas config: remove `disabledServices` list; refresh starr comments.
  Expected: `rg disabledServices` empty (except docs/plans history).

- [ ] **Step 3: Verify qBittorrent config unchanged + eval + build**

  Run: same serverConfig eval — diff against ledger, expect identical. `nix flake show` PASS. `nix build ...nas toplevel...` PASS.
  Expected: identical config, green build.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add modules/nixos/containers/starr.nix configurations/nixos/nas/configuration.nix
git commit -m "chore: drop retired starr services from container (qBittorrent only)"
```

### Task 2: homelab upstreams comments to steady state

**Files:**
- Modify: `homelab.nix` (comments only).

- [ ] **Step 1: Reword the seven upstreams comments**

  Replace `(plan step: flip)` phrasing with steady-state wording (e.g. `# Served from k3s via Traefik.`). No value changes.
  Expected: values untouched (`git diff` shows comment-only).

- [ ] **Step 2: Commit (NOT switched yet)**

```bash
nix fmt
git add homelab.nix
git commit -m "chore: steady-state comments on starr upstreams"
```

### Task 3: Manual switch + verify qBittorrent intact (user)

**Files:** none.

- [ ] **Step 1: Switch nas + verify**

  Switch nas. Checks: qbit WebUI 200 (`curl -o /dev/null -w "%{http_code}\n" http://10.200.0.2:4080/`), retired ports quiet (spot-check 2-3), container units show only qbittorrent + support (`sudo nixos-container ...` or machinectl shell + systemctl list-units — confirm no *arr units).
  Expected: qbit 200, retired quiet, units clean.

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off container cleanup. Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-26-starr-cleanup.md
git commit -m "docs: starr container cleanup complete"
```
