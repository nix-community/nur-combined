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
    ;
  cfg = config.services.lnshot;
  lnshot = pkgs.callPackage ../pkgs/lnshot { };
in
{
  options.services.lnshot = {
    enable = mkEnableOption "lnshot service";

    picturesName = mkOption {
      description = "Name of the directory to manage inside the Pictures folder.";
      type = types.str;
      default = "Steam Screenshots";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ lnshot ];

    systemd.user.services.lnshot = {
      Unit = {
        Description = "Steam Screenshot Symlinking Service";
      };
      Service = {
        ExecStart = "${lnshot}/bin/lnshot -p ${escapeShellArg cfg.picturesName} daemon";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
