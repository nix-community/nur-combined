### Task 1: Protectli agent config

**Files:**
- Modify: `configurations/nixos/Protectli/configuration.nix`

**Interfaces:**
- Consumes: `nixcfg.k3s.*` (existing, no module change), `config.sops.secrets."k3s-token".path`, nas API `https://10.1.0.3:6443`.
- Produces: agent config ready to deploy.

- [ ] **Step 1: Add `config` to module args**

  The header is `{ ekaPkgs, homelab, inputs, lib, stablePkgs, system, unstablePkgs, ... }:` — add `config` (needed for the sops secret path).

- [ ] **Step 2: Add the agent block + secret**

  Somewhere near networking/nixcfg: `nixcfg.k3s = { enable = true; role = "agent"; serverAddr = "https://10.1.0.3:6443"; tokenFile = config.sops.secrets."k3s-token".path; firewallInterfaces = [ "br0" ]; };` plus `sops.secrets."k3s-token" = { };`. Do NOT set `clusterInit`, `disableAgent`, `extraSANs`, or `traefik`.

- [ ] **Step 3: Verify evaluation**

  Run: `nix eval --json '.#nixosConfigurations."Protectli".config.nixcfg.k3s'` — expect `role:"agent"`, `serverAddr` set, `clusterInit:false`, `disableAgent:false`.
  Run: `nix eval --json '.#nixosConfigurations."Protectli".config.networking.firewall.allowedTCPPorts'` — expect `[]` (no global k3s ports); and `...interfaces.br0.allowedTCPPorts` contains 6443/10250/2379/2380.
  Expected: all match.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/Protectli/configuration.nix
git commit -m "feat: protectli joins k3s as worker agent"
```

