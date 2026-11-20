# Home Assistant Migration Implementation Plan

**Goal:** Home Assistant serves from k3s (local-path sqlite, exact-version image), data seeded from verified-live set with adapted proxy trust, container retired.

**Architecture:** New `nixcfg.k3sHomeassistant` module (StatefulSet + Service + Ingress, no media); Caddy upstreams flip; manual seed + verify + retire.

**Tech Stack:** NixOS (`services.k3s.manifests`), homeassistant/home-assistant pinned `2026.5.4` (hub-verified, exact container match), Traefik Ingress, Caddy multi-upstream.

**Spec:** `docs/superpowers/specs/2026-10-28-homeassistant-design.md`

## Global Constraints

- SQLite on local-path ONLY, `nodeAffinity: nas`; NO media PVC (HA has no /mnt use).
- Exact version pin 2026.5.4 (no migration risk by construction).
- Manifests from nas ONLY (single-writer rule).
- Seed ONLY from a verified-live set (`.backup` + `integrity_check`); container never restarted mid-migration.
- Old container service stays up until k8s instance verified.
- Run as root (image default); rollback needs `chown -R hass` on state dir.
- Allow minutes for manifest propagation after switch; delete stale pods rather than waiting.
- `nix fmt` before commit; validation is eval + toplevel builds; switches + seeding + in-app checks are manual, nas-then-router.

## Review Focus

- Trusted proxies incomplete (HA 400s everything) — expect `10.42.0.0/16` in BOTH seeded `configuration.yaml` AND `.storage/http`; test in Task 1 pins the file, test in Task 3 pins behavior (login works).
- Wrong image (version drift) — expect `2026.5.4`; test in Task 1 pins it.
- Pod scheduled off-nas (affinity typo) — expect pod on nas only; test in Task 3 pins it.
- Seeded from stale files (onboarding wizard, empty registry) — expect entity counts to match; test in Task 3 pins it.
- Retire-before-proof — ordering enforced; test in Task 3 pins it.

---

### Task 1: homeassistant manifests (dark)

**Files:**
- Create: `modules/nixos/k3s-homeassistant.nix` (new module, register in `modules/nixos/default.nix`).
- Modify: `configurations/nixos/nas/configuration.nix` (enable flag).

**Interfaces:**
- Consumes: HA port 8123. Produces: StatefulSet + Service + Ingress, nas-applied.

- [ ] **Step 1: Write the module**

  StatefulSet (1 replica, nodeAffinity nas, image `homeassistant/home-assistant:2026.5.4`, TZ America/Chicago, containerPort 8123, `/config` claimTemplate 5Gi, NO media), resources requests 256Mi/100m + limits 2Gi/2000m, Service ClusterIP :8123, Ingress traefik host `home-assistant.diekvoss.net`. Mirror k3s-homepage.nix structure.

- [ ] **Step 2: Register + enable + verify eval**

  Register in `modules/nixos/default.nix`; nas config: `nixcfg.k3sHomeassistant.enable = true;`. Run: `nix eval ...homeassistant-statefulset...` — expect image pinned, nodeAffinity nas, single volume (config claimTemplate), NO media. `nix flake show` PASS.
  Expected: all match.

- [ ] **Step 3: Build nas toplevel**

  Run: `nix build ...nas toplevel...` — PASS. Do NOT switch yet (Task 3 sequencing).

- [ ] **Step 4: Commit**

```bash
nix fmt
git add modules/nixos/k3s-homeassistant.nix modules/nixos/default.nix configurations/nixos/nas/configuration.nix
git commit -m "feat: homeassistant manifests in k3s (dark)"
```

### Task 2: Caddy upstreams (no behavior change yet)

**Files:**
- Modify: `homelab.nix` (`home-assistant.services.home-assistant.upstreams`)

- [ ] **Step 1: Add upstreams + prove rendering**

  Set `upstreams = [ "10.1.0.3:30080" "10.1.0.12:30080" ]`. Run: `nix eval ...router...virtualHosts."home-assistant.diekvoss.net".extraConfig` — expect dual-upstream reverse_proxy.
  Expected: matches.

- [ ] **Step 2: Commit (NOT switched yet)**

```bash
nix fmt
git add homelab.nix
git commit -m "feat: route home-assistant through traefik upstreams"
```

### Task 3: Manual deploy + seed + verify + flip + retire (user)

**Files:** none (`k8s/` untouched — no new secrets).

- [ ] **Step 1: Deploy dark + verify pod**

  Switch nas, allow minutes for manifest propagation. `kubectl get statefulset home-assistant`, pod Running on nas, `config-home-assistant-0` Bound (local-path). If the pod sits stale, delete it. Old container still serving.
  Expected: Running, bound, old still up.

- [ ] **Step 2: Seed from verified-live set**

  On nas: online `.backup` of live `home-assistant_v2.db` + `integrity_check` + entity count (via sqlite on `states` table or UI comparison later). Copy static tree (`.storage/`, `.HA_VERSION`, `blueprints/`, `custom_components/`, `deps/`, `nest/`, `tts/`, `.cloud/`, `.config/`) + adapted `configuration.yaml` (generated content + `10.42.0.0/16` in trusted_proxies) + patched `.storage/http` (same addition) + `.backup` DB as `home-assistant_v2.db`; `chown -R 0:0` (app runs as root); rollout restart; verify login works, entities present, no onboarding wizard.
  Expected: login green, library matches, no wizard.

- [ ] **Step 3: Verify integrations BEFORE flip**

  In k8s HA UI: Settings → Devices — omada/nest/met present, no unavailable storm; check logs for integration errors. From pod: `https://omada.diekvoss.net` reachable (same shape as split-brain). If systematic failures, STOP.
  Expected: all green.

- [ ] **Step 4: Flip + retire**

  Update homepage widget URL to `https://home-assistant.diekvoss.net` (same commit as... no — widget change needs deploy; do it with the router switch batch). Switch router (Caddy live), verify 200 + failover (mobile app unaffected — same public flow). Set container `nixcfg.containers.home-assistant.enable = false`, switch nas, confirm old port (`10.200.0.8:8123`) dead and k8s still serving.
  Expected: cutover complete.

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off homeassistant. Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-28-homeassistant.md
git commit -m "docs: homeassistant migration complete"
```
