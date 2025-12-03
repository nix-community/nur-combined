{
  config,
  lib,
  pkgs,
  vaculib,
  ...
}:
let
  name = "dyndns-powerhouse";
  resolvconf = pkgs.writeText "resolv.conf" ''
    nameserver 9.9.9.10
    nameserver 149.112.112.10
    nameserver 8.8.8.8
    nameserver 1.1.1.1
  '';
in
{
  sops.secrets.powerhouse_dyndns_key = {
    sopsFile = "${config.vacu.sops.secretsPath}/dynamic-dns.yaml";
  };

  systemd.timers."${name}-update" = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      # OnCalendar = "1h";
      OnActiveSec = "1m";
      OnUnitInactiveSec = "1h";
      RandomizedDelaySec = "5m";
      DeferReactivation = true;
      # Persistent = true;
    };
  };

  # cloudns recomended command is:
  # wget -q --read-timeout=0.0 --waitretry=5 --tries=400 --background https://ipv4.cloudns.net/api/dynamicURL/?q={key}
  # read timeout of 0 seems very strange... I'm not gonna do that.
  systemd.services."${name}-update" = {
    description = "Simple wget to update powerhouse.dyn.74358228.xyz (thru CNAME, updates powerhouse.shelvacu.com)";
    script = ''
      set -euo pipefail
      declare key
      key="$(<"$CREDENTIALS_DIRECTORY/dyndns-key.txt")"
      declare -a cmd
      cmd=(
        ${lib.getExe pkgs.wget}
        --read-timeout=5
        --waitretry=5 #this is the *maximum* time to wait between retries
        --tries=10
        --inet4-only
        --no-hsts
        --ca-certificate=${config.security.pki.caBundle}
        --output-document=/dev/null
        --no-verbose
        "https://ipv4.cloudns.net/api/dynamicURL/?q=$key"
      )
      exec "''${cmd[@]}"
    '';
    enableStrictShellChecks = true;

    confinement.enable = true;

    serviceConfig = {
      LoadCredential = "dyndns-key.txt:${config.sops.secrets.powerhouse_dyndns_key.path}";
      BindReadOnlyPaths = [
        "${resolvconf}:/etc/resolv.conf"
        config.security.pki.caBundle
      ];
      # confinement.enable sets:
      # MountAPIVFS=rue
      # PrivateDevices=true
      # PrivateMounts=true
      # PrivateTmp=true
      # PrivateUsers=true
      # ProtectControlGroups=true
      # ProtectKernelModules=true
      # ProtectKernelTunables=true
      # ReadOnlyPaths=+/
      # RootDirectory=/run/confinement/dyndns-powerhouse-update
      # RuntimeDirectory=confinement/dyndns-powerhouse-update

      ProtectProc = "invisible";
      ProcSubset = "pid";
      DynamicUser = true;
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      NoNewPrivileges = true;
      SecureBits = [
        "no-setuid-fixup-locked"
        "noroot-locked"
      ];
      KeyringMode = "private";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateNetwork = false; # this needs to access the network
      PrivateIPC = true;
      PrivatePIDs = true;
      PrivateUsers = "self";
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      RestrictAddressFamilies = [ "AF_INET" ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      SystemCallFilter = [
        "@system-service"
        "~@resources"
        "~@privileged"
        "~@setuid"
        "~pkey_alloc:ENOSPC"
      ];
      SystemCallArchitectures = "native";
      UMask = vaculib.maskStr { user = "allow"; };

      MemoryHigh = "10M";
      MemoryMax = "100M";
      IPAddressDeny = [
        "::/0" # deny all IPv6
        "localhost"
        "link-local"
        "multicast"
        "192.0.2.0/24" # TEST-NET-1, for documentation & examples
        "198.51.100.0/24" # TEST-NET-2
        "203.0.113.0/24" # TEST-NET-3
        "198.18.0.0/15" # "Used for benchmark testing of inter-network communications between two separate subnets"
        "255.255.255.255/32" # limited broadcast

        # private network blocks
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"

        #"100.64.0.0/10" #CGNAT
      ];
      SocketBindDeny = "any";
      # DeviceAllow not needed because PrivateDevices = true
    };
  };
}
