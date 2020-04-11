{ config, lib, pkgs, ... }:
{
  imports = [ ./git.nix ];
  home.packages = with pkgs; [ stack nixops ];

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.jq.enable = true;

  programs.emacs.enable = true;
  services.emacs.enable = true;

  programs.kakoune.enable = true;
  programs.kakoune.config = {
    colorScheme = "solarized-dark";
    numberLines.enable = true;
    showWhitespace.enable = true;
    ui.enableMouse = true;
  };
  services.lorri.enable = true;

  home.file.".stack/config.yaml".source =
    ./stack-config.yaml;
}
