{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) recurseIntoAttrs stdenv;
  inherit (pkgs.lib) deepSeq filterAttrs hasPrefix isDerivation mapAttrs pipe;

  selectDerivations = set:
    let
      # Check if a given derivation must be built in the current system.
      shouldBuildForPlatform = system: drv:
        builtins.elem system (drv.meta.hydraPlatforms or drv.meta.platforms or [ system ]);
      derivationTree = value:
        # Output derivations directly, but only if they're compatible
        # with this platform.
        if isDerivation value && shouldBuildForPlatform pkgs.system value
        then value
        else if value.recurseForDerivations or false
        then
          pipe value [
            # Don't evaluate linuxPackages outside Linux, or it will
            # break everything.
            (filterAttrs (name: value: ! stdenv.isLinux -> ! hasPrefix "linuxPackages" name))
            (mapAttrs (name: derivationTree))
            (filterAttrs (name: value: value != null))
            recurseIntoAttrs
          ]
        else null;
    in
    derivationTree (recurseIntoAttrs set);

  self = import ./. { inherit pkgs; };
in
{
  lib = deepSeq (import ./lib/tests.nix { lib = pkgs.lib; }) { };

  newPackages = selectDerivations self.packageSets.pkgs;

  patchedPackages = selectDerivations self.packageSets.patches;
}
