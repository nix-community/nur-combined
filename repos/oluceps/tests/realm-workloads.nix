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
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        {
          networking.hostName = "fixture";
          system.stateVersion = "26.05";
          realm = {
            enable = true;
            serviceDiscovery = {
              enable = true;
              address = "fdcc::3";
            };
            workloads = {
              sender = {
                egress.receiver = {
                  service = "receiver";
                  verifyID = "spiffe://nyaw.xyz/service/receiver";
                  localPort = 13100;
                };
              };
              receiver = {
                ingress.http = {
                  port = 19429;
                  target = "127.0.0.1:3030";
                  privateLoopback = true;
                  service = "receiver";
                  allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
                };
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
          users.users.sender = {
            isSystemUser = true;
            group = "sender";
          };
          users.users.receiver = {
            isSystemUser = true;
            group = "receiver";
          };
          users.groups.sender = { };
          users.groups.receiver = { };
        }
      ]
      ++ extra;
    }).config;
  cfg = evaluate [ ];
  fixed = evaluate [
    { realm.workloads.sender.egress.receiver.target = "[fdcc::3]:19429"; }
  ];
  ambiguous = evaluate [
    {
      realm.serviceDiscovery.catalog = {
        first.receiver = {
          unit = "receiver.service";
          address = "fdcc::4";
          port = 19429;
        };
        second.receiver = {
          unit = "receiver.service";
          address = "fdcc::5";
          port = 19429;
        };
      };
    }
  ];
  missing = evaluate [ { realm.workloads.sender.egress.receiver.service = lib.mkForce "missing"; } ];
  bad = evaluate [ { realm.workloads.receiver.ingress.http.allowedIDs = lib.mkForce [ ]; } ];
  realmAssertions =
    c: builtins.filter (a: !a.assertion && lib.hasPrefix "realm" a.message) c.assertions;
in
lib.runTests {
  testDeclarationsValid = {
    expr = lib.all (a: a.assertion) (realmAssertions cfg);
    expected = true;
  };
  testPrivateNetwork = {
    expr = cfg.systemd.services.sender.serviceConfig.PrivateNetwork;
    expected = true;
  };
  testNamespaceJoin = {
    expr = cfg.systemd.sockets.realm-local-sender-receiver.unitConfig.JoinsNamespaceOf;
    expected = "realm-net-sender.service";
  };
  testNoRuntimeSockets = {
    expr = cfg.systemd.services.sender.serviceConfig.TemporaryFileSystem;
    expected = [
      "/run:ro"
      "/tmp:mode=1777"
    ];
  };
  # Joining realm-net-<name> suppresses PrivateTmp, so the explicit tmpfs is the
  # only thing that keeps /tmp private and writable inside a workload.
  testPrivateTmpfs = {
    expr = cfg.systemd.services.realm-backend-receiver-http.serviceConfig.TemporaryFileSystem;
    expected = [ "/tmp:mode=1777" ];
  };
  testBackendPrivate = {
    expr = cfg.systemd.services.realm-backend-receiver-http.serviceConfig.PrivateNetwork;
    expected = true;
  };
  testOnlyIngressPublished = {
    expr = builtins.attrNames cfg.realm.serviceDiscovery.publish;
    expected = [ "receiver" ];
  };
  testPublishedUnit = {
    expr = cfg.realm.serviceDiscovery.publish.receiver.unit;
    expected = "realm-ingress-receiver-http.service";
  };
  testPublishedPort = {
    expr = cfg.realm.serviceDiscovery.publish.receiver.port;
    expected = 19429;
  };
  testIdentityBoundToProxy = {
    expr = cfg.realm.spire.registrations.realm-egress-sender-receiver.selectors;
    expected = [
      "systemd:id:realm-egress-sender-receiver.service"
      "unix:user:realm-sender"
    ];
  };
  testRejectEmptyPolicy = {
    expr = lib.any (a: !a.assertion) (realmAssertions bad);
    expected = true;
  };
  testSocketPermissions = {
    expr = cfg.systemd.sockets.realm-egress-sender-receiver.socketConfig.SocketMode;
    expected = "0660";
  };
  testFixedEgressKeepsIdentityChecks = {
    expr =
      let
        command = fixed.systemd.services.realm-egress-sender-receiver.serviceConfig.ExecStart;
      in
      lib.hasInfix "--target '[fdcc::3]:19429'" command
      && lib.hasInfix "--use-workload-api" command
      && lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/receiver" command
      && !(lib.hasInfix "srv-egress.py" command)
      && !(lib.hasInfix "python3" command);
    expected = true;
  };
  testProxyStopIsBounded = {
    expr =
      lib.hasInfix "--shutdown-timeout 15s" cfg.systemd.services.realm-egress-sender-receiver.serviceConfig.ExecStart
      && lib.hasInfix "--shutdown-timeout 15s" cfg.systemd.services.realm-ingress-receiver-http.serviceConfig.ExecStart;
    expected = true;
  };
  testDefaultEgressConnectsDirectly = {
    expr =
      let
        unit = cfg.systemd.services.realm-egress-sender-receiver;
      in
      lib.hasInfix "--target '[fdcc::3]:19429'" unit.serviceConfig.ExecStart
      && lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/receiver" unit.serviceConfig.ExecStart
      && !(lib.elem "caddy.service" unit.after)
      && !(cfg.systemd.services ? realm-discovery);
    expected = true;
  };
  testCoreDNSRetained = {
    expr =
      cfg.services.coredns.enable
      && lib.hasInfix "receiver.svc IN SRV" cfg.realm.serviceDiscovery.zoneText;
    expected = true;
  };
  testRejectAmbiguousDestination = {
    expr = lib.any (a: !a.assertion) (realmAssertions ambiguous);
    expected = true;
  };
  testRejectMissingDestination = {
    expr = lib.any (a: !a.assertion) (realmAssertions missing);
    expected = true;
  };
  testFixedEgressNeedsNoDiscovery = {
    expr =
      !(fixed.systemd.services ? realm-discovery)
      && !(lib.hasInfix "/run/realm-discovery" fixed.systemd.services.realm-egress-sender-receiver.serviceConfig.ExecStart);
    expected = true;
  };
  testNoCredentialCopy = {
    expr = cfg.systemd.services.realm-egress-sender-receiver.serviceConfig.LoadCredential or [ ];
    expected = [ ];
  };
}
