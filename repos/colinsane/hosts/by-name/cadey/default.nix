# MAME arcade cabinet
# MeLE Quieter 4C
# - 8GiB RAM
# - intel N100 4c/4t
{ lib, ... }:
{
  imports = [
    ../../common
    ./fs.nix
  ];

  networking.hostName = "cadey";
  sane.cpu = lib.mkDefault "x86_64";

  sane.roles.client = true;  # for WiFi creds

  # TODO: port to `sane.programs` interface
  services.xserver.desktopManager.kodi.enable = true;
}
