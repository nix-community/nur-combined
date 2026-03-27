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
    platforms
    ;

  root = ./.;
  buildFishPlugin = args @ {meta ? {}, ...}:
    fishPlugins.buildFishPlugin (
      args
      // {
        meta =
          meta
          // {
            description = meta.description or "";
            platforms = meta.platforms or platforms.unix;
          };
      }
    );

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
