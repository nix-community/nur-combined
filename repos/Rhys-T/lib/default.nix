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
  warnOnInstantiate =
    msg: drv:
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
    deprecateMAMEBuilds = oldestSupportedReleaseIsAtLeast 2505;
    warnMAME = attr: mame: myMAME: if deprecateMAMEBuilds then
      warnOnInstantiate "Rhys-T's `${attr}` package is deprecated. Please use ${
        if pkgs.lib.getName mame == "hbmame" then
          "Rhys-T's main `hbmame` package"
        else
          "the `mame` package from Nixpkgs"
      } instead." mame
    else myMAME;
}
