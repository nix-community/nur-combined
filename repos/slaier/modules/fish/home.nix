{ config, pkgs, ... }: {
  programs.fzf.enable = true;
  programs.fish = {
    enable = true;
  };
}
