{ checkoutNixpkgs }:
{ channel, overlays, jobset, supportedSystems }:

let

  set = checkoutNixpkgs { inherit channel overlays; };

  pkgs = set.invoke {};

in

  jobset (import (builtins.toPath "${pkgs.path}/pkgs/top-level/release-lib.nix") {
    inherit (set) packageSet nixpkgsArgs;
    inherit supportedSystems;
  })
