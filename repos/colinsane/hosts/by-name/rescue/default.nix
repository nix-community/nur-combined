{ pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];
  # sane.persist.enable = false;  # TODO: disable (but run `nix flake check` to ensure it works!)
  sane.nixcache.enable = false;  # don't want to be calling out to dead machines that we're *trying* to rescue

  # docs: https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.05";
}
