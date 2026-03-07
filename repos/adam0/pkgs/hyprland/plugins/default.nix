{
  callPackage,
  hyprland,
  lib,
  pkg-config,
  ...
} @ topLevelArgs: let
  inherit (builtins) readDir;
  inherit
    (lib)
    pipe
    filterAttrs
    mapAttrs
    ;

  mkHyprlandPlugin = {
    pluginName,
    hyprland ? topLevelArgs.hyprland,
    nativeBuildInputs ? [],
    buildInputs ? [],
    ...
  } @ args:
    hyprland.stdenv.mkDerivation (
      args
      // {
        pname = pluginName;
        nativeBuildInputs = nativeBuildInputs ++ [pkg-config];
        buildInputs = buildInputs ++ [hyprland] ++ hyprland.buildInputs;
        meta =
          {
            description = "";
            longDescription = "";
            platforms = hyprland.meta.platforms;
          }
          // (args.meta or {});
      }
    );

  root = ./.;
  call = name: _: callPackage (root + "/${name}") {inherit mkHyprlandPlugin;};
in
  pipe root [
    readDir
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs call)
  ]
  // {
    inherit mkHyprlandPlugin;
  }
