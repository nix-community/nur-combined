{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.vvmd;
  dbusServiceFile = pkgs.writeTextDir "share/dbus-1/services/org.kop316.vvm.service" ''
    [D-BUS Service]
    Name=org.kop316.vvm
    SystemdService=org.kop316.vvm.service

    # Exec= is still required despite SystemdService= being used:
    # https://github.com/freedesktop/dbus/blob/ef55a3db0d8f17848f8a579092fb05900cc076f5/test/data/systemd-activation/com.example.SystemdActivatable1.service
    Exec=${pkgs.coreutils}/bin/false vvmd
  '';
in
{
  #meta.maintainers = [ maintainers.mich-adams ];

  options.services.vvmd = {
    enable = mkEnableOption "Visual Voicemail Daemon";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.vvmd
      pkgs.vvmplayer
    ];

    services.dbus.packages = [ dbusServiceFile ];

    systemd.user.services.vvmd = {
      after = [ "ModemManager.service" ];
      aliases = [ "dbus-org.kop316.vvm.service" ];
      serviceConfig = {
        Type = "dbus";
        ExecStart = "${pkgs.vvmd}/bin/vvmd";
        BusName = "org.kop316.vvm";
        Restart = "on-failure";
      };
    };

  };
}
