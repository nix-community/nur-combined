{ config, lib, pkgs, ... }: {

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
  services.lorri.enable = true;
}
