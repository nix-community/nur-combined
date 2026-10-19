{
  lib,
  config,
  ...
}:
{
  nix-mineral.enable = lib.mkForce false;
  programs.nix-index.enable = lib.mkForce false;
  programs.nix-index-database.comma.enable = lib.mkForce false;
  # home-manager.users.avy.programs.nix-index.enable = lib.mkForce false;
  # home-manager.users.avy.programs.nix-index-database.comma.enable = lib.mkForce false;
  # home-manager.users.avy.catppuccin.enable = lib.mkForce false;
  nix.settings.trusted-users = [ "@wheel" ];
  system.stateVersion = "25.11";

  sops.secrets.wifi-password = {
    sopsFile = ../../../secrets/secrets.yaml;
    key = "wifi/password";
  };
  sops.templates."wireless.conf" = {
    content = ''
      psk_samosa=${config.sops.placeholder.wifi-password}
    '';
    owner = "wpa_supplicant";
    mode = "0400";
  };

  networking = {
    useDHCP = false;
    interfaces."wlan0".useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      secretsFile = config.sops.templates."wireless.conf".path;
      # ! Change the following to connect to your own network
      networks = {
        "samosa" = {
          pskRaw = "ext:psk_samosa";
        };
      };
    };
  };
  services.sshd.enable = true;
  services.tailscale.enable = true;
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # NTP time sync.
  services.timesyncd.enable = lib.mkForce true;
  users.users.avy = {
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  # ! Be sure to change the autologinUser.
  services.getty.autologinUser = "avy";

  # ! change the host name if you like
  networking.hostName = "pi0";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  # Hardware config (device tree overlays, kernel, zram, wifi firmware) and
  # base sd-image settings (image.fileName, extraFirmwareConfig) come from
  # inputs.nixos-pi-zero-2's `hardware` and `sd-image` modules.
  sdImage = {
    # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low on space.
    compressImage = true;

    # dwc2 gadget mode needed for the USB ethernet gadget below.
    populateFirmwareCommands = lib.mkAfter ''
      config=firmware/config.txt
      chmod u+w $config
      echo "dtoverlay=dwc2,dr_mode=peripheral" >> $config
      chmod u-w $config
    '';
  };

  # USB ethernet gadget over the data micro-USB port, so pi0 is reachable
  # over a direct USB cable before wifi credentials are available.
  boot.kernelModules = [
    "dwc2"
    "g_ether"
  ];
  boot.kernelParams = [ "modules-load=dwc2,g_ether" ];

  networking.interfaces.usb0.ipv4.addresses = [
    {
      address = "192.168.7.2";
      prefixLength = 24;
    }
  ];
}
