# MAME arcade cabinet
# MeLE Quieter 4C
# - 8GiB RAM
# - intel N100 4c/4t
{ ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;  # for WiFi creds

  # TODO: port to `sane.programs` interface
  services.xserver.desktopManager.kodi.enable = true;
}
