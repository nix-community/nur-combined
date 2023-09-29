{ lib, pkgs, ... }: {
  systemd.services.openfortivpn =
    let
      conf = "/etc/openfortivpn/openfortivpn.conf";
    in
    {
      enable = false;
      # [Unit]
      description = "OpenFortiVPN for %I";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      documentation = [
        "man:openfortivpn(1)"
        "https://github.com/adrienverge/openfortivpn#readme"
        "https://github.com/adrienverge/openfortivpn/wiki"
      ];
      unitConfig.ConditionPathExists = [ conf ];
      # [Service]
      serviceConfig = {
        Type = "notify";
        PrivateTmp = true;
        ExecStart = "${lib.getExe pkgs.openfortivpn} -c ${conf} --pppd-accept-remote";
        Restart = "on-failure";
        OOMScoreAdjust = -100;
      };
      # [Install]
      wantedBy = [ "multi-user.target" ];
    };
}
