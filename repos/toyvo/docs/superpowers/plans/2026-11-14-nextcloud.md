# Nextcloud Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nextcloud serves from k3s (official image pinned to 35.0.2, UID 360, Postgres seeded from live dump, cron sidecar, three external-storage mounts), Collabora retired with the container.

**Architecture:** New `nixcfg.k3sNextcloud` module (Deployment + cron sidecar + Postgres StatefulSet + Services + Ingress, 3 RW media PVCs, state PVC with custom_apps subPath); relay rebound to LAN IP; `homelab.nix` upstreams flip; manual seed + occ adaptation + verify + retire.

**Tech Stack:** NixOS (`services.k3s.manifests`), `nextcloud:35.0.2-apache` + `postgres:18-alpine` (both hub-verified), Traefik Ingress, NFS `nfs-pool` RW media.

**Spec:** `docs/superpowers/specs/2026-11-14-nextcloud-design.md`

## Global Constraints

- Exact version pin 35.0.2 (no migration risk by construction).
- UID/GID 360 throughout (`runAsUser`/`runAsGroup`, `nodeAffinity: nas`).
- Postgres + datadir on local-path ONLY; external storage RW via dedicated PVs.
- Manifests from nas ONLY (single-writer rule).
- Seed ONLY from the verified-live set (38M state, 99M DB); container untouched until seed day.
- No dual-run (stop-old → seed → verify-new); downtime accepted anytime (approved 2026-11-14).
- DB password via secretspec/kubectl contract (never the Nix store); SMTP password stays in sops.
- Collabora dies with the container (`richdocuments` disabled at cutover); OnlyOffice is a separate future project.
- `nix fmt` before describe; validation is eval + toplevel builds; switches + seeding + occ + in-app checks are manual. Commits via `jj describe`.
- POOL state dirs never deleted in this plan.

## Review Focus

