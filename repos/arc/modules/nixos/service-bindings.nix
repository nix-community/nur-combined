let
  localaddr = {
    ipv4 = "127.0.0.1";
    ipv6 = "::1";
  };
  wildaddr = {
    ipv4 = "0.0.0.0";
    ipv6 = "::";
  };
  inherit (import ./bindings.nix) connectionModule;
  nginxDomainModule = { config, lib, ... }: with lib; {
    options = {
      nginx = {
        enable = mkEnableOption "nginx virtual host" // { default = true; };
        extraParameters = mkOption {
          type = with types; listOf str;
          default = [ ];
        };
      };
      bindings = mkOption {
        type = let
          domain = config;
          domainConfig = { config, ... }: {
            nginx = {
              enable = mkDefault domain.nginx.enable;
              inherit (domain.nginx) extraParameters;
            };
          };
        in with types; attrsOf (submodule [
          domainConfig
          bindNginxModule
        ]);
      };
    };
  };
  bindNginxModule = { lib, config, options, ... }: with lib; {
    options = {
      nginx = {
        enable = mkEnableOption "nginx virtual host" // { default = true; };
        extraParameters = mkOption {
          type = with types; listOf str;
          default = [ ];
        };
        out = {
          listen = mkOption {
            type = types.unspecified;
            readOnly = true;
          };
        };
      };
    };
    config = {
      nginx.out.listen = {
        addr =
          if config.ipProtocol == "unix" then "unix:" + config.address
          else if config.isWildcard then (if config.ipProtocol == "ipv6" then "[${wildaddr.ipv6}]" else wildaddr.ipv4)
          else if config.isLocalhost then (if config.ipProtocol == "ipv6" then "[${localaddr.ipv6}]" else localaddr.ipv4)
          else if config.ipProtocol == "ipv6" && config.isAddress then "[${config.address}]"
          else config.address;
        inherit (config) port;
        inherit (config.nginx) extraParameters;
        ssl = config.protocol == "https";
      };
    };
  };
  nginxModuleVirtualHostLocation = { commonRoot, config, options, lib, ... }: with lib; {
    options = {
      proxyPassConnection = mkOption {
        type = types.submodule [
          connectionModule
          ({ config, ... }: {
            options.enable = mkEnableOption "proxyPass" // { default = true; };
            config.isLocal = mkDefault (commonRoot config.binding);
          })
        ];
      };
    };
    config = mkIf (options.proxyPassConnection.isDefined && config.proxyPassConnection.enable) {
      proxyPass = config.proxyPassConnection.url;
    };
  };
  nginxModuleVirtualHost = { commonRoot, config, lib, ... }: with lib; {
    options = {
      locations = mkOption {
        type = with types; attrsOf (submodule [
          nginxModuleVirtualHostLocation commonRoot.propagate
        ]);
      };
    };
  };
  serviceNginx = { commonRoot, config, lib, ... }: with lib; {
    options = {
      services.nginx.virtualHosts = mkOption {
        type = with types; attrsOf (submodule [
          nginxModuleVirtualHost commonRoot.propagate
        ]);
      };
      networking.domains = mkOption {
        type = with types; attrsOf (submodule nginxDomainModule);
      };
    };
    config.services.nginx.virtualHosts = let
      enableDomainFilter = _: d: d.enable && (filterAttrs enableBindingFilter d.bindings) != { };
      enableBindingFilter = _: b: b.enable && b.nginx.enable;
      enabledDomains = filterAttrs enableDomainFilter config.networking.domains;
      mapBindingListen = _: binding: binding.nginx.out.listen;
      mapDomain = name: domain: {
        ${domain.key} = { ... }: {
          config = mkMerge [ {
            serverName = mkDefault domain.fqdn;
            listen = mapAttrsToList mapBindingListen (filterAttrs enableBindingFilter domain.bindings);
          } (mkIf domain.ssl.enable {
            sslCertificate = mkDefault domain.ssl.certPath;
            sslCertificateKey = mkDefault domain.ssl.keyPath;
            #onlySSL = all (binding: binding.protocol == "https") (attrValues (filterAttrs enableBindingFilter domain.bindings));
            onlySSL = true; # must be set if ssl exists at all so...
          }) ];
        };
      };
    in mkMerge (mapAttrsToList mapDomain enabledDomains);
  };
  matrixAppserviceModule = { config, options, lib, ... }: with lib; {
    options = {
      binding = mkOption {
        type = types.unspecified;
      };
      hasBinding = mkOption {
        type = types.bool;
        default = options.binding.isDefined;
      };
      connection = mkOption {
        type = types.submodule connectionModule;
      };
    };
    config = {
      connection = mkIf config.hasBinding {
        binding = config.binding;
      };
      registration = mkIf config.hasBinding {
        port = mkDefault config.binding.port;
        host = mkDefault config.connection.host;
        url = mkDefault config.connection.url;
      };
    } // optionalAttrs (options ? port) {
      port = mkIf config.hasBinding (mkDefault config.binding.port);
    } // optionalAttrs (options ? appservice.port) {
      appservice = mkIf config.hasBinding {
        hostname = mkDefault config.binding.out.address;
        port = mkDefault config.binding.port;
      };
    } // optionalAttrs (options ? bridge.port) {
      bridge = mkIf config.hasBinding {
        bindAddress = mkDefault config.binding.out.address;
        port = mkDefault config.binding.port;
      };
    } // optionalAttrs (options ? listen.port) {
      listen = mkIf config.hasBinding {
        address = mkDefault config.binding.out.address;
        port = mkDefault config.binding.port;
      };
    } // optionalAttrs (options ? host.port) {
      host = mkIf config.hasBinding {
        hostname = mkDefault config.binding.out.address;
        port = mkDefault config.binding.port;
      };
    };
  };
  serviceMatrixAppservices = { config, lib, ... }: with lib; {
    options.services.matrix-appservices = mkOption {
      type = with types; attrsOf (submodule matrixAppserviceModule);
    };
    config.networking.enabledBindings = mkMerge (mapAttrsToList (_: appservice:
      mkIf (appservice.enable && appservice.hasBinding) [ appservice.binding ]
    ) config.services.matrix-appservices);
  };
  matrixSynapseListener = { config, options, lib, ... }: with lib; {
    options = {
      binding = mkOption {
        type = types.unspecified;
      };
      hasBinding = mkOption {
        type = types.bool;
        default = options.binding.isDefined;
      };
      port = mkOption { type = types.port; };
      bind_addresses = mkOption { type = with types; listOf str; };
      type = mkOption { type = types.str; default = "http"; };
      tls = mkOption { type = types.bool; default = true; };
      x_forwarded = mkOption { type = types.bool; default = false; };
      resources = mkOption { type = with types; listOf attrs; };
    };
    config = mkIf config.hasBinding {
      port = mkDefault config.binding.port;
      bind_addresses = singleton config.binding.out.address;
    };
  };
  serviceMatrixSynapse = { config, options, lib, ... }: with lib; let
    opts = options.services.matrix-synapse;
    cfg = config.services.matrix-synapse;
  in {
    options.services.matrix-synapse = {
      domains = {
        discovery = mkOption {
          type = types.unspecified;
        };
        public = mkOption {
          type = types.unspecified;
        };
        listeners = mkOption {
          type = with types; attrsOf (submodule matrixSynapseListener);
          default = { };
        };
      };
    };
    config = {
      services.matrix-synapse = {
        settings = {
          server_name = mkIf opts.domains.discovery.isDefined (mkDefault cfg.domains.discovery.fqdn);
          public_baseurl = mkIf opts.domains.public.isDefined (mkDefault cfg.domains.public.url);
          listeners = mkIf (cfg.domains.listeners != { }) (mapAttrsToList (_: listener: {
            inherit (listener) port bind_addresses type tls x_forwarded resources;
          }) cfg.domains.listeners);
        };
      };
      networking.enabledBindings = mkIf cfg.enable (mkMerge (mapAttrsToList (_: l:
        mkIf l.hasBinding [ l.binding ]
      ) cfg.domains.listeners));
    };
  };
  serviceVaultwarden = { config, options, lib, ... }: with lib; let
    opts = options.services.vaultwarden;
    cfg = config.services.vaultwarden;
  in {
    options.services.vaultwarden = {
      domain = mkOption {
        type = types.unspecified;
      };
      bindings = {
        rocket = mkOption {
          type = types.unspecified;
        };
        websocket = mkOption {
          type = types.unspecified;
        };
      };
    };
    config = {
      services.vaultwarden.config = {
        domain = mkIf opts.domain.isDefined (mkDefault cfg.domain.url);
        rocketPort = mkIf opts.bindings.rocket.isDefined (mkDefault cfg.bindings.rocket.port);
        rocketAddress = mkIf opts.bindings.rocket.isDefined (mkDefault cfg.bindings.rocket.out.address);
        websocketPort = mkIf opts.bindings.websocket.isDefined (mkDefault cfg.bindings.websocket.port);
        websocketAddress = mkIf opts.bindings.websocket.isDefined (mkDefault cfg.bindings.websocket.out.address);
      };
      networking.enabledBindings = mkMerge [
        (mkIf (cfg.enable && opts.bindings.rocket.isDefined) [ cfg.bindings.rocket ])
        (mkIf (cfg.enable && opts.bindings.websocket.isDefined) [ cfg.bindings.websocket ])
      ];
    };
  };
  serviceTaskserver = { config, options, lib, ... }: with lib; let
    opts = options.services.taskserver;
    cfg = config.services.taskserver;
    binding = cfg.domain.bindings.https4;
  in {
    options.services.taskserver = {
      domain = mkOption {
        type = types.unspecified;
      };
    };
    config = {
      services.taskserver = mkIf opts.domain.isDefined {
        fqdn = mkDefault cfg.domain.fqdn;
        listenPort = binding.port;
        listenHost = binding.out.address;
        pki.manual = mkIf cfg.domain.ssl.enable {
          server = {
            key = cfg.domain.ssl.keyPath;
            cert = cfg.domain.ssl.certPath;
          };
          #ca.cert = n/a
        };
      };
      #networking.enabledBindings = mkIf (cfg.enable && opts.domain.isDefined) [ binding ];
    };
  };
  prosodyMuc = { config, options, lib, ... }: with lib; {
    options = {
      domainRef = mkOption {
        type = types.unspecified;
      };
    };
    config = mkIf options.domainRef.isDefined {
      domain = mkDefault config.domainRef.fqdn;
    };
  };
  serviceProsody = { config, options, lib, ... }: with lib; {
    options.services.prosody = {
      bindings = {
        c2s = mkOption {
          type = types.unspecified;
        };
        s2s = mkOption {
          type = types.unspecified;
        };
        web = mkOption {
          type = types.unspecified;
        };
      };
      domains = {
        web = mkOption {
          type = types.unspecified;
        };
        virtual = mkOption {
          type = types.listOf types.unspecified;
        };
        components = mkOption {
          type = types.attrsOf types.unspecified;
        };
      };
      muc = mkOption {
        type = with types; listOf (submodule [
          prosodyMuc
          ({ ... }: {
            config.domainRef = mkIf (options.services.prosody.domains.components.isDefined && config.services.prosody.domains.components ? muc) (
              mkDefault config.services.prosody.domains.components.muc
            );
          })
        ]);
      };
    };
    config.services.prosody = let
      opts = options.services.prosody;
      cfg = config.services.prosody;
    in {
      virtualHosts = mkIf opts.domains.virtual.isDefined (
        listToAttrs (map (domain: nameValuePair domain.fqdn {
          enabled = domain.enable;
          domain = mkDefault domain.fqdn;
          ssl = mkIf domain.ssl.enable {
            key = mkDefault domain.ssl.keyPath;
            cert = mkDefault domain.ssl.certPath;
          };
        }) cfg.domains.virtual)
      );
      uploadHttp.domain = mkIf (opts.domains.components.isDefined && cfg.domains.components ? upload) (
        mkDefault cfg.domains.components.upload.fqdn
      );
      httpPorts = mkMerge [
        (mkIf opts.bindings.web.isDefined [ cfg.bindings.web.port ])
        (mkIf (opts.domains.web.isDefined && !cfg.domains.web.nginx.enable) (
          mapAttrsToList (_: b: b.port) (
            filterAttrs (_: b: b.enable && b.protocol == "http") cfg.domains.web.bindings
          )
        ))
      ];
      httpsPorts = mkIf (opts.domains.web.isDefined && !cfg.domains.web.nginx.enable) (
        mapAttrsToList (_: b: b.port) (
          filterAttrs (_: b: b.enable && b.protocol == "https") cfg.domains.web.bindings
        )
      );
      extraConfig = mkMerge [
        (mkIf opts.bindings.c2s.isDefined ''
          c2s_ports = { ${toString cfg.bindings.c2s.port} }
        '')
        (mkIf opts.bindings.s2s.isDefined ''
          s2s_ports = { ${toString cfg.bindings.s2s.port} }
        '')
        (mkIf (opts.domains.components.isDefined && cfg.domains.components != { }) ''
          component_ports = { ${concatMapStringsSep ", " toString (unique (mapAttrsToList (_: d: d.bindings.http4.port) cfg.domains.components))} }
        '') # TODO: component_interface = "0.0.0.0" ?
        (mkIf opts.domains.web.isDefined ''
          http_host = "${cfg.domains.web.fqdn}"
          http_external_url = "${cfg.domains.web.url}"
        '')
        (mkIf (opts.domains.web.isDefined && cfg.domains.web.nginx.enable) ''
          trusted_proxies = { "127.0.0.1", "::1", }
        '')
      ];
    };
  };
  nixosModule = { commonRoot, lib, ... }: with lib; {
    imports = [
      ./common-root.nix
    ];

    options = {
      networking = {
        bindings = mkOption {
          type = with types; attrsOf (submodule commonRoot.tag);
        };
        domains = mkOption {
          type = with types; attrsOf (submodule commonRoot.tag);
        };
      };
    };
  };
in {
  common = nixosModule;
  prosody = serviceProsody;
  nginx = serviceNginx;
  taskserver = serviceTaskserver;
  vaultwarden = serviceVaultwarden;
  matrix-synapse = serviceMatrixSynapse;
  matrix-appservices = serviceMatrixAppservices;

  __functor = self: { ... }: {
    imports = with self; [
      common
      prosody
      nginx
      taskserver
      vaultwarden
      matrix-synapse
      matrix-appservices
    ];
  };
}
