{ pkgs, lib }:
let
  callPackageByName = name: extraArgs: callPackage (lib.pkgPathByName name) extraArgs;

  pkgsLibPatch = pkgs.lib // {
    maintainers =
      pkgs.lib.maintainers
      // pkgs.lib.optionalAttrs (pkgs.lib.versionOlder pkgs.lib.version "25.05pre-git") {
        kuflierl = {
          email = "kuflierl@gmail.com";
          github = "kuflierl";
          githubId = 41301536;
          name = "Kennet Flierl";
        };
      };
    licenses =
      pkgs.lib.licenses
      // pkgs.lib.optionalAttrs (pkgs.lib.versionOlder pkgs.lib.version "25.05pre-git") {
        llvm-exception = {
          deprecated = false;
          free = true;
          fullName = "LLVM Exception";
          redistributable = true;
          shortName = "llvm-exception";
          spdxId = "LLVM-exception";
          url = "https://spdx.org/licenses/LLVM-exception.html";
        };
      };
  };

  callPackage = pkgs.lib.callPackageWith (
    pkgs
    // {
      lib = pkgsLibPatch;
      customLib = lib;
    }
    // packages
  );
  packages = {
    intel-oneapi-dpcpp-cpp = callPackageByName "intel-oneapi-dpcpp-cpp" { };
    level-zero-1-19 = callPackageByName "level-zero-1-19" { };
    intel-compute-runtime-24-39-31294-12 = callPackageByName "intel-compute-runtime-24-39-31294-12" { };
    oneapi-unified-memory-framework = callPackageByName "oneapi-unified-memory-framework" { };
  };
in
packages
