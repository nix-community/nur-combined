# Nextcloud migration to k3s — Short Design

Date: 2026-11-14
Status: approved 2026-11-14 (core-only big-bang, Collabora dropped, OnlyOffice later; downtime anytime)
Approach picked: Core-only big-bang (Nextcloud + Postgres + cron sidecar, no Collabora — office editing moves to OnlyOffice later, separately)

## Intent / why

Move Nextcloud (`containers.nextcloud`, `10.200.0.10:80`, state in
`/mnt/POOL/nextcloud`, media via external-storage mounts of
`/mnt/{Public,Collin,Chloe}`) into k3s on the nas. Of the remaining
containers it is the most complex single workload — but scoping showed
the complexity is bounded: the app state is 38M, the DB 99M, external
storage is exactly three `local`-backend mounts (verified in
`oc_storages`, not the whole pool), and Collabora is being dropped
rather than migrated.

## Goals

- Nextcloud runs in k3s as a Deployment pinned to nas:
  - Official image pinned to the exact NixOS version (`nextcloud35`
    35.0.2 → `nextcloud:35.0.2-apache`, hub-verified at build time).
  - Runs as UID/GID 360 (`ids.uids.nextcloud`) — the Immich lesson again:
    external-storage writes as root would be squashed to `nobody`.
  - `NEXTCLOUD_DATA_DIR=/var/lib/nextcloud` (matches the NixOS layout, so
    the seeded tree lands as-is), state PVC (10Gi local-path, seeded from
    `/mnt/POOL/nextcloud/nextcloud` + `custom_apps` subPath mount for
    store-installed apps), three RW media PVCs at `/mnt/Public`,
    `/mnt/Collin`, `/mnt/Chloe`.
  - New NFS exports for `/mnt/POOL/Collin` and `/mnt/POOL/Chloe`
    (`/mnt/POOL/Public` already exported); one RW PV per dir
    (PVs bind 1:1 — established rule).
  - Cron sidecar in the same pod (loop running `php cron.php` every 5
    min — no systemd timers in k8s; upstream-documented pattern).
