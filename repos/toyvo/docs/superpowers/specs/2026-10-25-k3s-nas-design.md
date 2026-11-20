# k3s on nas (lone cluster-init server) — Short Design

Date: 2026-10-25
Status: proposed, awaiting approval
Approach picked: A (nas-only server module now, join config later)

## Intent / why

Stand up k3s with 2 servers on day one (`nas` init + `MacMini-Intel`
join), with a clean join path for `router` and `Protectli`
(all x86_64, same 10.1.0.0/24 LAN) as servers later. No workload
migration or storage re-architecture in this step; that comes later,
plus aarch64 nodes after that.

## Goals

- Declarative k3s servers on `nas` (`clusterInit = true`) and
  `MacMini-Intel` (`serverAddr = https://10.1.0.3:6443`) via NixOS
  `services.k3s`, sharing one sops token.
- Single sops-managed cluster token (`k3s-token`) reusable by future servers.
- LAN-reachable API (6443) with TLS SANs for `nas` + future server IPs/DNS
  so joins don't force cert rotation.
- Firewall + CNI CIDRs chosen to avoid 10.1.0.0/24, 10.200.0.0/16
  (nixos-containers), and VLAN ranges.
- `kubectl` usable on `nas`; cluster survives reboot and `nixos-rebuild`.
- Router untouched in this step.

## Non-goals

- No joins for router/protectli yet (stubs deferred).
- No workload migration off nixos-containers.
- No Longhorn/Ceph/distributed storage; local-path only.
- No public ingress; no Caddy integration changes.
- No aarch64 support work.

## Anti-goals

- Don't break `nas` existing services (postgres, forgejo, ollama,
  7 containers, forgejo-runner memory headroom).
- Don't bind 80/443 on `nas` (router Caddy owns edge); don't open k3s
  API to WAN.
- Don't put token in world-readable store.

## Constraints

- `nas`: 31 GB RAM + 15 GB zram; runner capped 26–28 GB after Oct OOM.
  k3s server is light but etcd + pods add headroom pressure.
- NixOS `services.k3s` runs as systemd unit; needs `tokenFile`,
  firewall 6443/tcp, 10250/tcp, 8472/udp (flannel), 51820-51821/udp
  (flannel wireguard, if enabled).
- Secrets via sops-nix; token file owner root, mode 0400.
- Existing container net 10.200.0.0/16 must not collide with
  cluster-cidr/service-cidr (use k3s defaults 10.42.0.0/16 +
  10.43.0.0/16 unless collision found).

## Approaches considered

- A — nas-only module now (picked): new `modules/nixos/k3s.nix` with
  `nixcfg.k3s` opts, enabled only on nas. Cheapest, router untouched.
- B — pre-wire all four hosts now: faster joins later, but touches
  router early and adds eval complexity for disabled units.
- Rejected: upstream curl script / podman wrapper — imperative,
  token outside sops, manual joins.

## Decided (what the builder implements)

- New file `modules/nixos/k3s.nix`, imported in `modules/nixos/default.nix`:
  `options.nixcfg.k3s = { enable, role = "server", clusterInit,
  tokenFile, serverAddr, extraSANs, disableComponents }`.
  Note: 2-server etcd has no quorumHA (needs 3); expanding to router
  or protectli later fixes that.EXPECTed and accepted for day one.
- `nas/configuration.nix`: `nixcfg.k3s.enable = true`,
  `role="server"`, `clusterInit=true`,
  `tokenFile = config.sops.secrets."k3s-token".path`,
  `disable = [ "traefik" ]` (keep coredns, local-path, metrics-server;
  servicelb left default-off decision to builder after eval check),
  `tls-san = [ nas IP, nas hostname, 127.0.0.1 + future 10.1.0.1,
  10.1.0.6, 10.1.0.12 ]`.
- `sops.secrets."k3s-token"`: generate `openssl rand -hex 32`,
  `sops secrets.yaml` entry; no commit of plaintext.
- Firewall on nas: open 6443, 10250/tcp + 8472/udp (+51820/51821 if
  flannel-backend wireguard) restricted to 10.1.0.0/24 interface or LAN.
- `MacMini-Intel/configuration.nix`: `nixcfg.k3s.enable = true`,
  `clusterInit=false`, `serverAddr = "https://10.1.0.3:6443"`, same
  sops token + same disable list. Deploy nas first, then macmini.
- No changes to router/protectli configs in this step.
- Validation: `nix flake show`, `nixos-rebuild dry-activate`,
  then deploy nas, then macmini, `k3s kubectl get nodes -o wide`
  shows 2 Ready, reboot resilience.

## Left to builder (your call, marked in plan)

- Exact flannel backend (vxlan default vs wireguard-native) — default
  vxlan unless builder finds reason.
- Whether to also disable `servicelb` on a LAN without MetalLB yet.
- `kubeconfig` permissions for toyvo/agent users.
