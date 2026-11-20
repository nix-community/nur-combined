# Euro-Office Docs migration to k3s — Short Design

Date: 2026-11-14
Status: approved 2026-11-14 (approach A, vhost office.diekvoss.net; no DNS action needed — wildcard covers it)
Approach picked: Full k3s-native stack (all-in-one DocumentServer image + hand-built connector app), single Deployment, no Helm, no Collabora remnants

## Intent / why

Give Nextcloud back office editing (lost when Collabora was dropped) with
[Euro-Office](https://github.com/Euro-Office) ("Your sovereign office";
NOT office.eu, which is an unrelated SEO rider). Euro-Office is an
OnlyOffice-architecture sibling: a Document Server plus a Nextcloud
connector app (`eurooffice-nextcloud`), JWT-secured, with the same
triangle connectivity (browser↔DS, Nextcloud→DS, DS→Nextcloud POSTs).

## Goals

- Document Server runs in k3s as a Deployment pinned to nas:
  - Official image `ghcr.io/euro-office/documentserver:v9.3.1`
    (hub/ghcr-verified at build time — matches the 9.3.x line the
    connector app targets).
  - All-in-one image shape (bundled services, like upstream's
    `docker run`): single container, NOT the split docservice/converter
    shape of their Helm chart (that split is for scale-out; noted as a
    deliberate divergence).
  - Env: `JWT_ENABLED=true`, `JWT_SECRET` from a secretspec-managed
    Secret (32+ chars, generated — never the auto-generated value, which
    would desync on pod recreate), `JWT_HEADER=Authorization`
    (explicit on both sides so no default-parity guessing),
    `EXAMPLE_ENABLED=false` (explicit — the example app has no auth),
    `ALLOW_PRIVATE_IP_ADDRESS=true` (required: all DS↔Nextcloud traffic
    is cluster/LAN-private, default false would refuse it),
    `WOPI_ENABLED` unset (false default — the Nextcloud connector uses
    the native protocol, not WOPI).
  - Storage: local-path PVC for `/var/lib/euro-office/documentserver`
    (documents/config/secrets, 20Gi) + local-path PVC for
    `/var/www/euro-office/Data` (runtime state + generated secrets, 5Gi)
    + `emptyDir` for logs (ephemeral). No NFS (locking + latency).
  - `/dev/shm` as `emptyDir: {medium: Memory, sizeLimit: 2Gi}` —
    document conversion is chromium-based and fails under the 64Mi
    default shm (standing lesson from multimedia workloads: provision
    first, don't debug later).
  - `replicas: 1`, nodeAffinity nas. Health: readiness + liveness probes
    on `GET :80/healthcheck` (documented endpoint — first real probes in
    the fleet).
  - Resources ~ requests `500m`/2Gi, limits `4000m`/8Gi (image asks for
    4GB RAM minimum, 5GB disk).
- Connector app hand-built once on the nas (nixpkgs nodejs + php
  composer + git; tag picked at build time from the v11.x line for
  DS-9.3.x + Nextcloud-35 compat, recorded verbatim) and seeded into
  the existing `nextcloud-state` PVC at `custom_apps/eurooffice/`
  (alongside the 8 store apps — no new PVC).
- Wiring via `occ config:app:set eurooffice` (runbook, same pattern as
  the Nextcloud migration): `DocumentServerUrl=https://office.diekvoss.net/`
  (public — browsers and fallback), `DocumentServerInternalUrl=http://euro-office:80/`
  (cluster-internal service — pod-to-pod, no TLS hop),
  `StorageUrl=https://nextcloud.diekvoss.net/` (must be reachable FROM
  the DS pod for callbacks — hairpins through Traefik like Collabora's
  did), `jwt_secret` = same secretspec value, `jwt_header=Authorization`.
  UI-only flags (`sameTab`, `groups`, etc.) left at defaults unless the
  user asks (builder confirms the app's settings page loads; no mass
  configuration).
- Traefik Ingress `office.diekvoss.net` (class traefik, wildcard TLS).
  No DNS action needed (wildcard covers it — verified at flip simply by
  reaching the URL). No homelab entry (k3s-native service: Ingresses route
  natively, nothing in `homelab.nix` needs to know; homepage dashboard
  entry is a later nicety, explicitly out of scope).
- No secrets in the Nix store: JWT secret via new
  `k8s/office/secretspec.toml` contract (`euro-office-jwt` Secret,
  alias-invocation discipline, reconciled from Mac/kubectl-direct like
  the others).

## Non-goals

- No Collabora resurrection (dead, stays dead; richdocuments stays
    disabled).
- No OnlyOffice (this choice supersedes it).
- No version upgrades on either side once pinned (DS v9.3.1, connector
    tag recorded; upgrades are separate, deliberate).
- No homepage dashboard entry, no LDAP/SSO changes, no mobile apps.
- No custom fonts/dictionaries/plugins seeding (emptyDirs suffice;
    follow-ups if the user wants them).

## Anti-goals

- Don't run two Document Servers against one Nextcloud (split-brain
    editing sessions + callback races). There is no old instance, so
    this is greenfield — but the rule stands for any future rescheduling.
