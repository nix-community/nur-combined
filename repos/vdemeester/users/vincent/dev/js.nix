{ config, pkgs, ... }:
{
  home.file.".npmrc".text = ''
    prefix = ${config.home.homeDirectory}/.local/npm
  '';

  home.packages = with pkgs; [
    javascript-typescript-langserver
    # vscode-langservers-extracted
  ];
}
