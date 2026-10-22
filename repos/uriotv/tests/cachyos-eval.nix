# Evaluation only: do not compile kernels or depend on the xddxdd repository.
# The kernels are built with the repository nixpkgs (flake.lock). These checks
# verify that the constructor, package sets, overlay and NixOS boot path all
# resolve to the same derivation, and that the NixOS override surface still works.
{ pkgs, packages }:
let
  inherit (pkgs) lib;
  kernelNames = [
    "linux-cachyos-latest-x86_64-v3"
    "linux-cachyos-bore-x86_64-v3"
  ];
  outputs = k: map (name: k.${name}.outPath) k.outputs;
  check =
    name:
    let
      kernel = packages.${name};
      setName = builtins.replaceStrings [ "linux-" ] [ "linuxPackages-" ] name;
      packageSets = import ../lib/cachyos/package-sets.nix {
        inherit pkgs;
        kernels = packages;
      };
      nur = import ../. { inherit pkgs; };
      overlay = (import ../overlays).default pkgs { };
      # Real overlay fixpoint, as used by NixOS nixpkgs.overlays. A pkgs-only check
      # cannot reproduce recursion through final.stdenv.
      extended = pkgs.extend (import ../overlays).default;
      # Exercise the exact NixOS boot.kernelPackages apply/override path, not a
      # dummy override that ignores features/patches/randstructSeed.
      system = import (pkgs.path + "/nixos/lib/eval-config.nix") {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.pkgs = pkgs;
            boot.kernelPackages = packageSets.${setName};
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
    assert outputs (kernel.override { }) == outputs kernel;
    assert nur.${setName}.kernel.drvPath == kernel.drvPath;
    assert overlay.${setName}.kernel.drvPath == kernel.drvPath;
    assert extended.${setName}.kernel.drvPath == kernel.drvPath;
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
      current = kernel.drvPath;
      outputCount = builtins.length kernel.outputs;
    };
in
lib.genAttrs kernelNames check
