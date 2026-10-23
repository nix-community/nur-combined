# Evaluation only. A consumer whose nixpkgs differs from ours (simulated by a
# changed kernel build input) must still get the CI-built kernel derivation from the
# flake overlay, through the package set and the NixOS boot.kernelPackages path.
# The plain NUR overlay (./overlays) intentionally follows the consumer's nixpkgs.
{
  pkgs,
  overlay,
  pinned,
}:
let
  inherit (pkgs) lib;
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
  check =
    name:
    let
      setName = builtins.replaceStrings [ "linux-" ] [ "linuxPackages-" ] name;
      expected = pinned.${name}.drvPath;
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
    # Sanity: the simulated consumer change really alters an unpinned kernel.
    assert withPlainOverlay.${name}.drvPath != expected;
    assert withFlakeOverlay.${name}.drvPath == expected;
    assert withFlakeOverlay.${setName}.kernel.drvPath == expected;
    assert system.config.boot.kernelPackages.kernel.drvPath == expected;
    {
      passed = true;
      kernel = expected;
    };
in
lib.genAttrs [
  "linux-cachyos-latest-x86_64-v3"
  "linux-cachyos-bore-x86_64-v3"
] check
