{ modulesPath, nixosModules, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    nixosModules.profiles.core
    nixosModules.display.default
  ];
  services.fwupd.enable = false;
}
