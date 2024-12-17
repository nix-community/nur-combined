{ config, lib, pkgs, ... }:

let
  inherit (builtins) length;
  inherit (config) host;
  inherit (lib) getExe mkIf mkMerge mkOption;
  inherit (lib.types) listOf str;
  inherit (pkgs) curl obfs4;
in
{
  options.host.tor = {
    bridges = mkOption { type = listOf str; };
  };

  config = {
    services.tor = {
      enable = true;
      client.enable = true;

      settings = mkMerge [
        {
          CacheDirectory = "/var/cache/tor"; # TODO: Upstream
        }
        (mkIf (length host.tor.bridges > 0) {
          Bridge = host.tor.bridges;
          ClientTransportPlugin = "obfs4 exec ${getExe obfs4}";
          UseBridges = true;
        })
      ];
    };

    systemd.services.tor = {
      onFailure = [ "alert@%N.service" ];

      serviceConfig = {
        CacheDirectory = "%N"; # Used by services.tor.settings.CacheDirectory
        CacheDirectoryMode = "0700";
      };
    };

    systemd.services.tor-normalize = {
      description = "Normalize the existence of Tor traffic";
      bindsTo = [ "tor.service" ];
      startAt = "hourly";
      onFailure = [ "alert@%N.service" ];

      confinement.enable = true;

      script = ''
        set -Eeuo pipefail

        pool=(
          # Amnesty International
          'https://www.amnestyl337aduwuvpf57irfl54ggtnuera45ygcxzuftwxjvvmpuzqd.onion/en/feed/'

          # BBC News
          'https://feeds.bbcws2hcewhlhutm5qrjkekkg3eraphuc7ba7qh4jeinhibnx3ymxaqd.onion/news/stories/rss.xml'

          # Electronic Frontier Foundation
          'https://www.iykpqm7jiradoeezzkhj7c4b33g4hbgfwelht2evxxeicbpjy44c7ead.onion/rss.xml'

          # ProPublica
          'http://p53lf57qovyuvwsc6xnrppyply3vtqm7l6pcobkmyqsiofyeznfu5uqd.onion/feeds/propublica/main'

          # Reddit World News
          'https://old.reddittorjg6rue252oqsxryoxengawnmo46qy4kyii5wtqnwfj4ooad.onion/r/worldnews/.rss'

          # The Guardian
          'https://www.guardian2zotagl6tmjucg3lrhxdk4dw3lhbqnkvvkywawy3oqfoprid.onion/world/rss'

          # The New York Times
          # 'https://rss.nytimesn7cgmftshazwhfgzm37qxb44r64ytbb2dj3x62d2lljsciiyd.onion/services/xml/rss/nyt/HomePage.xml' # Pending updated TLS certificate

          # Tor Project
          'http://pzhdfe7jraknpj2qgu5cz2u3i4deuyfwmonvzu5i3nyw4t4bmg7o5pad.onion/feed.xml'
        )

        url="''${pool[$RANDOM % ''${#pool[@]}]}"

        echo "Retrieving $url" >&2
        ${getExe curl} \
          --fail-with-body \
          --no-progress-meter \
          --output '/dev/null' \
          --proxy 'socks5h://127.0.0.1:9050' \
          --user-agent 'feed-reader' \
          --write-out '%{stderr}HTTP status %{response_code}, %{size_download} B\n' \
          "$url"
      '';

      serviceConfig = {
        SyslogIdentifier = "%N";

        DynamicUser = true;
        BindReadOnlyPaths = [ "/etc/ssl/certs/ca-certificates.crt" ];

        CapabilityBoundingSet = "";
        DeviceAllow = "";
        DevicePolicy = "closed";
        IPAddressAllow = [ "127.0.0.1" ];
        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [ "AF_INET" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
        UMask = "0077";

        Type = "oneshot";
        CPUSchedulingPolicy = "batch";
        IOSchedulingClass = "idle";
      };
    };

    systemd.timers.tor-normalize.timerConfig.RandomizedDelaySec = "1h";
  };
}
