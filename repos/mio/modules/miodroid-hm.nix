{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.miodroid-rootless;
  wipWarning = "programs.miodroid-rootless is experimental: add each Home Manager user to virtualisation.miodroid-rootless.users to provision unprivileged LXC and shared binder access.";
in
{
  options.programs.miodroid-rootless = {
    enable = lib.mkEnableOption "experimental rootless Miodroid";
    package = lib.mkPackageOption pkgs "miodroid" { };
    workDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.dataHome}/miodroid";
      defaultText = lib.literalExpression ''"\${config.xdg.dataHome}/miodroid"'';
      description = "Writable work directory for the experimental rootless Miodroid instance.";
    };
    instance = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional named Miodroid instance.";
    };
    hostHelperService = lib.mkOption {
      type = lib.types.str;
      default = "miodroid-rootless-helper.service";
      defaultText = lib.literalExpression ''"miodroid-rootless-helper.service"'';
      description = "NixOS system service that prepares host devices for rootless Miodroid.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.warn wipWarning {
      home.packages = [ cfg.package ];

      systemd.user.services.miodroid-container = {
        Unit = {
          Description = "Experimental Rootless Miodroid Container";
          After = [
            "graphical-session.target"
            cfg.hostHelperService
          ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.systemd}/bin/systemctl --system is-active --quiet ${cfg.hostHelperService}";
          ExecStart = "${cfg.package}/bin/miodroid container start";
          Environment = [
            "MIODROID_ROOTLESS=1"
            "MIODROID_WORK=${cfg.workDirectory}"
          ]
          ++ lib.optional (cfg.instance != null) "MIODROID_INSTANCE=${cfg.instance}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
  );
}
