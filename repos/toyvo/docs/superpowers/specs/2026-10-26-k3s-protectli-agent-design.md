# Protectli joins as k3s agent — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: agent for capacity (quorum stays 3 voters)

## Intent / why

Add protectli (10.1.0.6, old firewall box, x86_64, same LAN) as a k3s
**agent** for workload capacity. Quorum deliberately untouched at 3 voters
(nas, macmini, router-etcd-only): a 4th voter adds no fault tolerance
(majority of 4 is 3 — still survives exactly 1 failure) while adding sync
overhead and another failure domain.

## Goals

- Protectli runs kubelet + containerd, registers as worker node, takes
  scheduled pods (including possible Traefik/homepage replicas).
- Joins via `role = "agent"`, `serverAddr = "https://10.1.0.3:6443"`,
  shared sops `k3s-token`.
- k3s ports (6443/10250 TCP, 8472/51820-51821 UDP) open on `enp1s0`
  only (`firewallInterfaces = [ "enp1s0" ]`): the node IP 10.1.0.6
  lives there (DHCP from the router; its uplink faces router LAN, not
  the internet). The 192.168.x layout on br0/VLANs is intentional
  (protectli is a test router) and untouched.

## Non-goals

- No etcd vote, no quorum change.
- No taints/affinity policy (oldest box — precious workloads get node
  affinity later, not now).
- No Traefik/Caddy changes; no storage work.

## Anti-goals

- Don't open k3s ports anywhere except `enp1s0` (node-IP interface).
  Its uplink faces the router LAN, not the internet, so risk is low —
  scoping is cheap insurance anyway (and protects the 192.168 test
  networks on br0/VLANs from cluster traffic).
- Don't disturb protectli's existing NAT/firewall role; additive change
  only. No 80/443 binds in-cluster (unchanged).

## Constraints

- `nixcfg.k3s` already supports `role = "agent"` (+ required
  `serverAddr`, `disableAgent` must stay false — enforced by assertion).
- `configurations/nixos/Protectli/configuration.nix` lacks the `config`
  arg — must add it for `config.sops.secrets."k3s-token".path`.
- Protectli age key is already in `.sops.yaml` key groups.
- Packaged-component disable flags stay uniform across servers
  (`["servicelb"]` effective everywhere traefik is on; agents don't manage
  manifests, so no Addon risk from this node).

## Approaches considered

- Agent (picked): capacity with zero quorum impact; module support exists.
- 4th voter (rejected): same 1-failure tolerance as 3, strictly worse
  availability math, more write acks.
- 5 voters (rejected): the only way to gain resilience (tolerates 2),
  overkill for a homelab today; revisit if aarch64 boards join as voters.

## Decided (what the builder implements)

- `Protectli/configuration.nix`: add `config` to module args; set
  `nixcfg.k3s = { enable = true; role = "agent"; serverAddr =
  "https://10.1.0.3:6443"; tokenFile =
  config.sops.secrets."k3s-token".path; firewallInterfaces = [ "enp1s0" ]; };`
  plus `sops.secrets."k3s-token" = { };`.
- Deploy: switch protectli; `kubectl get nodes` shows it Ready; spot-check
  a pod schedules there (or just observe natural spread).
- Rollback: set `enable = false`, switch, node drains/leaves.

## Left to the builder

- Confirm the node registers as 10.1.0.6 (`kubectl get nodes -o wide`).
  If k3s picks the wrong source IP (protectli's default route may point
  at the retired enp1s0 uplink), add a `nodeIP` passthrough to
  `nixcfg.k3s` (upstream `services.k3s.nodeIP` exists; wrapper doesn't
  expose it yet) and pin `10.1.0.6`.
- Disk check on protectli before switch (`df -h /var/lib`): images
  (homepage ~200MB, traefik ~100MB, pause) must fit.
