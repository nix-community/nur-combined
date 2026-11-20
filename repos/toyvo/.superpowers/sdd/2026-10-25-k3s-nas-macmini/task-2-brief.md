### Task 2: nas as init server

**Files:**
- Modify: `configurations/nixos/nas/configuration.nix`
- Manual: `secrets.yaml` (user runs sops)

**Interfaces:**
- Consumes: `nixcfg.k3s.*` from Task 1, `config.sops.secrets."k3s-token".path`, `homelab` IPs.
- Produces: running init server at `https://10.1.0.3:6443`, token shared with Task 3.

- [ ] **Step 1: Add manual token generation instruction (do not commit plaintext)**

  Run (user, on trusted machine): `openssl rand -hex 32` then add as `k3s-token: <value>` via `sops secrets.yaml`. Verify with `sops -d secrets.yaml | rg k3s-token` showing a key exists (value redacted in output check).

- [ ] **Step 2: Wire nas config**

  In `configurations/nixos/nas/configuration.nix`: set `nixcfg.k3s = { enable = true; role = "server"; clusterInit = true; tokenFile = config.sops.secrets."k3s-token".path; extraSANs = [ "10.1.0.3" "nas" "nas.diekvoss.net" "10.1.0.12" "10.1.0.1" "10.1.0.6" ]; disable = [ "traefik" ]; };` plus `sops.secrets."k3s-token" = { };` (owner root default, mode `0400`). Restrict firewall to LAN if module opens globally.

- [ ] **Step 2b: Verify no plaintext token + LAN-only firewall**

  Run: `rg -n "k3s-token|tokenFile" configurations/nixos/nas/configuration.nix modules/nixos/k3s.nix; rg -n "6443|8472|10250" modules/nixos/k3s.nix`
  Expected: only `tokenFile = config.sops.secrets."k3s-token".path` references, no hex value; firewall ports present and scoped to 10.1.0.0/24.

- [ ] **Step 3: Dry-activate nas**

  Run: `nixos-rebuild dry-activate --flake .#nas 2>&1 | tail -n 20` (or `nix build .#nixosConfigurations.nas.config.system.build.toplevel --dry-run`)
  Expected: PASS, no assertion `clusterInit must be false` errors.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add configurations/nixos/nas/configuration.nix docs/superpowers/specs/2026-10-25-k3s-nas-design.md
git commit -m "feat: k3s init server on nas"
```

