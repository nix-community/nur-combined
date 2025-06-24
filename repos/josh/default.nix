{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;

  callPackage = pkgs.lib.callPackageWith (pkgs // { nur.repos.josh = pkgs'; });

  packagesFromDirectory =
    directory:
    lib.attrsets.concatMapAttrs (
      name: type:
      let
        filename = lib.path.append directory name;
        isNix = lib.strings.hasSuffix ".nix" name;
        basename = lib.strings.removeSuffix ".nix" name;
      in
      if type == "regular" && isNix then { "${basename}" = callPackage filename { }; } else { }
    ) (builtins.readDir directory);

  pkgs' = lib.attrsets.concatMapAttrs (
    name: type:
    let
      dirname = lib.path.append ./pkgs name;
    in
    if type == "directory" then packagesFromDirectory dirname else { }
  ) (builtins.readDir ./pkgs);
in
pkgs'