- Don't expose the example app (no auth on it — `EXAMPLE_ENABLED`
    stays off and gets verified off).
- Don't bake the JWT secret anywhere except the Secret + secretspec.
- Don't auto-generate the JWT secret (a pod recreate would desync the
    pairing with no error until the first save fails).

## Constraints

- Node-pinned to nas (state locality; single replica by design —
    co-editing sessions + callback URLs assume one writer).
- Secrets never in the Nix store; manifests from nas ONLY.
- The nas needs nixpkgs nodejs + php composer + git available at build
    time for the one-shot connector build (builder verifies exact
    attribute paths; the build runs in /tmp, never in the repo).
- Manifest propagation lag + explicit pod deletion to recycle (standing).

## Approaches considered

- Full k3s-native, all-in-one image (picked): single mechanism (raw
    manifests like everything else), all state local, triangle stays
    inside the cluster except the public legs. Matches house patterns
    end to end.
- DS outside k8s (NixOS container / bare docker), connector in k8s
    (rejected): reintroduces a pet container — the exact thing the last
    four migrations removed — and straddles the callback triangle
    across two runtimes for no benefit.
- Upstream Helm chart (rejected): best-maintained manifests upstream,
    but Helm templating would be a second mechanism in a repo that does
    raw manifests via `services.k3s.manifests`; values used only as a
    crib sheet (JWT names, ports, healthcheck path).

## Decided (what the builder implements)

- New module `modules/nixos/k3s-office.nix` (separate file — office is
    not starr, not nextcloud): Deployment (1 replica, nodeAffinity nas,
    pinned image, env as above with JWT from `euro-office-jwt` Secret,
    containerPort 80, two local-path claimTemplates, `/dev/shm`
    memory-emptyDir, `/healthcheck` probes), Service ClusterIP :80,
    Ingress class traefik host `office.diekvoss.net` + wildcard TLS.
    forwardAuthGate: OFF (the DS has its own JWT auth; gating it would
    break callbacks — mirrors the *arr/Immich reasoning).
- `configurations/nixos/nas/configuration.nix`:
    `nixcfg.k3sOffice.enable = true;` (+ module import).
- `k8s/office/secretspec.toml`: new contract for `JWT_SECRET`
    (32+ chars; alias discipline; reconciled from Mac/kubectl-direct).
- Runbook (user executes, no downtime needed — nothing is being
    retired): connector build on nas (clone tag, npm install/build,
    composer install, no chown games — runs as 360 in the pod via the
    existing custom_apps mount) → rsync built `eurooffice/` dir into
    the `nextcloud-state` PVC's `custom_apps/` subdir → `kubectl rollout
    restart deployment/nextcloud` (picks up… actually no restart needed
    for apps; note it) → `occ app:enable eurooffice` → `occ
    config:app:set eurooffice …` (four keys + secret) → verify admin
    settings page shows connected (green check) → open a docx/xlsx from
    Nextcloud, edit, save, confirm round-trip + co-edit smoke if a
    second client is handy.
- Rollback: scale DS to 0 + `occ app:disable eurooffice`. No data at
    risk (documents live in Nextcloud; DS holds only caches).

## Left to the builder

- Exact connector tag from the v11.x line (compat with DS 9.3.x + NC 35
    — check the app's release notes/CHANGELOG at build time; record it).
- Exact nixpkgs attribute paths for nodejs/npm/composer/git used in the
    one-shot build.
- Whether `JWT_HEADER` env is honored by this DS build (else rely on
    matched defaults — verify the green check in the admin page, which
    fails closed on mismatch).
- Transcode-style mandatory test N/A; the mandatory proof here is:
    admin page green check + open/edit/save round-trip of a real docx.
- office.diekvoss.net DNS (manual Cloudflare entry — user action,
    flagged in runbook, no automation).

## Verification bar

(1) pod Running + `/healthcheck` green + cron… (n/a — no cron here),
(2) Nextcloud admin Euro-Office page shows connected (green),
(3) create/edit/save round-trip of docx AND xlsx incl. files with
umlauts/spaces in the name (mount-path encoding smoke test),
(4) co-edit smoke if a second client is handy (else deferred, noted),
(5) example app confirmed unreachable (`/example/` 404 or disabled).

## Builder self-check (no subagent tool)

- Read as builder: one new module + secretspec + Ingress, no new
    storage class, no DB, no companion service; the only novel steps are
    the one-shot npm/composer build (ephemeral /tmp, auditable) and the
    occ wiring quartet. Everything else is the proven template.
- Secrets never in store; nothing on NFS; no dual-run possible.
- Version pins (image tag + app tag recorded) eliminate drift risk.
