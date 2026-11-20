# Handoff: qBittorrent-in-k3s VPN data-plane failure

Date: 2026-10-28. Status: OPEN, blocked on distinguishing broken-endpoint vs broken-account.
No secrets in this file — keys live in Proton Pass `secretspec` vault (contract: `k8s/qbittorrent/secretspec.toml`).

## Goal

Run qBittorrent in k3s (nas-pinned StatefulSet) behind ProtonVPN with a provable
fail-closed kill switch, replacing the NixOS-container qbit (already disabled via
`nixcfg.containers.starr.enable = false`; rollback = revert that commit).

## Architecture (all in `modules/nixos/k3s-starr.nix`, `qbittorrent` block)

- Pod (nodeAffinity nas): `wireguard` (linuxserver/wireguard:1.0.20260223-r0-ls127)
  + `qbittorrent` (linuxserver/qbittorrent:5.3.0_v2.1.2-ls485, `WEBUI_PORT=4080`)
  + `port-forward` (alpine:3.21.9, NAT-PMP loop; currently BROKEN — apk can't
  install natpmpc pre-tunnel, see below).
- Secret `qbittorrent-vpn`, key `wg0.conf` (full Proton config + 4 added lines:
  `Table = off` and a `PostUp`; managed via SecretSpec, alias invocation only).
- `dnsPolicy: None`, nameserver `10.2.0.1` (Proton gateway; DNS must not leak).
- Split-tunnel policy rules (explicit prefs; wg-quick auto-alloc would lose):
  `10.42/16, 10.43/16, 10.1/16 -> table main pref 31000-31002`;
  `not fwmark 51820 -> table 51820 pref 32765`; default route dev wg0 in 51820.
- nft kill-switch in PostUp (filter chains, default DROP; holes: loopback,
  cluster/LAN CIDRs both ways, UDP to endpoint .245:51820 both ways, `-i/-o wg0`).
- Media via existing `pool-media-qbittorrent-rw` PVC (`/mnt`); config on local-path
  claim; legacy `/var/lib/qBittorrent` hostPath mount so seeded fastresume paths resolve.
- Endpoint in use: `79.127.187.245:51820` (US-IL). qbit PUID/PGID 353.

## What is PROVEN working (do not re-investigate without new evidence)

- Handshake completes (crypto, endpoint reachability, keys, fwmark, conntrack all OK).
- nft ruleset verified live via `nft list ruleset` (correct holes, DROP defaults).
- Routes/rules verified live (`ip rule`, `ip route show table 51820`).
- LAN bypass works (`curl 10.1.0.3:30080` → Traefik 404 through the pod).
- Pod DNS = only 10.2.0.1; resolution attempts leave via wg0.
- Host conntrack shows the tunnel flow (`10.2.0.2:xxxxx -> .245:51820 [UNREPLIED]`);
  LAN flows show ASSURED. Return traffic never arrives.
- Kill-switch exonerated twice: (a) full `nft flush` changed nothing;
  (b) clean-room debug pod (manual `wg`+`ip`, NO nft, NO wg-quick, CoreDNS)
  passed ping + HTTP through the same key/endpoint/server. Wait — see caveat below.
- DNS wildcard-shadowing saga (separate, FIXED via kubelet `--resolv-conf`):
  all pod external names resolved to 10.1.0.1 (Caddy alert-80). Fixed cluster-wide.
- WEBUI port: image hardcodes `--webui-port=8080`; `WEBUI_PORT=4080` env is required.
- Seeding works (BT_backup/config/categories copied, chown 353; image auto-migrates
  layout; login works; 14 torrents listed but not downloading).

## The problem

After a successful handshake, the server goes completely silent: no keepalive
responses, no data, zero RX bytes beyond the single 92 B handshake response.
Ping/DNS/HTTPS all fail. Persists across fresh pods, fresh creds, firewall on/off,
route rebuilds. Last verified state: tunnel up, handshake aging, transfer frozen.

Caveat on the "debug pod worked" data point: it worked BRIEFLY (ping + HTTP once),
then the same silence. Nothing in k8s reliably passes tunnel data for more than
minutes. So the exoneration is partial — the debug pod may simply have caught a
working window.

