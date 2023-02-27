{ config, pkgs, lib, ... }:
let
  meta = import ./meta.nix { inherit config pkgs lib; };

  # At time of writing an old ACL format was utilised; as multiple
  # headscale v0.16.0 beta releases have warned that the new format will be 
  # used: https://github.com/juanfont/headscale/releases/tag/v0.16.0-beta6
  # I did look at using an overlay for this but go modules build in magic ways
  # I fail to understand. So let's hack around this change for now.
  usingNewAclFormat =
    lib.strings.versionAtLeast config.services.headscale.package.version
    "0.16.0";

  # Below generates group values of "group:$X" for all pre-auth namespaces we've stored
  groups = builtins.foldl' (x: y: x // y) { }
    (builtins.map (x: { "group:${x}" = [ "${x}" ]; }) meta.users);

  # Below generates an allow ACL for inter-namespace communication where the namespace matches the origin
  defaultNamespaceCommunication = if usingNewAclFormat then
    (builtins.map (x: {
      action = "accept";
      src = [ "group:${x}" ];
      dst = [ "${x}:*" ];
    }) meta.users)
  else
    (builtins.map (x: {
      action = "accept";
      users = [ "group:${x}" ];
      ports = [ "${x}:*" ];
    }) meta.users);

  allowAdminToAll = if usingNewAclFormat then [{
    action = "accept";
    src = [ "group:admin" ];
    dst = [ "*:*" ];
  }] else [{
    action = "accept";
    users = [ "group:admin" ];
    ports = [ "*:*" ];
  }];

  allowAllToDNS = if usingNewAclFormat then [{
    action = "accept";
    src = [ "*" ];
    dst = [ "group:dns:53,8053" ];
  }] else [{
    action = "accept";
    users = [ "*" ];
    ports = [ "group:dns:53,8053" ];
  }];

  # Not keeping the below - just adding for documentation of things to fix.
  # see also: https://tailscale.com/kb/1103/exit-nodes/#prerequisites
  allowAllViaExitNodes = if usingNewAclFormat then [{
    action = "accept";
    src = [ "autogroup:members" ];
    dst = [ "autogroup:internet:*" ];
  }] else [{
    action = "accept";
    users = [ "autogroup:members" ];
    ports = [ "autogroup:internet:*" ];
  }];

  aclConfig = {
    inherit groups;
    acls = allowAdminToAll ++ allowAllToDNS ++ defaultNamespaceCommunication
      ++ allowAllViaExitNodes;
  };
in {
  environment.etc."headscale/acls.json" = {
    inherit (config.services.headscale) user group;
    text = builtins.toJSON aclConfig;
  };
}
