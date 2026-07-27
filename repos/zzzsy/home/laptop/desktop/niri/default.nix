{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    wl-clipboard
    wdisplays
    bluetui
    nirius
    imagemagick
    gpu-screen-recorder
    evtest
    # noctalia-shell
  ];
  # ++ [ inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  xdg.enable = true;
  xdg.portal = with pkgs; {
    enable = true;
    configPackages = [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal
    ];
    extraPortals = [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal
    ];
    xdgOpenUsePortal = true;
  };
  programs.noctalia = {
    enable = true;
  };
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/flakes/home/laptop/desktop/niri/niri.kdl";
}
