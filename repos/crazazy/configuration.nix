{config, pkgs, ...}:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/system-configuration
  ];
}
