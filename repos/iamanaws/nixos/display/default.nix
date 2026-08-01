{
  hostConfig,
  lib,
  pkgs,
  nixosModules,
  ...
}:
{
  imports = [
    nixosModules.programs.firefox
  ]
  ++ lib.optional hostConfig.hyprland nixosModules.display.hyprland
  ++ lib.optional hostConfig.gnome nixosModules.programs.gnome;

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    nerd-fonts.ubuntu-mono
  ];

  services = {
    gnome.gnome-keyring.enable = lib.mkDefault true;

    # Enable sound
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  environment.systemPackages = (
    with pkgs;
    [
      # ghostty
      fuse

      brightnessctl
      playerctl
      tray-tui

      rofi
      rofi-bluetooth
      networkmanager_dmenu
      nur.iamanaws.dmenu-wpctl
    ]
    ++ lib.optionals hostConfig.hyprland [
      grim
      slurp
      hyprpaper
      hyprpicker
      hyprsysteminfo
      # hyprlock
      hyprsunset
      hyprpolkitagent
      wl-clipboard
    ]
  );

  security.polkit.enable = true;
}
