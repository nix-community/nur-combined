{ config, lib, pkgs, ... }:

# using manual ddns now
lib.mkIf false
{
  systemd.services.ddns-afraid = {
    description = "update dynamic DNS entries for freedns.afraid.org";
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.ddns_afraid.path;
      # TODO: ProtectSystem = "strict";
      # TODO: ProtectHome = "full";
      # TODO: PrivateTmp = true;
    };
    script = let
      curl = "${pkgs.curl}/bin/curl -4";
    in ''
      ${curl} "https://freedns.afraid.org/dynamic/update.php?$AFRAID_KEY"
    '';
  };
  systemd.timers.ddns-afraid = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnStartupSec = "2min";
      OnUnitActiveSec = "10min";
    };
  };
}
