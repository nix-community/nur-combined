{
  config,
  lib,
  pkgs,
  vaculib,
  ...
}:
let
  turnHost = "coturn.shelvacu.com";
  # Shared TURN REST-API secret, minted into tmpfs on boot and handed to both
  # coturn and continuwuity via LoadCredential (both are sandboxed).
  secretFile = "/run/turn-shared-secret";
  # Public IP; like livekit, pin relays here or they'd use the private LAN IP.
  publicIp = toString config.vacu.hosts.prophecy.primaryIp;
  coturnCfg = config.services.coturn;
  # caddy's cert for turnHost, copied into place by check-coturn-cert (cf murmur).
  caddyCertDir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${turnHost}";
  coturnCertDir = "/var/lib/coturn/certs";
in
{
  services.coturn = {
    enable = true;
    realm = turnHost;
    use-auth-secret = true;
    static-auth-secret-file = "/run/credentials/coturn.service/turn_secret";
    listening-ips = [ publicIp ];
    relay-ips = [ publicIp ];
    min-port = 49152;
    max-port = 49999;
    cert = "${coturnCertDir}/tls.crt";
    pkey = "${coturnCertDir}/tls.key";
    no-tcp-relay = true;
    no-cli = true;
    extraConfig = ''
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  systemd.services.coturn = {
    wants = [ "check-coturn-cert.service" ];
    before = [ "check-coturn-cert.service" ];
    serviceConfig = {
      LoadCredential = [ "turn_secret:${secretFile}" ];
      # Module default is on-abort, which won't recover a nonzero exit.
      Restart = lib.mkForce "on-failure";
      RestartSec = 5;
    };
  };

  # No trailing newline so both readers get byte-identical secrets.
  systemd.services.turn-secret = {
    description = "Generate the shared coturn/continuwuity TURN secret";
    before = [
      "coturn.service"
      "continuwuity.service"
    ];
    wantedBy = [
      "coturn.service"
      "continuwuity.service"
    ];
    path = [
      pkgs.coreutils
      pkgs.openssl
    ];
    unitConfig.ConditionPathExists = "!${secretFile}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "077";
    };
    script = ''
      printf '%s' "$(openssl rand -hex 32)" > ${secretFile}
    '';
  };

  services.matrix-continuwuity.settings.global = {
    turn_uris = [
      "turns:${turnHost}?transport=udp"
      "turns:${turnHost}?transport=tcp"
      "turn:${turnHost}?transport=udp"
      "turn:${turnHost}?transport=tcp"
    ];
    turn_secret_file = "/run/credentials/continuwuity.service/turn_secret";
  };
  systemd.services.continuwuity.serviceConfig.LoadCredential = [ "turn_secret:${secretFile}" ];

  networking.firewall = {
    allowedTCPPorts = [
      coturnCfg.listening-port
      coturnCfg.tls-listening-port
    ];
    allowedUDPPorts = [
      coturnCfg.listening-port
      coturnCfg.tls-listening-port
    ];
    allowedUDPPortRanges = [
      {
        from = coturnCfg.min-port;
        to = coturnCfg.max-port;
      }
    ];
  };

  systemd.tmpfiles.settings.whatever.${coturnCertDir}.d = {
    user = "turnserver";
    group = "turnserver";
    mode = vaculib.accessModeStr { user = "all"; };
  };

  # Copy caddy's cert for turnHost into coturnCertDir when newer, restarting
  # coturn (which has no live cert reload). Adapted from ./murmur.nix.
  systemd.services.check-coturn-cert = {
    enable = true;
    enableStrictShellChecks = true;
    script = ''
      set -euo pipefail
      caddyCertDir=${lib.escapeShellArg caddyCertDir}
      coturnCertDir=${lib.escapeShellArg coturnCertDir}
      function getModified() {
        declare dir="$1" cert nullglobRestore
        shift

        nullglobRestore="$(shopt -p nullglob)"
        shopt -s nullglob
        cert="$(echo "$dir"/*.crt)"
        $nullglobRestore

        if [[ -z $cert ]]; then
          printf "0000\n"
        else
          date --utc --iso-8601=seconds --reference="$cert"
        fi;
        return 0
      }
      echo "Checking if cert has changed"
      if [[ $(getModified "$caddyCertDir") > $(getModified "$coturnCertDir") ]]; then
        echo "Change detected, copying files..."
        installCmd=(
          install
          --no-target-directory
          --owner turnserver
          --group turnserver
          --mode ${vaculib.accessMode { user = "all"; }}
          --preserve-timestamps
          --verbose
        )
        "''${installCmd[@]}" "$caddyCertDir"/*.crt "$coturnCertDir"/tls.crt
        "''${installCmd[@]}" "$caddyCertDir"/*.key "$coturnCertDir"/tls.key
        echo "Restarting coturn"
        systemctl try-restart coturn
        echo "Done"
      else
        echo "No change detected"
      fi
    '';
  };

  systemd.timers.check-coturn-cert = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    timerConfig.RandomizedDelaySec = "5s";
    timerConfig.OnUnitInactiveSec = "1h";
    timerConfig.OnActiveSec = "0s";
  };

  environment.persistence."/persistent".directories = [
    {
      directory = coturnCertDir;
      user = "turnserver";
      group = "turnserver";
      mode = vaculib.accessModeStr { user = "all"; };
    }
  ];

  # Just so caddy obtains/renews the TLS cert for turnHost.
  services.caddy.virtualHosts.${turnHost} = {
    vacu.hsts = false;
    extraConfig = ''
      respond "coturn TURN/STUN server for sv.mt Matrix calls" 200
    '';
  };
}
