{ lib, pkgs, config, name
, nixosConfig, enableIPv6
, ... }: with lib; {
  options = {
    enable = mkEnableOption "domain ${name}";
    enableIPv6 = mkEnableOption "ipv6" // {
      default = nixosConfig.networking.enableIPv6 or enableIPv6;
    };
    ssl = mkOption {
      type = types.submodule [
        ./ssl.nix
        ({ ... }: {
          config = {
            fqdn = mkDefault config.fqdn;
            _module.args = {
              inherit pkgs;
            };
          };
        })
      ];
    };
    sslOnly = mkOption {
      type = types.bool;
      default = false;
    };
    fqdn = mkOption {
      type = types.str;
      default = optionalString (config.domain != null) "${config.domain}." + config.zone;
    };
    zone = mkOption {
      type = types.str;
    };
    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    key = mkOption {
      type = types.str;
      default = config.url;
    };
    bindings = mkOption {
      type = let
        host = config.fqdn;
        defaultEnable = {
          ipv6 = config.enableIPv6;
        };
        domain = config;
        domainConfig = { config, ... }: {
          options.enable = mkEnableOption "binding" // { default = defaultEnable.${config.ipProtocol} or true; };
          config = {
            address = mkDefault "*";
            #inherit host;
          };
        };
        bindType = types.submodule [
          ./binding.nix
          domainConfig
        ];
      in types.attrsOf bindType;
      default = { };
    };
    connections = mkOption {
      type = with types; attrsOf (submodule ./connection.nix);
    };
    defaultConnection = mkOption {
      type = types.unspecified;
    };
    url = mkOption {
      type = types.str;
    };
    out = {
      enabledBindings = mkOption {
        type = with types; attrsOf unspecified;
      };
    };
  };
  config = {
    ssl = { };
    bindings = {
      http4 = {
        enable = mkIf (config.sslOnly && config.ssl.enable) (mkDefault false);
        ipProtocol = mkDefault "ipv4";
      };
      http6 = {
        enable = mkIf (config.sslOnly && config.ssl.enable) (mkDefault false);
        ipProtocol = mkDefault "ipv6";
        port = mkDefault config.bindings.http4.port;
      };
      https4 = {
        enable = mkIf (!config.ssl.enable) (mkDefault false);
        ipProtocol = mkDefault "ipv4";
        protocol = mkDefault "https";
      };
      https6 = {
        enable = mkIf (!config.ssl.enable) (mkDefault false);
        ipProtocol = mkDefault "ipv6";
        protocol = mkDefault "https";
        port = mkDefault config.bindings.https4.port;
      };
    };
    connections = mapAttrs (_: binding: {
      host = config.fqdn;
      isLocal = false;
      inherit binding;
    }) config.out.enabledBindings;
    defaultConnection = let
      sorted = sort (a: b: a.binding.protocol == "https") (attrValues config.connections);
    in mkIf (config.connections != { }) (head sorted);
    url = config.defaultConnection.url;
    out = {
      enabledBindings = filterAttrs (_: b: b.enable) config.bindings;
    };
  };
}
