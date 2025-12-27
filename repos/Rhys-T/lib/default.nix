{ pkgs }:

with pkgs.lib; rec {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  mirrors = import ./mirrors.nix;
  # HACK to make <nixpkgs/maintainers/scripts/update.nix> work:
  inherit getVersion;
  
  addMetaAttrsDeep = m: p: let
    inherit (pkgs.lib) addMetaAttrs;
  in if p?overrideAttrs then p.overrideAttrs (old: addMetaAttrs m old) else addMetaAttrs m p;
  
  # Variation of `pkgs.lib.warnOnInstantiate` that also leaves my custom attributes alone.
  # Also changes to an immediate warning for non-derivations.
  warnOnInstantiate =
    msg: drv:
    if !(pkgs.lib.isDerivation drv) then warn msg drv else
    let
      drvToWrap = removeAttrs drv [
        "meta"
        "name"
        "type"
        "_Rhys-T"
      ];
    in
    drv // mapAttrs (_: warn msg) drvToWrap;
    
    oldestSupportedReleaseIsAtLeast = pkgs.lib.oldestSupportedReleaseIsAtLeast or pkgs.lib.isInOldestRelease;
    isDeprecated = {
      allegro5 = oldestSupportedReleaseIsAtLeast 2505;
      ldc = oldestSupportedReleaseIsAtLeast 2505;
      mame = oldestSupportedReleaseIsAtLeast 2505;
      picolisp = oldestSupportedReleaseIsAtLeast 2505;
      pr419640 = oldestSupportedReleaseIsAtLeast 2511;
    };
    warnDeprecated = mapAttrs (deprType: isDepd: attr: pkg: myPkg: let
      isDrv = pkgs.lib.isDerivation pkg;
      noun = if isDrv then "package" else "attribute";
      nameOverrides = {
        picolisp = "picolisp"; # otherwise it says "PicoLisp"
      };
    in if isDepd then
      warnOnInstantiate "Rhys-T's `${attr}` ${noun} is deprecated. Please use ${
        if attr == "hbmame-metal" then
          "Rhys-T's main `hbmame` package"
        else
          "the `${nameOverrides.${attr} or (if isDrv then pkgs.lib.getName pkg else attr)}` ${noun} from Nixpkgs"
      } instead." (pkg // pkgs.lib.optionalAttrs (myPkg?meta.description) {
        meta = pkg.meta // { description = myPkg.meta.description + pkgs.lib.optionalString (!(pkgs.lib.hasInfix "[DEPRECATED]" myPkg.meta.description)) " [DEPRECATED]"; };
      })
    else myPkg) isDeprecated;
}
