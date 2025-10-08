default: (local "test")

local goal="switch" *FLAGS="":
  sudo nixos-rebuild {{goal}} --no-build-nix --flake .#local {{FLAGS}}

rollback:
  sudo nixos-rebuild test --no-build-nix --flake .#local --rollback
