{ config, lib, pkgs, ... }:

let
  inherit (config) host;
  inherit (lib) getExe getExe' mapAttrs' mapAttrsToList mkOption nameValuePair;
  inherit (lib.types) attrsOf int str submodule;
  inherit (pkgs) coreutils dig wireguard-tools writeShellApplication;

  wireguard-reresolve = writeShellApplication {
    name = "wireguard-reresolve";
    runtimeInputs = [ dig wireguard-tools ];
    text = ''
      ttl_default='3600'
      ttl_min='300'

      [[ "$PEER_ENDPOINT" =~ ^[^:]+ ]]
      domain="''${BASH_REMATCH[0]}"

      a=
      refresh=
      sleeper=

      trap 'refresh="✓"; [[ -n "$sleeper" ]] && kill "$sleeper" ||:' HUP

      while true; do
        refreshing="$refresh"
        refresh=
        response="$(dig +noall +answer "$domain" A ||:)"

        previous_a="$a"
        if [[ "$response" =~ [^[:space:]]+[[:blank:]]+([[:digit:]]+)[[:blank:]]+IN[[:blank:]]+A[[:blank:]]+([[:digit:].]+) ]]; then
          ttl="''${BASH_REMATCH[1]}"
          a="''${BASH_REMATCH[2]}"
        else
          ttl="$ttl_min"
          echo "Failed to resolve $domain: $response" >&2
        fi

        if [[ -n "$a" && -n "$previous_a" && "$a" != "$previous_a" ]]; then
          echo "Reresolved $domain: $previous_a → $a (TTL $ttl)" >&2
          wg set "$INTERFACE" peer "$PEER_PUBLIC_KEY" endpoint "$PEER_ENDPOINT"
        elif [[ -n "$a" && -n "$refreshing" ]]; then
          echo "Refreshed $domain: $a (TTL $ttl)" >&2
        fi

        if [[ -z "$refresh" ]]; then
          sleep "$(( ttl == 0 ? ttl_default : ttl < ttl_min ? ttl_min : ttl + 1 ))s" & sleeper=$!
          wait "$sleeper" ||:
          sleeper=
        fi
      done
    '';
  };
in
{
  options.host.wireguard = {
    ip = mkOption { type = str; };
    port = mkOption { type = int; };
    peers = mkOption {
      type = attrsOf (submodule {
        options = {
          ip = mkOption { type = str; };
          key = mkOption { type = str; };
          endpoint = mkOption { type = str; };
        };
      });
    };
  };

  config = {
    systemd.network = {
      enable = true;
      netdevs."90-wg0" = {
        netdevConfig = { Name = "wg0"; Kind = "wireguard"; };
        wireguardConfig.PrivateKeyFile = "/var/lib/wireguard/wg0.key";
        wireguardPeers = mapAttrsToList
          (_: peer: {
            AllowedIPs = [ "${peer.ip}/32" ];
            Endpoint = peer.endpoint;
            PublicKey = peer.key;
          })
          host.wireguard.peers;
      };
      networks."90-wg0" = { name = "wg0"; address = [ "${host.wireguard.ip}/24" ]; };
    };

    # Workaround for https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/6235
    networking.networkmanager.unmanaged = [ "wg0" ];

    networking.hosts = mapAttrs' (h: p: nameValuePair p.ip [ h ]) host.wireguard.peers;

    # Workaround for systemd/systemd#9911
    systemd.services = mapAttrs'
      (name: peer: nameValuePair "wireguard-reresolve-${name}" {
        wantedBy = [ "sys-subsystem-net-devices-wg0.device" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" "nss-lookup.target" ];
        unitConfig.StopWhenUnneeded = true;
        onFailure = [ "alert@%N.service" ];

        environment = {
          INTERFACE = "wg0";
          PEER_ENDPOINT = peer.endpoint;
          PEER_PUBLIC_KEY = peer.key;
        };

        serviceConfig = {
          SyslogIdentifier = "%N";

          ExecStart = getExe wireguard-reresolve;
          ExecReload = "${getExe' coreutils "kill"} -HUP $MAINPID";
        };
      })
      host.wireguard.peers;
  };
}
