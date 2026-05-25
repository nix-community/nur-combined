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
  nix-update aicommits --url https://github.com/Nutlope/aicommits --flake
  nix-update wokwigw --flake
