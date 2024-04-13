{ pkgs, ... }: {
  imports = [ ./base.nix ];

  console.useXkbConfig = true; # use xkbOptions in tty.

  fonts.fontconfig = {
    hinting.style = "medium";
    subpixel.rgba = "rgb";
  };

  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "9.9.9.9"
      "149.112.112.112"
    ];
    search = [ "~." ]; # Always use global name servers
    dhcpcd.enable = false;
    # networkmanager = {
    #   enable = true;
    #   wifi = {
    #     backend = "iwd";
    #     macAddress = "random";
    #   };
    # };
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
          AddressRandomization = "network";
        };
        Network.NameResolvingService = "systemd"; # Use resolved
        Settings.AlwaysRandomizeAddress = true;
      };
    };
  };

  services = {
    automatic-timezoned.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    resolved = {
      enable = true;
      fallbackDns = [ ]; # disable fallback DNS
      dnsovertls = "true";
      dnssec = "true";
      llmnr = "false";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
