{config, pkgs, lib, ...}:
let

  vhost = "flood.${config.networking.hostName}.${config.networking.domain}";
  floodPort = 65509;
  flood = pkgs.flood.overrideAttrs (old: { buildInputs = [ pkgs.nodejs-14_x ] ++ old.buildInputs; });
  defaultDaemonPort = 58846;

in lib.mkIf config.services.deluge.enable {
  networking.firewall = {
    allowedTCPPortRanges = [{ from = 6880; to = 6890; }];
    allowedUDPPortRanges = [{ from = 6880; to = 6890; }];
  };

  systemd.services.deluge-authfile = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      secret_user=$(systemd-id128 new)
      secret_passwd=$(systemd-id128 new)
      echo $secret_user:$secret_passwd:10 > /var/run/secrets.d/deluge-credentials
      echo _user=$secret_user > /var/run/secrets.d/deluge-credentials.env
      echo _passwd=$secret_passwd >> /var/run/secrets.d/deluge-credentials.env
      chown deluge:deluge /var/run/secrets.d/deluge-credentials*
      chmod 700 /var/run/secrets.d/deluge-credentials*
      ln -sf /var/run/secrets.d/deluge-credentials /var/lib/deluge/.config/deluge/auth
    '';
    before = [ "flood.service" "deluged.service" ];
  };

  systemd.services.flood = {
    requires = [ "deluged.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ flood ];
    serviceConfig = {
      inherit (config.systemd.services.deluged.serviceConfig) User;
    };
    script = ''
      source /var/run/secrets.d/deluge-credentials.env
      flood --dehost localhost \
        --deport ${toString defaultDaemonPort} \
        --deuser "$_user" \
        --depass "$_passwd" \
        --auth none \
        -p ${toString floodPort}
    '';
    restartIfChanged = true;
  };

  services.nginx.virtualHosts."${vhost}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString floodPort}/";
      proxyWebsockets = true;
    };
  };
}
