# k3s Ingress (Router Quorum + Traefik + Homepage) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Router joins as etcd-only third server; Traefik serves NodePorts behind Caddy; homepage migrates as first passenger.

**Architecture:** `nixcfg.k3s` gains `disableAgent`, `firewallInterfaces`, and `traefik` (HelmChartConfig NodePort pinning, byte-identical on both servers); router joins with LAN-scoped firewall; Caddy generator learns optional multi-upstream services; homepage ships as wrapper-generated manifests.

**Tech Stack:** NixOS (`services.k3s`, `services.caddy`), k3s HelmChartConfig, Traefik, Caddy reverse_proxy.

**Spec:** `docs/superpowers/specs/2026-10-25-k3s-ingress-router-design.md`

## Global Constraints

- Router k3s ports open on `br0` ONLY — never global (`enp2s0` is WAN-facing, `toyvo.dev` is public).
- Traefik HelmChartConfig content must be byte-identical on nas and macmini (generated from shared module inputs only).
- Caddy generator change is backward compatible: no `upstreams` → byte-identical output.
- Caddy keeps all TLS/ACME/forward_auth; nothing listens on 80/443 in-cluster; Traefik dashboard stays off.
- `nix fmt` before commit; validation is `nix flake show` + affected toplevel builds; deploys are manual, nas-then-macmini-then-router, each step revertible.

## Review Focus

- k3s API/etcd reachable on router WAN — expect `iptables -S` on router to show k3s ports under the br0 chain only, never global; test in Task 3 pins it.
- Traefik NodePorts randomly assigned (wrong chart value keys) breaking the Caddy contract — expect `kubectl get svc -n kube-system traefik` to show exactly 30080/30443; test in Task 2 pins it.
- Manifest divergence between servers (k3s never syncs) — expect `diff` of both servers' rendered `traefik-config.yaml`+`homepage.yaml` to be empty; test in Task 2/5 pins it.
- Caddy regression: an existing vhost's rendered config changes without `upstreams` set — expect `caddy adapt` diff on one untouched vhost to be empty; test in Task 4 pins it.
- Homepage CrashLoop without env file — expect Deployment `Ready` before the Caddy flip; test in Task 5 pins it (fallback: empty Secret + envFrom, operator decision still open).

---

### Task 1: Module — `disableAgent`, `firewallInterfaces`, `traefik`

**Files:**
- Modify: `modules/nixos/k3s.nix`

**Interfaces:**
- Consumes: upstream `services.k3s.{disableAgent, manifests}` (rancher base module; manifests verified present).
- Produces: `nixcfg.k3s.{disableAgent, firewallInterfaces, traefik.enable, traefik.httpNodePort, traefik.httpsNodePort}` for Tasks 2-3-5.

- [ ] **Step 1: Add the three options + mapping**

  In `options.nixcfg.k3s`: `disableAgent` (bool, default false); `firewallInterfaces` (null-or-list-of-str, default null); `traefik` submodule `{ enable (bool, false); httpNodePort (port, 30080); httpsNodePort (port, 30443); }`. Mapping: `services.k3s.disableAgent = cfg.disableAgent`; firewall ports (6443/10250 TCP, 2379/2380 TCP, 8472/51820-51821 UDP) go global when null, else under each `networking.firewall.interfaces.<name>`; when `traefik.enable`, drop `"traefik"` from the passed `disable` list and set `services.k3s.manifests."traefik-config.yaml".content` to the HelmChartConfig (apiVersion `helm.cattle.io/v1`, kind `HelmChartConfig`, metadata name `traefik` namespace `kube-system`, `spec.valuesContent` pinning NodePort type + both nodePorts). Assertion: `disableAgent -> role == "server"`.

- [ ] **Step 2: Verify chart value keys against the bundled Traefik chart**

  Run: `nix build --print-out-paths '.#nixosConfigurations."nas".config.services.k3s.package' --no-link` then inspect the packaged Traefik chart values for the service-type/nodePort keys; adjust `valuesContent` keys to match. Expected: keys confirmed (likely `service.type`, `ports.web.nodePort`, `ports.websecure.nodePort`).

- [ ] **Step 3: Verify evaluation**

  Run: `nix flake show 2>&1 | head -n 5`
  Expected: PASS, no eval error.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add modules/nixos/k3s.nix
git commit -m "feat: k3s module supports etcd-only members and Traefik NodePorts"
```

### Task 2: Traefik on nas + macmini, smoke-tested

**Files:**
- Modify: `configurations/nixos/nas/configuration.nix`, `configurations/nixos/MacMini-Intel/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.traefik.*` from Task 1.
- Produces: Traefik Service NodePorts 30080/30443 on both nodes.

- [ ] **Step 1: Enable traefik on both hosts**

  Add `traefik.enable = true;` inside each host's existing `nixcfg.k3s` block. No other changes.

- [ ] **Step 2: Build both toplevels**

  Run: `nix build --print-out-paths '.#nixosConfigurations."nas".config.system.build.toplevel' --no-link` and the same for `"MacMini-Intel-NixOS"`.
  Expected: both PASS. Then diff rendered manifests: `diff <(nix eval --raw ...nas...manifests) <(mac...)` — expect empty (byte-identical).

- [ ] **Step 3: Commit**

```bash
nix fmt
git add configurations/nixos/nas/configuration.nix configurations/nixos/MacMini-Intel/configuration.nix
git commit -m "feat: enable Traefik NodePorts on k3s servers"
```

- [ ] **Step 4: Manual deploy + smoke test (user on machines)**

  Deploy nas, then macmini. Then: `kubectl get svc -n kube-system traefik` shows 30080/30443; deploy 2 test pods (one per node via nodeName) and curl cross-node pod IPs (proves flannel+NixOS FORWARD path); `curl http://10.1.0.3:30080/dashboard/` → 404-from-Traefik (proves Traefik serves, dashboard off).

