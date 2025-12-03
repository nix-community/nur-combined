# Profile for physical devices
{
  inputs,
  lib,
  hostname,
  pkgs,
  ...
}:

let
  inherit (inputs) self;
  localLib = import "${self}/lib" { inherit inputs lib; };
  inherit (localLib) obtainIPV4Address;
  hostList = [
    "grimsnes"
    "surtsey"
    "irazu"
    "arenal"
  ];
  zerotierIps = builtins.listToAttrs (
    map (host: {
      name = host;
      value = obtainIPV4Address "${host}" "activos";
    }) hostList
  );

in
{
  environment.systemPackages = with pkgs; [
    # Android
    jmtpfs

    # iOS
    ifuse
    libimobiledevice

    # Display management
    ddcutil
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    graphics.enable = true;
    i2c.enable = true; # Display management
  };

  networking = {
    hosts = builtins.listToAttrs (
      map (host: {
        name = "${zerotierIps.${host}}";
        value = [ "${host}" ];
      }) hostList
    );
    firewall = {
      enable = false;
      allowedTCPPorts = [
        23561 # F;sskjfd
      ];
      allowedUDPPorts = [ ];
    };
    networkmanager.enable = true;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      sandbox = true;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  profile = {
    specialisations.work.simplerisk.enable = true;
    predicates.unfreePackages = [
      "video-downloadhelper"
      "zerotierone"
    ];
  };

  programs = {
    adb.enable = true;
    fuse.userAllowOther = true;
  };

  # Remember to add users to the rfkillers group
  security = {
    doas.extraConfig = ''
      permit nopass :rfkillers as root cmd /run/current-system/sw/bin/rfkill
    '';
    sudo.extraConfig = ''
      %rfkillers ALL=(root) NOPASSWD: /run/current-system/sw/bin/rfkill
    '';
  };

  services = {
    pipewire = {
      audio.enable = true;
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };
    pulseaudio.enable = lib.mkForce false;
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = 17131;
        }
        {
          addr = (obtainIPV4Address hostname "activos");
          port = 22;
        }
      ];
    };
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "a09acf02337dcfe5" ];
    };
  };

  time.timeZone = "America/Costa_Rica";
}
