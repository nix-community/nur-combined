# k3s nas + MacMini-Intel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring up a 2-server k3s cluster (nas init, MacMini-Intel join) declaratively via NixOS.

**Architecture:** New `nixcfg.k3s` wrapper module around upstream `services.k3s` keeps per-host configs tiny; nas uses `clusterInit=true` with embedded etcd, MacMini joins via `serverAddr=https://10.1.0.3:6443` with the same sops token; flannel vxlan defaults and local-path storage, traefik disabled.

**Tech Stack:** NixOS (`services.k3s`), sops-nix, flannel, embedded etcd, `nix flake show/check`.

**Spec:** `docs/superpowers/specs/2026-10-25-k3s-nas-design.md`

## Global Constraints

- Token must come from `config.sops.secrets."k3s-token".path` as `tokenFile`, never plaintext in store.
- `nas` is first server with `clusterInit = true`; `MacMini-Intel` joins with `serverAddr = "https://10.1.0.3:6443"`.
- Do not bind 80/443 on either node; edge stays on router Caddy.
- Cluster CIDRs must not collide with 10.1.0.0/24 or 10.200.0.0/16 (use k3s defaults 10.42.0.0/16 + 10.43.0.0/16).
- `nix fmt` before commit; validation is `nix flake show` + affected `nixos-rebuild dry-activate`.
- 2-server etcd has no quorum HA until a third server joins; accepted for day one.

## Review Focus

- Token file permissions / world-readable store leak — a reasonable person expects `sops.secrets."k3s-token"` to be root-only and only referenced via `tokenFile`.
- Firewall too open (0.0.0.0/0 on 6443) — expect LAN-only (10.1.0.0/24).
- Both nodes accidentally `clusterInit=true` causing split-brain — expect exactly one init.
- Traefik accidentally enabled binding 80/443 — expect `disable = [ "traefik" ]` on both.
- MacMini deployed before nas is up causing join flap — expect ordered rollout nas-then-macmini with retry/backoff working.

---

### Task 1: `nixcfg.k3s` wrapper module

**Files:**
- Create: `modules/nixos/k3s.nix`
- Modify: `modules/nixos/default.nix`

**Interfaces:**
- Consumes: upstream `services.k3s.{enable, role, clusterInit, serverAddr, tokenFile, extraFlags, disable}` (rancher base module).
- Produces: `nixcfg.k3s.{enable, role, clusterInit, serverAddr, tokenFile, extraSANs, disable}` for Tasks 2-3.

- [ ] **Step 1: Create `modules/nixos/k3s.nix` with `lib.mkEnableOption` + `lib.mkOption` interface**

  Define `options.nixcfg.k3s`: `enable` (bool), `role` (enum server/agent, default `"server"`), `clusterInit` (bool, default false), `serverAddr` (null-or-str, default null), `tokenFile` (null-or-path), `extraSANs` (list-of-str, default `[]`), `disable` (list-of-str, default `[ "traefik" ]`). Map to `services.k3s` when `cfg.enable`: `role`, `clusterInit`, `serverAddr` (mkIf non-null), `tokenFile`, `disable`, plus `extraFlags = map (san: "--tls-san=${san}") cfg.extraSANs`. Add firewall rules via `networking.firewall` for 6443/tcp, 10250/tcp, 8472/udp, 51820-51821/udp. Follow `modules/nixos/podman.nix` + `containers/*.nix` style (`cfg = config.nixcfg.k3s`, `lib.mkIf cfg.enable`).

- [ ] **Step 2: Register module in `modules/nixos/default.nix`**

  Add `./k3s.nix` to the `imports` list and `k3s = ./k3s.nix;` to the attribute set alongside `podman`.

- [ ] **Step 3: Verify evaluation**

  Run: `nix flake show 2>&1 | head -n 30`
  Expected: PASS (no eval error).

- [ ] **Step 4: Commit**

```bash
nix fmt
git add modules/nixos/k3s.nix modules/nixos/default.nix
git commit -m "feat: add nixcfg.k3s wrapper module"
```

