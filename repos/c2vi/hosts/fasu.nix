
{ inputs, pkgs, ... }:
{
	imports = [
		../common/all.nix
		../common/nixos.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
    ../users/me/headless.nix
    ../users/root/default.nix
    ../users/server/headles.nix
	];

  fileSystems."/" = {
    device = "/dev/disk/by-label/fasu-root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/FASU-BOOT";
    fsType = "vfat";
  };

  # allow acern to ssh into server
  users.users.server.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTV1VoNAjMha5IP+qb8XABDo02pW3iN0yPBIbSqZA27 me@acern"
  ];

  # allow server user to shutdown fusu
  security.sudo.extraRules = [
    {
      users = [ "server" ];
      commands = [ { command = "/run/current-system/sw/bin/shutdown"; options = [ "SETENV" "NOPASSWD" ]; } ];
    }
  ];

	# Use the GRUB 2 boot loader.
	boot.loader.grub = {
  	enable = true;
    #device = "/dev/nbd1";
    device = "nodev";
  	efiSupport = false;
		extraConfig = ''
			set timeout=2
		'';
  };

  #fileSystems."/boot" = {
  #  device = "/dev/disk/by-label/fusu-boot";
  #  fsType = "fat32";
  #};

	services.openssh = {
  		enable = true;
  		# require public key authentication for better security
  		settings.PasswordAuthentication = false;
  		settings.KbdInteractiveAuthentication = false;
  		settings.PermitRootLogin = "yes";

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
	};

	networking.firewall.allowPing = true;
	networking.firewall.enable = true;

	services.samba.openFirewall = true;

	networking.firewall.allowedTCPPorts = [
		8888 # for general usage
		9999 # for general usage
    8080 # for mitm proxy

    25565 # mc server
    25580 # wmc lobby server
    25566 # mc server
    3306 # mariadb for wmc
    6379 # redis for wmc
	];
	networking.firewall.allowedUDPPorts = [
    25572 # wmc voice to velocity proxy
    25800 # wmc voice lobby

    19132 # mc bedrock port
  ];

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
  ];

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

	nix.settings = {
		trusted-public-keys = [
			"sebastian@c2vi.dev:0tIXGRJMLaI9H1ZPdU4gh+BikUuBVHtk+e1B5HggdZo="
		];
      trusted-users = [ "me" ];
	};

	networking = {
		#usePredictableInterfaceNames = false;
		defaultGateway = {
			address = "192.168.1.1";
			interface = "eth0";
		};
		hostName = "fasu";
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
		interfaces = {
			"enp0s25" = {
				name = "eth0";
				ipv4.addresses = [
					{ address = "192.168.1.22"; prefixLength = 24;}
				];
			};
		};
	};

}
