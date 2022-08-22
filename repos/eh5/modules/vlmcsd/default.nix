{ lib, pkgs, config, ... }:
let
  cfg = config.services.vlmcsd;
in
{
  options.services.vlmcsd = {
    enable = lib.mkEnableOption "vlmcsd service";
  };

  config = lib.mkIf cfg.enable {
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
          ${pkgs.vlmcsd}/bin/vlmcsd -e -D
        '';
      };
    };
  };
}
