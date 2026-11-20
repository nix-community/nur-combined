### Task 3: MacMini-Intel joins as second server

**Files:**
- Modify: `configurations/nixos/MacMini-Intel/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.*` from Task 1, same `k3s-token` secret, nas API `https://10.1.0.3:6443`.
- Produces: 2-node cluster (`kubectl get nodes` shows both Ready).

- [ ] **Step 1: Wire MacMini-Intel config**

  Set `nixcfg.k3s = { enable = true; role = "server"; clusterInit = false; serverAddr = "https://10.1.0.3:6443"; tokenFile = config.sops.secrets."k3s-token".path; extraSANs = [ "10.1.0.12" "MacMini-Intel-NixOS" ]; disable = [ "traefik" ]; };` plus `sops.secrets."k3s-token" = { };`. Assert `clusterInit` is false (no split-brain).

- [ ] **Step 2: Dry-activate macmini**

  Run: `nixos-rebuild dry-activate --flake .#MacMini-Intel 2>&1 | tail -n 20`
  Expected: PASS.

- [ ] **Step 3: Ordered rollout note (deploy-time, not eval)**

  Deploy nas first, wait for `k3s kubectl get nodes` Ready, then deploy MacMini-Intel. Document in commit message.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/MacMini-Intel/configuration.nix
git commit -m "feat: join MacMini-Intel to k3s cluster"
```

