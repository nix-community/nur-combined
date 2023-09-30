{ lib, pkgs, ... }:
let
  conf = "/etc/openfortivpn/openfortivpn.conf";
in
{
  systemd.services.openfortivpn = {
    # [Unit]
    description = "OpenFortiVPN for %I";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    documentation = [
      "man:openfortivpn(1)"
      "https://github.com/adrienverge/openfortivpn#readme"
      "https://github.com/adrienverge/openfortivpn/wiki"
    ];
    # [Service]
    serviceConfig = {
      Type = "notify";
      PrivateTmp = true;
      ExecStart = "${lib.getExe pkgs.openfortivpn} -c ${conf} --pppd-accept-remote";
      Restart = "on-failure";
      OOMScoreAdjust = -100;
    };
  };
  sops.secrets.openfortivpn = {
    format = "ini";
    sopsFile = ../../secrets/openfortivpn.ini;
    path = conf;
  };
}
