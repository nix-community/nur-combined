{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  inherit (pkgs) lib;
  adapter = (import ../mod/ncps-client.nix).flake.modules.nixos.ncps-client;
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        adapter
        {
          networking.hostName = "fixture";
          system.stateVersion = "26.05";
          realm = {
            enable = true;
            spire.httpAttestation.trustHttpTransport = true;
            serviceDiscovery = {
              enable = true;
              address = "fdcc::3";
              catalog.cache.ncps = {
                address = "fdcc::4";
                port = 19428;
                serverID = "spiffe://nyaw.xyz/service/ncps";
              };
            };
          };
        }
      ]
      ++ extra;
    }).config;
  cfg = evaluate [ ];
  disabled = evaluate [ { realm.enable = lib.mkForce false; } ];
  workloadDisabled = evaluate [ { realm.workloads.nix-cache.enable = false; } ];
  settings = import ../lib/realm/caddy-ncps.nix { };
  unit = cfg.systemd.services.realm-ncps-client;
  egress = cfg.systemd.services.realm-egress-nix-cache-ncps;
  configfile = (pkgs.formats.json { }).generate "ncps-client-fixture.json" settings;
  unsetEnvironment = pkgs.writeText "ncps-client-unset-environment.json" (
    builtins.toJSON unit.serviceConfig.UnsetEnvironment
  );
in
{
  evaluation = lib.runTests {
    testDisabledHasNoRuntime = {
      expr = {
        adapter = disabled.systemd.services ? realm-ncps-client;
        egress = disabled.systemd.services ? realm-egress-nix-cache-ncps;
        config = disabled.environment.etc ? "realm-ncps-client/config.json";
        user = disabled.users.users ? realm-ncps-client;
      };
      expected = {
        adapter = false;
        egress = false;
        config = false;
        user = false;
      };
    };
    testWorkloadDisabledHasNoRuntime = {
      expr = {
        adapter = workloadDisabled.systemd.services ? realm-ncps-client;
        egress = workloadDisabled.systemd.services ? realm-egress-nix-cache-ncps;
        config = workloadDisabled.environment.etc ? "realm-ncps-client/config.json";
        user = workloadDisabled.users.users ? realm-ncps-client;
      };
      expected = {
        adapter = false;
        egress = false;
        config = false;
        user = false;
      };
    };
    testRealmAssertions = {
      expr = map (a: a.message) (
        builtins.filter (a: !a.assertion && lib.hasPrefix "realm" a.message) cfg.assertions
      );
      expected = [ ];
    };
    testDedicatedAccount = {
      expr = {
        user = unit.serviceConfig.User;
        group = unit.serviceConfig.Group;
        systemUser = cfg.users.users.realm-ncps-client.isSystemUser;
        proxyUser = egress.serviceConfig.User;
      };
      expected = {
        user = "realm-ncps-client";
        group = "realm-ncps-client";
        systemUser = true;
        proxyUser = "realm-nix-cache";
      };
    };
    testIdentityAndSocketPreserved = {
      expr = {
        identity = cfg.realm.workloads.nix-cache.spiffeID;
        registration = cfg.realm.spire.registrations.realm-egress-nix-cache-ncps.spiffeID;
        selectors = cfg.realm.spire.registrations.realm-egress-nix-cache-ncps.selectors;
        socket = cfg.systemd.sockets.realm-egress-nix-cache-ncps.listenStreams;
        socketGroup = cfg.systemd.sockets.realm-egress-nix-cache-ncps.socketConfig.SocketGroup;
        upstream =
          (builtins.head (builtins.elemAt settings.apps.http.servers.ncps.routes 1).handle).upstreams;
      };
      expected = {
        identity = "spiffe://nyaw.xyz/service/nix-cache";
        registration = "spiffe://nyaw.xyz/service/nix-cache";
        selectors = [
          "systemd:id:realm-egress-nix-cache-ncps.service"
          "unix:user:realm-nix-cache"
        ];
        socket = [ "/run/realm/nix-cache/egress/ncps.sock" ];
        socketGroup = "realm-ncps-client";
        upstream = [ { dial = "unix//run/realm/nix-cache/egress/ncps.sock"; } ];
      };
    };
    testPeerAuthenticationPreserved = {
      expr =
        lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/ncps" egress.serviceConfig.ExecStart
        && lib.hasInfix "--use-workload-api" egress.serviceConfig.ExecStart;
      expected = true;
    };
    testLoopbackOnlyAndNoAdmin = {
      expr = {
        listen = settings.apps.http.servers.ncps.listen;
        admin = settings.admin;
      };
      expected = {
        listen = [ "127.0.0.1:18502" ];
        admin.disabled = true;
      };
    };
    testUnitUsesCaddyAndWaitsForSocket = {
      expr =
        lib.hasInfix "/bin/caddy run --config /etc/realm-ncps-client/config.json" unit.serviceConfig.ExecStart
        && lib.elem "realm-egress-nix-cache-ncps.socket" unit.requires
        && lib.elem "realm-egress-nix-cache-ncps.socket" unit.after;
      expected = true;
    };
    testRuntimeSocketIsolation = {
      expr = {
        runtime = unit.serviceConfig.TemporaryFileSystem;
        visible = unit.serviceConfig.BindReadOnlyPaths;
        privileges = unit.serviceConfig.NoNewPrivileges;
        capabilities = unit.serviceConfig.CapabilityBoundingSet;
      };
      expected = {
        runtime = [ "/run:ro" ];
        visible = [
          "/run/realm/nix-cache/egress"
          "-/run/systemd/notify"
        ];
        privileges = true;
        capabilities = [ ];
      };
    };
    testProxyEnvironmentIsRemoved = {
      expr = unit.serviceConfig.UnsetEnvironment;
      expected = [
        "HTTP_PROXY"
        "HTTPS_PROXY"
        "ALL_PROXY"
        "NO_PROXY"
        "http_proxy"
        "https_proxy"
        "all_proxy"
        "no_proxy"
      ];
    };
    testNoEnvoyService = {
      expr = cfg.systemd.services ? envoy;
      expected = false;
    };
  };
  behavior =
    pkgs.runCommand "realm-ncps-client-behavior"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.caddy
        ];
      }
      ''
        export HOME="$TMPDIR"
        python3 ${./realm-ncps-client.py} --config ${configfile} --caddy ${pkgs.caddy}/bin/caddy --unset-environment ${unsetEnvironment}
        touch "$out"
      '';
}