## Theories, ranked

1. **Server-side session invalidation (duplicate identity).** Same private key used in
   multiple places (container had old creds — same key or not was never confirmed;
   debug pod shared the Secret while it lived). If Proton pins one session per key,
   ghosts fight forever. Mitigation tried: container disabled, debug pod deleted.
   Still dead → weakens but doesn't kill this (server-side ghosts take time to expire).
2. **Bad endpoint (.245).** Accepts handshakes, blackholes data. Test: config for a
   DIFFERENT Proton server. NOT YET DONE — this is the single highest-value next step.
3. **Account-level flagging.** The GB-scale outbound bursts (below) may have tripped
   abuse detection. Subscription confirmed current (family plan). Different-server test
   also distinguishes this.
4. **The flood.** Fresh pods emit 100s-of-MB outbound bursts (13 MB/s observed) with
   ~zero CPU from any process. Source unidentified (qbit DHT bootstrap is the prime
   suspect but unproven; per-process attribution inconclusive). May be cause
   (triggering server throttling) or symptom (retransmit storm into a blackhole).
   qbit runs idle at 0.1% CPU throughout.

## Ruled out (with evidence)

- Kill-switch blocking legit traffic: flushed live, no change; rules dumped correct.
- Routing/policy: verified live repeatedly; split-tunnel carve-out proven (LAN 404s).
- DNS config: pod resolv.conf correct; ping-by-IP also fails.
- MTU: all sizes fail identically, including 84 B pings.
- Duplicate live sessions (container dead per `curl 10.200.0.2:4080` timeout;
  debug pod deleted). Ghost server-side sessions NOT ruled out.
- Credentials format: verbatim Proton config + Table/PostUp; handshake proves validity.
- nft L3/L4 ordering, pref racing, initContainer DNS catch-22: all found and fixed
  along the way (initContainer deleted; PostUp owns everything explicit).

## Known remaining bugs (independent of the tunnel)

- Port-forward loop broken: `apk add natpmpc curl` fails (no DNS pre-tunnel) and never
  retries; fix = retry loop around apk or bake tools into the image.
- `resolvconf -a wg0` runs but is inert (pod DNS comes from dnsConfig, not resolv.conf).
- v6 address assigned on wg0 with no v6 routes (inert; DNS line already de-v6ed).

## Suggested next steps (in order)

1. New Proton server config (different city/country): update vault, sync Secret,
   delete pod, test ping within 2 min of handshake. Works → migrate, done.
2. If (1) fails identically: Proton account session list — log out all sessions,
   wait 10 min, fresh pod. Works → ghost sessions were it.
3. If still dead: packet capture on nas uplink for the endpoint (needs root tcpdump)
   to confirm whether handshake responses vs data responses differ on the wire.
4. Flood attribution (only after connectivity works): per-process io + AF_PACKET
   dst distribution during a burst; suspect qbit DHT — consider disabling DHT until stable.

## Key files / commands

- Manifests: `modules/nixos/k3s-starr.nix` (`qbittorrent` block), PV in
  `modules/nixos/k3s-storage.nix` (`pool-media-qbittorrent-rw`).
- Contract: `k8s/qbittorrent/secretspec.toml` (refs.kube item `wg0.conf`).
- Sync: `secretspec get WG_CONFIG -p pass -f k8s/qbittorrent/secretspec.toml | secretspec set WG_CONFIG -p kube -f k8s/qbittorrent/secretspec.toml --from-file -`
- Recreate: `sudo k3s kubectl delete pod -l app=qbittorrent` (no sudo needed for kubectl: wheel has NOPASSWD k3s — TEMPORARY, remove: `security.sudo.extraConfig` k3s line in nas config).
- Verify: `wg show` (handshake age + transfer), `ip rule`, `ip route show table 51820`,
  `ping -c2 10.2.0.1`, `curl https://1.1.1.1`, host conntrack via pod
  (`cat /proc/net/nf_conntrack | grep 51820`), `nft list ruleset`.
- Rollback: `git revert` the `enable = false` commit + switch nas (container returns).
