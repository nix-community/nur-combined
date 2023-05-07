{ pkgs ? import <nixpkgs> { } }:
with pkgs.lib;
let
  newPkgs = foldl'
    (acc: overlay: acc.extend overlay)
    pkgs
    [
      (import ./modules/firefox/firefox-addons/overlay.nix)
      (final: prev: {
        lib = prev.lib // {
          mergeAttrList = foldl' mergeAttrs { };
        };
      })
    ];

  makeRecurseIntoAttrs = set:
    let
      g =
        name: value:
        if !isAttrs value || isDerivation value then
          value
        else
          makeRecurseIntoAttrs value;
    in
    recurseIntoAttrs (mapAttrs g set);

  collectPackages = path: dirname:
    let
      set = builtins.readDir path;
    in
    foldl'
      (acc: name:
        let
          newPath = path + ("/" + name);
        in
        acc //
        (if name == "package.nix" then
          { ${dirname} = newPkgs.callPackage newPath { }; }
        else if name == "packages.nix" then
          { ${dirname} = makeRecurseIntoAttrs (filterAttrs (n: isDerivation) (newPkgs.callPackage newPath { })); }
        else optionalAttrs (set.${name} == "directory") (collectPackages newPath name)))
      { }
      (attrNames set);
in
collectPackages ./modules root
