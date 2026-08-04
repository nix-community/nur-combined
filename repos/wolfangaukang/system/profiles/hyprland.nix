{ ... }:

{
  imports = [
    ./wayland.nix
  ];

  programs = {
    hyprland.enable = true;
    xwayland.enable = true;
  };
  environment.sessionVariables.HYPRLAND_LOG_WLR = "1";
}
