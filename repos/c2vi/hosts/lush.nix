{ lib, pkgs, inputs, secretsDir, workDir, ... }:
{
  
  #system.stateVersion = "23.05"; # Did you read the comment?

  imports = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      #inputs.nixos-hardware.nixosModules.raspberry-pi-4
      inputs.networkmanager.nixosModules.networkmanager

      ../common/all.nix

	  	inputs.home-manager.nixosModules.home-manager
		  ../users/me/headless.nix

      ##### project modules #####

      # the module for the zwave setup
      #"${workDir}/htl/labor/hackl/zwave.nix"

      # labor nas project
      # with this moduel it does not boot, it waits for /dev/disk/by-label/nas-storage
      # "${workDir}/htl/labor/nas/nixos/lush-module.nix"
  ];

  # fix bluetooth
  hardware = {
    bluetooth = {
      package = pkgs.bluez;
      enable = true;
      powerOnBoot = false;
    };
  };
  
  boot.kernelParams = lib.mkForce ["console=ttyS0,115200n8" "console=tty0" "nohibernate" "loglevel=7" ];
	# hardware.bluetooth.enable = true;



 # home-manager.users.me = import ../users/me/home-headless.nix;


  /* for cross compiling
  #nixpkgs.hostPlatform.system = "aarch64-linux";
  #nixpkgs.buildPlatform.system = "x86_64-linux";
  nixpkgs.overlays = [

    (outerFinal: outerPrev: {
    #https://github.com/adrienverge/openfortivpn/issues/446
    #https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/tools/networking/openfortivpn/default.nix#L47
      openfortivpn = outerPrev.openfortivpn.overrideAttrs (final: prev: {
        configureFlags = prev.configureFlags or [] ++ [
          "--disable-proc"
          "--with-rt_dst=yes"
          "--with-pppd=/usr/sbin/pppd"
        ];
      });
    })
  ];
  */

  services.blueman.enable = true;
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

  ########################### ssh ############################
  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  	settings.PermitRootLogin = "no";
    settings.X11Forwarding = true;
    extraConfig = ''
      X11UseLocalhost no
    '';
  };


  ####################################### networking ##########################

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
      51820  # wireguard
      67 # allow DHCP traffic
      53 # allow dns
	];

  networking.hostName = "lush";

  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    home = {
      connection = {
        id = "main";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "-999";
        interface-name = "eth0";
        autoconnect = true;
      };

      ipv4 = {
        address1 = "192.168.1.44/24,192.168.1.1";
        dns = "1.1.1.1;";
        method = "manual";
      };
    };

    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlan0";
      };

      wifi = {
        hidden = "true";
        mode = "infrastructure";
        ssid = builtins.readFile "${secretsDir}/wifi-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/wifi-password";
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
        autoconnect = false;
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

    pt = {
      connection = {
        id = "pt";
        uuid = "f028117e-9eef-47c1-8483-574f7ee798a4";
        type = "bluetooth";
        autoconnect = true;
      };

      bluetooth = {
        bdaddr = "E8:78:29:C4:BA:7C";
        type = "panu";
      };

      ipv4 = {
        address1 = "192.168.44.22/24";
        method = "auto";
      };
    };


    /*
    me = {
     connection = {
        id = "me";
        uuid = "fe45d3bc-21c6-41ff-bc06-c936017c6e02";
        type = "wireguard";
        autoconnect = "true";
        interface-name = "me0";
     };
      wireguard = {
        listen-port = "51820";
        private-key = builtins.readFile "${secretsDir}/wg-private-lush";
      };
      ipv4 = {
        address1 = "10.1.1.4/24";
        method = "manual";
      };
    } // (import ../common/wg-peers.nix { inherit secretsDir; });
    */
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
