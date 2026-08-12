{ config, lib, ... }:

let
  inherit (lib) mkOption mkEnableOption types;

  MIN_RANGE = 1024;
  MAX_RANGE = 49151;

  isPortValid = port: if lib.isInt port then (port > MIN_RANGE) && (port < MAX_RANGE) else false;

  portFromKey =
    key:
    let
      hashed = builtins.hashString "md5" key;
      getPort =
        partial:
        let
          parsed = builtins.fromTOML "v=0x${lib.substring 0 4 partial}";
          port = parsed.v;
          recursiveStep = getPort (lib.substring 4 (lib.stringLength partial) partial);
        in
        if (isPortValid port) then port else recursiveStep;
    in
    getPort hashed;

  cfg = config.networking.ports;
in
{
  options = {
    networking.ports = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          {
            name,
            config,
            options,
            ...
          }:
          {
            options = {
              enable = mkEnableOption "port";
              key = mkOption {
                description = lib.mdDoc "Key hashed to derivate the port";
                type = types.str;
                default = name;
              };
              port = mkOption {
                description = lib.mdDoc "Port allocated";
                type = types.port;
                default = portFromKey config.key;
              };
            };
          }
        )
      );
    };

    debug = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };
  };

  config = {
    # networking.ports.a.port = 69;
    # networking.ports.x.port = 2048;
    # networking.ports.y.port = 2048;

    assertions =
      let
        portNames = lib.attrNames cfg;
        # sort by port number
        cmp = a: b: cfg.${a}.port < cfg.${b}.port;
        sorted = lib.sort cmp portNames;

        pairs =
          lst:
          let
            ltail = lib.tail lst;
            a = lib.head lst;
            b = lib.head ltail;
            len = lib.length lst;
          in
          if len < 2 then [ ] else [ { inherit a b; } ] ++ (pairs ltail);

        pairsSorted = pairs sorted;

        assertsValid = map (item: {
          assertion = isPortValid cfg.${item}.port;
          message = "The port for '${item}' (${toString cfg.${item}.port}) is invalid. If this port is derived from another to reserve a port range please change the key of the first port. If it's explicitly set then make sure it's between the range of ${toString MIN_RANGE} and ${toString MAX_RANGE}";
        }) sorted;

        assertsConflict = map (pair: {
          assertion = cfg.${pair.a}.port != cfg.${pair.b}.port;
          message = "The ports for '${pair.a}' and '${pair.b}' are the same (${toString cfg.${pair.a}.port}). This may happen because either one or both of them are explicitly set to a value or a hash collision from the key value.";
        }) pairsSorted;
      in
      assertsConflict ++ assertsValid;
  };
}
