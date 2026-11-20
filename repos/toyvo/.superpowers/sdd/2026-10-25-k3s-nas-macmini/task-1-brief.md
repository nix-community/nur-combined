### Task 1: `nixcfg.k3s` wrapper module

**Files:**
- Create: `modules/nixos/k3s.nix`
- Modify: `modules/nixos/default.nix`

**Interfaces:**
- Consumes: upstream `services.k3s.{enable, role, clusterInit, serverAddr, tokenFile, extraFlags, disable}` (rancher base module).
- Produces: `nixcfg.k3s.{enable, role, clusterInit, serverAddr, tokenFile, extraSANs, disable}` for Tasks 2-3.

- [ ] **Step 1: Create `modules/nixos/k3s.nix` with `lib.mkEnableOption` + `lib.mkOption` interface**

  Define `options.nixcfg.k3s`: `enable` (bool), `role` (enum server/agent, default `"server"`), `clusterInit` (bool, default false), `serverAddr` (null-or-str, default null), `tokenFile` (null-or-path), `extraSANs` (list-of-str, default `[]`), `disable` (list-of-str, default `[ "traefik" ]`). Map to `services.k3s` when `cfg.enable`: `role`, `clusterInit`, `serverAddr` (mkIf non-null), `tokenFile`, `disable`, plus `extraFlags = map (san: "--tls-san=${san}") cfg.extraSANs`. Add firewall rules via `networking.firewall` for 6443/tcp, 10250/tcp, 8472/udp, 51820-51821/udp. Follow `modules/nixos/podman.nix` + `containers/*.nix` style (`cfg = config.nixcfg.k3s`, `lib.mkIf cfg.enable`).

- [ ] **Step 2: Register module in `modules/nixos/default.nix`**

  Add `./k3s.nix` to the `imports` list and `k3s = ./k3s.nix;` to the attribute set alongside `podman`.

- [ ] **Step 3: Verify evaluation**

  Run: `nix flake show 2>&1 | head -n 30`
  Expected: PASS (no eval error).

- [ ] **Step 4: Commit**

```bash
nix fmt
git add modules/nixos/k3s.nix modules/nixos/default.nix
git commit -m "feat: add nixcfg.k3s wrapper module"
```

