extraLibs:
{
  ...
}:
{
  perSystem =
    {
      lib,
      ...
    }:
    {
      topology.modules = [
        (
          { config, ... }:
          let
            inherit (config.lib.topology)
              mkInternet
              mkConnection
              mkRouter
              ;
          in
          {
            renderers.elk.overviews = {
              networks.enable = true;
              services.enable = false;
            };

            nodes =
              (lib.listToAttrs (
                map (n: {
                  name = "internet-${n}";
                  value = mkInternet {
                    connections = mkConnection n "eno1";
                  };
                }) ((builtins.attrNames (lib.filterAttrs (_: v: !v.nat) extraLibs.data.node)) ++ [ "router" ])
              ))
              // (lib.listToAttrs (
                map (n: {
                  name = n;
                  value = {
                    interfaces = lib.concatMapAttrs (target: _: {
                      "wg-${target}" = {
                        virtual = true;
                        physicalConnections = [
                          {
                            node = target;
                            interface = "wg-${n}";
                          }
                        ];
                      };
                    }) (extraLibs.conn { }).${n};

                  };
                }) (builtins.attrNames extraLibs.data.node)
              ))
              // {
                router = mkRouter "MartinRouterKing" {
                  info = "home router";
                  interfaceGroups = [
                    [
                      "eth1"
                      "eth2"
                      "eth3"
                    ]
                    [ "eth0" ]
                  ];
                  connections.eth1 = mkConnection "hastur" "eth0";
                  connections.eth2 = mkConnection "eihort" "eth0";
                  connections.eth3 = mkConnection "kaambl" "wlan0";
                };
              };
            networks.wg-overlay = {
              name = "wireguard overlay (babel)";
              cidrv6 = "fdcc::0/64";
            };
            networks.nat = {
              name = "NAT";
              cidrv4 = "192.168.1.0/24";
            };
          }
        )
      ];

    };
}
