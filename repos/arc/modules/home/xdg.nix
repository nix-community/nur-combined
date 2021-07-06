{ config, lib, ... }: with lib; let
  userDirs = getAttrs [
    "desktop" "documents" "download" "music" "pictures" "publicShare" "templates" "videos"
  ] config.xdg.userDirs;
in {
  options.xdg.userDirs.absolute = mkOption {
    type = with types; attrsOf path;
    readOnly = true;
  };

  config.xdg.userDirs.absolute =
    mapAttrs (_: replaceStrings [ "$HOME" ] [ config.home.homeDirectory ]) userDirs;
}
