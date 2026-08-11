{pkgs, ...}: {
  services.flatpak.enable = true;
  # Apply available Flatpak updates whenever this NixOS configuration activates.
  services.flatpak.update.onActivation = true;
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
    config.common.default = "kde";
  };
}
