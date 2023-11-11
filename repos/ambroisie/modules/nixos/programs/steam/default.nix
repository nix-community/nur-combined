{ config, lib, pkgs, ... }:
let
  cfg = config.my.programs.steam;

  steam = pkgs.steam;
in
{
  options.my.programs.steam = with lib; {
    enable = mkEnableOption "steam configuration";

    dataDir = mkOption {
      type = types.str;
      default = "$XDG_DATA_HOME/steamlib";
      example = "/mnt/steam/";
      description = ''
        Which directory should be used as HOME to run steam.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
    };

    environment.systemPackages = builtins.map lib.hiPrio [
      # Respect XDG conventions, leave my HOME alone
      (pkgs.writeShellScriptBin "steam" ''
        mkdir -p "${cfg.dataDir}"
        HOME="${cfg.dataDir}" exec ${lib.getExe steam} "$@"
      '')
      # Same, for GOG and other such games
      (pkgs.writeShellScriptBin "steam-run" ''
        mkdir -p "${cfg.dataDir}"
        HOME="${cfg.dataDir}" exec ${lib.getExe steam.run}  "$@"
      '')
    ];
  };
}
