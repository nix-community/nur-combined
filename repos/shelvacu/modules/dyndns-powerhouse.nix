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
      declare -a cmd_common
      cmd_common=(
        ${lib.getExe pkgs.wget}
        --read-timeout=5
        --waitretry=5 #this is the *maximum* time to wait between retries
        --tries=10
        --no-hsts
        --ca-certificate=${config.security.pki.caBundle}
        --output-document=/dev/null
        --no-verbose
      )
      "''${cmd_common[@]}" --inet4-only "https://ipv4.cloudns.net/api/dynamicURL/?q=$key" || true
      "''${cmd_common[@]}" --inet6-only "https://ipv6.cloudns.net/api/dynamicURL/?q=$key"
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
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
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
        "localhost"    # 127.0.0.0/8, ::1/128
        "link-local"   # 169.254.0.0/16, fe80::/64  (see note)
        "multicast"    # 224.0.0.0/4, ff00::/8

        # documentation & examples
        "192.0.2.0/24"     # TEST-NET-1
        "198.51.100.0/24"  # TEST-NET-2
        "203.0.113.0/24"   # TEST-NET-3
        "2001:db8::/32"    # RFC 3849
        "3fff::/20"        # RFC 9637 (2024), second documentation block

        # benchmarking
        "198.18.0.0/15"    # RFC 2544
        "2001:2::/48"      # RFC 5180 (per errata; the RFC text's 2001:200::/48 was a typo)

        "255.255.255.255/32" # limited broadcast; no v6 equivalent (multicast covers it)
        "fe80::/10"          # full link-local range, not just the /64 systemd assumes
        "fec0::/10"          # deprecated site-local (RFC 3879)

        # private network blocks
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "fc00::/7"           # ULA (covers fd00::/8 locally-assigned half)

        # v4 reachable via v6 — these are the ones that actually bypass the rules above
        "::ffff:0:0/96"      # v4-mapped
        "::/96"              # deprecated v4-compatible
        "64:ff9b::/96"       # NAT64 well-known prefix (RFC 6052)
        "64:ff9b:1::/48"     # local-use NAT64 (RFC 8215)
        "2002::/16"          # 6to4 (RFC 7526, deprecated)
        "2001::/32"          # Teredo

        # misc special-purpose
        "100::/64"           # discard-only (RFC 6666)
        "2001:10::/28"       # ORCHID, deprecated
        "2001:20::/28"       # ORCHIDv2
        "2001:30::/28"       # drone remote ID
        "5f00::/16"          # SRv6 SIDs (RFC 9602)
        "3ffe::/16"          # ex-6bone
        "2001:4:112::/48"    # AS112-v6
        "2620:4f:8000::/48"  # AS112 direct delegation

        #"100.64.0.0/10"     # CGNAT
      ];
      SocketBindDeny = "any";
      # DeviceAllow not needed because PrivateDevices = true
    };
  };
}
