{
  # keep-sorted start
  callPackage,
  fishPlugins,
  lib,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    mapAttrs
    readDir
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    filterAttrs
    pipe
    platforms
    # keep-sorted end
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
