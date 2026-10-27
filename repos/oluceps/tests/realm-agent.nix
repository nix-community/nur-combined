{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  inherit (pkgs) lib;
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-agent.nix
        ../nixosModules/realm-http.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        {
          system.stateVersion = "26.05";
          realm = {
            enable = true;
            serviceDiscovery = {
              enable = true;
              address = "::1";
            };
            workloads.fixture = { };
          };
          systemd.services.fixture.serviceConfig = {
            User = "fixture";
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          };
        }
      ]
      ++ extra;
    }).config;
  failures =
    c:
    map (a: a.message) (lib.filter (a: !a.assertion && lib.hasPrefix "realm" a.message) c.assertions);
  cfg = evaluate [ ];
  disabled = evaluate [ { realm.workloads.fixture.transparent.enable = lib.mkForce false; } ];
  hostDisabled = evaluate [ { realm.agent.enable = false; } ];
  hostNetwork = evaluate [ { realm.workloads.fixture.isolation.privateNetwork = false; } ];
  external = evaluate [ { realm.workloads.fixture.runtime = "external"; } ];
  unsupportedContainer = evaluate [ { realm.workloads.fixture.runtime = "container"; } ];
  proxyFallback = evaluate [
    {
      realm.agent.enable = false;
      realm.workloads.fixture.http.internet = true;
    }
  ];
  transparentHTTP = evaluate [ { realm.workloads.fixture.http.internet = true; } ];
  unsafe = evaluate [
    {
      realm.workloads.fixture = {
        isolation.privateNetwork = false;
        transparent.enable = true;
      };
    }
  ];
  internet = evaluate [ { realm.workloads.fixture.egress.outside.service = "internet-proxy"; } ];
  ambiguous = evaluate [
    {
      realm.workloads.fixture.egress = {
        first.service = "internet-proxy";
        second.service = "internet-proxy";
      };
    }
  ];
  badRoute = evaluate [ { realm.workloads.fixture.transparent.internetRoute = "missing"; } ];
  overlap = evaluate [ { realm.workloads.fixture.transparent.tcpPort = 15053; } ];
  dynamic = evaluate [
    {
      systemd.services.fixture.serviceConfig = {
        User = lib.mkForce "fixture";
        DynamicUser = true;
      };
    }
  ];
  implicitDynamic = evaluate [
    {
      systemd.services.fixture.serviceConfig = {
        User = lib.mkForce "";
        DynamicUser = true;
      };
    }
  ];
  wrongUser = evaluate [ { systemd.services.fixture.serviceConfig.User = lib.mkForce "other"; } ];
in
assert failures cfg == [ ];
assert failures dynamic == [ ];
assert failures implicitDynamic == [ ];
assert lib.any (lib.hasInfix "configured workload user") (failures wrongUser);
assert !(disabled.systemd.services ? realm-agent);
assert !(hostDisabled.systemd.services ? realm-agent);
assert !(hostNetwork.systemd.services ? realm-agent);
assert !(external.systemd.services ? realm-agent);
assert !(unsupportedContainer.systemd.services ? realm-agent);
assert proxyFallback.systemd.services.fixture.environment.HTTPS_PROXY == "http://127.0.0.1:13128";
assert !(transparentHTTP.systemd.services.fixture.environment ? HTTPS_PROXY);
assert cfg.realm.workloads.fixture.transparent.internetRoute == null;
assert internet.realm.workloads.fixture.transparent.internetRoute == "outside";
assert ambiguous.realm.workloads.fixture.transparent.internetRoute == null;
assert lib.any (lib.hasInfix "isolated") (failures unsafe);
assert lib.any (lib.hasInfix "internetRoute") (failures badRoute);
assert lib.any (lib.hasInfix "overlap") (failures overlap);
assert cfg.users.users.rnet-fixture.group == "fixture";
assert builtins.elem "realm-agent.service" cfg.systemd.services.fixture.wants;
assert !(builtins.elem "realm-agent.service" cfg.systemd.services.fixture.requires);
assert lib.any (lib.hasInfix "gate --socket /run/realm-agent/fixture/control.sock")
  cfg.systemd.services.fixture.serviceConfig.ExecStartPre;
assert cfg.systemd.services.realm-agent.serviceConfig.KillMode == "control-group";
assert cfg.systemd.services.realm-agent.serviceConfig.DelegateSubgroup == "supervisor";
assert
  cfg.systemd.services.realm-agent.serviceConfig.Delegate == [
    "cpu"
    "memory"
    "pids"
  ];
assert cfg.systemd.services.realm-agent.serviceConfig.OOMPolicy == "continue";
assert cfg.systemd.services.realm-agent.serviceConfig.MemoryMax == 416 * 1024 * 1024;
assert cfg.realm.workloads.fixture.transparent.workerMemoryMiB == 128;
assert cfg.realm.workloads.fixture.transparent.workerTasks == 64;
assert cfg.realm.workloads.fixture.transparent.workerCPUQuota == 100;
{
  passed = true;
  config = cfg.systemd.services.realm-agent.serviceConfig.ExecStart;
}
