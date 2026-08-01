{
  config,
  lib,
  flakeRoot,
  nixosModules,
  ...
}:

let
  secrets = flakeRoot + /secrets/daedalus;
  hostUtils = import (flakeRoot + /lib/hostUtils.nix) { inherit lib; };
  userKeys = hostUtils.collectSshKeys { inherit flakeRoot; };
in

{
  imports = [
    secrets
  ]
  ++ (with nixosModules; [
    hardened
    programs.lanzaboote
    services.auto-upgrade
  ]);

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    iamanaws = {
      hashedPasswordFile = config.sops.secrets.passwd.path;
      openssh.authorizedKeys.keys = [ userKeys.archimedes.iamanaws ];
    };
  };

  services = {
    getty.autologinUser = lib.mkForce "iamanaws";
  };

}
