default: (local "test")

local goal="switch":
  sudo nixos-rebuild {{goal}} --no-build-nix --flake .#local

n1 goal="switch":
  #!/usr/bin/env bash
  set -euxo pipefail
  nix build .#nixosConfigurations.n1.config.system.build.toplevel -o result-n1
  nixos-rebuild {{goal}} --no-build-nix --target-host root@n1.lan --flake .#n1
  if [ "{{goal}}" = "boot" ]; then
    ssh root@n1.lan reboot
  fi

apply goal="switch": (local goal) (n1 goal)

iso:
  nix build .#install-iso -o result-iso

sd-image:
  nix build .#sd-aarch64-installer -o result-sd-image

update:
  find . -type f -name update.sh | parallel -j+1 'cd {//} && ./update.sh'
  nix fmt . 2>/dev/null
