{ nixpkgs }:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  inherit (pkgs) lib;
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-http.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        {
          networking.hostName = "fixture";
          system.stateVersion = "26.05";
          realm = {
            enable = true;
            spire.httpAttestation.trustHttpTransport = true;
            serviceDiscovery = {
              enable = true;
              address = "fdcc::3";
              # Endpoints for both proxy sources: the Internet proxy and the
              # internal HTTPS gateway. Without one catalog entry per egress
              # service the generated clients cannot pick a destination.
              catalog.eihort = {
                https-fixture = {
                  unit = "realm-ingress-caddy-eihort-https.service";
                  address = "fdcc::9";
                  port = 443;
                  serverID = "spiffe://nyaw.xyz/service/caddy-eihort";
                };
                internet-proxy = {
                  unit = "realm-ingress-caddy-internet.service";
                  address = "fdcc::9";
                  port = 13128;
                  serverID = "spiffe://nyaw.xyz/service/internet";
                };
              };
            };
            http.gateways.eihort = {
              hosts = [
                "oidc.nyaw.xyz"
                "s3.nyaw.xyz"
              ];
              service = "https-fixture";
              verifyID = "spiffe://nyaw.xyz/service/caddy-eihort";
            };
            workloads = {
              sender = {
                http = {
                  internet = true;
                  gateway = {
                    ref = "eihort";
                    resolveHosts = [ "oidc.nyaw.xyz" ];
                  };
                };
                isolation.hosts = {
                  "box.nyaw.xyz" = "127.0.0.1";
                  "smtp.nyaw.xyz" = "127.0.0.1";
                };
              };
              # No HTTP access at all; the HTTP module must leave it untouched.
              plain = { };
              # Declares HTTP access but is disabled; it must create no units.
              disabled = {
                enable = false;
                http = {
                  internet = true;
                  gateway = {
                    ref = "eihort";
                    resolveHosts = [ "oidc.nyaw.xyz" ];
                  };
                };
              };
            };
          };
          systemd.services.sender.serviceConfig = {
            User = "sender";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
          systemd.services.plain.serviceConfig = {
            User = "plain";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
          systemd.services.disabled.serviceConfig = {
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
        }
      ]
      ++ extra;
    }).config;
  multipleHosts = evaluate [
    {
      realm.workloads.sender.http.gateway.resolveHosts = lib.mkForce [
        "oidc.nyaw.xyz"
        "s3.nyaw.xyz"
      ];
    }
  ];
  cfg = evaluate [ ];
  localGateway = evaluate [
    ../nixosModules/realm-observability.nix
    (import ../mod/realm-internet.nix).flake.modules.nixos.realm-internet
    (
      { config, ... }:
      {
        realm.serviceDiscovery.catalog.fixture = config.realm.serviceDiscovery.publish;
        realm.workloads.manual.egress.internet.service = "internet-proxy";
        realm.workloads.remote.egress.internet = {
          service = "internet-proxy";
          node = "eihort";
        };
      }
    )
  ];
  realmAssertions =
    c: builtins.filter (a: !a.assertion && lib.hasPrefix "realm" a.message) c.assertions;
  rejected = c: lib.any (a: !a.assertion) (realmAssertions c);
  expectedNoProxy = "localhost,127.0.0.1,::1,box.nyaw.xyz,oidc.nyaw.xyz,smtp.nyaw.xyz";
  proxyVariables = [
    "NO_PROXY"
    "no_proxy"
    "HTTP_PROXY"
    "HTTPS_PROXY"
    "http_proxy"
    "https_proxy"
  ];
  # systemd adds a default PATH, so only the proxy variables say whether the
  # HTTP module touched a unit.
  proxyEnvironment = env: lib.filterAttrs (key: _: builtins.elem key proxyVariables) env;
  gateway = {
    hosts = [
      "oidc.nyaw.xyz"
      "s3.nyaw.xyz"
    ];
    service = "https-fixture";
    verifyID = "spiffe://nyaw.xyz/service/caddy-eihort";
  };
  # A name that no gateway serves.
  unknownDomain = evaluate [
    { realm.workloads.sender.http.gateway.resolveHosts = lib.mkForce [ "unknown.nyaw.xyz" ]; }
  ];
  # An explicit gateway reference disambiguates shared hostnames.
  sharedDomain = evaluate [
    {
      realm.http.gateways.second = gateway // {
        hosts = [ "oidc.nyaw.xyz" ];
      };
    }
  ];
  # Aliases must belong to the explicitly selected gateway.
  wrongGateway = evaluate [
    {
      realm.http.gateways.mail = gateway // {
        hosts = [ "mail.nyaw.xyz" ];
      };
      realm.workloads.sender.http.gateway.resolveHosts = lib.mkForce [
        "oidc.nyaw.xyz"
        "mail.nyaw.xyz"
      ];
    }
  ];
  missingReference = evaluate [
    { realm.workloads.sender.http.gateway.ref = lib.mkForce null; }
  ];
  duplicatePort = evaluate [
    {
      realm.workloads.sender.egress.other = {
        service = "https-fixture";
        verifyID = gateway.verifyID;
        localPort = 443;
      };
    }
  ];
  containerRuntime = evaluate [ { realm.workloads.sender.runtime = "container"; } ];
  noPrivateNetwork = evaluate [ { realm.workloads.sender.isolation.privateNetwork = false; } ];
  httpUnitsOf =
    name:
    builtins.filter (n: lib.hasPrefix "realm" n && lib.hasInfix name n) (
      builtins.attrNames cfg.systemd.services
      ++ builtins.attrNames cfg.systemd.sockets
      ++ builtins.attrNames cfg.realm.spire.registrations
    );
