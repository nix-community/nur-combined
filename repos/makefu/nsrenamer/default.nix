{ pkgs,... }:
# TODO: dependencies: coreutils, nx_game_info,
pkgs.writeScriptBin "nsrenamer" (builtins.readFile ./nsrenamer.sh)
