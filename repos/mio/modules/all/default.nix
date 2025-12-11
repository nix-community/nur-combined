{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../linux-enable-ir-emitter.nix
    ../howdy
    ../pam.nix
    ../zfs-impermanence-on-shutdown.nix
  ];
}
