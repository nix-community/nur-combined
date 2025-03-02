{ config, lib, ... }:

with lib;

let

  xpad-noone = config.boot.kernelPackages.callPackage ../pkgs/linux/xpad-noone { };

in
{

  meta.maintainers = [ maintainers.Cryolitia ];

  boot.extraModulePackages = [ xpad-noone ];
  boot.kernelModules = [
    "xpad-noone"
  ];
}
