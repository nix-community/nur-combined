{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  aic8800 = config.boot.kernelPackages.callPackage ../pkgs/linux/aic8800/package.nix { };
  aic8800-firmware = pkgs.callPackage ../pkgs/by-name/aic8800-firmware/package.nix { };

in
{
  meta.maintainers = [ maintainers.Cryolitia ];

  boot.extraModulePackages = [ aic8800 ];

  boot.kernelModules = [
    "aic8800_fdrv"
    "aic_btusb"
    "aic_load_fw"
  ];
}
