{ config, pkgs, ... }: {
  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
