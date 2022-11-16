{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.vlmcsd;
in
{
  options.services.vlmcsd = {
    enable = mkEnableOption "vlmcsd service";
    package = mkPackageOption pkgs "vlmcsd" { default = [ "vlmcsd" ]; };
  };

  config = mkIf cfg.enable {
    systemd.sockets.vlmcsd = {
      description = "KMS Emulator Listening Socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "1688" ];
      socketConfig.Accept = "yes";
    };
    systemd.services."vlmcsd@" = {
      description = "KMS Emulator Service";
      requires = [ "vlmcsd.socket" ];
      serviceConfig = {
        DynamicUser = true;
        StandardInput = "socket";
        StandardOutput = "journal";
        ExecStart = ''
          ${cfg.package}/bin/vlmcsd -e -D
        '';
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
