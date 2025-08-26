default: (local "test")

local goal="switch" *FLAGS="":
  sudo nixos-rebuild {{goal}} --no-build-nix --flake .#local {{FLAGS}}

rollback:
  sudo nixos-rebuild test --no-build-nix --flake .#local --rollback

installer:
  sudo disko-install --flake .#local-installer --extra-files /persist/key.txt /persist/key.txt --mode mount --mount-point /tmp/disko-installer-root --disk installer /dev/sda

update:
  find . -type f -name update.sh | parallel -j+1 'cd {//} && ./update.sh'
  nix fmt . 2>/dev/null
