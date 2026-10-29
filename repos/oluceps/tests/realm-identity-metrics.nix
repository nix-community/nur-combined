{ nixpkgs }:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [
      (_: prev: {
        writeText =
          name: text:
          if name == "realm-identity-metrics.json" then
            builtins.toFile name (builtins.unsafeDiscardStringContext text)
          else
            prev.writeText name text;
      })
    ];
  };
  inherit (pkgs) lib;
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/realm-observability.nix
        ../nixosModules/realm-internet.nix
        ../nixosModules/service-discovery.nix
        {
          networking.hostName = "eihort";
          system.stateVersion = "26.05";
          realm = {
            enable = true;
            address = "::1";
            serviceDiscovery = {
              enable = true;
              address = "::1";
            };
            observability.enable = true;
            internet = {
              enable = true;
              allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
            };
            spire = {
              server.enable = true;
              httpAttestation = {
                trustHttpTransport = true;
                agent.trustBundlePath = "/run/bootstrap.pem";
                server.nodes.eihort.addresses = [ "fdcc::91" ];
              };
              metrics = {
                enable = true;
                package = pkgs.emptyDirectory;
                nodes = [ "eihort" ];
                independent = {
                  enable = true;
                  address = "10.9.8.91";
                  observers = [
                    "10.9.8.1/32"
                    "10.9.8.3/32"
                  ];
                };
              };
            };
            workloads = {
              sender.egress.receiver = {
                service = "receiver";
                verifyID = "spiffe://nyaw.xyz/service/receiver";
                localPort = 13100;
              };
              receiver.ingress.http = {
                port = 19429;
                target = "127.0.0.1:3030";
                privateLoopback = true;
                service = "receiver";
                allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
              };
            };
          };
          systemd.services.sender.serviceConfig = {
            User = "sender";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
          systemd.services.receiver.serviceConfig = {
            User = "receiver";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
          users.groups = {
            sender = { };
            receiver = { };
          };
          users.users = {
            sender = {
              isSystemUser = true;
              group = "sender";
            };
            receiver = {
              isSystemUser = true;
              group = "receiver";
            };
          };
        }
      ]
      ++ extra;
    }).config;
  cfg = evaluate [ ];
  client = evaluate [ { realm.spire.server.enable = lib.mkForce false; } ];
  disabled = evaluate [ { realm.spire.metrics.enable = lib.mkForce false; } ];
  duplicate = evaluate [
    (
      { config, ... }:
      {
        realm.spire.metrics.caddyPort = config.realm.spire.metrics.statusPorts.realm-egress-sender-receiver;
      }
    )
  ];
  extraRegistration = evaluate [
    {
      realm.spire.registrations.realm-egress-aaa-extra = {
        spiffeID = "spiffe://nyaw.xyz/service/extra";
        selectors = [ "unix:user:extra" ];
      };
    }
  ];
  doc =
    c:
    builtins.fromJSON (
      builtins.readFile (
        builtins.unsafeDiscardStringContext (
          lib.last (lib.splitString " " c.systemd.services.realm-identity-metrics.serviceConfig.ExecStart)
        )
      )
    );
  metadata = doc cfg;
  failures =
    c: builtins.filter (a: !a.assertion && lib.hasPrefix "realm.spire.metrics:" a.message) c.assertions;
