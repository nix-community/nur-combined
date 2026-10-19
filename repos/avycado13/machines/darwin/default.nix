{
  inputs,
  ...
}:
let
  helpers = import ../../flakeHelpers.nix inputs;
in
{
  nixpkgs = helpers.nixpkgsCfg;
  imports = [ ../../modules/nix/default.nix ];

  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    # "${config.users.users.avy.home}/.ssh/avy"
  ];

}
