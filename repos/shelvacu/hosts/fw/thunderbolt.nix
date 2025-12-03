{ lib, config, ... }:
{
  services.hardware.bolt.enable = true;

  vacu.packages = lib.mkMerge [
    ''
      thunderbolt
      bolt
      kdePackages.plasma-thunderbolt
    ''
    { bolt.package = config.services.hardware.bolt.package; }
  ];
}
