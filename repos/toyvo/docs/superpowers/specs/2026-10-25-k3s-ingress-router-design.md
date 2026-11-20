# Router as etcd-only member + Traefik ingress behind Caddy — Full Design

Date: 2026-10-25
Status: proposed, awaiting approval
Approach picked: A (router joins etcd-only; Traefik on nas/macmini; Caddy stays edge)

## Intent / why

Give the 2-server cluster real etcd quorum (3rd vote) without putting any
workload on the router, and stand up the ingress path every later migration
needs: Caddy (edge, TLS, ACME — unchanged) → Traefik (in-cluster routing) →
first passenger (homepage-dashboard). Homepage is the agreed first move:
single HTTP port, config-driven, stateless, nothing depends on it.

## Goals

- Router runs k3s server with `disableAgent` (etcd vote only, zero workloads).
- Traefik enabled on nas/macmini as a NodePort service with **pinned**
  nodePorts `30080` (web) / `30443` (websecure), identical config from both
  servers.
- Router Caddy gains multi-upstream support; migrated vhosts forward to
  Traefik on both servers (`reverse_proxy 10.1.0.3:30080 10.1.0.12:30080`).
- homepage-dashboard migrated: Deployment + ClusterIP Service + Ingress
  (`diekvoss.net` root host preserved, Caddy forward_auth unchanged).
- Smoke-proven: cross-node pod traffic, Caddy→Traefik→homepage 200, failover
  with one server stopped.

## Non-goals

- No ACME move (Traefik terminates nothing; Caddy keeps all certs).
- No MetalLB / LoadBalancer services; no Traefik dashboard exposure.
- No homepage secrets (env/API keys land via a later secrets-operator
  decision; homepage starts without its env file).
- No protectli join, no storage work, no other migrations.

## Anti-goals

- Don't open k3s ports on the router's WAN (`enp2s0`): the box is
  internet-reachable (`toyvo.dev` is public). k3s ports open on LAN (`br0`)
  only.
- Don't break router DNS (Technitium :53/:5380), DHCP, Caddy (:80/:443),
  sshd (:22/:2222), or wireguard (`wg0` :51820/udp — note flannel default
  is vxlan :8472, no conflict).
- Don't bind 80/443 anywhere in-cluster yet.
- No half-synced Traefik config between servers (k3s does not sync
  manifests; both servers must render byte-identical content).

## Constraints

- `nixcfg.k3s` wrapper is the only interface host configs use.
- Upstream `services.k3s.manifests` auto-deploys but never syncs across
  servers — identical generation from shared module inputs satisfies this
  by construction.
- Caddy vhosts are generated from `homelab.nix` (`virtual-hosts.nix`
  emits one `reverse_proxy http://<ip>:<port>`); extension must stay
  backward compatible.
- NixOS firewall defaults: global `allowedTCPPorts` opens on **all**
  interfaces — unusable on the router.

## Approaches considered

- **A — etcd-only router + Traefik behind Caddy (picked).** Quorum without
  data-plane risk; TLS/ACME/auth untouched; Caddy change is additive.
- B — Router as full server with Traefik on host 80/443. Retires Caddy but
  moves TLS, ACME (Cloudflare DNS challenge), and the public/private
  listen split onto the LAN's most critical box. Rejected: risk without
  matching reward.
- C — Router stays out; quorum via protectli later. Safest but leaves
  etcd at 2 votes and still needs the Caddy→Traefik hop. Rejected: A is
  strictly more available for the same ingress work.

## Decided (what the builder implements)

### 1. `modules/nixos/k3s.nix` additions

- `disableAgent` (bool, default `false`) → `services.k3s.disableAgent`.
- `firewallInterfaces` (null-or-list-of-str, default `null`): null keeps
  today's global rules (nas/macmini); non-null emits the same ports under
  `networking.firewall.interfaces.<name>` instead. Router sets `["br0"]`
  (loopback is trusted by NixOS firewall by default).
- `traefik` (attrs): `enable` (bool, default `false`; when true, remove
  `"traefik"` from `services.k3s.disable`), `httpNodePort` (default
  `30080`), `httpsNodePort` (default `30443`). When enabled the wrapper
  sets `services.k3s.manifests."traefik-config.yaml".content` to a
  `HelmChartConfig` (`helm.cattle.io/v1`, name `traefik`, namespace
  `kube-system`) whose `valuesContent` sets NodePort service type with the
  pinned nodePorts (exact chart value keys verified against the bundled
  Traefik chart version during implementation).
- Assertion: `disableAgent -> role == "server"` (mirrors upstream).

### 2. Router wiring (`configurations/nixos/router/configuration.nix`)

