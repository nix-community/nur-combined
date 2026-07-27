# AGENTS.md

## Mandates

- Do not unify `mise.toml` files.
- Prefer `sdw` over `sd` so you run the copy from this dotfiles tree, not a stale shim.
- Never run `workspaced codebase apply` on this repo.

## Where things live

- `nix/` - Nix/NixOS configs
- `nix/nodes/` - per-machine configs and non-NixOS bits (Android, etc.)
- `nix/pkgs/custom/` - custom package sources (`nix/overlay.nix`)
- `modules/` - workspaced modules (configs, base16 themes)
- `bin/` - CLI scripts (`source bin/source_me` for env); `bin/prelude` is only `sd` shim code — see `bin/prelude/README.md`
- `config/` - workspaced home templates (source of truth for shell snippets, not `bin/prelude`)

- `infra/` - Terraform
- `flake.nix` - global knobs (user, email, IPs, DE)
- `nix/nodes/common/sops.nix` - secrets via sops-nix

## Machines

- riverwood - laptop, Intel CPU/GPU, ext4, Sway/i3
- whiterun - desktop, Ryzen 5600G, ZFS, monitoring/containers
- ravenrock - Hostinger VPS, running debian, config has a older version for GCP

## Common commands

- NixOS apply: `sudo nixos-rebuild switch --flake .`
- Deploy: `sd nix rrun .#deploy`
- Build: `nix build .#nixosConfigurations.MACHINE.config.system.build.toplevel`
- Workspaced: `workspaced home apply` / `workspaced home plan` / `workspaced driver doctor`
