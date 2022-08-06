{pkgs, global, ...}: {
  imports = [
    ../../modules/gui/system.nix
  ];
  services.xserver.displayManager.lightdm = {
    background = pkgs.custom.wallpaper;
    greeters.enso = {
      enable = true;
      blur = true;
    };
  };

  fonts.fonts = with pkgs; [
    siji
    noto-fonts
    noto-fonts-emoji
    fira-code
  ];

  services.xserver = {
    layout = "br,us";
    xkbOptions = "grp:win_space_toggle,terminate:ctrl_alt_bksp";
    xkbModel = "acer_laptop";
    xkbVariant = ",";
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Redshift
  services.redshift.enable = true;
  location = {
    latitude = -24.0;
    longitude = -54.0;
  };
}
