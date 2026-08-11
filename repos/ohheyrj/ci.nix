# This file provides all the buildable packages and package outputs in your
# package set. These are what gets built by CI, so if you correctly mark
# packages as broken your CI will not try to build them and the cache
# will not contain them.

{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, system ? builtins.currentSystem
}:

let
  # Import nixpkgs for the requested system WITH allowUnfree
  pkgsForSystem = import <nixpkgs> { 
    inherit system; 
    config.allowUnfree = true; 
  };
  
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  
  # Safe evaluation that won't fail if package can't be evaluated
  tryGetMeta = p: attr: default:
    let result = builtins.tryEval (p.meta.${attr} or default);
    in if result.success then result.value else default;
  
  # Check if package is buildable on current platform
  isBuildable = p:
    let
      platformCheck = builtins.tryEval (
        isDerivation p && 
        !(tryGetMeta p "broken" false) &&
        (
          let platforms = tryGetMeta p "platforms" [];
          in if platforms == [] 
             then true  # No platforms specified means all platforms
             else builtins.elem system platforms
        )
      );
    in platformCheck.success && platformCheck.value;

  nurAttrs = import ./default.nix { pkgs = pkgsForSystem; };

  # Filter to only include derivations that are buildable on this platform
  nurPkgs = pkgsForSystem.lib.filterAttrs (n: v:
    !isReserved n && 
    (builtins.tryEval (isBuildable v)).value or false
  ) nurAttrs;

in rec {
  # Packages that can be built on the current platform
  buildPkgs = nurPkgs;
  
  # Packages to be cached (same as buildPkgs in this case)
  cachePkgs = nurPkgs;

  # The actual derivations to be built
  buildOutputs = builtins.attrValues buildPkgs;
  cacheOutputs = builtins.attrValues cachePkgs;
}
