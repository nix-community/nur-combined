{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
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
              sender.egress.receiver = {
                service = "receiver";
                localPort = 13100;
              };
              receiver.ingress.http = {
                service = "receiver";
                port = 19429;
                backend = {
                  kind = "private-tcp";
                  port = 3030;
                };
                allow.workloads = [ "sender" ];
              };
            };
          };
          systemd.services.sender.serviceConfig.ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          systemd.services.receiver.serviceConfig.ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
        }
      ]
      ++ extra;
    }).config;
  cfg = evaluate [ ];
  legacy = evaluate [
    {
      realm.workloads.receiver.ingress.http = {
        backend = lib.mkForce null;
        allow.workloads = lib.mkForce [ ];
        target = "127.0.0.1:3030";
        privateLoopback = true;
        allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
      };
      realm.workloads.sender.egress.receiver.verifyID = "spiffe://nyaw.xyz/service/receiver";
    }
  ];
  unix = evaluate [
    {
      realm.workloads.receiver.ingress.http.backend = lib.mkForce {
        kind = "unix";
        path = "/run/backend.sock";
      };
    }
  ];
  host = evaluate [
    {
      realm.workloads.receiver.isolation.privateNetwork = false;
      realm.workloads.receiver.ingress.http.backend = lib.mkForce {
        kind = "host-tcp";
        port = 3030;
      };
    }
  ];
  native = evaluate [
    {
      realm.workloads.receiver = {
        runtime = "external";
        isolation.privateNetwork = false;
        ingress.http.backend = lib.mkForce { kind = "native"; };
      };
    }
  ];
  missing = evaluate [ { realm.workloads.sender.egress.receiver.service = lib.mkForce "missing"; } ];
  invalid = evaluate [
    { realm.workloads.receiver.ingress.http.backend = lib.mkForce { kind = "unix"; }; }
  ];
  unknownGrant = evaluate [
    { realm.workloads.receiver.ingress.http.allow.workloads = lib.mkForce [ "missing" ]; }
  ];
  group = evaluate [
    {
      realm.authorization.groups.clients = [ "spiffe://nyaw.xyz/service/sender" ];
      realm.workloads.receiver.ingress.http.allow = {
        workloads = lib.mkForce [ ];
        groups = [ "clients" ];
      };
    }
  ];
  unknownGroup = evaluate [ { realm.workloads.receiver.ingress.http.allow.groups = [ "missing" ]; } ];
  aliases = {
    first.client = "spiffe://nyaw.xyz/service/client-first";
    second.client = "spiffe://nyaw.xyz/service/client-second";
  };
  ambiguous = evaluate [
    {
      realm.identityCatalog = aliases;
      realm.workloads.receiver.ingress.http.allow.workloads = lib.mkForce [ "client" ];
    }
  ];
  qualified = evaluate [
    {
      realm.identityCatalog = aliases;
      realm.workloads.receiver.ingress.http.allow.workloads = lib.mkForce [ "second/client" ];
    }
  ];
  manual = evaluate [
    {
      realm.workloads.sender.egress.receiver = {
        target = "[fdcc::9]:19429";
        verifyID = "spiffe://external.test/service/receiver";
      };
    }
  ];
  plain = evaluate [
    {
      realm.serviceDiscovery.catalog.fixture.receiver = cfg.realm.serviceDiscovery.publish.receiver // {
        transport = "plain";
      };
    }
  ];
  badIdentity = evaluate [
    { realm.workloads.sender.egress.receiver.verifyID = "spiffe://nyaw.xyz/service/wrong"; }
  ];
  duplicate = evaluate [
    {
      realm.serviceDiscovery.catalog.second.receiver = {
        address = "fdcc::4";
        port = 19429;
        serverID = "spiffe://nyaw.xyz/service/receiver";
      };
      realm.serviceDiscovery.catalog.fixture.receiver = cfg.realm.serviceDiscovery.publish.receiver;
    }
  ];
  chosen = evaluate [
    {
      realm.serviceDiscovery.catalog.second.receiver = {
        address = "fdcc::4";
        port = 19429;
        serverID = "spiffe://nyaw.xyz/service/receiver";
      };
      realm.serviceDiscovery.catalog.fixture.receiver = cfg.realm.serviceDiscovery.publish.receiver;
      realm.workloads.sender.egress.receiver.node = "second";
    }
  ];
  failed = c: builtins.filter (a: !a.assertion && lib.hasPrefix "realm" a.message) c.assertions;
  receiver = c: c.realm.workloads.receiver.ingress.http;
in
lib.runTests {
  testManualTargetHasUnknownReceiverPolicy = {
    expr = builtins.head (map (e: e.allowed) manual.realm.authorization.connections);
    expected = null;
  };
  testPlainEndpointRejected = {
    expr = failed plain != [ ];
    expected = true;
  };
  testTypedDeclarationsValid = {
    expr = failed cfg;
    expected = [ ];
  };
  testLegacyAndTypedUnitsMatch = {
    expr =
      cfg.systemd.units."realm-ingress-receiver-http.service".text
      == legacy.systemd.units."realm-ingress-receiver-http.service".text
      &&
        cfg.systemd.units."realm-egress-sender-receiver.service".text
        == legacy.systemd.units."realm-egress-sender-receiver.service".text;
    expected = true;
  };
  testUnixBackend = {
    expr = (receiver unix).target;
    expected = "unix:/run/backend.sock";
  };
  testHostBackend = {
    expr = (receiver host).hostLoopback && !(receiver host).privateLoopback;
    expected = true;
  };
  testNativeBackend = {
    expr = native.realm.spire.registrations ? realm-native-receiver;
    expected = true;
  };
  testNativeHasNoGhostunnel = {
    expr = native.systemd.services ? realm-ingress-receiver-http;
    expected = false;
  };
  testIncompleteBackendRejected = {
    expr = failed invalid != [ ];
    expected = true;
  };
  testUnknownEndpointRejected = {
    expr = failed missing != [ ];
    expected = true;
  };
  testUnknownWorkloadRejected = {
    expr = failed unknownGrant != [ ];
    expected = true;
  };
  testUnknownGroupRejected = {
    expr = failed unknownGroup != [ ];
    expected = true;
  };
  testGroupPreservesAuthorization = {
    expr = (receiver group).allowedIDs;
    expected = (receiver cfg).allowedIDs;
  };
  testAmbiguousIdentityRejected = {
    expr = failed ambiguous != [ ];
    expected = true;
  };
  testQualifiedIdentity = {
    expr = (receiver qualified).allowedIDs;
    expected = [ aliases.second.client ];
  };
  testEndpointIdentityMismatchRejected = {
    expr = failed badIdentity != [ ];
    expected = true;
  };
  testMultiplePublishersRejected = {
    expr = failed duplicate != [ ];
    expected = true;
  };
  testSelectedPublisherUsed = {
    expr = lib.hasInfix "--target '[fdcc::4]:19429'" chosen.systemd.services.realm-egress-sender-receiver.serviceConfig.ExecStart;
    expected = true;
  };
}
