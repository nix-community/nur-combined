{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    escapeShellArg
    optionalString
    ;
  cfg = config.services.lnshot;
  lnshot = pkgs.callPackage ../pkgs/lnshot/package.nix { };
in
{
  options.services.lnshot = {
    enable = mkEnableOption "lnshot service";

    picturesName = mkOption {
      description = "Name of the directory to manage inside the Pictures folder.";
      type = types.str;
      default = "Steam Screenshots";
    };

    singleUserID64 = mkOption {
      description = "User to read screenshots from. Setting this will skip creating user-specific folders in the pictures folder.";
      type = types.nullOr types.int;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ lnshot ];

    systemd.user.services.lnshot = {
      Unit = {
        Description = "Steam Screenshot Symlinking Service";
      };
      Service = {
        ExecStart = "${lnshot}/bin/lnshot ${
          optionalString (cfg.singleUserID64 != null) "--single-user-id64 ${toString cfg.singleUserID64}"
        } -p ${escapeShellArg cfg.picturesName} daemon";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
