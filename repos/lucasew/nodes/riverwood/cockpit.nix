{ pkgs, config, lib, ... }: let
  cfg = config.services.cockpit;
  inherit (lib) types mkEnableOption mkOption mkIf;
in {
  options = {
    services.cockpit = {
      enable = mkEnableOption "Cockpit";
      package = mkOption {
        description = "Cockpit package to be used";
        type = types.package;
        default = pkgs.nbr.wip.cockpit;
        defaultText = "pkgs.cockpit";
      };
      port = mkOption {
        description = "Port where cockpit will listen";
        type = types.port;
        default = 9090;
      };
      openFirewall = mkOption {
        description = "Open port for cockpit";
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/share/cockpit" ];
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
    environment.systemPackages = [ cfg.package ];
    systemd.slices.system-cockpithttps = { # Translation from $out/lib/systemd/system/systemd-cockpithttps.slice
      description = "Resource limits for all cockpit-ws-https@.service instances";
      sliceConfig = {
        TasksMax = 200;
        MemoryHigh = "75%";
        MemoryMax = "90%";
      };
    };
    systemd.sockets."cockpit-wsinstance-https@" = { # Translation from $out/lib/systemd/system/cockpit-wsinstance-https@.socket
      unitConfig = {
        Description= "Socket for Cockpit Web Service https instance %I";
        BindsTo= [ "cockpit.service" "cockpit-wsinstance-https@%i.service" ];
        # clean up the socket after the service exits, to prevent fd leak
        # this also effectively prevents a DoS by starting arbitrarily many sockets, as
        # the services are resource-limited by system-cockpithttps.slice
        Documentation="man:cockpit-ws(8)";
      };
      socketConfig = {
        ListenStream="/run/cockpit/wsinstance/https@%i.sock";
        SocketUser="root";
        SocketMode="0600";
      };
    };
    systemd.services."cockpit-wsinstance-https@" = { # Translation from $out/lib/systemd/system/cockpit-wsinstance-https@.service
      description = "Cockpit Web Service https instance %I";
      bindsTo = [ "cockpit.service"];
      path = [ cfg.package ];
      documentation = [ "man:cockpit-ws(8)" ];
      serviceConfig = {
        Slice = "system-cockpithttps.slice";
        ExecStart = "${cfg.package}/libexec/cockpit-ws --for-tls-proxy --port=0";
        User = "root";
        Group = "";
      };
    };
    systemd.sockets.cockpit-wsinstance-http = { # Translation from $out/lib/systemd/system/cockpit-wsinstance-http.socket
      unitConfig = {
        Description="Socket for Cockpit Web Service http instance";
        BindsTo="cockpit.service";
        Documentation="man:cockpit-ws(8)";
      };
      socketConfig = {
        ListenStream="/run/cockpit/wsinstance/http.sock";
        SocketUser="root";
        SocketMode="0600";
      };
    };
    systemd.sockets.cockpit-wsinstance-https-factory = { # Translation from $out/lib/systemd/system/cockpit-wsinstance-https-factory.socket
      unitConfig = {
        Description="Socket for Cockpit Web Service https instance factory";
        BindsTo="cockpit.service";
        Documentation="man:cockpit-ws(8)";
      };
      socketConfig = {
        ListenStream="/run/cockpit/wsinstance/https-factory.sock";
        Accept=true;
        SocketUser="root";
        SocketMode="0600";
      };
    };
    systemd.services."cockpit-wsinstance-https-factory@" = { # Translation from $out/lib/systemd/system/cockpit-wsinstance-https-factory@.service
      description = "Cockpit Web Service https instance factory";
      documentation = [ "man:cockpit-ws(8)" ];
      path = [ cfg.package ];
      serviceConfig = {
        ExecStart = "${cfg.package}/libexec/cockpit-wsinstance-factory";
        User = "root";
      };
    };
    systemd.services."cockpit-wsinstance-http" = { # Translation from $out/lib/systemd/system/cockpit-wsinstance-http.service
      description = "Cockpit Web Service http instance";
      bindsTo = [ "cockpit.service" ];
      path = [ cfg.package ];
      documentation = [ "man:cockpit-ws(8)" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/libexec/cockpit-ws --no-tls --port=0";
        User = "root";
        Group = "";
      };
    };
    systemd.sockets."cockpit" = { # Translation from $out/lib/systemd/system/cockpit.socket
      unitConfig = {
        Description="Cockpit Web Service Socket";
        Documentation="man:cockpit-ws(8)";
        Wants="cockpit-motd.service";
      };
      socketConfig = {
        ListenStream=cfg.port;
        ExecStartPost= [
          "-${cfg.package}/share/cockpit/motd/update-motd \"\" localhost"
          "-${pkgs.coreutils}/bin/ln -snf active.motd /run/cockpit/motd"
        ];
        ExecStopPost="-${pkgs.coreutils}/bin/ln -snf inactive.motd /run/cockpit/motd";
      };
      wantedBy = [ "sockets.target" ];
    };
    systemd.services."cockpit" = { # Translation from $out/lib/systemd/system/cockpit.service
      description = "Cockpit Web Service";
      documentation = [ "man:cockpit-ws(8)" ];
      path = with pkgs; [ coreutils cfg.package ];
      requires = [ "cockpit.socket" "cockpit-wsinstance-http.socket" "cockpit-wsinstance-https-factory.socket" ];
      after = [ "cockpit-wsinstance-http.socket" "cockpit-wsinstance-https-factory.socket" ];
      environment = {
        G_MESSAGES_DEBUG = "cockpit-ws,cockpit-bridge";
      #   RUNTIME_DIRECTORY = "/run/cockpit/tls";
      };
      serviceConfig = {
        RuntimeDirectory="cockpit/tls";
        # systemd ≥ 241 sets this automatically
        ExecStartPre=[
          "+${pkgs.coreutils}/bin/mkdir -p $RUNTIME_DIRECTORY"
          "+${cfg.package}/libexec/cockpit-certificate-ensure --for-cockpit-tls"

        ];
        ExecStart="${cfg.package}/libexec/cockpit-tls";
        User="root";
        Group="";
        NoNewPrivileges=true;
        ProtectSystem="strict";
        ProtectHome=true;
        PrivateTmp=true;
        PrivateDevices=true;
        ProtectKernelTunables=true;
        RestrictAddressFamilies= [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        MemoryDenyWriteExecute=true;
      };
    };
    systemd.services."cockpit-motd" = { # Translation from $out/lib/systemd/system/cockpit-motd.service
      path = with pkgs; [ gnused nettools ];
      unitConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/share/cockpit/motd/update-motd";
      };
      description = "Cockpit motd updater service";
      documentation = [ "man:cockpit-ws(8)" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "cockpit.socket" ];
    };
    systemd.tmpfiles.rules = [ # From $out/lib/tmpfiles.d/cockpit-tmpfiles.conf
      "C /run/cockpit/inactive.motd 0640 root root - ${cfg.package}/share/cockpit/motd/inactive.motd"
      "f /run/cockpit/active.motd   0640 root root -"
      "L+ /run/cockpit/motd - - - - inactive.motd"
    ];
    security.pam.services.cockpit = {};
  };
}
