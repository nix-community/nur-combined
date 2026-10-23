{
  config,
  lib,
  flakeRoot,
  nixosModules,
  userKeys,
  ...
}:

let
  secrets = flakeRoot + /secrets/daedalus;
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
