{ lib, pkgs, inputs, secretsDir, workDir, ... }:
{
  
  imports = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      #inputs.nixos-hardware.nixosModules.raspberry-pi-4
      inputs.networkmanager.nixosModules.networkmanager

      ../common/all.nix

	  	inputs.home-manager.nixosModules.home-manager

  ];

  hardware.enableRedistributableFirmware = true;

  # This causes an overlay which causes a lot of rebuilding
  environment.noXlibs = lib.mkForce false;


  environment.systemPackages = with pkgs; [
    vim
    bluez
    git
  ];

  # "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" creates a
  # disk with this label on first boot. Therefore, we need to keep it. It is the
  # only information from the installer image that we need to keep persistent
  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  boot = {
    #kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    loader = {
      generic-extlinux-compatible.enable = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
    };
  };

  users.users.root.password = "changeme";

  ########################### ssh ############################
  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
  	settings.PermitRootLogin = "yes";
    settings.X11Forwarding = true;
    extraConfig = ''
      X11UseLocalhost no
    '';
  };


  ####################################### networking ##########################

  networking.hostName = "lush";

  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        autoconnect = true;
        interface-name = "wlan0";
      };

      wifi = {
        hidden = "true";
        mode = "infrastructure";
        ssid = builtins.readFile "/wifi-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "/wifi-password";
      };

      ipv4 = {
        address1 = "192.168.20.21/24";
        method = "auto";
      };
    };

    share = {
      connection = {
        id = "share";
        uuid = "f55f34e3-4595-4642-b1f6-df3185bc0a04";
        type = "ethernet";
        autoconnect = true;
        interface-name = "eth0";
      };

      ethernet = {
        mac-address = "F4:39:09:4A:DF:0E";
      };

      ipv4 = {
        address1 = "192.168.4.1/24";
        method = "shared";
      };

      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
    };

  };


  systemd.services.iwd.serviceConfig.Restart = "always";
  /*
  networking = {
    interfaces."wlan0".useDHCP = true;

    interfaces."eth0" = {
				#name = "eth0";
				ipv4.addresses = [
					{ address = "192.168.5.5"; prefixLength = 24;}
				];
    };
    */

    /*
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        seb-phone.psk = "hellogello";
      };
    };
  };

    */


  ####################################### wireguard ##########################
  /*
  systemd.network.netdevs.me0 = {
    enable = true;
    wireguardPeers = import ../common/wg-peers.nix { inherit secretsDir; };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKeyFile = "/etc/wireguard/secret.key";
    };
  };
  networking.wireguard.interfaces = {
    me = {
      ips = [ "10.1.1.11/24" ];
  };
  */

  /*
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  */

}
