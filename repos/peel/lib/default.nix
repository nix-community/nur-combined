{ pkgs }:

with pkgs.lib; {
  mkOverlay = username:
              let homePath = if pkgs.stdenv isDarwin then "Users" else "home";
              in builtins.toPath "/${homePath}/${username}/.config/nurpkgs";
}
