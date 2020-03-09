{config, pkgs, ...}:
{
  imports = with import ./modules; [
    ./hardware-configuration.nix
    system-config
    desktop-config
  ];
}
