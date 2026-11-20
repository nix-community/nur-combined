# k3s Storage Platform: NFS Static PVs + local-path DBs — Full Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: A (NFS CSI for shared dirs + local NVMe for databases)

## Intent / why

Give the cluster two boring, appropriate storage classes matching the
actual hardware (one disk-rich node, two disk-poor ones): shared POOL
dirs reachable from any node for bulk/media data, and fast local NVMe
for Postgres-class data with safety from scheduled dumps, not
replication. This step builds and proves the *platform only* — no
production migration rides along.

## Goals

- NFSv4 exports on nas for an explicit per-directory list (new dirs for
  new needs; existing data untouched, mounted read-only where the
  consumer only reads, e.g. media libraries).
- `csi-driver-nfs` deployed cluster-wide via k3s manifests (same
  HelmChart/manifest mechanism as Traefik), with **static** PVs declared
  per directory — no dynamic provisioner, no operator for the files.
- Local-path remains the DB story: StatefulSets pinned to nas
  (`nodeAffinity`) on NVMe, plus a `pg_dump` CronJob pattern writing to
  an NFS-backed PVC (mirrors today's `*-pg17-backup-*.tar.gz` practice
  on the POOL, now scheduled in-cluster).
- Proven end to end with throwaway resources: a scratch Postgres
  (init → write → dump → restore-to-second-instance → verify), plus a
  read/write test file on an NFS PVC from pods on two different nodes.
  Proof resources deleted afterwards; the *pattern* is the deliverable.

## Non-goals

- No S3/object storage (nothing needs the API right now).
- No replication (Longhorn/Ceph), no dynamic provisioning, no CSI
  snapshots.
- No production DB or data migration (forgejo/authentik/nextcloud DBs
  stay native; first migration is a separate design).
- No new public surface; storage traffic stays on 10.1.0.0/24.

## Anti-goals

- Never run Postgres (or any lock-hungry DB) on NFS — silent
  corruption risk, not just slowness.
- Don't restructure `/mnt/POOL`, don't change existing permissions or
  the btrfs snapshot story; new dirs only, least privilege per export
  (`ro` where the consumer reads, `root_squash` by default).
- Don't export NFS beyond the LAN; NFSv4 only (single port 2049/tcp,
  no rpcbind/mountd sprawl).
- No `hostPath` for shared data (ties pods to nas silently, invisible
  in the API) — hostPath only where genuinely node-local (DB data on
  nas NVMe sits behind local-path, not raw hostPath).

## Constraints

- nas is the only storage node (5.5T POOL, 4.7T free); macmini-Intel
  and Protectli have system disks only; router runs no workloads.
  Multi-node replication is off the table until hardware changes.
- Nodes need NFS client capability for csi-driver-nfs mounts; nas
  firewall needs 2049/tcp on LAN (nas is LAN-only, global open is
  consistent with existing k3s ports).
- k3s auto-deploys manifests per server from local files: identical
  inputs on nas/macmini/router/protectli keep the driver definition
  in sync by construction (same lesson as Traefik).
- DB failover means restore-from-dump (minutes RTO), not automatic
  failover. Stated openly, accepted for homelab scale.

## Approaches considered

- **A — NFS static PVs + local-path DBs with dumps (picked).** Files
  reachable anywhere (future: transcodes off nas CPU), DBs fast on
  NVMe with dump-based safety, one DaemonSet of new machinery, every
  piece independently revertible (unexport, delete PVs).
- B — nas-pinned hostPath/local-path only, no NFS. Zero new infra,
  but stateful pods can never leave nas and macmini/protectli stay
  compute-only for anything with state. Kept as fallback if NFS
  proves painful; costs nothing to keep in reserve.
- C — Longhorn / Rook-Ceph replicated block. Real mobility, but
  needs disks that don't exist on 2–3 nodes, heaviest operational
  burden in the homelab space, and still doesn't solve shared RWX
  media well. Rejected: risk and cost without a matching requirement.

## Decided (what the builder implements)

### 1. nas NFS export (`configurations/nixos/nas/configuration.nix`)

- `services.nfs.server.enable = true`, `lockdPort`/`mountdPort`/
  `statdPort` fixed (deterministic firewall), NFSv4 only.
