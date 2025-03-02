{
  config,
  lib,
  pkgs,
  ...
}:
let

  inherit (lib)
    mkOption
    mkPackageOption
    types
    concatMapAttrs
    mkIf
    attrsToList
    ;
  cfg = config.repack.phantun;

  inherit (lib.data) node;
  inherit (config.networking) hostName;
  thisConn = (lib.conn { }).${hostName};
  thisNode = node.${hostName};

  connThrouTunnel = (
    lib.filterAttrs (
      k: _:
      let
        peerNode = node.${k};
        directConnect = (thisNode.nat && peerNode.nat) || (thisNode.censor == peerNode.censor);
      in
      !directConnect
    ) thisConn
  );

in

{
  disabledModules = [ "services/networking/phantun.nix" ];

  options = {

    # this module is inadequate
    repack.phantun = {
      mode = mkOption {
        type = types.addCheck types.str (s: s == "client" || s == "server") // {
          description = "either `client` or `server`";
        };
      };

      package = mkPackageOption pkgs "phantun" { };

      device = mkOption {
        type = types.str;
        default = "eth0";
      };
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services = concatMapAttrs (peerName: peerPort: {
      "phantun-${peerName}" = {
        description = "phantun to ${peerName} daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Environment = [ "RUST_LOG=debug" ];
          ExecStart =
            "${pkgs.phantun}/bin/${cfg.mode}"
            + " "
            + (lib.concatStringsSep " " (
              let
                serverRcvPort = (toString (peerPort + 1000));
                localWgListenAddr = "127.0.0.1:${toString peerPort}";
                peerNode = node.${peerName};
              in
              [
                "--local"

                (if (cfg.mode == "client") then localWgListenAddr else serverRcvPort)

                "--remote"

                (if (cfg.mode == "client") then node.${peerName}.addr + ":" + serverRcvPort else localWgListenAddr)

                "--tun-local"

                (
                  if (cfg.mode == "client") then
                    "192.168.200.${toString (peerNode.id + 1)}" # FIXME: > 9
                  else
                    "192.168.201.${toString (peerNode.id + 1)}"
                )

                "--tun-peer"

                (
                  if (cfg.mode == "client") then
                    "192.168.200.${toString (peerNode.id + 2)}" # FIXME: > 9
                  else
                    "192.168.201.${toString (peerNode.id + 2)}"
                )

                "--tun-local6"

                (
                  if (cfg.mode == "client") then
                    "fcc8::${toString (thisNode.id + 1)}"
                  else
                    "fcc9::${toString (peerNode.id + 1)}"
                )

                "--tun-peer6"

                (
                  if (cfg.mode == "client") then
                    "fcc8::${toString (thisNode.id + 2)}"
                  else
                    "fcc9::${toString (peerNode.id + 2)}"
                )

                "--tun"
                "tun-phan-${peerName}"
              ]
            ));
          CapabilityBoundingSet = [
            "CAP_NET_RAW"
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
          ];
          AmbientCapabilities = [
            "CAP_NET_RAW"
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
          ];
          Restart = "on-failure";
        };
      };
    }) connThrouTunnel;

    networking.firewall.allowedTCPPorts = mkIf (cfg.mode == "server") (
      map (i: i + 1000) (builtins.attrValues connThrouTunnel)
    );

    networking.nftables.ruleset = (
      lib.concatMapStrings (
        i:
        let
          peerNode = node.${i.name};
          peerPort = thisConn.${i.name};
          serverRcvPort = (toString (peerPort + 1000));
        in
        if (cfg.mode == "server") then
          ''
            table inet nat {
                chain prerouting {
                    type nat hook prerouting priority dstnat; policy accept;
                    iifname eth0 tcp dport ${serverRcvPort} dnat ip to 192.168.201.${toString (peerNode.id + 1)}
                    iifname eth0 tcp dport ${serverRcvPort} dnat ip6 to fcc9::${toString (peerNode.id + 1)}
                }
            }
          ''
        else
          ''
            table inet nat {
                chain postrouting {
                    type nat hook postrouting priority srcnat; policy accept;
                    iifname tun-phan-${i.name} oifname ${cfg.device} masquerade
                }
            }
          ''
      ) (attrsToList connThrouTunnel)
    );

  };
}