- Postgres `ghcr.io/immich-app/postgres`-style official image? No —
  Nextcloud needs plain Postgres: `postgres:18-alpine` (matches the
  NixOS module's bundled-PG major; builder verifies against the live
  container's `SELECT version()`), local-path 5Gi, seeded via
  `pg_dumpall` from the live container (99M) with the Immich
  LOCALE_PROVIDER playbook on standby. Seeded config uses peer auth;
  k8s gets password auth: new generated password (secretspec contract
  like Immich, reconciled from Mac/kubectl-direct since pass-cli is
  broken on headless hosts), `ALTER ROLE` + `occ config:system:set
  dbhost/dbpassword` post-restore.
- Seeded `config.php` adapted post-restore via `occ` (runbook, same
  pattern as Immich's `ALTER ROLE`): `dbhost` → TCP service name,
  `dbpassword` → new secret, `trusted_proxies` += `10.42.0.0/16` (keep
  router IP), `mail_smtphost` → nas LAN IP (relay rebind, below).
  `overwriteprotocol`, `overwrite.cli.url`, `maintenance_window`,
  `default_phone_region` ride unchanged.
- SMTP relay rebound: `protonmail-bridge-relay` socat unit moves from
  the container veth (`10.200.0.9:1025`, retired with the container) to
  the nas LAN IP (`10.1.0.3:1025`, firewall opened); Nextcloud SMTP
  settings repointed via `occ` (host, same port/auth, same
  no-verify-TLS stream options for the bridge's self-signed cert).
- The 8 remaining extra apps (bookmarks, calendar, contacts, cookbook,
  mail, music, notes, tasks) installed from the app store at compatible
  versions via `occ app:install` + `app:enable` (runbook); `occ
  maintenance:repair --include-expensive` replicated post-seed (the
  module's mimetype-migration step).
- Ingress `nextcloud.diekvoss.net` (class traefik) + `homelab.nix`
  `nextcloud.services.nextcloud.upstreams` flip. `forwardAuthGate`
  UNCHANGED (default on — matches current behavior; native login kept).
- Old container retired via `nixcfg.containers.nextcloud.enable = false`
  after verification (takes Collabora `coolwsd` with it — intended);
  old ports dead. POOL state dirs remain on disk as backups.

## Non-goals

- No Collabora migration (dropped; `richdocuments` disabled via `occ`
  at cutover so no broken WOPI entry remains).
- No OnlyOffice work (separate future project: Document Server install +
  integration; document editing is knowingly unavailable in between).
- No version upgrade (35.0.2 → 35.0.2).
- No external-storage reorganization (same three mounts, same paths).

## Anti-goals

- Don't run two Nextclouds against one DB or one datadir (split-brain
  filecache + job-queue races). Cutover is stop-old → seed → verify-new.
  Downtime accepted.
- Don't put Postgres or the datadir on NFS.
- Don't bake secrets in the Nix store (DB password via secretspec/kubectl
  contract; SMTP password already in sops).
- Don't leave `richdocuments` enabled pointing at a dead Collabora.
- Don't "fix" LDAP/SSO or add new auth in this migration (none exists;
  native login kept).

## Constraints

- Node-pinned to nas (state + DB + cron locality); local-path claims
  only for state/DB (10Gi/5Gi for 38M/99M actuals + app growth).
- Three new RW PVs (one per external-storage dir); two new NFS exports
  (Collin, Chloe).
- UID/GID 360 for all Nextcloud file writes (state + external storage).
- Manifests from nas ONLY (single-writer rule).
- Seed ONLY from the verified-live container set; container untouched
    until seed day. DB dump while running is fine (snapshot-consistent),
    then stop before file copy (filecache consistency).
- Manifest propagation lag + explicit pod deletion to recycle (standing).
- Image tag hub-verified (standing).

## Approaches considered

- Core-only big-bang, Collabora dropped (picked): one downtime window,
    retires the whole container, no interim split-WOPI topology to prove
    twice; office-editing gap is explicit and accepted (OnlyOffice later).
- Full stack incl. Collabora (rejected after discussion): preserves
    editing with zero gap, but WOPI rewire (localhost→cluster DNS,
    allowlists incl. pod CIDR, hairpin behavior) is the fiddliest part
    and Collabora is being dropped anyway.
- Phased core-then-Collabora (rejected with the above): same WOPI
    re-verification cost as full stack plus an interim cross-system
    topology nobody would finish.
- Leave containerized (rejected: user direction is zero NixOS containers
    except VPN-bound qBittorrent).

## Decided (what the builder implements)

- New module `modules/nixos/k3s-nextcloud.nix` (separate file — not
    starr): Nextcloud Deployment (1 replica, nodeAffinity nas, pinned
    image, `runAsUser`/`runAsGroup` 360, TZ, containerPort 80,
    `NEXTCLOUD_DATA_DIR=/var/lib/nextcloud`, state PVC mount at
    `/var/lib/nextcloud` + `custom_apps` subPath at
    `/var/www/html/custom_apps`, three media PVCs at `/mnt/*`,
    emptyDir for `/tmp`/`run` if the image needs writable runtime dirs —
    builder proves via logs), cron sidecar (same image, php-cron loop),
    Postgres StatefulSet (local-path claimTemplate 5Gi, password from
    `nextcloud-db` Secret), Services ClusterIP, Ingress class traefik
    host `nextcloud.diekvoss.net` via the shared middleware helper.
- `modules/nixos/k3s-storage.nix`: three RW PVs (Public/Collin/Chloe
    shares, `Retain`, `vers=4.2`).
- `configurations/nixos/nas/configuration.nix`: NFS exports for
    Collin/Chloe; `nixcfg.k3sNextcloud.enable = true;`; relay unit
    rebound to LAN IP + firewall 1025 (scoped if trivially possible,
    else global with a comment — the relay only proxies to the
    password-authed bridge).
- `k8s/nextcloud/secretspec.toml`: new contract for `DB_PASSWORD`
    (same discipline as Immich; reconciled via Mac/kubectl-direct).
- `homelab.nix`: add `upstreams` to `nextcloud.services.nextcloud`
    (dark until switch; removes the edge route; collabora vhost dies
    with the container — no k8s replacement).
- Runbook (user executes, downtime window anytime): switch nas (dark,
    server at 0 preferred) → verify infra → `pg_dumpall` → stop
    container → rsync state + `chown -R 360:360` → restore DB + set
    role password → `occ` adaptations (dbhost, dbpassword,
    trusted_proxies, mail_smtphost, app:disable richdocuments,
    app:install/enable ×8, repair --include-expensive) → scale to 1 →
    verify login, files (all three mounts), shares, SMTP test mail,
    background jobs (cron sidecar logging) → flip → retire container
    (`enable = false`, switch, old ports dead incl. 9980).
- Rollback: flip back, re-enable container. Dumps + POOL backups kept.

## Left to the builder

- Hub-verify `nextcloud:35.0.2-apache` (exact tag; fallback ruling if
    upstream tags differ).
- Live container PG major (`SELECT version()`) → PG image tag.
- Whether the image needs emptyDir runtime dirs (`/tmp`, `/var/run`)
    as non-root 360 — prove via pod logs (EACCES = add).
- Exact `occ` command list for the 8 apps + repair (verbatim in plan).
- Transcode-style mandatory test N/A here; the SMTP test mail IS the
    mandatory end-to-end proof (it exercises relay rebind + secrets).

## Verification bar

(1) seeded state + DB row counts match (users, filecache, storages,
mounts, shares), (2) login works, files visible + writable on all three
mounts (upload one file, delete it), shares intact, LDAP/SSO N/A,
(3) SMTP test mail arrives, cron job last-run timestamp advances,
richdocuments disabled with no setup-check errors, (4) flip + old ports
dead, (5) no Nextcloud security/setup warnings beyond pre-existing ones
(compare admin overview before/after).

## Builder self-check (no subagent tool)

- Read as builder: no new mechanisms beyond proven local-path-state +
    NFS-media + secretspec + Ingress-flip + occ-runbook template; the
    only Nextcloud-specific steps are the 3-PV external storage, the
    SMTP relay rebind, the cron sidecar, and the occ adaptation list.
- Secrets never in store; DB never on NFS; no dual-run.
- Version parity (35.0.2 → 35.0.2) eliminates migration risk.
