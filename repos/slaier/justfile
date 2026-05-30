default: (local "test")

local goal="switch" *FLAGS="":
  sudo nixos-rebuild {{goal}} --flake .#local {{FLAGS}}

rollback:
  sudo nixos-rebuild test --flake .#local --rollback

iso:
  nix build .#nixosConfigurations.installer.config.system.build.isoImage

update:
  nix flake update
  nix-update CloudflareSpeedTest --flake
