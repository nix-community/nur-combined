{ pkgs, ... }: {
  imports = [ ./base.nix ];

  console.useXkbConfig = true; # use xkbOptions in tty.

  fonts.fontconfig = {
    hinting.style = "medium";
    subpixel.rgba = "rgb";
  };

  networking = {
    dhcpcd.enable = false;
    networkmanager = {
      enable = true;
      wifi = {
        # backend = "iwd";
        macAddress = "random";
      };
    };
  };

  services = {
    automatic-timezoned.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
