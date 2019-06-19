{ nixpkgs ? <nixpkgs>
, supportedSystems ? [ builtins.currentSystem ] }:

with import <nixpkgs/pkgs/top-level/release-lib.nix> {
  inherit supportedSystems;
  packageSet = import ./ci.nix;
  scrubJobs = false;
};

mapTestOn (packagePlatforms pkgs)
#in {
#  pkgs-darwin = (import ./ci.nix { pkgs = pkgs.x86_64-darwin; }).buildPkgs;
#}
