{
  lib,
  callPackage,
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

  mkSpicetifyExtension = args @ {meta ? {}, ...}:
    args
    // {
      meta =
        meta
        // {
          description = meta.description or "";
          platforms = meta.platforms or platforms.all;
        };
    };

  call = name: callPackage (root + "/${name}") {inherit mkSpicetifyExtension;};
in
  pipe root [
    readDir
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs (name: _: call name))
  ]
  // {
    inherit mkSpicetifyExtension;
  }
