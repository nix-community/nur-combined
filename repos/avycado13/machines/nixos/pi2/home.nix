{ lib, pkgs, ... }:
{
  imports = [
    ../../../modules/nixos/apps/tuigreet.nix
  ];
  programs.zsh.enable = true;
  users.users.avy.shell = pkgs.zsh;
  dots = {
    terminal = {
      enable = true;
      st.enable = true;
    };
    apps.qutebrowser.enable = true;
    theme.enable = true;
  };

  services.tuigreet = {
    enable = true;
    remember = true;
  };

  # ultra lightweight desktop enviroment (JWM)
  services.xserver.windowManager.jwm.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true;
  };

  home-manager.users.avy.home.stateVersion = lib.mkForce "26.05";
}
