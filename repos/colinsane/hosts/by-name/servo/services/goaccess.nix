{ pkgs, ... }:
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
        ${pkgs.goaccess}/bin/goaccess \
          -f /var/log/nginx/public.log \
          --log-format=VCOMBINED \
          --real-time-html \
          --html-refresh=30 \
          --no-query-string \
          --anonymize-ip \
          --ignore-panel=HOSTS \
          --ws-url=wss://sink.uninsane.org:443/ws \
          --port=7890 \
          -o /var/lib/uninsane/sink/index.html
      '';
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";

      # hardening
      WorkingDirectory = "/tmp";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = "read-only";
      ProtectSystem = "strict";
      SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @memlock @module @mount @obsolete @privileged @reboot @resources @setuid @swap @raw-io";
      ReadOnlyPaths = "/";
      ReadWritePaths = [ "/proc/self" "/var/lib/uninsane/sink" ];
      PrivateDevices = "yes";
      ProtectKernelModules = "yes";
      ProtectKernelTunables = "yes";
    };
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  # server statistics
  services.nginx.virtualHosts."sink.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    # inherit kTLS;
    root = "/var/lib/uninsane/sink";

    locations."/ws" = {
      proxyPass = "http://127.0.0.1:7890";
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

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."sink" = "native";
}
