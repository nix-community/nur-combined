{ lib, secretsDir, pkgs, inputs, unstable, ... }: let

in {

  imports = [
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    inputs.networkmanager.nixosModules.networkmanager
    inputs.disko.nixosModules.disko
    ../users/me/gui.nix
    ../users/root/default.nix
    ../common/nixos-wayland.nix
  ];
  services.tailscale.enable = true;
  programs.nix-ld.enable = true;

  services.keyd.enable = lib.mkForce false;

	networking.hostName = "ki";
  networking.firewall.enable = false;
  services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
  };
	networking.firewall.allowedTCPPorts = [
		8888 # for general usage
		9999 # for general usage
    6000 # Xserver
    6666 # vnc sway
    5900 # vnc for win VM
    5901 # vnc
    5902 # vnc
    4400 # rdp win VM
    4401 # ssh for mandroid
    4402 # random
    4403 # random
    4404 # random
    4405 # clipboard sync
	];

	networking.firewall.allowedUDPPorts = [
      48899 # GoodWe inverter discovery
      4410 # lan-mouse
      41641 # tailscale
	];

  services.resilio = {
    enable = true;
    enableWebUI = true;
    httpListenAddr = "100.96.201.42";
    checkForUpdates = false;
    listeningPort = 44444;
  };
  users.users.me.extraGroups = [ "rslsync" ];
  users.users.rslsync.extraGroups = [ "users" ];
  users.users.me.homeMode = "770"; # important for resilio
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    44444 # resilio sync
    9000 # resilio webui
  ];


	swapDevices = [ { device = "/swapfile"; } ];

  boot.kernelModules = [ "usbip_core" ];
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  home-manager.users.me.home.file.".config/sway/config".text = ''
    exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 6666
  '';

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuSwtpm = true;
    #qemuOvmfPackage = pkgs.OVMFFull;
  };

  environment.systemPackages = with pkgs; [
    linuxPackages.usbip
    helvum
    passt
    mount
    pkgs.hicolor-icon-theme
    efibootmgr
    tcpdump
  ];


	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "no";

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
	};

  systemd.extraConfig = "DefaultLimitNOFILE=2048";

	services.logind = {
		extraConfig = ''
			HandlePowerKey=suspend-then-hibernate
		'';
		lidSwitch = "ignore";
		lidSwitchExternalPower = "ignore";
		lidSwitchDocked = "ignore";
	};

  services.dbus.enable = true;

  fonts.enableDefaultPackages = true;
  xdg.icons.enable = true;
  gtk.iconCache.enable = true;

  services.udisks2.enable = false;
  hardware.opengl.enable = true;
  hardware.enableRedistributableFirmware = true;

  systemd.defaultUnit = "graphical.target";


  ############################# networkmanager
  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlp2s0";
        autoconnect-priority = "200";
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
        #address1 = "192.168.20.11/24";
        dns = "1.1.1.1;8.8.8.8;";
        method = "auto";
      };
    };

    gw = {
      connection = {
        id = "gw";
        uuid = "de655c52-1af2-4b46-b7b2-8ddad9edb52f";
        type = "wifi";
        interface-name = "wlp2s0";
        autoconnect-priority = "300";
      };

      wifi = {
        hidden = "false";
        mode = "infrastructure";
        ssid = builtins.readFile "${secretsDir}/gw-ssid";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/gw-password";
      };

      ipv4 = {
        #address1 = "192.168.20.11/24";
        dns = "1.1.1.1;8.8.8.8;";
        method = "auto";
      };
    };

    hot = {
      connection = {
        id = "hot";
        uuid = "ab51de8a-9742-465a-928b-be54a83ab6a3";
        type = "wifi";
        autoconnect = false;
        interface-name = "wlp3s0";
      };
      wifi = {
        mode = "ap";
        ssid = "c2vi-ki";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = builtins.readFile "${secretsDir}/wifi-password";
      };

      ipv4 = {
        method = "shared";
      };
    };

    share = {
      connection = {
        id = "share";
        uuid = "f55f34e3-4595-4642-b1f6-df3185bc0a04";
        type = "ethernet";
        autoconnect = false;
        interface-name = "enp2s0";
      };

      ethernet = {
        mac-address = "C8:2A:14:0B:7F:3D";
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

    dhcp = {
      connection = {
        id = "dhcp";
        uuid = "c006389a-1697-4f77-91c3-95b466f85f13";
        type = "ethernet";
        autoconnect = true;
        interface-name = "enp2s0";
      };

      ethernet = {
        mac-address = "C8:2A:14:0B:7F:3D";
      };

      ipv4 = {
        method = "auto";
        address1 = "192.168.1.33/24,192.168.1.1";
      };
    };

  };

  ############### disk config
  boot.plymouth.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "nodev" ];
	boot.loader.grub.extraConfig = ''
		set timeout=2
	'';

  # the flash drive in use for te
  #disko.devices.disk.root.device = "/dev/disk/by-id/usb-Generic_Flash_Disk_FF830E8F-0:0";
  disko.devices.disk.root.device = "/dev/disk/by-id/ata-SSD_HB202408140276168";
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {

            biosboot = {
              size = "2M";
              type = "21686148-6449-6E6F-744E-656564454649"; # BIOS boot
            };

            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
