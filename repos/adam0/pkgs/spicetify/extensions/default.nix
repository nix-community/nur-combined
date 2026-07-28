{
  # keep-sorted start
  callPackage,
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

  mkSpicetifyExtension = args @ {meta ? {}, ...}:
    args
    // {
      meta =
        meta
        // {
          # keep-sorted start
          description = meta.description or "";
          platforms = meta.platforms or platforms.all;
          # keep-sorted end
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