- Root on NFS writes (squash → nobody; ACLs know 360) — expect `runAsUser: 360`; test in Task 1 pins it.
- Wrong image (35.0.2 mismatch migrates the old DB) — expect hub-verified tag; test in Task 1 pins it.
- DB auth gap (peer → password; secret vs role mismatch = Immich's 28P01) — expect `secretKeyRef` + runbook sets role password to the same value; test in Task 3 pins clean startup logs.
- Stale seed (setup wizard, empty filecache) — expect row counts match; test in Task 3 pins it.
- External-storage ID drift (mounts point nowhere) — expect `oc_storages`/`oc_mounts` counts match + files visible on all three mounts; test in Task 3 pins it.

---

### Task 1: nextcloud manifests dark

**Files:**
- Create: `modules/nixos/k3s-nextcloud.nix`
- Modify: `modules/nixos/default.nix` (registry)
- Modify: `modules/nixos/k3s-storage.nix` (3 RW media PVs)
- Modify: `configurations/nixos/nas/configuration.nix` (NFS exports Collin/Chloe, import + `nixcfg.k3sNextcloud.enable = true`, relay rebind to LAN IP + firewall 1025)
- Create: `k8s/nextcloud/secretspec.toml`
- Modify: `todos.md` (add tracking entry)

**Interfaces:**
- Consumes: nextcloud port 80, `homelab.nextcloud.services.nextcloud` flags, `nfs-pool` class, nas LAN IP for SMTP relay.
- Produces: Deployment (+cron sidecar) + Postgres StatefulSet + Services + Ingress (dark), `nextcloud-db` Secret shape, 3 media PVCs + PVs, LAN-bound relay.

- [ ] **Step 1: Verify image tags + live PG major**

  Docker Hub: `nextcloud:35.0.2-apache` resolves (manifest API). Live container: `SELECT version();` (expect PG18; if different, record the ruling and pin the matching `postgres:<major>-alpine` tag, hub-verified the same way). If the exact nextcloud tag is absent, STOP — do not substitute.
  Expected: both tags recorded verbatim in the module.

- [ ] **Step 2: Write `modules/nixos/k3s-nextcloud.nix`**

  Deployment (1 replica, nodeAffinity nas, pinned image, `runAsUser`/`runAsGroup` 360, TZ, containerPort 80, `NEXTCLOUD_DATA_DIR=/var/lib/nextcloud`, state PVC mount at `/var/lib/nextcloud` + `custom_apps` subPath at `/var/www/html/custom_apps`, media PVCs at `/mnt/Public` `/mnt/Collin` `/mnt/Chloe` RW, emptyDir for `/tmp` only if builder proves need), cron sidecar (same image, `php -f /var/www/html/cron.php` loop every 5 min), Postgres StatefulSet (local-path claimTemplate 5Gi, `POSTGRES_USER=postgres`/`POSTGRES_DB=nextcloud`/`POSTGRES_PASSWORD` from `nextcloud-db` secret, `--data-checksums`), Services (`nextcloud:80`, `nextcloud-postgres:5432`), Ingress class traefik host `nextcloud.diekvoss.net` via the shared middleware helper with `homelab.nextcloud.services.nextcloud` flags. No literal secrets.
  Expected: file exists, replicas as decided (0 dark preferred, 1 acceptable with rationale), 360 everywhere, 3 media mounts RW, cron sidecar present.

- [ ] **Step 3: Storage PVs + NFS exports + relay + secretspec**

  `k3s-storage.nix`: add `pool-media-nextcloud-{public,collin,chloe}-rw` PVs (`nfs-pool`, `Retain`, `vers=4.2`, shares `/mnt/POOL/Public|Collin|Chloe`). Nas config: exports for `/mnt/POOL/Collin` + `/mnt/POOL/Chloe` (`10.1.0.0/24(rw,sync,no_subtree_check,root_squash)`); rebind `protonmail-bridge-relay` from the container veth to the nas LAN IP + open firewall 1025 (note scope decision). `k8s/nextcloud/secretspec.toml`: contract for `DB_PASSWORD` (32-char A-Za-z0-9, same discipline as Immich).
  Expected: 3 PVs + 2 exports + relay moved + contract file all present.

- [ ] **Step 4: Register + enable + verify eval**

  Register in `modules/nixos/default.nix`; nas config: import + `nixcfg.k3sNextcloud.enable = true;` (do NOT touch `homelab.nix` upstreams yet). Run: `nix eval` on the deployment/statefulset specs — expect image pinned, 359→360 (runAsUser 360), cron sidecar present, 3 media PVCs on `nfs-pool` RW, Ingress host `nextcloud.diekvoss.net`, middlewares include lan-only AND forward-auth (gate stays on). `nix flake show` PASS.
  Expected: all match, no eval errors.

- [ ] **Step 5: Build nas toplevel (no switch)**

  Run: `nix build .#nixosConfigurations.nas.config.system.build.toplevel` — PASS. Do NOT switch yet (Task 3 sequencing).
  Expected: build green.

- [ ] **Step 6: Describe commit**

```bash
nix fmt
jj describe -m "feat: nextcloud manifests in k3s (dark)"
```

### Task 2: secrets + dark deploy + baseline (user)

**Files:** none (`nextcloud-db` via secretspec/kubectl-direct; SMTP password already in sops).

- [ ] **Step 1: Generate + load `DB_PASSWORD` (user)**

  Builder hands over a generated 32-char A-Za-z0-9 password. Load into Proton Pass from the Mac (pass-cli broken on headless nas — standing issue), then `kubectl create secret generic nextcloud-db --from-literal=DB_PASSWORD='...'` (secretspec kube provider patches only, never creates — Immich lesson). Verify: `kubectl get secret nextcloud-db -o jsonpath='{.data}'` shows exactly `DB_PASSWORD`.
  Expected: Secret exists with one key.

- [ ] **Step 2: Dark deploy + verify infra (user)**

  Switch nas, allow minutes. `kubectl get pods -o wide | rg nextcloud`, PVCs Bound (state local-path, 3 media to the new PVs), Ingress exists, edge still routes to the container.
  Expected: infra green, container still serving.

- [ ] **Step 3: Record live baseline (user)**

  On nas: `du -sh` state + pg dirs. From the live container DB: counts for `users` (`oc_users`? record actual table), `storages` (`oc_storages`), `mounts` (`oc_mounts`), `filecache` (`oc_filecache`), `share` (`oc_share`). From the admin UI: user list + app list (the 8 + richdocuments present).
  Expected: numbers recorded; 38M/99M confirmed in range of 10Gi/5Gi claims.

### Task 3: seed + cutover + flip + retire (user, downtime window anytime)

**Files:**
- Modify: `homelab.nix` (`nextcloud.services.nextcloud.upstreams`)
- Modify: `configurations/nixos/nas/configuration.nix` (container `enable = false` at the end)

- [ ] **Step 1: Dump live DB, stop container, seed files**

  `pg_dumpall --clean` from the live container (writes into its bind-mounted pg dir), verify size + checksum, stop the container, rsync state into the provisioned local-path volume dir (`--delete`, then `chown -R 360:360`), scale server to 1.
  Expected: dump sane, container stopped (old port dead), pod running.

- [ ] **Step 2: Restore + adapt via occ**

  Copy dump into the k8s postgres pod, `psql -U postgres -f` (Immich LOCALE_PROVIDER playbook on standby for extension/locale errors — gate on filtered error output), set role password to the Task 2 secret value, `REINDEX DATABASE`, integrity counts (must match Task 2 exactly). Then, verbatim via `kubectl exec deploy/nextcloud -- php occ ...`:
  `config:system:get trusted_proxies` (note index of router IP) → `config:system:set trusted_proxies <next-index> --value="10.42.0.0/16"` → `config:system:set dbhost --value="nextcloud-postgres"` → `config:system:set dbpassword --value="<secret>"` → `config:system:set mail_smtphost --value="10.1.0.3"` → `app:disable richdocuments` → `app:enable calendar` + `app:enable contacts` → `app:install bookmarks cookbook mail music notes tasks` → `app:enable` each installed one → `maintenance:repair --include-expensive` → `files:scan --unscanned` → `status`.
  Expected: counts match, occ chain clean, `status` green.

- [ ] **Step 3: Verify app BEFORE flip**

  Port-forward or pod-direct: login works (existing admin, no setup wizard), files visible + writable on all three mounts (upload one file, delete it), shares intact, SMTP test mail arrives (admin settings → send test mail), cron last-run advances (`backgroundjobs` — watch the sidecar log fire once), no setup-check errors beyond pre-existing ones (compare admin overview before/after).
  Expected: all green; wizard = STOP (wrong/empty state).

- [ ] **Step 4: Flip + retire**

  `homelab.nix`: add `upstreams = [ "10.1.0.3:30080" "10.1.0.12:30080" ]` (removes the edge route; collabora vhost dies with the container — no replacement). Switch nas, verify public URL incl. login, set `nixcfg.containers.nextcloud.enable = false`, switch nas again, confirm old ports (`10.200.0.10:80`, `:9980`) dead and k8s still serving.
  Expected: cutover complete, old ports dead.

### Task 4: docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off the nextcloud item (add OnlyOffice follow-up if not present). Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Describe commit**

```bash
jj describe -m "docs: nextcloud migration complete"
```