### Task 3: Router joins etcd-only

**Files:**
- Modify: `configurations/nixos/router/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.*` from Task 1, `k3s-token` secret, nas API.
- Produces: 3-server etcd (`kubectl get nodes` shows router as control-plane,etcd, no workloads).

- [ ] **Step 1: Wire router config**

  `nixcfg.k3s = { enable = true; role = "server"; clusterInit = false; serverAddr = "https://10.1.0.3:6443"; tokenFile = config.sops.secrets."k3s-token".path; disableAgent = true; firewallInterfaces = [ "br0" ]; extraSANs = [ "10.1.0.1" "router" "router.diekvoss.net" ]; };` plus `sops.secrets."k3s-token" = { };`. Confirm `config` is in the module args (it is — uses `config.networking.hostName`).

- [ ] **Step 2: Verify no WAN exposure in evaluation**

  Run: `nix eval --json '.#nixosConfigurations."router".config.networking.firewall.allowedTCPPorts'` → expect `[]` (or at minimum no 6443/2379/2380/10250); and `nix eval --json ...interfaces.br0.allowedTCPPorts` contains 6443/10250/2379/2380.
  Expected: LAN-only confirmed pre-deploy.

- [ ] **Step 3: Build router toplevel**

  Run: `nix build --print-out-paths '.#nixosConfigurations."router".config.system.build.toplevel' --no-link`
  Expected: PASS; router k3s unit contains `--disable-agent`, no `--server` absence issue (has `--server https://10.1.0.3:6443`).

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/router/configuration.nix
git commit -m "feat: router joins k3s as etcd-only member"
```

- [ ] **Step 5: Manual deploy (user on router)**

  Switch router; `kubectl get nodes` shows 3 servers, router with no pods (`kubectl get pods -A -o wide` shows nothing on router).

### Task 4: Caddy multi-upstream support (no behavior change)

**Files:**
- Modify: `configurations/nixos/router/virtual-hosts.nix`

**Interfaces:**
- Consumes: `homelab.nix` service entries (unchanged schema + optional `upstreams`).
- Produces: generator honoring `upstreams` when present.

- [ ] **Step 1: Extend the generator**

  In the per-service destructuring add `upstreams ? null`. When null, emit today's exact string. When set (list of `"ip:port"`), emit `reverse_proxy <join " " upstreams> { header_down -Server }` keeping the surrounding HSTS/log/forward_auth blocks identical.

- [ ] **Step 2: Prove zero regression**

  Run: build router toplevel before/after (stash trick or `nix build` + `caddy adapt` on rendered Caddyfile) and diff one untouched vhost block.
  Expected: empty diff when no service sets `upstreams`.

- [ ] **Step 3: Commit**

```bash
nix fmt
git add configurations/nixos/router/virtual-hosts.nix
git commit -m "feat: caddy vhosts support multi-upstream backends"
```

### Task 5: homepage migrates (manifests → flip → cleanup)

**Files:**
- Modify: `modules/nixos/k3s.nix` (or new `modules/nixos/k3s-homepage.nix` — builder picks; prefer separate file imported from `modules/nixos/default.nix`), `homelab.nix`, `configurations/nixos/nas/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.traefik` NodePorts from Task 1 (Ingress assumes Traefik serves 30080).
- Produces: homepage served from cluster; nas native service retired.

- [ ] **Step 1: Add homepage manifests (identical both servers)**

  `services.k3s.manifests."homepage.yaml".content`: Deployment `homepage` (2 replicas, pinned `docker.io/gethomepage/homepage:<tag>`, containerPort 8082), Service ClusterIP `:8082`, Ingress (ingressClassName `traefik`, host `diekvoss.net`, path `/` → service). No env file. Diff nas-vs-macmini rendered content: expect empty.

- [ ] **Step 2: Build + commit manifests (traffic still on nas service)**

```bash
nix build --print-out-paths '.#nixosConfigurations."nas".config.system.build.toplevel' --no-link
nix fmt
git add <manifest file(s)> homelab.nix
git commit -m "feat: homepage manifests in cluster (dark)"
```

  (homelab.nix unchanged here — flip comes next.)

- [ ] **Step 3: Manual flip + verify (user)**

  Deploy nas+macmini (Ingress exists, idle). Then set `nas.services.homepage.upstreams = [ "10.1.0.3:30080" "10.1.0.12:30080" ]` in homelab.nix, deploy router, verify `https://diekvoss.net` 200 with auth gate, stop k3s on one server → still 200. Then disable `services.homepage-dashboard` on nas + close 8082, redeploy nas.

- [ ] **Step 4: Commit the flip separately**

```bash
nix fmt
git add homelab.nix configurations/nixos/nas/configuration.nix
git commit -m "feat: homepage served from k3s via Traefik"
```

### Task 6: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format, full eval**

  Check off router-quorum/Traefik/homepage items; add follow-ups (homepage secrets operator, ACME-in-Traefik decision, protectli join, storage). Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-25-k3s-ingress-router.md
git commit -m "docs: k3s ingress rollout complete"
```