- `services.nfs.server.exports` (or `fileSystems`-adjacent exports
  list): explicit per-directory entries, e.g.
  `/mnt/POOL/k3s-test 10.1.0.0/24(rw,sync,no_subtree_check)` plus a
  read-only media path for the proof read (`/mnt/POOL/Public`
  `ro,...` — read-only proves the RO path too). New dirs only;
  `root_squash` default, `no_root_squash` nowhere.
- Firewall: 2049/tcp (and the fixed lockd/mountd/statd ports if the
  NixOS module needs them even for v4-only) on LAN. nas is LAN-only
  so global `allowedTCPPorts` entries match existing practice.

### 2. csi-driver-nfs (all servers, identical manifest)

- Upstream release yaml (pinned tag/hash, recorded in the plan)
  applied via the shared k8s wrapper: new `nixcfg.k3s.nfs` option?
  No — keep the wrapper small: deploy through
  `services.k3s.manifests` on nas only? NO — manifests must be
  identical on all servers *if set on multiple*, but a manifest set
  on *one* server deploys cluster-wide (addons are cluster objects).
  Decision: apply the driver manifest from nas only (single writer,
  no sync question at all), same as homepage manifests today.
- Static PVs (one per exported dir, `storageClassName: ""`? No —
  give them an explicit class, e.g. `nfs-pool`, `persistentVolume-
  ReclaimPolicy: Retain`, hard-coded `nfs: { server: 10.1.0.3, path }`)
  also from nas only. PVCs are per-workload, created by each
  migration later; the proof creates a throwaway PVC.

### 3. DB pattern (documented, proven with scratch instance)

- Scratch postgres StatefulSet (Bitnami or official image, pinned
  tag): `nodeAffinity: nas`, `volumeClaimTemplates` on the default
  local-path class, init → write canary row → `pg_dump` CronJob to
  an NFS PVC → restore into a *second* scratch instance from that
  dump → verify rows. Then delete everything (instances, PVCs keep?
  No — delete proof PVC contents too; keep the *volume dir*? Delete
  all of it. Clean cluster.)
- The pattern (StatefulSet + nodeAffinity + CronJob-to-NFS) is
  written up as the template for the first real DB migration;
  CloudNativePG-style operators explicitly deferred until a DB
  needs HA, which none do today.

### Rollout order

1. nas: NFS export + firewall → verify mount from macmini
   (`mount -t nfs4 10.1.0.3:/mnt/POOL/k3s-test`) *before* k8s does.
2. Driver manifest + static PVs (nas switch) → `kubectl get csidriver`
   + PVs Available.
3. Scratch DB + dump/restore proof → verify → delete proof resources.
4. Commit each step separately; every step revertible (unexport,
   delete manifests/PVs — Retain policy means data survives).

### Verification

- NFS mount works node-side first; k3s never debugs the network.
- PVs `Available`, PVC binds, pod on macmini writes a file visible
  on nas (`/mnt/POOL/k3s-test`), pod on nas reads it back
  (cross-node RWX proven).
- Scratch DB round-trip (write → dump → restore → verify).
- `traefik`/`homepage` untouched; `kubectl get pods -A` clean
  afterwards (proof deleted).

## Left to the builder

- Exact upstream csi-driver-nfs release yaml (pinned tag + hash;
  verify `nfs.csi.k8s.io` driver name and v4 defaults in that
  release).
- Export option details (`fsid`, `sec=sys`, squash choices per dir)
  and mount options (`vers=4.2`, timeouts) — verify against the
  release's docs, keep minimal.
- Whether the NixOS nodes need any extra package for NFS mounts
  (driver containerizes mount.nfs; confirm no host package needed).
- Scratch postgres image + tag (official `postgres:<pin>` preferred).

## Builder self-check (no subagent tool)

- Single-writer principle for shared Addons applied: driver + PVs
  from nas only, dodging the multi-server manifest-sync trap that
  bit Traefik (documented in the ingress design).
- DBs never touch NFS (anti-goal stated + enforced by scheduling
  DBs to local-path only in the pattern).
- RTO honestly stated (restore-from-dump, minutes) — no HA theater.
- Nothing in this plan moves production data or credentials.