### Task 2: nas as init server

**Files:**
- Modify: `configurations/nixos/nas/configuration.nix`
- Manual: `secrets.yaml` (user runs sops)

**Interfaces:**
- Consumes: `nixcfg.k3s.*` from Task 1, `config.sops.secrets."k3s-token".path`, `homelab` IPs.
- Produces: running init server at `https://10.1.0.3:6443`, token shared with Task 3.

- [ ] **Step 1: Add manual token generation instruction (do not commit plaintext)**

  Run (user, on trusted machine): `openssl rand -hex 32` then add as `k3s-token: <value>` via `sops secrets.yaml`. Verify with `sops -d secrets.yaml | rg k3s-token` showing a key exists (value redacted in output check).

- [ ] **Step 2: Wire nas config**

  In `configurations/nixos/nas/configuration.nix`: set `nixcfg.k3s = { enable = true; role = "server"; clusterInit = true; tokenFile = config.sops.secrets."k3s-token".path; extraSANs = [ "10.1.0.3" "nas" "nas.diekvoss.net" "10.1.0.12" "10.1.0.1" "10.1.0.6" ]; disable = [ "traefik" ]; };` plus `sops.secrets."k3s-token" = { };` (owner root default, mode `0400`). Restrict firewall to LAN if module opens globally.

- [ ] **Step 2b: Verify no plaintext token + LAN-only firewall**

  Run: `rg -n "k3s-token|tokenFile" configurations/nixos/nas/configuration.nix modules/nixos/k3s.nix; rg -n "6443|8472|10250" modules/nixos/k3s.nix`
  Expected: only `tokenFile = config.sops.secrets."k3s-token".path` references, no hex value; firewall ports present and scoped to 10.1.0.0/24.

- [ ] **Step 3: Dry-activate nas**

  Run: `nixos-rebuild dry-activate --flake .#nas 2>&1 | tail -n 20` (or `nix build .#nixosConfigurations.nas.config.system.build.toplevel --dry-run`)
  Expected: PASS, no assertion `clusterInit must be false` errors.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/nas/configuration.nix docs/superpowers/specs/2026-10-25-k3s-nas-design.md
git commit -m "feat: k3s init server on nas"
```

### Task 3: MacMini-Intel joins as second server

**Files:**
- Modify: `configurations/nixos/MacMini-Intel/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.*` from Task 1, same `k3s-token` secret, nas API `https://10.1.0.3:6443`.
- Produces: 2-node cluster (`kubectl get nodes` shows both Ready).

- [ ] **Step 1: Wire MacMini-Intel config**

  Set `nixcfg.k3s = { enable = true; role = "server"; clusterInit = false; serverAddr = "https://10.1.0.3:6443"; tokenFile = config.sops.secrets."k3s-token".path; extraSANs = [ "10.1.0.12" "MacMini-Intel-NixOS" ]; disable = [ "traefik" ]; };` plus `sops.secrets."k3s-token" = { };`. Assert `clusterInit` is false (no split-brain).

- [ ] **Step 2: Dry-activate macmini**

  Run: `nixos-rebuild dry-activate --flake .#MacMini-Intel 2>&1 | tail -n 20`
  Expected: PASS.

- [ ] **Step 3: Ordered rollout note (deploy-time, not eval)**

  Deploy nas first, wait for `k3s kubectl get nodes` Ready, then deploy MacMini-Intel. Document in commit message.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/MacMini-Intel/configuration.nix
git commit -m "feat: join MacMini-Intel to k3s cluster"
```

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md` (add follow-ups: third server for quorum, storage re-architecture, aarch64, Caddy ingress), this plan checkboxes.

**Interfaces:**
- Consumes: nothing new.
- Produces: closed loop, no stale todos.

- [ ] **Step 1: Update todos.md and verify formatting**

  Run: `nix fmt && nix flake show 2>&1 | head -n 20`
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-25-k3s-nas-macmini.md
git commit -m "docs: k3s two-node rollout follow-ups"
```
