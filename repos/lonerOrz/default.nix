# {
#   # The `lib`, `modules`, and `overlays` names are special
#   lib = import ./lib { inherit pkgs; }; # functions
#   modules = import ./modules; # NixOS modules
#   overlays = import ./overlays; # nixpkgs overlays
#
#   # example-package = pkgs.callPackage ./pkgs/example-package { };
#   xdman7 = pkgs.callPackage ./pkgs/xdman7 { };
#   abdm = pkgs.callPackage ./pkgs/abdm { };
#   mpv-handler = pkgs.callPackage ./pkgs/mpv-handler { };
#   astronaut-sddm = pkgs.callPackage ./pkgs/astronaut-sddm { };
#   bongocat = pkgs.callPackage ./pkgs/bongocat { };
#   linux-wallpaperengine = pkgs.callPackage ./pkgs/linux-wallpaperengine { };
# }

{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  dir ? ./pkgs,
  pkgFileName ? "default.nix",
}:
let
  lib = pkgs.lib;
  entries = builtins.readDir dir;

  excludedNames = [ ]; # exclud import packages
  names = lib.filter (name: !(lib.elem name excludedNames)) (builtins.attrNames entries);

  importDir = lib.foldl' (
    acc: name:
    let
      path = dir + "/${name}";
      kind = entries.${name};
    in
    if kind == "regular" && lib.hasSuffix ".nix" name then
      let
        relativePath = dir + "/${name}";
        drv = pkgs.callPackage relativePath { };
      in
      acc
      // {
        "${lib.removeSuffix ".nix" name}" = drv // {
          passthru = (drv.passthru or { }) // {
            updateFile = relativePath;
          };
        };
      }
    else if kind == "directory" then
      let
        subPath = dir + "/${name}/${pkgFileName}";
      in
      if builtins.pathExists subPath then
        let
          drv = pkgs.callPackage subPath { };
        in
        acc
        // {
          "${name}" = drv // {
            passthru = (drv.passthru or { }) // {
              updateFile = subPath;
            };
          };
        }
      else
        acc
    else
      acc
  ) { } names;

in
importDir
