{ lib, pkgs, ... }:
lib.mkIf false  #< 2024/09/30: disabled because i haven't used it in several months
{
  # based on <https://bytes.fyi/real-time-goaccess-reports-with-nginx/>
  # log-format setting can be derived with this tool if custom:
  # - <https://github.com/stockrt/nginx2goaccess>
  # config options:
  # - <https://github.com/allinurl/goaccess/blob/master/config/goaccess.conf>

  systemd.services.goaccess = {
    description = "GoAccess server monitoring";
    serviceConfig = {
      ExecStart = ''
        ${lib.getExe pkgs.goaccess} \
          -f /var/log/nginx/public.log \
          --log-format=VCOMBINED \
          --real-time-html \
          --html-refresh=30 \
          --no-query-string \
          --anonymize-ip \
          --ignore-panel=HOSTS \
          --ws-url=wss://sink.uninsane.org:443/ws \
          --port=7890 \
          -o /var/lib/goaccess/index.html
      '';
      ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";

      # hardening
      # TODO: run as `goaccess` user and add `goaccess` user to group `nginx`.
      NoNewPrivileges = true;
      PrivateDevices = "yes";
      PrivateTmp = true;
      ProtectHome = "read-only";
      ProtectKernelModules = "yes";
      ProtectKernelTunables = "yes";
      ProtectSystem = "strict";
      ReadOnlyPaths = [ "/var/log/nginx" ];
      ReadWritePaths = [ "/proc/self" "/var/lib/goaccess" ];
      StateDirectory = "goaccess";
      SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @memlock @module @mount @obsolete @privileged @reboot @resources @setuid @swap @raw-io";
      WorkingDirectory = "/var/lib/goaccess";
    };
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  # server statistics
  services.nginx.virtualHosts."sink.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    # inherit kTLS;
    root = "/var/lib/goaccess";

    locations."/ws" = {
      proxyPass = "http://127.0.0.1:7890";
      recommendedProxySettings = true;
      # XXX not sure how much of this is necessary
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_buffering off;
        proxy_read_timeout 7d;
      '';
    };
  };

  sane.dns.zones."uninsane.org".inet.CNAME."sink" = "native";
}
