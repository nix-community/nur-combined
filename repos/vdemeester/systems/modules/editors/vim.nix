{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.editors.vim;
in
{
  options.modules.editors.vim = {
    enable = mkEnableOption "enable vim editor";
  };
  config = mkIf cfg.enable {
    environment = {
      systemPackages = [ pkgs.vim ];
      shellAliases = {
        v = "vim";
      };
    };
  };
}
