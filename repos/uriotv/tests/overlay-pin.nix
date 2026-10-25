# Evaluation-only tests for the flake overlay contract. Package derivations must
# equal CI's pinned derivations even when the consumer changes its nixpkgs set.
{
  pkgs,
  overlay,
  pinned,
  ciPackages,
}:
let
  inherit (pkgs) lib;
  packageNames = import ../pkgs/registry.nix { packageDirectory = ../pkgs; };
  consumer = pkgs.extend (
    _: prev: {
      bc = prev.bc.overrideAttrs (old: {
        pname = "bc-consumer";
        name = "bc-consumer-${old.version}";
      });
    }
  );
  withFlakeOverlay = consumer.extend overlay;
  withPlainOverlay = consumer.extend (import ../overlays).default;
  checkPackage =
    name:
    let
      expected = ciPackages.${name}.drvPath;
    in
    assert pinned.${name}.drvPath == expected;
    assert withFlakeOverlay.${name}.drvPath == expected;
    {
      passed = true;
      drvPath = expected;
    };
  kernelNames = [
    "linux-cachyos-latest-x86_64-v3"
    "linux-cachyos-bore-x86_64-v3"
  ];
  checkKernel =
    name:
    let
      setName = builtins.replaceStrings [ "linux-" ] [ "linuxPackages-" ] name;
      expected = ciPackages.${name}.drvPath;
      system = import (pkgs.path + "/nixos/lib/eval-config.nix") {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.pkgs = withFlakeOverlay;
            boot.kernelPackages = withFlakeOverlay.${setName};
          }
        ];
      };
    in
    # The alternate consumer really has a different dependency; ordinary overlay
    # recipes follow it, whereas the flake overlay remains pinned to CI.
    assert withPlainOverlay.${name}.drvPath != expected;
    assert withFlakeOverlay.${name}.drvPath == expected;
    assert withFlakeOverlay.${setName}.kernel.drvPath == expected;
    assert system.config.boot.kernelPackages.kernel.drvPath == expected;
    {
      passed = true;
      drvPath = expected;
    };
  packageResults = builtins.mapAttrs (name: _: checkPackage name) (
    lib.genAttrs packageNames (_: true)
  );
  kernelResults = builtins.mapAttrs (name: _: checkKernel name) (lib.genAttrs kernelNames (_: true));
in
assert consumer.bc.drvPath != pkgs.bc.drvPath;
assert withFlakeOverlay.rimsort.drvPath == pinned.rimsort-appimage.drvPath;
{
  packages = packageResults;
  kernels = kernelResults;
}
