let
  localaddr = {
    ipv4 = "127.0.0.1";
    ipv6 = "::1";
  };
  wildaddr = {
    ipv4 = "0.0.0.0";
    ipv6 = "::";
  };
  connectionModule = { lib, config, options, ... }: with lib; {
    options = {
      url = mkOption {
        type = types.str;
      };
      host = mkOption {
        type = types.str;
      };
      extraUrlArgs = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
      isLocal = mkOption {
        type = types.bool;
        default = config.binding.isLocalhost;
      };
      binding = mkOption {
        type = types.unspecified;
      };
    };
    config = let
      url = genUrl ({
        inherit (config) host;
        inherit (config.binding) protocol port;
        isUrl = config.binding.ipProtocol != "unix";
      } // config.extraUrlArgs);
      host = if config.binding.isLocal && (config.binding.isWildcard || !config.binding.isAddress)
        then localaddr.${config.binding.ipProtocol}
        else config.address;
    in {
      url = mkOptionDefault (if config.binding.ipProtocol == "unix" then config.address else url);
      host = mkOptionDefault host;
    };
  };
  bindModule = { lib, config, options, ... }: with lib; {
    options = {
      protocol = mkOption {
        type = types.str;
        default = "http";
      };
      port = mkOption {
        type = types.port;
      };
      address = mkOption {
        type = with types; either (enum [ "localhost" "*" ]) str;
        default = "localhost";
      };
      ipProtocol = mkOption {
        type = types.enum [ "ipv4" "ipv6" "unix" ];
      };
      transport = mkOption {
        type = types.enum [ "tcp" "udp" ];
        default = "tcp";
      };
      isAddress = mkOption {
        type = types.bool;
        readOnly = true;
      };
      isLocalhost = mkOption {
        type = types.bool;
        readOnly = true;
      };
      isWildcard = mkOption {
        type = types.bool;
        readOnly = true;
      };
      isLocal = mkOption {
        type = types.bool;
        readOnly = true;
      };
      isExternal = mkOption {
        type = types.bool;
        readOnly = true;
      };
      out = {
        address = mkOption {
          type = types.str;
          readOnly = true;
        };
      };
      firewall = {
        open = mkOption {
          type = types.bool;
          default = config.isExternal;
        };
        interfaces = mkOption {
          type = with types; nullOr (listOf str);
          default = null; # TODO: find interface with address?
        };
      };
    };
    config = let
      isUnix = config.ipProtocol == "unix";
      isIpv4 = builtins.match ''[0-9]+\.[0-9.]*'' config.address != null;
      isIpv6 = hasInfix ":" config.address;
      ip = if hasPrefix "/" config.address then "unix"
        else if isIpv6 then "ipv6"
        else "ipv4";
      port = {
        http = 80;
        https = 443;
      }.${config.protocol} or (throw "Unknown port for protocol ${config.protocol}");
      isLocalhost = {
        ipv4 = hasPrefix "127." config.address;
        ipv6 = config.address == "::1";
        unix = true;
      };
    in {
      protocol = mkIf isUnix "unix";
      ipProtocol = mkOptionDefault ip;
      port = mkOptionDefault port;
      isAddress = isIpv4 || isIpv6 || isUnix;
      isLocalhost = config.address == "localhost" || isLocalhost.${config.ipProtocol} or false;
      isWildcard = config.address == "*";
      isLocal = config.isLocalhost || config.isWildcard;
      isExternal = config.isWildcard || !config.isLocalhost;
      out = {
        address = if config.address == "*" then wildaddr.${config.ipProtocol}
          else if config.address == "localhost" then localaddr.${config.ipProtocol}
          else config.address;
      };
    };
  };
  bindServiceModule = { lib, config, ... }: with lib; {
    options = {
      provides = mkOption {
        type = types.listOf types.str;
      };
    };
  };
  sslModule = { lib, config, options, pkgs, name, ... }: with lib; {
    options = {
      enable = mkEnableOption "ssl" // { default = options.keyPath.isDefined; };
      keyPath = mkOption {
        type = types.path;
      };
      pem = mkOption {
        type = types.str;
      };
      certPath = mkOption {
        type = types.path;
        default = pkgs.writeText "${config.fqdn}.pem" config.pem;
      };
      fqdn = mkOption {
        type = types.str;
        default = name;
      };
      fqdnAliases = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };
  domainModule = { enableIPv6, lib, pkgs, config, name, ... }: with lib; {
    options = {
      enable = mkEnableOption "domain ${name}";
      enableIPv6 = mkEnableOption "ipv6" // { default = enableIPv6; };
      ssl = mkOption {
        type = types.submodule [
          sslModule
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
            bindModule
            domainConfig
          ];
        in types.attrsOf bindType;
        default = { };
      };
      connections = mkOption {
        type = with types; attrsOf (submodule connectionModule);
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
  };
  nixosModule = { commonRoot, pkgs, config, options, lib, ... }: with lib; {
    imports = [
      ./common-root.nix
    ];

    options = {
      networking = {
        enabledBindings = mkOption {
          type = with types; listOf unspecified;
          default = [ ];
        };
        bindings = mkOption {
          type = with types; attrsOf (submodule [
            bindModule
            commonRoot.tag
          ]);
        };
        domains = mkOption {
          type = with types; attrsOf (submodule [
            domainModule
            commonRoot.tag
            ({ ... }: {
              config._module.args = {
                inherit pkgs;
                inherit (config.networking) enableIPv6;
              };
            })
          ]);
        };
      };
    };
    config = {
      networking = {
        bindings = { };
        domains = { };
        enabledBindings = let
          enabledDomains = filterAttrs (_: d: d.enable) config.networking.domains;
          enabledBindings = domain: filterAttrs (_: b: b.enable) domain.bindings;
          mapDomain = _: domain: attrValues (enabledBindings domain);
        in mkMerge (mapAttrsToList mapDomain enabledDomains);
      };
      networking.firewall = let
        externalBindings = filter (binding: binding.firewall.open) config.networking.enabledBindings;
        public' = partition (binding: binding.firewall.interfaces == null) externalBindings;
        public = public'.right;
        interfaces'' = concatMap (binding: map (interface: nameValuePair interface binding) binding.firewall.interfaces) public'.wrong;
        interfaces' = groupBy (b: b.name) interfaces'';
        interfaces = mapAttrs (_: map ({ name, value }: value)) interfaces';
        mapToAllowed = bindings: let
          tcp = partition (b: b.transport == "tcp") bindings;
        in {
          allowedTCPPorts = map (binding: binding.port) tcp.right;
          allowedUDPPorts = map (binding: binding.port) tcp.wrong;
        };
      in mapToAllowed public // {
        interfaces = mapAttrs (_: mapToAllowed) interfaces;
      };
      lib.arc = {
        inherit (ty) domainType bindType;
      };
    };
  };
in {
  inherit bindModule domainModule connectionModule;

  services = import ./service-bindings.nix;

  __functor = self: nixosModule;
}
