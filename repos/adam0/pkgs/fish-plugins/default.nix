{
  lib,
  callPackage,
  fishPlugins,
}: let
  inherit
    (builtins)
    readDir
    mapAttrs
    ;
  inherit
    (lib)
    filterAttrs
    pipe
    ;

  root = ./.;
  inherit (fishPlugins) buildFishPlugin;

  call = name: callPackage (root + "/${name}") {inherit buildFishPlugin;};
in
  pipe root [
    readDir
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs (name: _: call name))
  ]
  // {
    inherit buildFishPlugin;
  }
