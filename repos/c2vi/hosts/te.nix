{ lib, secretsDir, pkgs, inputs, unstable, ... }: let

in {

  #users.users.me.password = builtins.readFile "${secretsDir}/te-password";
  #users.users.root.password = builtins.readFile "${secretsDir}/te-password";

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

	networking.hostName = "te";
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
	];

	networking.firewall.allowedUDPPorts = [
      48899 # GoodWe inverter discovery
      4410 # lan-mouse
	];

	swapDevices = [ 
    { 
      device = "/swapfile";
      size = 4 * 1024;
    } 
  ];

  boot.kernelModules = [ "usbip_core" ];
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuSwtpm = true;
    #qemuOvmfPackage = pkgs.OVMFFull;
  };

  environment.systemPackages = with pkgs; [
    linuxPackages.usbip
    mount
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

  systemd.services."sway@" = let
        mySway = unstable.sway.overrideAttrs (prev: {
            /*
            src = pkgs.fetchFromGitHub {
              owner = "WillPower3309";
              repo = "swayfx";
              rev = "";
              hash = "";
            };
            */
            src = pkgs.fetchFromGitHub {
              owner = "swaywm";
              repo = "sway";
              rev = "73c244fb4807a29c6599d42c15e8a8759225b2d6";
              hash = "sha256-P2w1oRVUNBWajt8jZOxPXvBE29urbrhtORy+lfYqnF8=";
            };
          });
  in {
    enable = false;
    after = [ "systemd-user-sessions.service" "dbus.socket" "systemd-logind.service" "getty@%i.service" "plymouth-deactivate.service" "plymouth-quit.service" ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-deactivate.service" ];
    wantedBy = [ "graphical.target" ];
    conflicts = [ "getty@%i.service" ]; # "plymouth-quit.service" "plymouth-quit-wait.service"

    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${lib.getExe mySway}";
      User = "me";

      # ConditionPathExists = "/dev/tty0";
      IgnoreSIGPIPE = "no";

      # Log this user with utmp, letting it show up with commands 'w' and
      # 'who'. This is needed since we replace (a)getty.
      UtmpIdentifier = "%I";
      UtmpMode = "user";
      # A virtual terminal is needed.
      TTYPath = "/dev/%I";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      # Fail to start if not controlling the virtual terminal.
      #StandardInput = "tty-fail";
      #StandardOutput = "syslog";
      #StandardError = "syslog";
      # Set up a full (custom) user session for the user, required by Cage.
      PAMName = "cage";
    };
  };

  systemd.extraConfig = "DefaultLimitNOFILE=2048";

  ###################################################### the kiosk stuff

  services.dbus.enable = true;

  fonts.enableDefaultPackages = true;
  xdg.icons.enable = true;
  gtk.iconCache.enable = true;

  services.udisks2.enable = false;
  hardware.opengl.enable = true;
  hardware.enableRedistributableFirmware = true;

  systemd.defaultUnit = "graphical.target";


  ############################# networkmanager

  # update name of wifi-interface
  systemd.services.update-wifi-iface = {
    description = "Update Wi-Fi interface name in network manager";
    path = with pkgs; [
      networkmanager  # for nmcli
      iproute2        # for ip
      gawk            # for awk
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScriptBin "run" ''
        name=$(ip link | awk -F: '/^[0-9]+: wl/ {print $2}' | sed 's/^ //')
        nmcli connection modify pw connection.interface-name $name
      ''}/bin/run";
    };
    wantedBy = [ "multi-user.target" ];
    after = [ "Networkmanager.service" "network.target" ];
  };

  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlp3s0";
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

    pt = {
      connection = {
        id = "pt";
        uuid = "f028117e-9eef-47c1-8483-574f7ee798a4";
        type = "bluetooth";
        autoconnect = "false";
      };

      bluetooth = {
        bdaddr = "E8:78:29:C4:BA:7C";
        type = "panu";
      };

      ipv4 = {
        address1 = "192.168.44.11/24";
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
        ssid = "c2vi-te";
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

  };

  ############ boot stuff
  boot.plymouth.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "uhci_hcd"
    "ohci_hcd"
    "usb_storage"
    "uas"
    "sd_mod"
    "sr_mod"
    "scsi_mod"
  ];
	boot.loader.grub.extraConfig = ''
		set timeout=2
	'';

  ############### disk config
  # the flash drive in use for te
  #disko.devices.disk.root.device = "/dev/disk/by-id/usb-Generic_Flash_Disk_FF830E8F-0:0";
  disko.devices.disk.root.device = "/dev/disk/by-id/ata-KBG40ZNV512G_KIOXIA_70GPGA85QBV1";
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {

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

            biosboot = {
              size = "2M";
              type = "21686148-6449-6E6F-744E-656564454649"; # BIOS boot
            };

            root = {
              size = "240G";
              content = {
                # LUKS passphrase will be prompted interactively only
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };

            pub = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "exfat";
                mountpoint = "/pub";
              };
            };
          };
        };
      };
    };
  };
}
