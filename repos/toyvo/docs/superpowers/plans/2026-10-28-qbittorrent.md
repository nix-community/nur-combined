# qBittorrent Migration Implementation Plan

**Goal:** qBittorrent serves from k3s (VPN-isolated pod with proven kill-switch), container retired, zero NixOS containers left in the media stack.

**Architecture:** Extend `nixcfg.k3sStarr` with qbittorrent (StatefulSet: wireguard + qbittorrent + port-forward containers, iptables initContainer, Proton DNS, SecretSpec key, local-path config, RW media PVC); Caddy upstreams flip; manual secret load + kill-switch proof + cutover + retire.

**Tech Stack:** NixOS (`services.k3s.manifests`), linuxserver/qbittorrent pinned (hub-verified), WireGuard sidecar, SecretSpec k8s provider, Traefik Ingress, Caddy multi-upstream.

**Spec:** `docs/superpowers/specs/2026-10-28-qbittorrent-design.md`

## Global Constraints

- NO secrets in the Nix store (SecretSpec path only; verify with `nix` — no key material in eval output).
- NEVER two live qBittorrents (stop container qbit before k8s takes traffic).
- DNS through the tunnel only (`dnsPolicy: None` + Proton gateway).
- Node-pinned to nas; local-path config (never NFS); downloads reuse `/mnt/Downloads`.
- Download test MANDATORY (this workload's purpose; no deferral).
- `nix fmt` before commit; validation is eval + toplevel builds; switches + secrets + cutover manual, nas-then-router.

## Review Focus

- Kill-switch holes too wide (leak on tunnel drop) — expect DROP defaults + only endpoint/cluster/wg0 holes; test in Task 3 pins it (fail-closed proof).
- Secret in store (key material in eval/build output) — expect Secret references only; test in Task 1 pins it (rg eval output).
- DNS leaking to LAN (tracker lookups visible) — expect `dnsPolicy: None` + Proton nameserver; test in Task 3 pins it (query-path check).
- Dual-qbit operation (port-forward fights, duplicate announces) — expect container qbit stopped before k8s verification; ordering in Task 3 pins it.
- qBittorrent config drift (WebUI edits reverted) — expect declarative-only changes; standing lesson.

---

### Task 1: qbittorrent manifests (dark) + SecretSpec contract

**Files:**
- Modify: `modules/nixos/k3s-starr.nix` (add qbittorrent block), `configurations/nixos/nas/configuration.nix` (enable flag).
- Create: SecretSpec contract file for the WireGuard key material (location per existing homepage pattern).

**Interfaces:**
- Consumes: qbittorrent port 4080, existing qbit UID/GID, ProtonVPN endpoint/gateway (confirm current), SecretSpec-managed Secret.
- Produces: qbittorrent StatefulSet + Service + Ingress (dark), nas-applied.

- [ ] **Step 1: Confirm ProtonVPN endpoint + pick pinned images**

  Verify current endpoint IP/port + gateway (today `79.127.187.156:5180` / `10.2.0.1` — re-confirm, Proton rotates). Hub-verify linuxserver/qbittorrent tag + wireguard sidecar image tag.
  Expected: values recorded in ledger, no `latest` anywhere.

- [ ] **Step 2: Write the SecretSpec contract (values by user)**

  Contract file with `refs.kube` entries for the WireGuard private key (and endpoint/public key if not hardcoded). User loads values into Proton Pass `secretspec` vault; builder verifies via alias invocation + `kubectl get secret` key names only (never values).
  Expected: Secret exists with exact key names, values never in repo/store.

- [ ] **Step 3: Add qbittorrent block (NO storage shortcuts)**

  StatefulSet (1 replica, nodeAffinity nas, three containers + iptables initContainer with NET_ADMIN, `dnsPolicy: None` + Proton DNS, `wg0.conf` secret volume, local-path config claimTemplate + RW media PVC on `nfs-pool`, containerPort 4080), Service ClusterIP :4080, Ingress class traefik host `qbittorrent.diekvoss.net`. PUID/PGID = existing qbit ids.

- [ ] **Step 4: Enable + verify eval (INCLUDING secret absence)**

  nas config: `nixcfg.k3sStarr.qbittorrent.enable = true;`. Run: manifest eval — expect image pins, NET_ADMIN present, dnsPolicy None, no storage shortcuts. Run: `nix eval ... | rg -i "private|secret|key"` — expect NO key material (only refs/names).
  Expected: structure correct, store clean.

- [ ] **Step 5: Build nas toplevel**

  Run: `nix build ...nas toplevel...` — PASS. Do NOT switch yet.

- [ ] **Step 6: Commit**

```bash
nix fmt
git add modules/nixos/k3s-starr.nix configurations/nixos/nas/configuration.nix <secretspec-contract>
git commit -m "feat: qbittorrent manifests in k3s (dark, vpn-isolated)"
```

### Task 2: Caddy upstreams (no behavior change yet)

**Files:**
- Modify: `homelab.nix` (`starr.services.qbittorrent.upstreams`)

- [ ] **Step 1: Add upstreams + prove rendering**

  Set `upstreams = [ "10.1.0.3:30080" "10.1.0.12:30080" ]`. Run: `nix eval ...router...virtualHosts."qbittorrent.diekvoss.net".extraConfig` — expect dual-upstream reverse_proxy.
  Expected: matches.

- [ ] **Step 2: Commit (NOT switched yet)**

```bash
nix fmt
git add homelab.nix
git commit -m "feat: route qbittorrent through traefik upstreams"
```

### Task 3: Manual deploy + kill-switch proof + cutover + flip + retire (user)

**Files:** none.

- [ ] **Step 1: Deploy dark + verify pod (container qbit STILL RUNNING)**

  Switch nas, allow propagation. Pod Running on nas, all containers ready, PVCs bound. Old container still serving (no traffic moved yet).
  Expected: healthy pod, old still up.

- [ ] **Step 2: Kill-switch proof (THE GATE — before any traffic)**

  From the pod: `wg show` (handshake recent). Then `ip link set wg0 down` (or stop the wireguard container): prove ALL external egress fails (curl timeout) while cluster-local still answers. Restore wg0, prove egress returns. If fail-open anywhere, STOP.
  Expected: fail-closed proven, documented.

- [ ] **Step 3: DNS-path check**

  From the pod: resolve a tracker hostname; confirm the query went through the tunnel resolver (not CoreDNS/LAN). If LAN DNS answers, STOP (dnsPolicy wrong).
  Expected: Proton resolver only.

- [ ] **Step 4: Cutover (stop old BEFORE new takes traffic)**

  STOP container qBittorrent. Seed k8s state (config + fastresume continuity per builder recommendation). Repoint download clients in sonarr/lidarr/radarr/readarr to `http://qbittorrent:4080`. Test each client.
  Expected: all four green, exactly one qbit alive.

- [ ] **Step 5: End-to-end download (MANDATORY)**

  Trigger a real download; confirm the file lands in `/mnt/Downloads`, completes, and imports into the requesting app's library.
  Expected: full loop proven — the migration's entire purpose.

- [ ] **Step 6: Flip + retire**

  Switch router, verify 200 + failover. Confirm old port dead. (Container module removal follows as separate cleanup.)
  Expected: cutover complete.

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off qbittorrent (media stack fully in k3s). Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-28-qbittorrent.md
git commit -m "docs: qbittorrent migration complete"
```
