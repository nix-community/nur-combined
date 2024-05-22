default: (local "test")

local goal="switch":
  sudo nixos-rebuild {{goal}} --no-build-nix --flake .#local

rollback:
  sudo nixos-rebuild test --no-build-nix --flake .#local --rollback

iso:
  nix build .#install-iso -o result-iso

update:
  find . -type f -name update.sh | parallel -j+1 'cd {//} && ./update.sh'
  nix fmt . 2>/dev/null
