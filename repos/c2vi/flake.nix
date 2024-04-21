{
	description = "Sebastian (c2vi)'s NixOS";

	inputs = {
    # don't forget to also change the hash of the used nixpkgs in programs/bash.nix the export nip
		nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
		#nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		
    #old-nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";

		firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox-addons = {
      # ref: https://github.com/Misterio77/nix-config/blob/main/flake.nix#L66
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };


		home-manager = {
			url = "github:nix-community/home-manager/release-23.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};


		nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";


		nix-index-database.url = "github:Mic92/nix-index-database";
    	nix-index-database.inputs.nixpkgs.follows = "nixpkgs";


		nixos-generators = {
     		 url = "github:nix-community/nixos-generators";
      	inputs.nixpkgs.follows = "nixpkgs";
    	};


    nixos-hardware.url = "github:nixos/nixos-hardware";

    networkmanager.url = "github:c2vi/nixos-networkmanager-profiles";

    robotnix = {
      url = "github:nix-community/robotnix";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.05";
      #url = "github:zhaofengli/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # for bootstrap zip ball creation and proot-termux builds, we use a fixed version of nixpkgs to ease maintanence.
    # head of nixos-23.05 as of 2023-06-18
    # note: when updating nixpkgs-for-bootstrap, update store paths of proot-termux in modules/environment/login/default.nix
    nixpkgs-for-bootstrap.url = "github:NixOS/nixpkgs/c7ff1b9b95620ce8728c0d7bd501c458e6da9e04";

    nix-wsl.url = "github:nix-community/NixOS-WSL";

    my-log.url = "path:/home/me/work/log/new";
    #my-log.inputs.nixpkgs.follows = "nixpkgs";

    podman.url = "github:ES-Nix/podman-rootless";

 		flake-utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default";

	};

	outputs = { self, nixpkgs, nixos-generators, flake-utils, systems, ... }@inputs: 
		let 
			confDir = "/home/me/work/config";
			workDir = "/home/me/work";
			secretsDir = "/home/me/work/here/secrets";
			persistentDir = "/home/me/work/app-data";

      tunepkgs = import nixpkgs {

        localSystem = {
          gcc.arch = "kabylake";
          gcc.tune = "kabylake";
          system = "x86_64-linux";
        };
        
        #system = "x86_64-linux"; 
        #overlays = [
          #(self: super: {
            #stdenv = super.impureUseNativeOptimizations super.stdenv;
          #})
        #];
      };
      mypkgs = import nixpkgs { 
        system = "x86_64-linux"; 
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-24.8.6"
            "electron-25.9.0"
            ];
        }; 
        overlays = [ 
          #( import ./mods/my-nixpkgs-overlay.nix { inherit nixpkgs; } )
          #( import ./mods/second-overlay.nix { inherit nixpkgs; } )
        ];
      };

      specialArgs = {
				inherit inputs confDir workDir secretsDir persistentDir self tunepkgs;
        system = "x86_64-linux";
        pkgs = mypkgs;
			};
		in
	{
   	nixosConfigurations = rec {
   		"main" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/main.nix
					  ./hardware/hpm-laptop.nix
      		];
   		};

   		"hpm" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/hpm.nix
					  ./hardware/hpm-laptop.nix
            #./mods/hec-server.nix
      		];
   		};

   		"gui" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
            nixos-generators.nixosModules.all-formats
            ({ ... }: {
              boot.kernelParams = [ "console=tty0" ];
              boot.loader.grub.device = "nodev";
  	          virtualisation.libvirtd.enable = true;
              fileSystems = {
                "/" = {
                  label = "nixos";
                  fsType = "ext4";
                };
              };
            })
            #"${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-x86_64.nix"
            ./common/all.nix
            ./common/nixos.nix
            ./common/nixos-graphical.nix
            ./common/building.nix

            inputs.home-manager.nixosModules.home-manager
            ./users/me/gui.nix
            ./users/root/default.nix
      		];
   		};

   		"fusu" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/fusu.nix
					  ./hardware/fusu.nix
      		];
   		};

      # my server at home
   		"rpi" = nixpkgs.lib.nixosSystem rec {
			  #inherit specialArgs;
        specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self system; };
        system = "aarch64-linux";
        modules = [
          ./hosts/rpi.nix
        ];
      };

      # my raspberry to try out stuff with
   		"lush" = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self system; };
        modules = [
          ./hosts/lush.nix

        ];
      };

   		"hec-tmp" = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self system; };
        modules = [
          ./hosts/tmp-hec.nix
        ];
      };

      # my headless nixos vm
   		"loki" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
      };

      # a nixos chroot environment
   		"chroot" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";

      	modules = [
          ./hosts/the-most-default.nix
          ({ ... }: {
            
          })
        ];
      };

   		"acern" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
        modules = [
          ./hosts/acern.nix
        ];
      };

   		"acern-real" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
        modules = [
          ./hosts/acern-real.nix
        ];
      };

			"the-most-default" = nixpkgs.lib.nixosSystem rec {
      		system = "x86_64-linux";
      		specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self system; };
      		modules = [


            # sample de
            ({
              #services.xserver.enable = true;
              #services.xserver.desktopManager.plasma5.enable = true;

              services.xserver.desktopManager.xterm.enable = false;
              services.xserver.desktopManager.xfce.enable = true;

              #services.xserver.desktopManager.gnome.enable = true;
            })

            # ssh server
            # /*
            ({
              services.openssh = {
                enable = true;
                ports = [ 22 ];

                settings.PasswordAuthentication = false;
                settings.KbdInteractiveAuthentication = false;
                settings.X11Forwarding = true;
                extraConfig = ''
                  X11UseLocalhost no
                '';
              };
            })
            # */

            # boot loader and filesystem
            # /*
            ({ ... }: {
              fileSystems."/" = {
                device = "/dev/disk/by-uuid/6518e61e-7120-48ef-81a3-5eae0f67297e";
                fsType = "btrfs";
               };

              system.stateVersion = "23.05"; # Did you read the comment?
              boot.loader.grub = {
                  enable = true;
                  device = "nodev";
                  efiSupport = true;
                extraConfig = ''
                  set timeout=2
                '';
              };
            })
            # */

            # sdcard
            #"${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-x86_64.nix"

            # modules
         		#./hosts/the-most-default.nix
            #./users/root/default.nix
            #./users/me/headless.nix
		        #inputs.home-manager.nixosModules.home-manager
		        #./common/all.nix
            #./common/nixos.nix
            #"${workDir}/htl/net-ksn/AA07/http-server.nix"
      		];
			};

			"test" = nixpkgs.lib.nixosSystem rec {
      		specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self system; };
      		system = "aarch64-linux";
          #inherit specialArgs;
      		modules = [
            "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./common/all.nix
            #./common/nixos-headless.nix
            #./common/nixos-graphical.nix
            #./common/building.nix

            inputs.home-manager.nixosModules.home-manager
            ./users/me/headless.nix
      		];
      };
   	};

    robotnixConfigurations = rec {
      "phone" = inputs.robotnix.lib.robotnixSystem (import ./hosts/phone/default.nix);
    };

    nixOnDroidConfigurations = rec {
      "phone" = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./hosts/phone/nix-on-droid.nix
          {
            home-manager.extraSpecialArgs = {
				      inherit inputs self;
              confDir = "/data/data/com.termux.nix/files/home/work/config";
              workDir = "/data/data/com.termux.nix/files/home/work";
              secretsDir = "/data/data/com.termux.nix/files/home/secrets";
              persistentDir = "/data/data/com.termux.nix/files/home/work/app-data/";
              hostname = "phone";
            };
          }
        ];
      };
      "tab" = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./hosts/tab/nix-on-droid.nix
          {
            home-manager.extraSpecialArgs = {
				      inherit inputs self;
              confDir = "/data/data/com.termux.nix/files/home/work/config";
              workDir = "/data/data/com.termux.nix/files/home/work";
              secretsDir = "/data/data/com.termux.nix/files/home/secrets";
              persistentDir = "/data/data/com.termux.nix/files/home/work/app-data/";
              hostname = "tab";
            };
          }
        ];
      };

    };

    homeModules = {
      #me-headless = import ./users/me/headless.nix;
      me-headless = import ./users/common/home.nix;
    };

		packages.aarch64-linux = {
      cbm = nixpkgs.legacyPackages.aarch64-linux.callPackage ./mods/cbm.nix { };
    };

		packages.x86_64-linux = {
      tunefox = mypkgs.firefox-unwrapped.overrideAttrs (final: prev: {
        NIX_CFLAGS_COMPILE = [ (prev.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
        requireSigning = false;
      });

      pkgsWithOverlays = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import ./overlays/static-overlay.nix) (import ./overlays/my-overlay.nix) ];
      };

			hi = self.nixosConfigurations.the-most-default.config.system.build.toplevel;
      #testing = nixpkgs.legacyPackages.x86_64-linux;
      testing = (nixpkgs.legacyPackages.x86_64-linux.writeShellApplication {
        name = "log";
        #runtimeInputs = [ inputs.my-log.packages.${system}.pythonForLog ];
        #text = "cd /home/me/work/log/new; nix develop -c 'python ${workDir}/log/new/client.py'";
        text = ''${inputs.my-log.packages.x86_64-linux.pythonForLog}/bin/python ${workDir}/log/new/client.py "$@"'';
      });


      hello-container = mypkgs.dockerTools.buildImage {
        name = "hello-docker";
        config = {
          Cmd = [ "${mypkgs.hello}/bin/hello" ];
        };
      };
     
      #test = inputs.firefox.packages.${nixpkgs.legacyPackages.x86_64-linux.pkgs.system}; #.firefox-nightly-bin.overrideAttrs (old: {
        #NIX_CFLAGS_COMPILE = [ (old.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
      #});

			cbm = nixpkgs.legacyPackages.x86_64-linux.callPackage ./mods/cbm.nix { };
			run-vm = specialArgs.pkgs.writeScriptBin "run-vm" ''
				${self.nixosConfigurations.hpm.config.system.build.vm}/bin/run-hpm-vm -m 4G -cpu host -smp 4
        '';
      #luna = (self.nixosConfigurations.luna.extendModules {
        #modules = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix" ];
      #}).config.system.build.sdImage;

      acern = self.nixosConfigurations.acern.config.system.build.tarballBuilder;
      lush = self.nixosConfigurations.lush.config.system.build.sdImage;
      rpi = self.nixosConfigurations.rpi.config.system.build.sdImage;

      hec-img = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          ./hosts/hpm.nix
        ];
        format = "raw";
				inherit specialArgs;
      };


      prootTermux = inputs.nix-on-droid.outputs.packages.x86_64-linux.prootTermux;
      docker = let pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs; in pkgs.dockerTools.buildImage {
        name = "hello";
        tag = "0.1.0";

        config = { Cmd = [ "${pkgs.bash}/bin/bash" ]; };

        created = "now";
        };

		};

		apps.x86_64-linux = {
      test = inputs.nix-on-droid.outputs.apps.x86_64-linux.deploy;

      wsl = {
        type = "app";
        program = "${self.nixosConfigurations.acern.config.system.build.tarballBuilder}/bin/nixos-wsl-tarball-builder";
      };
		  default = {
        type = "app";
        program = "${self.packages.x86_64-linux.run-vm}/bin/run-vm";
      };
		};

    tunepkgs = tunepkgs;
    pkgs = mypkgs;
    home.me = import ./users/me/gui-home.nix;
    top = builtins.mapAttrs (name: value: value.config.system.build.toplevel) (self.nixOnDroidConfigurations // self.nixosConfigurations);
    #nur = let nur-systems = [ "x86_64-linux" "aarch64-linux" ]; in flake-utils.eachDefaultSystem (system: inputs.nixpkgs-unstable.legacyPackages.${system}.callPackage ./nur.nix {});
    overlays = {
      static = import ./overlays/static-overlay.nix;
    };
	};
}
