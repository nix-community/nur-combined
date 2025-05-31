{
  config,
  ...
}:
{
  boot.kernelModules = [
    "8851bu"
  ];
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ../pkgs/rtl8851bu/default.nix { })
  ];
}
