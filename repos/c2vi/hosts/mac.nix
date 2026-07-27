{ lib, secretsDir, pkgs, inputs, unstable, ... }: let

myobs = pkgs.wrapOBS {
  plugins = with pkgs.obs-studio-plugins; [
    obs-ndi
    obs-teleport
      droidcam-obs
  ];
};


in {

  imports = [
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    inputs.networkmanager.nixosModules.networkmanager
    ../users/me/gui.nix
    ../users/root/default.nix
    ../common/nixos-wayland.nix
  ];
  services.tailscale.enable = true;
  programs.nix-ld.enable = true;

  #services.pid-fan-controller.enable = true;

	networking.hostName = "mac";
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
	];
	
	##### Netbird Configuration
  services.netbird.clients.ppc = {
    #login = {
      #enable = true;
      #setupKeyFile = "${secretsDir}/netbird-setup-key";
      #};
    port = 51821;
    ui.enable = false;
    openFirewall = true;
    #openInternalFirewall = true;
  };
  

	swapDevices = [ { device = "/swapfile"; } ];

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

	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
    #device = "/dev/nbd1";
    device = "nodev";
  	efiSupport = true;
		extraConfig = ''
			set timeout=2
		'';
  };
  
  # fix bluetooth-3-0-keyboard not reporting left and right cmd seperately (and remapping the other things the way i want them)
  services.udev.extraHwdb = ''
    evdev:input:b0005v05AC*
      KEYBOARD_KEY_700e3=leftctrl
      KEYBOARD_KEY_700e7=rightalt
      KEYBOARD_KEY_700e2=leftmeta
      KEYBOARD_KEY_700e0=leftalt
  '';
  
  # fan speed fix
  systemd.services.my-fan-speed-fix = {
    description = "Set applesmc fan values";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        /bin/sh -c 'echo 1 > /sys/devices/platform/applesmc.768/fan2_manual; echo 1000 > /sys/devices/platform/applesmc.768/fan2_output'
      '';
    };
    #startAt = "*:0/3"; # Runs every 3 minutes
    wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
  };

  environment.systemPackages = with pkgs; [
    myobs
    lm_sensors
    linuxPackages.usbip
    helvum
    passt
    mount
    pkgs.hicolor-icon-theme
    efibootmgr
    tcpdump
  ];


  fileSystems."/" = {
    device = "/dev/disk/by-label/mac-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

	networking = {
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
	};

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

  #home-manager.users.me.home.file.".config/sway/config".text = ''
    #exec ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 6666
    #exec 'wl-paste -w ${pkgs.netcat-openbsd}/bin/nc 192.168.1.11 4405'
    #exec 'sh -c "while true; do ${pkgs.netcat-openbsd}/bin/nc -l 4405 | wl-copy; done"'
    #exec 'sh -c "while true; do cat ~/clipboard | wl-paste; done"'
  #'';

  home-manager.users.me.programs.lan-mouse = {
    enable = true;
    systemd = true;
    settings = {
      authorized_fingerprints."f1:f2:c8:38:fd:e9:34:2f:a0:79:49:b4:ca:d6:4e:c6:31:10:42:1b:9f:ba:61:6f:41:9a:b7:ce:1a:32:47:a1" = "main";
      port = 4410;
      clients = [
        {
          position = "left";
          hostname = "main";
          activate_on_startup = true;
          ips = [ "192.168.4.2" "100.71.47.106" ];
          port = 4410;
        }
      ];
    };
  };
  home-manager.users.me.systemd.user.services.lan-mouse.Service.Environment = "PATH=/bin";

  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgKLRF9iYRH3Y8hPjLX1ZY6GyavruqcQ0Q0Y8bnmpv9 me@tab"
  ];

  services.greetd = lib.mkForce {
    enable = true;
    settings = rec {
      terminal.vt = 1;
      initial_session = let

        newerUnstableSrc = builtins.getFlake "nixpkgs/d0fc30899600b9b3466ddb260fd83deb486c32f1";
        newerUnstable = import newerUnstableSrc.outPath {};

        mySway = newerUnstable.sway.override {
          sway-unwrapped = (newerUnstable.sway-unwrapped.overrideAttrs (prev: {
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
          })).override {
            wlroots = newerUnstable.wlroots.overrideAttrs (prev: {
              version = "master";
              src = pkgs.fetchFromGitLab {
                domain = "gitlab.freedesktop.org";
                owner = "wlroots";
                repo = "wlroots";
                rev = "master";
                sha256 = "sha256-2FK6FGRpgf/YYqwJST0LVA/pnNRSUDrfrrp6mSwA0Fk=";
              };

            });
          };
        };


      in {
        #command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time -d --env WLR_RENDERER_ALLOW_SOFTWARE=1 --cmd sway";
        command = "${pkgs.writeScriptBin "run-sway" ''
          export WLR_RENDERER_ALLOW_SOFTWARE=1
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORM=wayland
          export XDG_CURRENT_DESKTOP=sway
          export XDG_SESSION_DESKTOP=sway
          exec ${pkgs.lib.getExe mySway}
        ''}/bin/run-sway";
        user = "me";
      };
      default_session = initial_session;
    };
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

  boot.plymouth.enable = true;
  services.dbus.enable = true;

  fonts.enableDefaultPackages = true;
  xdg.icons.enable = true;
  gtk.iconCache.enable = true;

  services.udisks2.enable = false;
  hardware.opengl.enable = true;
  hardware.enableRedistributableFirmware = true;

  systemd.services."cage@" = {
    enable = false;
    after = [ "systemd-user-sessions.service" "dbus.socket" "systemd-logind.service" "getty@%i.service" "plymouth-deactivate.service" "plymouth-quit.service" ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-deactivate.service" ];
    wantedBy = [ "graphical.target" ];
    conflicts = [ "getty@%i.service" ]; # "plymouth-quit.service" "plymouth-quit-wait.service"

    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.cage}/bin/cage -d -- ${pkgs.moonlight-qt}/bin/moonlight";
      User = "root";

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
      StandardInput = "tty-fail";
      #StandardOutput = "syslog";
      #StandardError = "syslog";
      # Set up a full (custom) user session for the user, required by Cage.
      PAMName = "cage";
    };
  };

  security.pam.services.cage.text = ''
    auth    required pam_unix.so nullok
    account required pam_unix.so
    session required pam_unix.so
    session required ${pkgs.systemd}/lib/security/pam_systemd.so
  '';

  systemd.targets.graphical.wants = [ "cage@tty1.service" ];

  systemd.defaultUnit = "graphical.target";


  ############################# networkmanager
  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    home = {
      connection = {
        id = "home";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "300";
        interface-name = "enp2s0";
      };
      ipv4 = {
        address2 = "192.168.4.3/24";
        dns = "1.1.1.1;";
        method = "manual";
      };
    };

    pw = {
      connection = {
        id = "pw";
        uuid = "e0103dac-7da0-4e32-a01b-487b8c4c813c";
        type = "wifi";
        interface-name = "wlp3s0";
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
        interface-name = "wlp3s0";
        autoconnect-priority = "300";
      };

      wifi = {
        hidden = "true";
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
        interface-name = "wlp3s0";
        autoconnect-priority = "100";
      };
      wifi = {
        mode = "ap";
        ssid = "c2vi-mac";
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
        autoconnect = false;
        autoconnect-priority = "200";
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
}