in
lib.runTests {
  testValid = {
    expr = failures cfg;
    expected = [ ];
  };
  testLoopback = {
    expr = [
      cfg.services.spire.agent.settings.telemetry.Prometheus.host
      cfg.services.spire.server.settings.telemetry.Prometheus.host
      metadata.listen_address
    ];
    expected = [
      "127.0.0.1"
      "127.0.0.1"
      "127.0.0.1:18494"
    ];
  };
  testResponderMetricsWithoutAttestation = {
    expr = cfg.systemd.services.realm-node-attest-responder.wantedBy;
    expected = [ "multi-user.target" ];
  };
  testResponderRemainsSocketActivatedWithoutMetrics = {
    expr = disabled.systemd.services.realm-node-attest-responder.wantedBy;
    expected = [ ];
  };
  testNoSPIREDependency = {
    expr = cfg.systemd.services.realm-identity-metrics.requires;
    expected = [ ];
  };
  testCanarySelectors = {
    expr = cfg.realm.spire.registrations.realm-identity-metrics.selectors;
    expected = [
      "systemd:id:realm-identity-metrics.service"
      "unix:user:root"
    ];
  };
  testCanaryIdentity = {
    expr = cfg.realm.spire.registrations.realm-identity-metrics.spiffeID;
    expected = "spiffe://nyaw.xyz/observer/identity/eihort";
  };
  testNoSecretState = {
    expr = builtins.elem "-/var/lib/spire/agent" cfg.systemd.services.realm-identity-metrics.serviceConfig.InaccessiblePaths;
    expected = true;
  };
  testAgentMetrics = {
    expr = cfg.realm.spire.httpAttestation.metrics.enable;
    expected = true;
  };
  testPrivateSockets = {
    expr = cfg.systemd.sockets.realm-node-attest-control.socketConfig.SocketMode;
    expected = "0600";
  };
  testStatusPorts = {
    expr = builtins.attrValues cfg.realm.spire.metrics.statusPorts;
    expected = builtins.attrValues cfg.realm.spire.metrics.statusPorts;
  };
  testStatusPortsAreDistinctAndInRange = {
    expr =
      let
        ports = builtins.attrValues cfg.realm.spire.metrics.statusPorts;
      in
      builtins.length (lib.unique ports) == builtins.length ports
      && lib.all (port: port >= 30000 && port < 40000) ports;
    expected = true;
  };
  testStatusPortStableWhenRegistrationAdded = {
    expr =
      (
        extraRegistration.realm.spire.metrics.statusPorts.realm-egress-sender-receiver
        == cfg.realm.spire.metrics.statusPorts.realm-egress-sender-receiver
      )
      && (
        extraRegistration.realm.spire.metrics.statusPorts.realm-ingress-receiver-http
        == cfg.realm.spire.metrics.statusPorts.realm-ingress-receiver-http
      );
    expected = true;
  };
  testEgressStatus = {
    expr = lib.hasInfix "--status=https://127.0.0.1:${toString cfg.realm.spire.metrics.statusPorts.realm-egress-sender-receiver}" cfg.systemd.services.realm-egress-sender-receiver.serviceConfig.ExecStart;
    expected = true;
  };
  testIngressStatus = {
    expr = lib.hasInfix "--status=https://127.0.0.1:${toString cfg.realm.spire.metrics.statusPorts.realm-ingress-receiver-http}" cfg.systemd.services.realm-ingress-receiver-http.serviceConfig.ExecStart;
    expected = true;
  };
  testDistinctProcessInventory = {
    expr = map (w: w.unit) metadata.workloads;
    expected = [
      "realm-egress-sender-receiver.service"
      "realm-ingress-receiver-http.service"
      "realm-observability.service"
      "realm-internet.service"
    ];
  };
  testSourceSemantics = {
    expr = map (w: w.source) metadata.workloads;
    expected = [
      "ghostunnel_status_watch"
      "ghostunnel_status_watch"
      "caddy_loaded"
      "caddy_loaded"
    ];
  };
  testInternetCoreMetrics = {
    expr = {
      port = cfg.realm.observability.endpoints.internet-gateway.port;
      path = cfg.realm.observability.endpoints.internet-gateway.path;
      envoy = cfg.realm.observability.endpoints ? envoy;
    };
    expected = {
      port = 19329;
      path = "/metrics";
      envoy = false;
    };
  };
  testInternetStatusMetadata = {
    expr = lib.findFirst (w: w.unit == "realm-internet.service") null metadata.workloads;
    expected = {
      unit = "realm-internet.service";
      identity = "spiffe://nyaw.xyz/service/internet";
      address = "127.0.0.1:19330";
      source = "caddy_loaded";
    };
  };
  testIPv6Endpoint = {
    expr = (doc (evaluate [ { realm.spire.serverAddress = "::1"; } ])).server_address;
    expected = "[::1]:8081";
  };
  testServerInventory = {
    expr = metadata.nodes;
    expected = [ "eihort" ];
  };
  testClientNoAdmin = {
    expr = (doc client) ? server_admin_socket;
    expected = false;
  };
  testClientNoAdminCapability = {
    expr = client.systemd.services.realm-identity-metrics.serviceConfig.CapabilityBoundingSet;
    expected = [ ];
  };
  testObserverFirewall = {
    expr = lib.hasInfix ''iifname "hts-0" ip saddr 10.9.8.1/32 ip daddr 10.9.8.91 tcp dport 18497 accept'' cfg.networking.firewall.extraInputRules;
    expected = true;
  };
  testIndependentListener = {
    expr = cfg.systemd.sockets.realm-identity-heartbeat.listenStreams;
    expected = [ "10.9.8.91:18497" ];
  };
  testIndependentObservers = {
    expr = cfg.systemd.sockets.realm-identity-heartbeat.socketConfig.IPAddressAllow;
    expected = [
      "10.9.8.1/32"
      "10.9.8.3/32"
    ];
  };
  testMetricsDisabled = {
    expr = disabled.systemd.services ? realm-identity-metrics;
    expected = false;
  };
  testNoStatusWhenDisabled = {
    expr = lib.hasInfix "--status=" disabled.systemd.services.realm-egress-sender-receiver.serviceConfig.ExecStart;
    expected = false;
  };
  testCollisionRejected = {
    expr = builtins.length (failures duplicate) > 0;
    expected = true;
  };
}
