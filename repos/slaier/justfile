default: (local "test")

local goal="switch":
  sudo nixos-rebuild {{goal}} --no-build-nix --flake .#local

n1 goal="switch":
  #!/usr/bin/env bash
  set -euxo pipefail
  nix build .#nixosConfigurations.n1.config.system.build.toplevel
  nixos-rebuild {{goal}} --no-build-nix --target-host root@n1.lan --flake .#n1
  if [ "{{goal}}" = "boot" ]; then
    ssh root@n1.lan reboot
  fi

apply goal="switch": (local goal) (n1 goal)

sd-image:
  nix build --no-link --print-out-paths .#nixosConfigurations.sd-image-aarch64-installer.config.system.build.sdImage

update:
  find . -type f -name update.sh | parallel -j+1 'cd {//} && ./update.sh'
  nix fmt . 2>/dev/null
