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
              ;
          in
          {
            nodes =
              (lib.listToAttrs (
                map (n: {
                  name = "internet-${n}";
                  value = mkInternet {
                    connections = mkConnection n "eth0";
                  };
                }) (lib.filter (n: n != "kaambl") (builtins.attrNames extraLibs.data.meta))
              ))
              // (lib.listToAttrs (
                map (n: {
                  name = n;
                  value = {
                    interfaces = lib.concatMapAttrs (target: _: {
                      "wg-${target}" = {
                        physicalConnections = [
                          {
                            node = target;
                            interface = "wg-${n}";
                          }
                        ];
                      };
                    }) (extraLibs.conn { }).${n};
                    # renderer.hidePhysicalConnections = false;

                  };
                }) (builtins.attrNames extraLibs.data.meta)
              ))
              // {
                internet-kaambl = mkInternet {
                  connections = mkConnection "kaambl" "wlan0";
                };
              };
            networks.inner = {
              name = "wireguard overlay (babel)";
              cidrv6 = "fdcc::0/64";
            };
          }
        )
      ];

    };
}
