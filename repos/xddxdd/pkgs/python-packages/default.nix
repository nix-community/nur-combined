{
  pkgs,
  _packages,
  createCallPackage,
  createLoadPackages,
  ...
}:
let
  callPackage = createCallPackage (_packages // pkgs.python3Packages // self);
  loadPackages = createLoadPackages callPackage;
  packages = loadPackages ./. { };

  self = packages // {
  };
in
self
