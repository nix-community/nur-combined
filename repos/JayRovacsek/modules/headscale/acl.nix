{ config, pkgs, lib, ... }:
let
  meta = import ./meta.nix { inherit config pkgs lib; };

  # Below generates group values of "group:$X" for all pre-auth namespaces we've stored
  groups = builtins.foldl' (x: y: x // y) { }
    (builtins.map (x: { "group:${x}" = [ "${x}" ]; }) meta.users);

  # Below generates an allow ACL for inter-namespace communication where the namespace matches the origin
  defaultNamespaceCommunication = builtins.map (x: {
    action = "accept";
    src = [ "group:${x}" ];
    dst = [ "${x}:*" ];
  }) meta.users;

  allowAdminToAll = [{
    action = "accept";
    src = [ "group:admin" ];
    dst = [ "*:*" ];
  }];

  allowAllToDNS = [{
    action = "accept";
    src = [ "*" ];
    dst = [ "group:dns:53,8053" ];
  }];

  # Not keeping the below - just adding for documentation of things to fix.
  # see also: https://tailscale.com/kb/1103/exit-nodes/#prerequisites
  allowAllViaExitNodes = [{
    action = "accept";
    src = [ "autogroup:members" ];
    dst = [ "autogroup:internet:*" ];
  }];

  testPolicies = [ ];

  aclConfig = {
    inherit groups;
    acls = allowAdminToAll ++ allowAllToDNS ++ defaultNamespaceCommunication
      ++ allowAllViaExitNodes ++ testPolicies;
  };
in {
  environment.etc."headscale/acls.json" = {
    inherit (config.services.headscale) user group;
    text = builtins.toJSON aclConfig;
  };
}
