{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dunst;
in
{
  options.services.dunst = {
    enable = mkEnableOption "dunst";

    package = mkOption {
      type = types.package;
      default = pkgs.dunst;
    };

    settings = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = ''
        Configuration set alternative to <literal>configFile</literal>.
      '';
      example = {
        global = {
          monitor = 0;
          follow = "none";
        };
      };
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to dunstrc configuration file.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings != null && cfg.configFile != null);
        message = "only one of services.dunst.settings or .configFile may be specified";
      }
    ];

    environment.systemPackages = [ (getOutput "man" cfg.package) ];

    systemd.user.services.dunst = {
      description = "Dunst notification daemon";
      documentation = [ "man:dunst(1)" ];
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart =
          let
            config =
              if (cfg.settings != null)
              then pkgs.writeText "dunstrc" (generators.toINI { } cfg.settings)
              else if (cfg.configFile != null)
              then cfg.configFile
              else null;
          in
          "${cfg.package}/bin/dunst ${optionalString (config != null) "-conf ${config}"}";
      };
    };
  };
}
