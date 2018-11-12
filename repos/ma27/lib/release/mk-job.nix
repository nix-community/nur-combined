{ checkoutNixpkgs }:
{ channel, overlays ? [], jobset, supportedSystems, trackBranches ? false, upstream ? "NixOS" }:

let

  set = checkoutNixpkgs { inherit channel overlays trackBranches upstream; };

  pkgs = set.invoke {};

in

  jobset (import (builtins.toPath "${pkgs.path}/pkgs/top-level/release-lib.nix") {
    inherit (set) packageSet nixpkgsArgs;
    inherit supportedSystems;
  })
