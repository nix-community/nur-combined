{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sfl;
in
{
  options.services.sfl = {
    enable = lib.mkEnableOption "sing-box for Linux (SFL) desktop client and daemon";

    insecureMode = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = ''
        Whether profiles may use privileges unrelated to networking, including
        unrestricted file access and command execution as root. Enable only for
        trusted profiles. Applied before each daemon start; null leaves the
        upstream setting unmanaged, false explicitly restores restrictions.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/sfl { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/sfl { }";
      description = "SFL package containing the desktop client and sing-box-daemon.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.polkit.enable = true;

    environment.systemPackages = [ cfg.package ];

    systemd.packages = [ cfg.package ];

    systemd.services.sing-box-daemon = {
      wantedBy = [ "multi-user.target" ];
      preStart = lib.mkIf (cfg.insecureMode != null) ''
        ${lib.getExe' cfg.package "sing-box-daemon"} service set-insecure-mode ${lib.boolToString cfg.insecureMode} --working-directory /var/lib/sing-box-daemon
      '';
      path = with pkgs; [
        dbus
        glib
        iproute2
        iptables
        kdePackages.kconfig
        nftables
        systemd
      ];
    };
  };
}
