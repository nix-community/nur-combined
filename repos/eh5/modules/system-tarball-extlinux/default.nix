{ config, lib, pkgs, nixpkgs, ... }:
{
  system.build.tarball = pkgs.callPackage "${nixpkgs}/nixos/lib/make-system-tarball.nix" {
    contents = [ ];
    storeContents = [{
      object = config.system.build.toplevel;
      symlink = "/run/current-system";
    }];

    extraCommands = pkgs.pkgs.writeShellScript "populate-boot" ''
      mkdir -p ./boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./boot
    '';

    compressCommand = "zstd";
    compressionExtension = ".zst";
    extraInputs = [ pkgs.zstd ];
  };

  boot.postBootCommands = ''
    # On the first boot do some maintenance tasks
    if [ -f /nix-path-registration ]; then
      set -euo pipefail
      set -x

      # Register the contents of the initial Nix store
      ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

      # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

      # Prevents this from running on later boots.
      rm -f /nix-path-registration
    fi
  '';
}
