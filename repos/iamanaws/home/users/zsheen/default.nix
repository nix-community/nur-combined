{ ... }:

{
  imports = [ ../../shared/services/flatpak.nix ];

  home = {
    username = "zsheen";
    homeDirectory = "/home/zsheen";
  };

  programs.home-manager.enable = true;

  services.flatpak.packages = [
    "org.vinegarhq.Sober"
  ];

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.05";
}
