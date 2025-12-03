{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  outerConfig = config;
  ip4Segment = "[0-9]{1,3}";
  ip4Address = types.addCheck (types.strMatching (
    lib.concatStringsSep "\\." [
      ip4Segment
      ip4Segment
      ip4Segment
      ip4Segment
    ]
  )) (s: lib.all (p: (lib.toInt p) < 255) (lib.splitString "." s));
  # Note: This accepts plenty of strings that aren't valid ipv6 addresses, this is just to catch when you accidentally put an ipv4 or something else in
  ip6Address = types.strMatching "([a-fA-F0-9]{4}::?){1,7}[a-fA-F0-9]{4}";
  ipAddress = types.either ip4Address ip6Address;
in
{
  #       vacu.proxiedServices.habitat
  options.vacu.proxiedServices = mkOption {
    default = { };
    type = types.attrsOf (
      types.submodule (
        { name, config, ... }:
        {
          options = {
            enable = mkOption {
              type = types.bool;
              default = false;
            };

            name = mkOption {
              default = name;
              type = types.str;
            };

            fromContainer = mkOption {
              default = null;
              type = types.nullOr types.str;
            };

            port = mkOption { type = types.port; };

            ipAddress = mkOption { type = ipAddress; };

            unixSocket = mkOption {
              type = types.nullOr types.path;
              default = null;
            };

            domain = mkOption { type = types.str; };

            forwardFor = mkOption {
              type = types.bool;
              default = false;
            };

            maxConnections = mkOption {
              type = types.int;
              default = 500;
            };

            useSSL = mkOption {
              type = types.bool;
              default = false;
            };

            upstreamAddress = mkOption {
              type = types.str;
              internal = true;
              readOnly = true;
            };
          };

          config = lib.mkMerge [
            (lib.mkIf (config.fromContainer != null) {
              ipAddress = outerConfig.containers.${config.fromContainer}.localAddress;
            })
            {
              upstreamAddress =
                if config.unixSocket != null then
                  "unix@${config.unixSocket}"
                else
                  "${config.name}:${toString config.port}";
            }
          ];
        }
      )
    );
  };
}