- `nixcfg.k3s = { enable = true; role = "server"; clusterInit = false;
  serverAddr = "https://10.1.0.3:6443";
  tokenFile = config.sops.secrets."k3s-token".path; disableAgent = true;
  firewallInterfaces = [ "br0" ];
  extraSANs = [ "10.1.0.1" "router" "router.diekvoss.net" ]; };`
- `sops.secrets."k3s-token" = { };` (router age key already in key groups).
- No workloads (no kubelet with disableAgent), no 80/443 binds. Traefik IS
enabled here too (see §3 correction) — no pods can land without a kubelet.
- Port-conflict evidence: router serves 53/5380 (Technitium), 22/2222
  (ssh), 80/443 (Caddy), 67/68 (DHCP), 51820/udp (wg0) — none collide
  with 6443/10250/2379/2380/8472/30080/30443.

### 3. Traefik on all three servers

- Set `nixcfg.k3s.traefik.enable = true` on nas, macmini AND router
  (disable list drops traefik everywhere). All render the identical
  HelmChartConfig → sync safe.
- 2026-10-26 correction: a subset is not just untidy, it is broken. k3s
  shares one Addon object per packaged chart across all servers, and a
  server starting with `--disable=traefik` deletes it cluster-wide.
  Observed: router (disabled) joined 15:35:49, Traefik uninstalled itself
  15:36:15, 26s later. No nas switch happened in that window (profile
  links: 15:19:29 → 15:50:21), and nas logged no local deletion — the
  removal came from the router's deploy controller.
- Traefik dashboard stays off; nothing listens on 80/443 in-cluster.

### 4. Caddy generator (`configurations/nixos/router/virtual-hosts.nix`)

- Service entries gain optional `upstreams` (list of `"ip:port"` strings).
  When absent, today's single-`reverse_proxy http://ip:port` output is
  byte-identical. When present, emit
  `reverse_proxy <u1> <u2> { header_down -Server }` (Caddy LB + failover).
  forward_auth/HSTS/ACME blocks unchanged.
- `homelab.nix` `nas.services.homepage` gains
  `upstreams = [ "10.1.0.3:30080" "10.1.0.12:30080" ]`
  (ip/port left as fallback documentation; generator prefers upstreams).

### 5. homepage manifests (via wrapper, both servers, identical)

- `services.k3s.manifests."homepage.yaml".content`: Namespace `homepage`(?)
  — keep default namespace to stay simple: Deployment `homepage`
  (2 replicas, image `docker.io/gethomepage/homepage:<pinned tag>`,
  port 8082), Service ClusterIP 8082, Ingress class `traefik`,
  host `diekvoss.net` → service. No env file (secrets deferred);
  builder verifies homepage serves without it.
- `services.homepage-dashboard` on nas disabled after cutover; firewall
  8082 closed; Caddy vhost flips to upstreams in the same change…
  safer split: manifests deployed first (Ingress exists, no traffic),
  Caddy flip second, nas service disabled third. Rollback = revert flip.

### Rollout order

1. Module + Traefik manifests → switch nas, then macmini (Traefik appears).
2. Smoke test (whoami/pause pods both nodes, cross-node curl, NodePorts).
3. Router etcd-only join → `kubectl get nodes` shows 3 servers.
4. Caddy `upstreams` support deployed (no behavior change, no upstreams set).
5. homepage manifests → Caddy flip → verify → disable nas service.
6. Push each as its own commit; every step independently revertible.

## Verification

- `nix flake show` + both toplevels build; unit asserts no `--disable-agent`
  on nas/mac, `--disable-agent` on router, no `--server` on nas.
- Live: 3 Ready servers; `kubectl get svc -n kube-system traefik` NodePorts
  30080/30443; cross-node pod curl 200; Caddy→homepage 200 with auth gate;
  stop k3s on one server → homepage still 200.

## Left to the builder

- Exact Traefik chart value keys for NodePort pinning (verify against
  bundled chart; likely `service.type` + `ports.web/websecure.nodePort`).
- Homepage image tag pin (latest stable at build time).
- Whether homepage truly starts clean with no env file (verify; else ship
  an empty-Secret + envFrom and note the operator decision still open).

## Builder self-check (no subagent tool — author review)

- Router WAN exposure: covered by `firewallInterfaces`; anti-goal explicit.
- Manifest sync: identical generation both servers; noted.
- Traefik-on-router impossibility: disableAgent ⇒ no kubelet ⇒ scheduler
  can't place there; stated.
- Caddy backward compat: `upstreams` optional, output identical when absent.
- Rollback path: ordered steps each revertible; stated.
- Gap admitted, not hand-waved: chart value keys + image tag + env-file
  behavior are verify-during-build items in the plan.
