# Evaluation only: do not compile kernels or depend on the xddxdd repository.
# Keep the old 7.2.11 derivations reproducible from frozen inputs as regression
# evidence for the migration. A deliberate toolchain/recipe change must review
# these expectations rather than silently discarding existing cache compatibility.
{ pkgs, packages }:
let
  inherit (pkgs) lib;
  baseline = builtins.fromJSON (builtins.readFile ./cachyos-cache-baseline.json);
  pin = builtins.fromJSON (builtins.readFile ../lib/cachyos/nixpkgs.json);
  outputs = k: map (name: k.${name}.outPath) k.outputs;
  check =
    name: fixture:
    let
      frozen = import ../lib/cachyos {
        pname = name;
        inherit (fixture) source variant;
      };
      kernel = packages.${name};
      # Exercise the exact NixOS boot.kernelPackages apply/override path, not a
      # dummy override that ignores features/patches/randstructSeed.
      system = import (pkgs.path + "/nixos/lib/eval-config.nix") {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.pkgs = pkgs;
            boot.kernelPackages = pkgs.linuxPackagesFor kernel;
          }
        ];
      };
      overridden = kernel.override {
        kernelPatches = [
          {
            name = "cachyos-eval-test";
            patch = null;
            extraConfig = "LOCALVERSION_AUTO n";
          }
        ];
      };
    in
    assert pin == baseline.nixpkgs;
    assert frozen.drvPath == fixture.drvPath;
    assert outputs frozen == fixture.paths;
    assert outputs (kernel.override { }) == outputs kernel;
    assert !(builtins.tryEval (kernel.override { lto = "thin"; }).drvPath).success;
    assert !(builtins.tryEval (kernel.override { processorOpt = "native"; }).drvPath).success;
    assert system.config.boot.kernelPackages.kernel.drvPath == kernel.drvPath;
    assert overridden.drvPath != kernel.drvPath;
    assert builtins.elem "cachyos-eval-test" (map (p: p.name) overridden.kernelPatches);
    assert kernel.meta.license.spdxId == "GPL-2.0-only";
    assert kernel.meta.platforms == [ "x86_64-linux" ];
    assert kernel.meta.ciBuild == false;
    assert
      kernel.version == (builtins.fromJSON (builtins.readFile (../pkgs + "/${name}/source.json")))
      .version;
    {
      passed = true;
      cachedBaseline = frozen.drvPath;
      current = kernel.drvPath;
      outputCount = builtins.length kernel.outputs;
    };
in
lib.mapAttrs check baseline.kernels
