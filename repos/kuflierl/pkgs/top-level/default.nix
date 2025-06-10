{ pkgs, lib }:
let
  callPackageByName = name: extraArgs: callPackage (lib.pkgPathByName name) extraArgs;

  callPackage = pkgs.lib.callPackageWith (pkgs // { customLib = lib; } // packages);
  packages = {
    intel-oneapi-dpcpp-cpp = callPackageByName "intel-oneapi-dpcpp-cpp" { };
    level-zero-1-19 = callPackageByName "level-zero-1-19" { };
    intel-compute-runtime-24-39-31294-12 = callPackageByName "intel-compute-runtime-24-39-31294-12" { };
    oneapi-unified-memory-framework = callPackageByName "oneapi-unified-memory-framework" { };
    intel-oneapi-dpcpp-cpp-pure = callPackageByName "intel-oneapi-dpcpp-cpp-pure" { };
    cup = pkgs.lib.warnOnInstantiate "'cup' has been renamed to 'cup-docker' due to a package with the same name: 'cup: LALR parser generator'" packages.cup-docker;
    cup-docker = callPackageByName "cup-docker" { };
    cup-docker-noserver = callPackageByName "cup-docker" { withServer = false; };
    ugdb = callPackageByName "ugdb" { };
  };
in
packages
