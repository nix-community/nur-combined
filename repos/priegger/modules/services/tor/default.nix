{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.priegger.services.tor;
in
{
  options.priegger.services.tor = {
    enable = mkEnableOption "Enable the Tor daemon. By default, the daemon is run without relay, exit or bridge connectivity. ";
  };

  config = mkIf cfg.enable {
    services.tor = mkDefault {
      enable = true;
      controlPort = 9051;

      client.enable = true;

      hiddenServices = {
        "ssh" = {
          map = [
            { port = 22; }
          ];
          version = 3;
        };
      };
    };

    programs.ssh.extraConfig = mkIf config.services.tor.enable ''
      Host *.onion
      ProxyCommand ${pkgs.netcat}/bin/nc -xlocalhost:9050 -X5 %h %p
    '';
  };
}
