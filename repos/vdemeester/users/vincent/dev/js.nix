{ config, pkgs, ... }:
{
  home.file.".npmrc".text = ''
    prefix = ${config.home.homeDirectory}/.local/npm
  '';
}
