{
  lib,
  ...
}:

{
  # assertion: The 'fileSystems' option does not specify your root file system.
  fileSystems."/" = lib.mkDefault { device = "/dev/disk/by-label/nixos"; };
  # assertion: You must set the option 'boot.loader.grub.devices' or 'boot.loader.grub.mirroredBoots' to make the system bootable.
  boot.loader.grub.enable = lib.mkDefault false;
}
