{
  lib,
  config,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./homelab.nix
    ./home.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];
  # Disable modules that conflict with SD image builds or are inappropriate
  # for a small embedded device.
  nix-mineral.enable = lib.mkForce false;
  programs.nix-index.enable = lib.mkForce false;
  programs.nix-index-database.comma.enable = lib.mkForce false;
  services.smartd.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    iw
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi3;
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
    };
    tmp.cleanOnBoot = true;
    swraid.enable = lib.mkForce false;
    supportedFilesystems.zfs = lib.mkForce false;
    zfs.forceImportRoot = lib.mkForce false;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    kernelParams = [ "dwc_otg.fiq_fsm_mask=0x3" ];
    extraModprobeConfig = ''
      options brcmfmac roamoff=1 pm_config=1
    '';
  };

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.settings.Macs = [
    # Current defaults:
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
    # Added:
    "hmac-sha2-256"
  ];
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # size in MiB
    }
  ];

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
    hostName = "pi1";
    useDHCP = false;
    interfaces."wlan0".useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      secretsFile = config.sops.templates."wireless.conf".path;
      networks."samosa".pskRaw = "ext:psk_samosa";
    };
    firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    # Comcast blocks inbound IPv4 port forwarding, so *.avyay.in is served
    # directly over pi1's public IPv6 address instead. Disable privacy
    # extensions so that address stays stable for DNS instead of rotating.
    tempAddresses = "disabled";
  };

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

  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-exit-node"
      "--ssh"
    ];
  };
  services.timesyncd.enable = lib.mkForce true;
  services.getty.autologinUser = "avy";

  hardware = {
    enableRedistributableFirmware = lib.mkForce true;
    firmware = [ pkgs.raspberrypiWirelessFirmware ];
  };

  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  sdImage.compressImage = true;

  # SD card storage is the tightest resource on this device, so garbage
  # collect and dedup aggressively rather than the repo-wide weekly/7d
  # defaults in modules/nix.
  nix = {
    settings = {
      min-free = lib.mkForce (128 * 1024 * 1024);
      max-free = lib.mkForce (1024 * 1024 * 1024);
    };
    gc = {
      automatic = lib.mkForce true;
      dates = lib.mkForce "daily";
      options = lib.mkForce "-d --delete-older-than 3d";
    };
    optimise = {
      automatic = lib.mkForce true;
      dates = lib.mkForce [ "daily" ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  users = {
    mutableUsers = false;
    users.root.password = "root";
    users.avy.hashedPassword = "!";
  };

  system.stateVersion = "25.05";
  systemd.services.wifi-powersave-off = {
    description = "Disable WiFi power saving";
    after = [ "sys-subsystem-net-devices-wlan0.device" ];
    bindsTo = [ "sys-subsystem-net-devices-wlan0.device" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iw}/bin/iw dev wlan0 set power_save off";
    };
  };
}
