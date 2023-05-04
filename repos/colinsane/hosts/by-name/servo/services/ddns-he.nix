{ config, lib, pkgs, ... }:

# we use manual DDNS now
lib.mkIf false
{
  systemd.services.ddns-he = {
    description = "update dynamic DNS entries for HurricaneElectric";
    serviceConfig = {
      EnvironmentFile = config.sops.secrets.ddns_he.path;
      # TODO: ProtectSystem = "strict";
      # TODO: ProtectHome = "full";
      # TODO: PrivateTmp = true;
    };
    # HE DDNS API is documented: https://dns.he.net/docs.html
    script = let
      crl = "${pkgs.curl}/bin/curl -4";
    in ''
      ${crl} "https://he.uninsane.org:$HE_PASSPHRASE@dyn.dns.he.net/nic/update?hostname=he.uninsane.org"
      ${crl} "https://native.uninsane.org:$HE_PASSPHRASE@dyn.dns.he.net/nic/update?hostname=native.uninsane.org"
      ${crl} "https://uninsane.org:$HE_PASSPHRASE@dyn.dns.he.net/nic/update?hostname=uninsane.org"
    '';
  };
  systemd.timers.ddns-he = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnStartupSec = "2min";
      OnUnitActiveSec = "10min";
    };
  };
}
