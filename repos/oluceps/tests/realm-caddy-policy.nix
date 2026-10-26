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
              default = {
                eihort = "fdcc::3";
              };
            };
          };
        }
      ];
    }).config.realm.caddy;
in
lib.runTests {
  testNodesHaveDistinctIdentities = {
    expr = cfg.ids.eihort != cfg.ids.nodens;
    expected = true;
  };
  testPublicEdgeCannotReachStorageAdmin = {
    expr = lib.elem cfg.ids.nodens cfg.allowedIDs.seaweedfs-master;
    expected = false;
  };
  testStorageAdminRemainsAvailableToEihort = {
    expr = lib.elem cfg.ids.eihort cfg.allowedIDs.seaweedfs-master;
    expected = true;
  };
  testPublicRelayOnlyAdmitsYidhra = {
    expr = cfg.allowedIDs.public-http;
    expected = [ cfg.ids.yidhra ];
  };
  testPocketIDOnlyAdmitsEihort = {
    expr =
      lib.elem cfg.ids.eihort cfg.allowedIDs.pocket-id
      && !(lib.elem cfg.ids.nodens cfg.allowedIDs.pocket-id)
      && !(lib.elem cfg.ids.abhoth cfg.allowedIDs.pocket-id);
    expected = true;
  };
  testLegacySharedIdentityIsNotAuthorized = {
    expr = lib.any (lib.elem "spiffe://nyaw.xyz/service/caddy") (builtins.attrValues cfg.allowedIDs);
    expected = false;
  };
}
