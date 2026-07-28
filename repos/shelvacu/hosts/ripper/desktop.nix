{ ... }: {
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.settings.General.DisplayServer = "wayland";
  services.displayManager.autoLogin = {
    enable = true;
    user = "ripper";
  };
}