in
lib.runTests {
  testLocalGatewaySupportsMultiplePublishers = {
    expr = realmAssertions localGateway;
    expected = [ ];
  };
  testAutomaticAndManualInternetRoutesUseLocalGateway = {
    expr = map (name: localGateway.realm.workloads.${name}.egress.internet.node) [
      "sender"
      "manual"
    ];
    expected = [
      "fixture"
      "fixture"
    ];
  };
  testLocalGatewayTargetAndIdentity = {
    expr =
      let
        command = localGateway.systemd.services.realm-egress-sender-internet.serviceConfig.ExecStart;
      in
      lib.hasInfix "[fdcc::3]:19328" command
      && lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/internet" command;
    expected = true;
  };
  testExplicitInternetNodeRemainsSupported = {
    expr = localGateway.realm.workloads.remote.egress.internet.node;
    expected = "eihort";
  };
  testInternalGatewaySelectionUnchanged = {
    expr = localGateway.realm.workloads.sender.egress.http-eihort.node;
    expected = null;
  };
  testMultipleHostnamesShareOneGatewayProxy = {
    expr = map (c: c.systemd.units."realm-egress-sender-http-eihort.service".text) [
      cfg
      multipleHosts
    ];
    expected = lib.replicate 2 cfg.systemd.units."realm-egress-sender-http-eihort.service".text;
  };
  testMultipleHostnamesUseOneHTTPSAdapter = {
    expr = {
      aliases = multipleHosts.realm.workloads.sender.isolation.hosts;
      routes = builtins.attrNames multipleHosts.realm.workloads.sender.egress;
      listeners = multipleHosts.systemd.sockets.realm-local-sender-http-eihort.listenStreams;
    };
    expected = {
      aliases = {
        "box.nyaw.xyz" = "127.0.0.1";
        "oidc.nyaw.xyz" = "127.0.0.1";
        "s3.nyaw.xyz" = "127.0.0.1";
        "smtp.nyaw.xyz" = "127.0.0.1";
      };
      routes = [
        "http-eihort"
        "internet"
      ];
      listeners = [ "127.0.0.1:443" ];
    };
  };
  testInternetIdentityComesFromPublisher = {
    expr = lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/internet" cfg.systemd.services.realm-egress-sender-internet.serviceConfig.ExecStart;
    expected = true;
  };
  testDeclarationsValid = {
    expr = realmAssertions cfg;
    expected = [ ];
  };
  testAliasesMerged = {
    expr = cfg.realm.workloads.sender.isolation.hosts;
    expected = {
      "box.nyaw.xyz" = "127.0.0.1";
      "oidc.nyaw.xyz" = "127.0.0.1";
      "smtp.nyaw.xyz" = "127.0.0.1";
    };
  };
  testMergedAliasesMounted = {
    expr = lib.any (
      p: lib.hasSuffix ":/etc/hosts" p
    ) cfg.systemd.services.sender.serviceConfig.BindReadOnlyPaths;
    expected = true;
  };
  testNoProxyUppercase = {
    expr = cfg.systemd.services.sender.environment.NO_PROXY;
    expected = expectedNoProxy;
  };
  testNoProxyLowercase = {
    expr = cfg.systemd.services.sender.environment.no_proxy;
    expected = expectedNoProxy;
  };
  testNoProxyIncludesInternalHosts = {
    expr =
      let
        value = cfg.systemd.services.sender.environment.NO_PROXY;
      in
      lib.hasInfix "smtp.nyaw.xyz" value
      && lib.hasInfix "oidc.nyaw.xyz" value
      && lib.hasInfix "box.nyaw.xyz" value;
    expected = true;
  };
  testProxyUppercase = {
    expr = [
      cfg.systemd.services.sender.environment.HTTP_PROXY
      cfg.systemd.services.sender.environment.HTTPS_PROXY
    ];
    expected = [
      "http://127.0.0.1:13128"
      "http://127.0.0.1:13128"
    ];
  };
  testProxyLowercase = {
    expr = [
      cfg.systemd.services.sender.environment.http_proxy
      cfg.systemd.services.sender.environment.https_proxy
    ];
    expected = [
      "http://127.0.0.1:13128"
      "http://127.0.0.1:13128"
    ];
  };
  testInternetEgress = {
    expr = cfg.realm.workloads.sender.egress.internet;
    expected = {
      service = "internet-proxy";
      verifyID = null;
      node = null;
      localPort = 13128;
      target = null;
      socket = null;
    };
  };
  testGatewayEgress = {
    expr = cfg.realm.workloads.sender.egress.http-eihort;
    expected = {
      service = "https-fixture";
      verifyID = "spiffe://nyaw.xyz/service/caddy-eihort";
      node = null;
      localPort = 443;
      target = null;
      socket = null;
    };
  };
  testOnlyServedGatewayAttached = {
    expr = builtins.attrNames cfg.realm.workloads.sender.egress;
    expected = [
      "http-eihort"
      "internet"
    ];
  };
  testGatewayAdapterListensOn443 = {
    expr = cfg.systemd.sockets.realm-local-sender-http-eihort.listenStreams;
    expected = [ "127.0.0.1:443" ];
  };
  testGatewayEgressIdentity = {
    expr = cfg.realm.spire.registrations.realm-egress-sender-http-eihort;
    expected = {
      spiffeID = "spiffe://nyaw.xyz/service/sender";
      selectors = [
        "systemd:id:realm-egress-sender-http-eihort.service"
        "unix:user:realm-sender"
      ];
    };
  };
  testGatewayEgressTargetsCatalog = {
    expr =
      let
        command = cfg.systemd.services.realm-egress-sender-http-eihort.serviceConfig.ExecStart;
      in
      lib.hasInfix "--target '[fdcc::9]:443'" command
      && lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/caddy-eihort" command;
    expected = true;
  };
  testUnknownDomainRejected = {
    expr = rejected unknownDomain;
    expected = true;
  };
  testExplicitGatewayDisambiguatesSharedDomain = {
    expr = realmAssertions sharedDomain;
    expected = [ ];
  };
  testHostnamesOutsideSelectedGatewayRejected = {
    expr = rejected wrongGateway;
    expected = true;
  };
  testHostnamesWithoutGatewayReferenceRejected = {
    expr = rejected missingReference;
    expected = true;
  };
  testDuplicateAdapterPortRejected = {
    expr = rejected duplicatePort;
    expected = true;
  };
  testContainerRuntimeRejected = {
    expr = rejected containerRuntime;
    expected = true;
  };
  testNoPrivateNetworkRejected = {
    expr = rejected noPrivateNetwork;
    expected = true;
  };
  testDisabledWorkloadHasNoUnits = {
    expr = httpUnitsOf "disabled";
    expected = [ ];
  };
  testDisabledWorkloadHasNoEnvironment = {
    expr = proxyEnvironment (cfg.systemd.services.disabled.environment or { });
    expected = { };
  };
  testPlainWorkloadUntouched = {
    expr =
      (cfg.realm.workloads.plain.isolation.hosts == { })
      && (proxyEnvironment (cfg.systemd.services.plain.environment or { }) == { })
      && !(cfg.systemd.services ? realm-egress-plain-http-eihort)
      && !(cfg.realm.spire.registrations ? realm-egress-plain-http-eihort);
    expected = true;
  };
}
