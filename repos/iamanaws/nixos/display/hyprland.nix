{
  services.xserver.enable = false;

  programs.hyprland = {
    enable = true;
  };

  programs.hyprlock = {
    enable = true;
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
