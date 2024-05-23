{
  pkgs ? import <nixpkgs> { },
}:
builtins.removeAttrs (import ./pkgs { inherit pkgs; }) [
  "catppuccin-discord-git"
  "vscode-insiders"
  "vscode-insiders-with-extensions"
  "vscodium-insiders"
]
// {
  lib = import ./lib { inherit (pkgs) lib; };
  overlays = rec {
    default = abszero;
    abszero = final: _: import ./pkgs { pkgs = final; };
  };
}
