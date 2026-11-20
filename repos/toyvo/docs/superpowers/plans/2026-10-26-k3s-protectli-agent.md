# k3s Protectli Agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Protectli joins the cluster as a worker agent for capacity; quorum stays 3.

**Architecture:** Host config only — `nixcfg.k3s` agent mode (`role="agent"`, `serverAddr` at nas, shared sops token, `firewallInterfaces=["enp1s0"]` — node IP 10.1.0.6 lives there via router DHCP); no module changes unless the nodeIP fallback triggers. Also adds the k3s module to Protectli's cherry-picked imports.

**Tech Stack:** NixOS (`services.k3s` agent), sops-nix, flannel.

**Spec:** `docs/superpowers/specs/2026-10-26-k3s-protectli-agent-design.md`

## Global Constraints

- Protectli is `role = "agent"` — never `clusterInit`, never `disableAgent` (assertions enforce).
- k3s ports on `enp1s0` only (node IP interface); nothing global. Its 192.168.x br0/VLAN layout is intentional (test router), untouched.
- Packaged disable flags stay uniform (`["servicelb"]` effective); agents don't manage manifests.
- `nix fmt` before commit; validation is `nix flake show` + protectli toplevel build; deploy is manual.
- Rollback: `enable = false` + switch; node leaves.

## Review Focus

- Agent accidentally becomes voter (`clusterInit=true` or `role="server"` typo) — expect `kubectl get nodes` to show protectli WITHOUT control-plane/etcd roles and etcd staying 3 voters; test in Task 3 pins it.
- Token mismatch (wrong sops key name) — expect join to fail closed with auth error, never half-join; test in Task 3 pins it (password-verified log line).
- Wrong node IP (stale default route via enp1s0) — expect INTERNAL-IP 10.1.0.6; test in Task 3 pins it, fallback is a `nodeIP` passthrough.
- Firewall too broad (ports on enp1s0) — expect `nix eval` of global `allowedTCPPorts` to lack k3s ports; test in Task 2 pins it.
- Disk pressure from images on old hardware — expect `df` check before switch; test in Task 3 pins it.

---

### Task 1: Protectli agent config

**Files:**
- Modify: `configurations/nixos/Protectli/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.*` (existing, no module change), `config.sops.secrets."k3s-token".path`, nas API `https://10.1.0.3:6443`.
- Produces: agent config ready to deploy.

- [ ] **Step 1: Add `config` to module args**

  The header is `{ ekaPkgs, homelab, inputs, lib, stablePkgs, system, unstablePkgs, ... }:` — add `config` (needed for the sops secret path).

- [ ] **Step 2: Add the agent block + secret**

  Add `inputs.nixcfg.modules.nixos.k3s` to its imports (it cherry-picks modules; k3s is absent). Somewhere near networking/nixcfg: `nixcfg.k3s = { enable = true; role = "agent"; serverAddr = "https://10.1.0.3:6443"; tokenFile = config.sops.secrets."k3s-token".path; firewallInterfaces = [ "enp1s0" ]; };` plus `sops.secrets."k3s-token" = { };`. Do NOT set `clusterInit`, `disableAgent`, `extraSANs`, or `traefik`.

- [ ] **Step 3: Verify evaluation**

  Run: `nix eval --json '.#nixosConfigurations."Protectli".config.nixcfg.k3s'` — expect `role:"agent"`, `serverAddr` set, `clusterInit:false`, `disableAgent:false`.
  Run: `nix eval --json '.#nixosConfigurations."Protectli".config.networking.firewall.allowedTCPPorts'` — expect `[]` (no global k3s ports); and `...interfaces.enp1s0.allowedTCPPorts` contains 6443/10250/2379/2380.
  Expected: all match.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/Protectli/configuration.nix
git commit -m "feat: protectli joins k3s as worker agent"
```

### Task 2: Build + unit proof

**Files:** none (verification only).

- [ ] **Step 1: Build protectli toplevel**

  Run: `nix build --print-out-paths '.#nixosConfigurations."Protectli".config.system.build.toplevel' --no-link`
  Expected: PASS. Then: `rg "disable-agent|cluster-init|--server https" <toplevel>/etc/systemd/system/k3s.service` — expect `--server https://10.1.0.3:6443`, NO `--disable-agent`, NO `--cluster-init`.

- [ ] **Step 2: Ledger the build**

  Append `Task 2: complete (toplevel <hash>, unit shows agent join, no disable-agent/cluster-init)` to this plan's progress ledger.

### Task 3: Manual deploy + verify (user on protectli)

**Files:** none.

- [ ] **Step 1: Pre-flight disk check**

  Run on protectli: `df -h /var/lib` — expect ≥2GB free (homepage ~200MB + traefik ~100MB + pause + etcd-less overhead).

- [ ] **Step 2: Switch and watch the join**

  Run: `sudo nixos-rebuild switch --flake .#Protectli`. Then from any server: `sudo k3s kubectl get nodes -o wide` — expect protectli `Ready`, ROLES empty (worker), INTERNAL-IP `10.1.0.6`. If the IP is wrong (stale enp1s0 default route): STOP, report back — fallback is a `nodeIP` passthrough in `nixcfg.k3s` (new Task 1b, ~5 lines + eval).

- [ ] **Step 3: Confirm quorum untouched + workload spreads**

  Run: router journal `journalctl -u k3s --no-pager | grep "switched to configuration voters" | tail -1` — expect still 3 voters. Run: `sudo k3s kubectl get pods -A -o wide | grep -i protectli` (or wait for natural spread) — expect pods can schedule there.

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off protectli-join; keep aarch64/storage follow-ups. Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-26-k3s-protectli-agent.md
git commit -m "docs: protectli agent rollout complete"
```
