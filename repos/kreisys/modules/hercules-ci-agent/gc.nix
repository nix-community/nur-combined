{ lib, pkgs, config, ... }:
let

  inherit (lib) types mkIf mkOption;
  cfg = config.services.hercules-ci-agent;

in
{
  options.services.hercules-ci-agent = {
    freespaceGB = mkOption {
      type = types.nullOr types.int;
      default = 30;
      description = ''
        Amount of free space (GB) to ensure on garbage collection
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.freespaceGB != null) {
    nix.gc.automatic = true;
    nix.gc.options = ''--max-freed "$((${toString cfg.freespaceGB} * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';
  };
}
