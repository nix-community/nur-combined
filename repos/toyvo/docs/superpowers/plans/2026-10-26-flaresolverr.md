# FlareSolverr Migration Implementation Plan

**Goal:** FlareSolverr serves from k3s (stateless, no storage), Prowlarr repointed to the cluster-internal address, container retired.

**Architecture:** Extend `nixcfg.k3sStarr` with flaresolverr (StatefulSet with no storage + Service + Ingress); Caddy upstreams flip; manual repoint + verify + retire.

**Tech Stack:** NixOS (`services.k3s.manifests`), flaresolverr/flaresolverr pinned `v3.5.2`, Traefik Ingress, Caddy multi-upstream.

**Spec:** `docs/superpowers/specs/2026-10-26-flaresolverr-design.md`

## Global Constraints

- NO storage objects (no PVC, no PV). No PUID/PGID env.
- `nodeAffinity: nas`; manifests from nas ONLY (single-writer rule).
- Container FlareSolverr stays up until k8s instance verified (Prowlarr needs one live solver at all times).
- Allow minutes for manifest propagation after switch; delete stale pods rather than waiting.
- `nix fmt` before commit; validation is eval + toplevel builds; switches + in-app reconfig are manual, nas-then-router.

## Review Focus

- Storage accidentally included (defeats statelessness) — expect NO volumeClaimTemplates and NO media mounts; test in Task 1 pins it.
- Wrong image (linuxserver habit) — expect `flaresolverr/flaresolverr:v3.5.2`; test in Task 1 pins it.
- Pod scheduled off-nas (affinity typo) — expect pod on nas only; test in Task 3 pins it.
- Prowlarr still pointing at container (silent fallback to retiring service) — expect host `http://flaresolverr:8191` + green test; test in Task 3 pins it.
- Retire-before-proof — ordering enforced; test in Task 3 pins it.

---

### Task 1: flaresolverr manifests (dark)

**Files:**
- Modify: `modules/nixos/k3s-starr.nix` (add flaresolverr block), `configurations/nixos/nas/configuration.nix` (enable flag).

**Interfaces:**
- Consumes: flaresolverr port 8191. Produces: StatefulSet (no storage) + Service + Ingress, nas-applied.

- [ ] **Step 1: Add flaresolverr block**

  Mirror readarr minus ALL storage: StatefulSet (1 replica, nodeAffinity nas, image pinned, TZ only, containerPort 8191, NO volumeMounts, NO volumes, NO volumeClaimTemplates), Service ClusterIP :8191, Ingress class traefik host `flaresolverr.diekvoss.net`.

- [ ] **Step 2: Enable + verify eval**

  nas config: `nixcfg.k3sStarr.flaresolverr.enable = true;`. Run: `nix eval ...flaresolverr-statefulset...` — expect image pinned, NO storage fields, nodeAffinity nas. `nix flake show` PASS.
  Expected: all match.

- [ ] **Step 3: Build nas toplevel**

  Run: `nix build ...nas toplevel...` — PASS. Do NOT switch yet (Task 3 sequencing).

- [ ] **Step 4: Commit**

```bash
nix fmt
git add modules/nixos/k3s-starr.nix configurations/nixos/nas/configuration.nix
git commit -m "feat: flaresolverr manifests in k3s (dark, stateless)"
```

### Task 2: Caddy upstreams (no behavior change yet)

**Files:**
- Modify: `homelab.nix` (`starr.services.flaresolverr.upstreams`)

- [ ] **Step 1: Add upstreams + prove rendering**

  Set `upstreams = [ "10.1.0.3:30080" "10.1.0.12:30080" ]`. Run: `nix eval ...router...virtualHosts."flaresolverr.diekvoss.net".extraConfig` — expect dual-upstream reverse_proxy.
  Expected: matches.

- [ ] **Step 2: Commit (NOT switched yet)**

```bash
nix fmt
git add homelab.nix
git commit -m "feat: route flaresolverr through traefik upstreams"
```

### Task 3: Manual deploy + repoint + flip + retire (user)

**Files:** none.

- [ ] **Step 1: Deploy dark + verify pod**

  Switch nas, allow minutes for manifest propagation. `kubectl get statefulset flaresolverr`, pod Running on nas, NO PVCs created for it. If the pod sits stale, delete it. Old container still serving.
  Expected: Running, no storage, old still up.

- [ ] **Step 2: Repoint Prowlarr BEFORE flip**

  In k8s Prowlarr UI: Settings → Indexers → FlareSolverr host → `http://flaresolverr:8191`, Test. If the test fails, STOP (container address keeps working; diagnose before proceeding).
  Expected: test green.

- [ ] **Step 3: Flip + retire**

  Switch router (Caddy live), verify 200 + failover. Add `"flaresolverr"` to `disabledServices`, switch nas, confirm old port (`10.200.0.2:8191`) dead and Prowlarr still solving (re-run host test post-retire).
  Expected: cutover complete.

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off flaresolverr (last migratable starr service; only qBittorrent remains, deliberately). Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-26-flaresolverr.md
git commit -m "docs: flaresolverr migration complete"
```
