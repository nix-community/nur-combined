{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.nix-ld;
in
{
  options.nixcfg.nix-ld.enable = lib.mkEnableOption "nix-ld with bundled libraries for appimages and dynamic binaries";

  config = lib.mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries =
        with pkgs;
        (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
        ++ (appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
        ++ [
          SDL
          SDL_image
          SDL_mixer
          SDL_ttf
          freeglut
          fuse
          fuse3
          icu
          libclang.lib
          libdbusmenu
          libgcc
          libxcrypt-legacy
          libxml2
          mesa
          pcre
          pcre-cpp
          pcre2
          python3
          stdenv.cc.cc
          xz
        ];
    };
  };
}
