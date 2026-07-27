
{ inputs, pkgs, secretsDir, lib, ... }:
{

  #disabledModules = [ "services/databases/couchdb.nix" ];
	imports = [
    #"${inputs.nixpkgs-unstable}/nixos/modules/services/databases/couchdb.nix"
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    ../users/me/headless.nix
    ../users/root/default.nix
    ../users/server/headless.nix

    inputs.arion.nixosModules.arion
    ../mods/fesu-services.nix
	];

  users.users.server.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNXOPxlnSxkhm050ui56D5SHrkhuFwUOU0Gf0C+Vmks melektron@goarnix"
  ];
  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNXOPxlnSxkhm050ui56D5SHrkhuFwUOU0Gf0C+Vmks melektron@goarnix"
  ];

  services.tailscale.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuSwtpm = true;
    #qemuOvmfPackage = pkgs.OVMFFull;
  };
  users.users.server.extraGroups = [ "docker" ];

	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
    #device = "/dev/disk/by-id/ata-TOSHIBA_MQ04ABF100_11MYT5RBT";
    device = "nodev"; # don't install, when i do nixre -h fusu ... but when installing onto the two discs (sata hdd and nvme ssd) change to the device like above
  	efiSupport = true;
		extraConfig = ''
			set timeout=2
		'';
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/fes-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/FES-BOOT";
    fsType = "vfat";
  };

	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "yes";
      ports = [ 22 49004 ];

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
	};

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 
    443 # couchdb for obsidian live sync https
    44444 # resilio sync
    9000 # resilio webui
  ];

	services.samba.openFirewall = true;

	networking.firewall.allowedTCPPorts = [
    80 # http
    443 # https

		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy
    5901 # vnc

  	5357 # wsdd
    8080 # for mitm proxy

    49388
    49389
    49390
    49391
    49392
    49393

	];


  networking.firewall.allowedTCPPortRanges = [
    { from = 49000; to = 49300;} # general
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 49000; to = 49300;} # general
  ];

	networking.firewall.allowedUDPPorts = [
  		3702 # wsdd
      67 # allow DHCP traffic
      53 # allow dns
	];

  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  environment.systemPackages = with pkgs; [
    sshfs
    ntfs3g
    virtiofsd
    bcache-tools
    su
    fuse3
    terraform
    usbutils
  ];

	nix.settings = {
		trusted-public-keys = [
			"sebastian@c2vi.dev:0tIXGRJMLaI9H1ZPdU4gh+BikUuBVHtk+e1B5HggdZo="
		];
      trusted-users = [ "me" ];
	};

  networking.useDHCP = false;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp4s0" ];
    };
  };
  networking.interfaces.br0.ipv4.addresses = [ {
    address = "192.168.1.4";
    prefixLength = 24;
  } ];
	networking = {
		usePredictableInterfaceNames = true;
		defaultGateway = {
			address = "192.168.1.1";
			interface = "br0";
		};
		hostName = "fe";
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
	};

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices = [{
    device = "/swapfile";
    size = 63 * 1024; # 64GB
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  ################################ services ############################
  services.traefik = {
  };


}
