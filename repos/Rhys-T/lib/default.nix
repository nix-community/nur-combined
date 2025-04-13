{ pkgs }:

with pkgs.lib; {
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
}
