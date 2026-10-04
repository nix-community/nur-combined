{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.miodroid-rootless;
  wipWarning = "programs.miodroid-rootless is experimental: add this user to the NixOS rootless group and lxc-user, and enable users.users.<name>.autoSubUidGidRange = true.";
in
{
  options.programs.miodroid-rootless = {
    enable = lib.mkEnableOption "experimental rootless Miodroid";
    package = lib.mkPackageOption pkgs "miodroid" { };
    imagePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = lib.literalExpression "pkgs.miodroid-images.a16";
      description = ''
        Declarative system.img and vendor.img bundle to make available in
        the rootless Miodroid work directory. When null, use the normal OTA
        workflow.
      '';
    };
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
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = [
            "${pkgs.systemd}/bin/systemctl --system is-active --quiet ${cfg.hostHelperService}"
          ]
          ++ lib.optionals (cfg.imagePackage != null) [
            "${pkgs.coreutils}/bin/install -d ${cfg.workDirectory}/images"
            "${pkgs.coreutils}/bin/install -m 0644 ${cfg.imagePackage}/system.img ${cfg.workDirectory}/images/system.img"
            "${pkgs.coreutils}/bin/install -m 0644 ${cfg.imagePackage}/vendor.img ${cfg.workDirectory}/images/vendor.img"
          ];
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
