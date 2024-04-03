{ config, lib, pkgs, inputs, secretsDir, ...}:
{
  imports = [
    ../users/me/gui.nix

    inputs.networkmanager.nixosModules.networkmanager
		inputs.home-manager.nixosModules.home-manager
    ../common/all.nix
    ../common/nixos.nix
    ../common/nixos-headless.nix
  ];

  # hack fix
  #home-manager.users.me.programs.firefox.
  #home-manager.users.me.programs.firefox.
  nixpkgs.config.allowUnfree = true;

  services.xserver = {
    desktopManager.gnome.enable = true;

    /*
    displayManager.lightdm = {
      enable = true;
      greeters.enso = {
        enable = true;
        blur = true;
        extraConfig = ''
          default-wallpaper=/usr/share/streets_of_gruvbox.png
        '';
      };
    };
    # */
    layout = "at";
  };
	sound.enable = true;
	hardware.pulseaudio.enable = true;
  services.blueman.enable = true;
	hardware.bluetooth.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
	services.xserver.libinput.enable = true;



	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
  	version = 2;
  	device = "nodev";
  	efiSupport = true;
		extraConfig = ''
			set timeout=2
      menuentry "win-server" {
        insmod part_gpt
        insmod fat
        insmod search_fs_uuid
        insmod chain
        search --label --set=root EFI
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
		'';
	};
	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
	hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	boot.initrd.availableKernelModules = [ "xhci_pci" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	boot.initrd.kernelModules = [ "dm-snapshot" ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];
  boot.loader.efi.canTouchEfiVariables = true;

  
	fileSystems."/" = {
		device = "/dev/disk/by-label/nixos-root";
   	fsType = "btrfs";
    options = [ "subvol=main" ];
  };



  services.openssh = {
    enable = true;
    ports = [ 2222 ];

    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.X11Forwarding = true;
    extraConfig = ''
      X11UseLocalhost no
    '';
  };

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];


  ######################### networking #####################################

  networking.hostName = "acern";
	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	networking.firewall.allowedUDPPorts = [
  	3702 # wsdd
    51820  # wireguard
	];

	networking.firewall.allowedTCPPorts = [
    2222 # sshd
  ];

  networking.networkmanager.enable = true;

  networking.networkmanager.profiles = {
    main = {
      connection = {
        id = "main";
        uuid = "a02273d9-ad12-395e-8372-f61129635b6f";
        type = "ethernet";
        autoconnect-priority = "-999";
        interface-name = "enp1s0";
      };
      ipv4 = {
        address1 = "192.168.1.5/24,192.168.1.1";
        dns = "1.1.1.1;";
        method = "manual";
      };
    };
  };
}
