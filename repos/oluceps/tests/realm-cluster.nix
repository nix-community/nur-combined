{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  inherit (pkgs) lib;
  evaluate =
    extras:
    let
      systems = lib.genAttrs [ "eihort" "caller" ] (
        host:
        import (nixpkgs + "/nixos/lib/eval-config.nix") {
          inherit pkgs;
          modules = [
            ../nixosModules/realm-workloads.nix
            ../nixosModules/realm-http.nix
            ../nixosModules/realm-spire.nix
            ../nixosModules/service-discovery.nix
            ((import ../mod/realm-http.nix { self.nixosConfigurations = systems; }).flake.modules.nixos.realm)
            (
              { config, ... }:
              {
                options.data = lib.mkOption {
                  type = lib.types.raw;
                  default.serviceHosts.eihort = [ "oidc.test" ];
                };
                config = {
                  networking.hostName = host;
                  system.stateVersion = "26.05";
                  realm = {
                    enable = true;
                    identityCatalog = lib.mapAttrs (_: s: s.config.realm.localIdentities) systems;
                    serviceDiscovery = {
                      enable = true;
                      address = if host == "eihort" then "fdcc::3" else "fdcc::4";
                      catalog = lib.mapAttrs (_: s: s.config.realm.serviceDiscovery.publish) systems;
                    };
                    workloads =
                      if host == "eihort" then
                        {
                          gateway = {
                            runtime = "external";
                            isolation.privateNetwork = false;
                            spiffeID = "spiffe://nyaw.xyz/service/caddy-eihort";
                            ingress.https = {
                              service = "https-gateway";
                              port = 19443;
                              backend = {
                                kind = "host-tcp";
                                port = 443;
                              };
                              allowedIDs = config.realm.http.gatewayClientIDs.eihort;
                            };
                          };
                        }
                      else
                        {
                          sender.http.gateway = {
                            ref = "eihort";
                            resolveHosts = [ "oidc.test" ];
                          };
                          disabled = {
                            enable = false;
                            http.gateway = {
                              ref = "eihort";
                              resolveHosts = [ "oidc.test" ];
                            };
                          };
                        };
                  };
                  systemd.services.sender.serviceConfig.ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
                };
              }
            )
          ]
          ++ (extras.${host} or [ ]);
        }
      );
    in
    lib.mapAttrs (_: s: s.config) systems;
  cfg = evaluate { };
  explicit = evaluate {
    eihort = [ { realm.http.gateways.eihort.admission = lib.mkForce "explicit"; } ];
  };
  namedNode = evaluate {
    caller = [ { realm.workloads.sender.egress.http-eihort.node = "eihort"; } ];
  };
  badIdentity = evaluate {
    caller = [
      { realm.workloads.sender.egress.http-eihort.verifyID = "spiffe://nyaw.xyz/service/wrong"; }
    ];
  };
  disabled = evaluate {
    caller = [ { realm.workloads.sender.enable = false; } ];
  };
  badReference = evaluate {
    caller = [ { realm.workloads.sender.http.gateway.ref = lib.mkForce "missing"; } ];
  };
  failed = c: builtins.filter (a: !a.assertion && lib.hasPrefix "realm" a.message) c.assertions;
in
lib.runTests {
  testClusterHasNoFailedAssertions = {
    expr = lib.concatMap (c: failed c) (builtins.attrValues cfg);
    expected = [ ];
  };
  testPublisherExportsIdentity = {
    expr = cfg.eihort.realm.serviceDiscovery.publish.https-gateway.serverID;
    expected = "spiffe://nyaw.xyz/service/caddy-eihort";
  };
  testCallerIdentityReachesReceiverPolicy = {
    expr = cfg.eihort.realm.workloads.gateway.ingress.https.allowedIDs;
    expected = [ "spiffe://nyaw.xyz/service/sender" ];
  };
  testDisabledCallerIsNotGrantedAccess = {
    expr = cfg.eihort.realm.http.gatewayClientIDs.eihort;
    expected = [ "spiffe://nyaw.xyz/service/sender" ];
  };
  testExplicitReceiverDoesNotAdmitDeclaredClients = {
    expr = explicit.eihort.realm.http.gatewayClientIDs.eihort;
    expected = [ ];
  };
  testCallerPinsPublishedIdentity = {
    expr = lib.hasInfix "--verify-uri spiffe://nyaw.xyz/service/caddy-eihort" cfg.caller.systemd.services.realm-egress-sender-http-eihort.serviceConfig.ExecStart;
    expected = true;
  };
  testNodeSelectionPreservesDestination = {
    expr = namedNode.caller.systemd.services.realm-egress-sender-http-eihort.serviceConfig.ExecStart;
    expected = cfg.caller.systemd.services.realm-egress-sender-http-eihort.serviceConfig.ExecStart;
  };
  testKnownIdentityMismatchFailsEvaluation = {
    expr = failed badIdentity.caller != [ ];
    expected = true;
  };
  testUnknownGatewayFailsEvaluation = {
    expr = failed badReference.caller != [ ];
    expected = true;
  };
  testDisabledWorkloadRemovesClusterGrant = {
    expr = disabled.eihort.realm.http.gatewayClientIDs.eihort;
    expected = [ ];
  };
  testDisabledWorkloadRemovesProxy = {
    expr = disabled.caller.systemd.services ? realm-egress-sender-http-eihort;
    expected = false;
  };
  testAuthorizationTableShowsActualReceiver = {
    expr = map (e: { inherit (e) service serverID allowedIDs; }) cfg.caller.realm.authorization.matrix;
    expected = [
      {
        service = "https-gateway";
        serverID = "spiffe://nyaw.xyz/service/caddy-eihort";
        allowedIDs = [ "spiffe://nyaw.xyz/service/sender" ];
      }
    ];
  };
  testConnectionTableChecksReceiverGrant = {
    expr = map (e: { inherit (e) serverID allowed node; }) cfg.caller.realm.authorization.connections;
    expected = [
      {
        serverID = "spiffe://nyaw.xyz/service/caddy-eihort";
        allowed = true;
        node = "eihort";
      }
    ];
  };
}
