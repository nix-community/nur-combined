{ inputs, pkgs, ... }:
{
	imports = [
    #"${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-x86_64.nix"
		../common/all.nix
		../common/nixos.nix
		../common/nixos-graphical.nix
    ../common/building.nix

		inputs.home-manager.nixosModules.home-manager
		../users/me/gui.nix
	];

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

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  virtualisation.podman.enable = true;

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
		hostName = "hpm";
		nameservers = [ "1.1.1.1" "8.8.8.8" ];
		interfaces = {
			"enp0s13f0u1c2" = {
				name = "eth0";
				ipv4.addresses = [
					{ address = "192.168.1.6"; prefixLength = 24;}
				];
			};
		};
	};

	services.logind = {
		lidSwitch = "ignore";
		lidSwitchExternalPower = "ignore";
		lidSwitchDocked = "ignore";
	};

}

