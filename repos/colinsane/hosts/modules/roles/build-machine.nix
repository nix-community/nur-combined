{ config, lib, pkgs, sane-lib, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  inherit (config.programs.ccache) cacheDir;
  cfg = config.sane.roles.build-machine;
in
{
  options.sane.roles.build-machine = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    emulation = mkOption {
      type = types.bool;
      default = true;
    };
    ccache = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    ({
      sane.programs.qemu = pkgs.qemu;
    })
    (mkIf cfg.enable {
      # enable opt-in emulation of any package at runtime.
      # i.e. `nix build '.#host-pkgs.moby.bash' ; qemu-aarch64 ./result/bin/bash`.
      sane.programs.qemu.enableFor.user.colin = true;
      # serve packages to other machines that ask for them
      sane.services.nixserve.enable = true;

      # enable cross compilation
      # TODO: do this via stdenv injection, linking into /run/binfmt the stuff in <nixpkgs:nixos/modules/system/boot/binfmt.nix>
      boot.binfmt.emulatedSystems = lib.optionals cfg.emulation [
        "aarch64-linux"
        # "aarch64-darwin"  # not supported
        # "x86_64-darwin"   # not supported
      ];
      # corresponds to env var: NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
      # nixpkgs.config.allowUnsupportedSystem = true;
    })
    (mkIf (cfg.enable && cfg.ccache) {
      # programs.ccache.cacheDir = "/var/cache/ccache";  # nixos default
      # programs.ccache.cacheDir = "/homeless-shelter/.ccache";  # ccache default (~/.ccache)

      # if the cache doesn't reside at ~/.ccache, then CCACHE_DIR has to be set.
      # we can do that manually as commented out below, or let nixos do it for us by telling it to use ccache on a dummy package:
      programs.ccache.packageNames = [ "dummy-pkg-to-force-ccache-config" ];
      # nixpkgs.overlays = [
      #   (self: super: {
      #     # XXX: if the cache resides not at ~/.ccache (i.e. /homeless-shelter/.ccache)
      #     # then we need to explicitly tell ccache where that is.
      #     ccacheWrapper = super.ccacheWrapper.override {
      #       extraConfig = ''
      #         export CCACHE_DIR="${cacheDir}"
      #       '';
      #     };
      #   })
      # ];

      # granular compilation cache
      # docs: <https://nixos.wiki/wiki/CCache>
      # investigate the cache with:
      # - `nix-ccache --show-stats`
      # - `build '.#ccache'
      #   - `sudo CCACHE_DIR=/var/cache/ccache ./result/bin/ccache --show-stats -v`
      # TODO: whitelist `--verbose` in <nixpkgs:nixos/modules/programs/ccache.nix>
      # TODO: configure without compression (leverage fs-level compression), and enable file-clone (i.e. hardlinks)
      programs.ccache.enable = true;
      nix.settings.extra-sandbox-paths = [ cacheDir ];
      sane.persist.sys.plaintext = [
        { group = "nixbld"; mode = "0775"; directory = config.programs.ccache.cacheDir; }
      ];
      sane.fs."${cacheDir}/ccache.conf" = sane-lib.fs.wantedText ''
        max_size = 50G
      '';
    })
  ];
}
