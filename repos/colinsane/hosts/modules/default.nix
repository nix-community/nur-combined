{ config, lib, ... }:
let
  cfg = config.sane;
in
{
  imports = [
    ./hal
    ./hosts.nix
    ./nixcache.nix
    ./roles
    ./services
    ./wg-home.nix
  ];

  options = {
    sane.hostVariant = lib.mkOption {
      type = lib.types.enum [
        "smoke"
        "min"
        "light"
        "full"
      ];
      default = "full";
      description = ''
        how much of the system to build:
        - smoke: GUI-less; minimal system containing a shell, networking, and some admin tools.
        - min:   a base GUI system containing a web browser, most chat apps, but lacking excessively heavy non-critical apps.
                 i.e. no steam, no webkitgtk/electron, where possible.
        - light: contains everything i use daily/weekly, but lacking excessively heavy rarely-used apps.
                 i.e. no webkitgtk-4.1 (geary).
        - full:  contains all apps i want on a normal system.
      '';
    };
    # TODO: replace these with `buildPlatform` and `hostPlatform` ...;
    # equivalents to `nixpkgs.{build,host}Platform` but which merge properly.
    sane.libc = lib.mkOption {
      type = lib.types.enum [
        "glibc"
        "musl"
      ];
      default = "glibc";
    };
    sane.buildLibc = lib.mkOption {
      type = lib.types.enum [
        "glibc"
        "musl"
      ];
      default = cfg.libc;
    };
    sane.cpu = lib.mkOption {
      type = lib.types.enum [
        "aarch64"
        "armv7l"
        "x86_64"
      ];
    };
  };

  config = {
    sane.maxBuildCost = lib.mkMerge [
      (lib.mkIf (cfg.hostVariant == "smoke") (lib.mkDefault 0))
      (lib.mkIf (cfg.hostVariant == "min") (lib.mkDefault 0))
      (lib.mkIf (cfg.hostVariant == "light") (lib.mkDefault 2))
    ];

    sane.programs = lib.mkIf (cfg.hostVariant == "smoke") {
      sway.enableFor.user.colin = lib.mkForce false;
      consoleUtils.enableFor.user.colin = false;
      consoleMediaUtils.enableFor.user.colin = false;
      pcConsoleUtils.enableFor.user.colin = false;
      pcTuiApps.enableFor.user.colin = false;
      devPkgs.enableFor.user.colin = false;
      sysadminUtils.enableFor.system = false;
    };

    system.name = lib.mkDefault (
      if cfg.hostVariant == "full" then
        config.networking.hostName
      else
        "${config.networking.hostName}-${cfg.hostVariant}"
    );

    nixpkgs =
    let
      # inherit (lib.systems.parse) abis;
      # abi = {
      #   glibc = abis.gnu;
      #   musl = abis.musl;
      # }."${cfg.libc}";
      abiForLibc = libc: {
        glibc = "gnu";
        musl = "musl";
      }."${libc}";
    in {
      # XXX(2026-01-29): nixpkgs doesn't properly merge `buildPlatform` or `hostPlatform` definitions,
      # so we must assign to it only once, to be predictable.
      #
      # it NEEDS a `system` attribute, but if provided `system` overrides `abi` (i.e. this example breaks):
      # - `hostPlatform = { system = "x86_64-linux"; abi = "musl"; }`
      buildPlatform = {
        # we _could_ use different libc's on build v.s. host, but it largely doesn't make sense.
        system = "${config.nixpkgs.system}-${abiForLibc cfg.buildLibc}";
      };
      hostPlatform = {
        system = "${cfg.cpu}-linux-${abiForLibc cfg.libc}";
      };
    };
  };
}
