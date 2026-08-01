{ ... }:

{
  services.xserver.enable = false;

  programs.hyprland = {
    enable = true;
    # .override {
    #   withUWSM = true;
    # };
  };

  programs.hyprlock = {
    enable = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      binPath = "/run/current-system/sw/bin/Hyprland";
      comment = "Hyprland session managed by uwsm";
      prettyName = "Hyprland";
    };
  };

  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # services = {
  #   displayManager = {
  #     defaultSession = "hyprland";
  #   };
  # };

  security.pam.services.hyprlock = { };

}
