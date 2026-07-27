{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.shell.git;
in
{
  options.modules.shell.git = {
    enable = mkEnableOption "enable git";
  };
  config = mkIf cfg.enable {
    environment = {
      # Install some packages
      systemPackages = with pkgs; [
        git
        # gitAndTools.git-extras
        (mkIf config.modules.shell.gnupg.enable
          gitAndTools.git-crypt)
        lazygit
      ];
      # Default gitconfig
      etc."gitconfig".source = ./git/config;
      etc."gitignore".source = ./git/ignore;
    };
  };
}
