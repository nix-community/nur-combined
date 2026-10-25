# Flake-specific overlay: package recipes come from this repository's pinned
# legacyPackages, matching direct flake outputs and CI/cache derivations exactly.
# Only linuxPackagesFor uses the consumer's pkgs, for out-of-tree kernel modules.
{
  pinned,
  pkgs,
}:
let
  packageNames = import ../pkgs/registry.nix { packageDirectory = ../pkgs; };
  packages = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = pinned.${name};
    }) packageNames
  );
  kernels = {
    inherit (pinned) linux-cachyos-latest-x86_64-v3 linux-cachyos-bore-x86_64-v3;
  };
in
packages
// kernels
// {
  # Compatibility alias; always point at the pinned canonical derivation.
  rimsort = pinned.rimsort-appimage;
}
// import ../lib/cachyos/package-sets.nix {
  inherit pkgs kernels;
}
