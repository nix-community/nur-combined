
{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib stdenv;

  # Recursively find all ./pkgs/**/default.nix files
  findDefaultNixFiles = path:
    lib.flatten (lib.mapAttrsToList (name: type:
      let fullPath = "${toString path}/${name}";
      in if type == "directory" then findDefaultNixFiles fullPath
         else if name == "default.nix" then [ fullPath ]
         else []
    ) (builtins.readDir path));

  defaultNixFiles = findDefaultNixFiles ./pkgs;

  # Turn file path into attribute name (e.g. pkgs/chat/chatterino → chatterino)
  deriveName = path:
    builtins.baseNameOf (toString (builtins.dirOf path));

  rawPackages = lib.genAttrs (map deriveName defaultNixFiles) (name:
    let
      file = lib.findFirst (p: deriveName p == name) null defaultNixFiles;
      drv = pkgs.callPackage file {};
    in
      if lib.elem stdenv.hostPlatform.system (drv.meta.platforms or []) then drv else null
  );

  filteredPackages = lib.filterAttrs (_: v: v != null) rawPackages;

in {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
} // filteredPackages

