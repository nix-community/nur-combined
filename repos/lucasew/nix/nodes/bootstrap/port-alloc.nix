{ config, lib, ... }:

let
  inherit (builtins) removeAttrs;
  inherit (lib) mkOption types submodule literalExpression mdDoc mkDefault attrNames foldl' mapAttrs mkEnableOption attrValues;
in

{
  options.networking.ports = mkOption {
    default = {};

    example = literalExpression ''{
      {
        app.enable = true;
      }
    }'';

    description = "Build time port allocations for services that are only used internally";

    apply = ports: lib.pipe ports [
      (attrNames) # gets only the names of the ports
      (foldl' (x: y: x // {
        "${y}" = (ports.${y}) // {
          port = x._port;
        };
        _port = x._port - 1;
      })  {_port = 65534; }) # gets the count down of the ports
      (x: removeAttrs x ["_port"]) # removes the utility _port entity
    ];

    type = types.attrsOf (types.submodule ({ name, config, options, ... }: {
      options = {
        enable = mkEnableOption "Enable automatic port allocation for service ${name}";
        port = mkOption {
          description = "Allocated port for service ${name}";
          type = types.nullOr types.port;
        };
      };
      }));
  };

  config.environment.etc = lib.pipe config.networking.ports [
    (attrNames)
    (foldl' (x: y: x // {
      "ports/${y}" = {
        inherit (config.networking.ports.${y}) enable;
        text = toString config.networking.ports.${y}.port;
      };
    }) {})
  ];
}
