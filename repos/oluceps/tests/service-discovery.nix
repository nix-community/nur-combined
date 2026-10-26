{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  inherit (pkgs) lib;
  evaluate =
    modules:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/service-discovery.nix
        {
          networking.hostName = "test-node";
          system.stateVersion = "26.05";
        }
      ]
      ++ modules;
    }).config;
  published = {
    realm.serviceDiscovery = {
      enable = true;
      address = "fdcc::3";
      publish.demo = {
        unit = "demo.service";
        port = 8888;
      };
    };
    systemd.services.demo.serviceConfig.ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
  };
  enabled = evaluate [ published ];
  disabled = evaluate [ { } ];
  portless = evaluate [
    published
    { realm.serviceDiscovery.publish.demo.port = lib.mkForce null; }
  ];
  socket = evaluate [
    published
    {
      realm.serviceDiscovery.publish.demo.unit = lib.mkForce "demo.socket";
      systemd.sockets.demo.listenStreams = [ "8888" ];
      systemd.services.demo.enable = false;
    }
  ];
  custom = evaluate [
    published
    { realm.serviceDiscovery.publish.demo.address = "fdcc:3::10"; }
  ];
  replica = evaluate [
    published
    {
      networking.hostName = lib.mkForce "replica";
      realm.serviceDiscovery.address = lib.mkForce "fdcc::5";
      realm.serviceDiscovery.publish.demo.port = lib.mkForce 9999;
    }
  ];
  missingUnit = evaluate [
    published
    { realm.serviceDiscovery.publish.demo.unit = lib.mkForce "missing.service"; }
  ];
  disabledUnit = evaluate [
    published
    { systemd.services.demo.enable = false; }
  ];
  invalidName = evaluate [
    published
    { realm.serviceDiscovery.publish."Invalid.Name".unit = "demo.service"; }
  ];
  invalidPort = evaluate [
    published
    { realm.serviceDiscovery.publish.demo.port = lib.mkForce 65536; }
  ];
  clusterModule =
    (import ../mod/mesh-dns.nix {
      self.nixosConfigurations = {
        test-node.config = enabled;
        replica.config = replica;
        disabled.config = disabled;
      };
    }).flake.modules.nixos.mesh-dns;
  cluster = evaluate [
    clusterModule
    (
      { lib, ... }:
      {
        options.data = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
        config = {
          networking.hostName = lib.mkForce "observer";
          data.node = {
            test-node.unique_addr_nomask = "fdcc::3";
            replica.unique_addr_nomask = "fdcc::5";
            observer.unique_addr_nomask = "fdcc::7";
          };
        };
      }
    )
  ];
  allPass =
    config:
    !lib.any (a: !a.assertion && lib.hasPrefix "realm.serviceDiscovery." a.message) config.assertions;
  contains = config: record: lib.hasInfix record config.realm.serviceDiscovery.zoneText;
  tests = {
    testDisabled = {
      expr = {
        dns = disabled.services.coredns.enable;
        consul = disabled.services.consul.enable;
      };
      expected = {
        dns = false;
        consul = false;
      };
    };
    testLocalListener = {
      expr =
        enabled.services.coredns.enable
        && lib.hasInfix "mesh.nyaw.xyz:8600" enabled.services.coredns.config
        && lib.hasInfix "bind 127.0.0.1" enabled.services.coredns.config
        && !enabled.services.consul.enable;
      expected = true;
    };
    testNodeAAAA = {
      expr = contains enabled "test-node.node IN AAAA fdcc::3";
      expected = true;
    };
    testServiceRecords = {
      expr = lib.all (contains enabled) [
        "demo.svc IN AAAA fdcc::3"
        "demo.test-node.svc IN AAAA fdcc::3"
        "demo.svc IN SRV 0 1 8888 demo.test-node.svc.mesh.nyaw.xyz."
      ];
      expected = true;
    };
    testPortless = {
      expr = contains portless "demo.svc IN AAAA fdcc::3" && !contains portless " IN SRV ";
      expected = true;
    };
    testSocketActivation = {
      expr = allPass socket;
      expected = true;
    };
    testCustomEndpoint = {
      expr = contains custom "demo.svc IN AAAA fdcc:3::10";
      expected = true;
    };
    testMissingUnit = {
      expr = allPass missingUnit;
      expected = false;
    };
    testDisabledUnit = {
      expr = allPass disabledUnit;
      expected = false;
    };
    testInvalidName = {
      expr = allPass invalidName;
      expected = false;
    };
    testInvalidPort = {
      expr =
        (builtins.tryEval (builtins.deepSeq invalidPort.realm.serviceDiscovery.zoneText true)).success;
      expected = false;
    };
    testClusterCatalog = {
      expr = builtins.attrNames cluster.realm.serviceDiscovery.catalog;
      expected = [
        "replica"
        "test-node"
      ];
    };
    testReplicaRecords = {
      expr = lib.all (contains cluster) [
        "observer.node IN AAAA fdcc::7"
        "demo.svc IN AAAA fdcc::3"
        "demo.svc IN AAAA fdcc::5"
        "demo.svc IN SRV 0 1 8888 demo.test-node.svc.mesh.nyaw.xyz."
        "demo.svc IN SRV 0 1 9999 demo.replica.svc.mesh.nyaw.xyz."
      ];
      expected = true;
    };
    testDNSDelegation = {
      expr = cluster.services.resolved.dnsDelegates.mesh.Delegate;
      expected = {
        DNS = [ "127.0.0.1:8600" ];
        Domains = [ "~mesh.nyaw.xyz" ];
        DefaultRoute = false;
      };
    };
    testPrivateDNSSECAnchors = {
      expr =
        let
          anchors = lib.splitString "\n" cluster.environment.etc."dnssec-trust-anchors.d/mesh.negative".text;
        in
        lib.all (domain: builtins.elem domain anchors) [
          "mesh.nyaw.xyz"
          "lan"
          "home.arpa"
          "d.f.ip6.arpa"
          "16.172.in-addr.arpa"
          "31.172.in-addr.arpa"
        ];
      expected = true;
    };
    testNoRuntimeHealthChecks = {
      expr =
        !(enabled.realm.serviceDiscovery.publish.demo ? checks)
        && !(enabled.systemd.services ? consul)
        && lib.hasInfix "$TTL 5" enabled.realm.serviceDiscovery.zoneText;
      expected = true;
    };
  };
  failures = lib.runTests tests;
in
if failures == [ ] then
  { passed = builtins.length (builtins.attrNames tests); }
else
  throw (builtins.toJSON failures)
