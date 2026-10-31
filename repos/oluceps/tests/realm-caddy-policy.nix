{ nixpkgs }:
let
  lib = import (nixpkgs + "/lib");
  cfg =
    (lib.evalModules {
      modules = [
        (import ../mod/realm-caddy-policy.nix).flake.modules.nixos.realm
        {
          options = {
            networking.hostName = lib.mkOption {
              type = lib.types.str;
              default = "eihort";
            };
            realm.authorization.groups = lib.mkOption {
              type = lib.types.attrsOf (lib.types.listOf lib.types.str);
              default = { };
            };
            realm.servicePrefix = lib.mkOption {
              type = lib.types.str;
              default = "spiffe://nyaw.xyz/service/";
            };
            realm.serviceDiscovery.nodes = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = lib.genAttrs [
                "abhoth"
                "azasos"
                "eihort"
                "nodens"
                "yidhra"
              ] (_: "fdcc::1");
            };
          };
        }
      ];
    }).config.realm;
  ids = cfg.caddy.ids;
  groups = cfg.authorization.groups;
in
lib.runTests {
  testNodesHaveDistinctIdentities = {
    expr = ids.eihort != ids.nodens;
    expected = true;
  };
  testIdentitiesFollowNodeList = {
    expr = builtins.attrNames ids;
    expected = builtins.attrNames cfg.serviceDiscovery.nodes;
  };
  testPublicEdgeCannotReachStorageAdmin = {
    expr = lib.elem ids.nodens groups.entry-caddy;
    expected = false;
  };
  testStorageAdminRemainsAvailableToEihort = {
    expr = groups.entry-caddy;
    expected = [ ids.eihort ];
  };
  testPerNodeGroupIsSingleIdentity = {
    expr = groups.caddy-yidhra;
    expected = [ ids.yidhra ];
  };
  testRelayExcludesAzasos = {
    expr = lib.elem ids.azasos groups.relay-caddy;
    expected = false;
  };
  testLegacySharedIdentityIsNotAuthorized = {
    expr = lib.any (lib.elem "spiffe://nyaw.xyz/service/caddy") (builtins.attrValues groups);
    expected = false;
  };
}
