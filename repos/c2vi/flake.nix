{
	description = "Sebastian (c2vi)'s NixOS";

  ################################### INPUTS #########################################
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
		#nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		
		nixpkgs-new.url = "github:NixOS/nixpkgs/release-25.11";

		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		nixpkgs-old.url = "github:NixOS/nixpkgs/release-23.11";
		
    nur.url = "github:nix-community/NUR";

		firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox-addons = {
      # ref: https://github.com/Misterio77/nix-config/blob/main/flake.nix#L66
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    zed.url = "github:zed-industries/zed";
    #zed.inputs.nixpkgs.follows = "nixpkgs";

    hetzner_ddns = {
      url = "github:c2vi/hetzner_ddns";
      flake = false;
    };
    
		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			#url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

    compass = {
      url = "github:ppc-social/compass";
			inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant = {
      url = "github:abenz1267/elephant";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

		home-manager-old = {
			url = "github:nix-community/home-manager/release-23.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";

    arion = {
      url = "github:hercules-ci/arion";
			inputs.nixpkgs.follows = "nixpkgs";
    };

		nix-index-database.url = "github:Mic92/nix-index-database";
    	nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

		nixos-generators = {
     		 url = "github:nix-community/nixos-generators";
      	inputs.nixpkgs.follows = "nixpkgs";
    	};

    nixos-hardware.url = "github:nixos/nixos-hardware";

    networkmanager.url = "github:c2vi/nixos-networkmanager-profiles";

    lan-mouse.url = "github:feschber/lan-mouse";

    disko = {
      url = "github:nix-community/disko/latest";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    robotnix = {
      #url = "github:nix-community/robotnix";
      url = "github:c2vi/robotnix";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # use fork see: https://github.com/nix-community/nix-on-droid/pull/203#issuecomment-2956162178
    nix-on-droid = {
      url = "github:frankitox/nix-on-droid/supervisord";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # for bootstrap zip ball creation and proot-termux builds, we use a fixed version of nixpkgs to ease maintanence.
    # head of nixos-23.05 as of 2023-06-18
    # note: when updating nixpkgs-for-bootstrap, update store paths of proot-termux in modules/environment/login/default.nix
    nixpkgs-for-nix-on-droid-bootstrap.url = "github:NixOS/nixpkgs/49ee0e94463abada1de470c9c07bfc12b36dcf40";

    nix-wsl.url = "github:nix-community/NixOS-WSL";

    #my-log.url = "path:/home/me/work/log/new";
    #my-log.inputs.nixpkgs.follows = "nixpkgs";

    podman.url = "github:ES-Nix/podman-rootless";

 		flake-utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default";
    victorinix.url = "github:c2vi/victorinix";
    victorinix.inputs.nixpkgs.follows = "nixpkgs";

    ####### keyboard
    zephyr-nix = {
      url = "github:adisbladis/zephyr-nix";
      #url = "/home/me/work/config/gitignore/zephyr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    waveforms = {
      url = "github:liff/waveforms-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, nixos-generators, flake-utils, systems, ... }@inputs:

  ################################### LET FOR OUPUTS #########################################
		let 
			confDir = "/home/me/work/config";
			workDir = "/home/me/work";
			secretsDir = "/home/me/secrets";
			persistentDir = "/home/me/work/app-data";
      dataDir = "/home/server/host";

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

      pkgsUnstable = import nixpkgs-unstable {
        system = "x86_64-linux"; 
        config = {
          allowUnfree = true;
        };
      };

      specialArgs = {
				inherit inputs confDir workDir secretsDir persistentDir self tunepkgs unstable nur pkgsUnstable dataDir;
        system = "x86_64-linux";
        pkgs = mypkgs;
			};
      eachSystem = inputs.flake-utils.outputs.lib.eachSystem;
      allSystems = inputs.flake-utils.outputs.lib.allSystems;

      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      nur = import inputs.nur { pkgs = mypkgs; };
		in

  ################################### EACH SYSTEM OUPUTS #########################################
  eachSystem allSystems (system: {

  ############ packages ################
  packages = {

    # nixpkgs with my overlays applied, for convenience
    pkgsOverlay = import nixpkgs {
      inherit system;
      overlays = [ (import ./overlays/static-overlay.nix) (import ./overlays/my-overlay.nix) ];
    };

    # same with nixpkgs-unstable
    pkgsOverlayUnstable = import nixpkgs-unstable {
      inherit system;
      overlays = [ (import ./overlays/static-overlay.nix) (import ./overlays/my-overlay.nix) ];
    };

    nod = (mypkgs.callPackage ./mods/nix-on-droid-pkgs.nix {
      system = "aarch64-linux";
      _nativeSystem = "x86_64-linux";
      nix-on-droid-flake = inputs.nix-on-droid;
      nixpkgs = inputs.nixpkgs-for-nix-on-droid-bootstrap;
      nixOnDroidChannelURL = "${inputs.nix-on-droid}";
      nixpkgsChannelURL = "${inputs.nixpkgs-for-nix-on-droid-bootstrap}";
      home-manager-flake = inputs.home-manager-old; 
      #nixOnDroidFlakeURL = inputs.nix-on-droid.
    }).customPkgs.bootstrapZip;

    # collection of only my nur pkgs
    # my nur is unstable by default
    mynurPkgs = inputs.nixpkgs-unstable.legacyPackages.${system}.callPackage ./nur.nix {};
    mynurPkgsStable = inputs.nixpkgs.legacyPackages.${system}.callPackage ./nur.nix {};

    nurPkgs = let tmp = import inputs.nixpkgs-unstable {
      inherit system;
      overlays = [ inputs.nur.overlay ];
    }; in tmp.nur.repos;
    
    nurPkgsStable = let tmp = import inputs.nixpkgs {
      inherit system;
      overlays = [ inputs.nur.overlay ];
    }; in tmp.nur.repos;

    nurSrcs = let tmp = import inputs.nixpkgs-unstable {
      inherit system;
      overlays = [ inputs.nur.overlay ];
    }; in tmp.nur.repo-sources;

    nurSrcUrls = let tmp = import inputs.nixpkgs-unstable {
      inherit system;
      overlays = [ inputs.nur.overlay ];
    }; in builtins.mapAttrs (name: value: value.inputDerivation.urls) tmp.nur.repo-sources;

    # collection of random things I played around with /built once
    # in seperate path to keep this flake cleaner
    random = import ./random-pkgs.nix {
      inherit system;
      # inherit all inputs
	    inherit self nixpkgs nixpkgs-unstable nixos-generators flake-utils systems inputs;
      # inherit all my let bindings
      # inherit all my let bindings
			inherit confDir workDir secretsDir persistentDir tunepkgs mypkgs specialArgs eachSystem allSystems;
    };

    pkgsCross.aarch64-multiplatform = (import ./nur.nix {pkgs = nixpkgs.legacyPackages.${system}.pkgsCross."aarch64-multiplatform";});

    test-cbm = nixpkgs.legacyPackages.${system}.pkgsCross.aarch64-multiplatform.callPackage ./mods/cbm.nix {};


  }
  // # include nur packages from ./nur.nix
  # my nur is unstable by default
  (import ./nur.nix {pkgs = nixpkgs-unstable.legacyPackages.${system};})

  #// # my idea on how to do cross compilaton with flakes....
  #eachSystem allSystems (crossSystem: {
  #})
  ;

  ############ apps ################
  apps = {
    flash = let

        # echo the disks which will be flashed...
        diskListing = hostname: let
          list = mypkgs.lib.attrsets.mapAttrsToList (name: value: "echo flashing disk ${name} onto device ${value.device}") self.nixosConfigurations.${hostname}.config.disko.devices.disk;
          string = mypkgs.lib.strings.concatStringsSep "\n" list;
        in string;

        diskDefinitionsList = hostname: let
          list = mypkgs.lib.attrsets.mapAttrsToList (name: value: "diskDefinitions[${name}]=${value.device}") self.nixosConfigurations.${hostname}.config.disko.devices.disk;
          string = mypkgs.lib.strings.concatStringsSep "\n" list;
        in string;

        createFlashScript = hostname: {
          type = "app";
          program = "${mypkgs.writeShellScriptBin "flash-te" ''
            set -eo pipefail

            echo flashing for host ${hostname}
            ${diskListing hostname}

            declare -A diskDefinitions
            ${diskDefinitionsList hostname}


            # default value if no --mode provided
            MODE="format"
            ARGS=()

            while [[ $# -gt 0 ]]; do
              case "$1" in
                --)                    # end of options; take remaining args as-is
                  shift
                  while [[ $# -gt 0 ]]; do
                    ARGS+=("$1")
                    shift
                  done
                  break
                  ;;
                --mode=*)              # --mode=VALUE
                  MODE="''${1#*=}"
                  shift
                  ;;
                --mode)                # --mode VALUE
                  if [[ $# -lt 2 ]]; then
                    echo "Error: --mode requires a value" >&2
                    exit 1
                  fi
                  MODE="$2"
                  shift 2
                  ;;
                --do-flash)
                  DO_FLASH=yes
                  shift 1
                  ;;
                --efi-vars)
                  ARGS+=("--write-efi-boot-entries")         # all other args preserved
                  shift 1
                  ;;
                --help)
                  ARGS+=("--help")         # all other args preserved
                  DO_FLASH=yes
                  shift 1
                  ;;
                --disk)                # --mode VALUE
                  if [[ $# -lt 3 ]]; then
                    echo "Error: --disk requires two values" >&2
                    exit 1
                  fi
                  diskname="$2"
                  diskval="$3"
                  diskDefinitions["$diskname"]="$diskval"
                  shift 3
                  ;;
                *)
                  ARGS+=("$1")         # all other args preserved
                  shift
                  ;;
              esac
            done


            # generate arg string from diskDefinitions
            diskDefinitionString=""
            for i in "''${!diskDefinitions[@]}"
            do
              diskDefinitionString="$diskDefinitionString --disk $i ''${diskDefinitions[$i]}"
            done


            echo would run: sudo -E ${inputs.disko.packages.x86_64-linux.disko-install}/bin/disko-install --mode $MODE --flake ${self}#${hostname} $diskDefinitionString ''${ARGS[@]}


            if [[ $DO_FLASH != "yes" ]]
            then
              echo type yes to continue...
              read acc
              if [[ "$acc" != "yes" ]]
              then
                echo aborting...
                exit
              fi
            fi

            echo flashing...
            sudo -E ${inputs.disko.packages.x86_64-linux.disko-install}/bin/disko-install --mode $MODE --flake ${self}#${hostname} $diskDefinitionString ''${ARGS[@]}
          ''}/bin/flash-te";
        };
      in {
      te = createFlashScript "te";
      ki = createFlashScript "ki";
      fasu = createFlashScript "fasu";
    };

    wsl = {
      type = "app";
      program = "${self.nixosConfigurations.acern.config.system.build.tarballBuilder}/bin/nixos-wsl-tarball-builder";
    };
    default = {
      type = "app";
      program = "${self.packages.x86_64-linux.random.run-vm}/bin/run-vm";
    };
  };


  }) # end of each-system-outputs

  // # combine with other-outputs

  ################################### OTHER OUPUTS #########################################
	{
    top = builtins.mapAttrs (name: value: value.config.system.build.toplevel) (self.nixOnDroidConfigurations // self.nixosConfigurations);

    img = builtins.mapAttrs (name: value: 
      # build tarball for wsl systems and sdImage for others.....
      if builtins.hasAttr "wsl" value.config && value.config.wsl.enable then value.config.system.build.tarballBuilder else value.config.system.build.sdImage
    ) (self.nixOnDroidConfigurations // self.nixosConfigurations);

    # this is my nur repo, that you can import and call with pkgs
    nur = import ./nur.nix;

    tunepkgs = tunepkgs;
    pkgs = mypkgs;

    overlays = {
      static = import ./overlays/static-overlay.nix;
    };

    # I want to be able to referency my inputs as an output as well
    # eg usefull for nix eval github:c2vi/nixos#inputs.nixpkgs.rev to get the current pinned nixpkgs version
    inherit inputs self;

  ############ homeModules ################
    homeModules = {
      #me-headless = import ./users/me/headless.nix;
      me-headless = import ./users/common/home.nix;
      me = import ./users/me/gui-home.nix;
    };
    
    lib = {
      flakeAddCross = config: pkgs-lambda: let
        hostSystemShortString = config.system;
        hostSystem = nixpkgs.lib.systems.parse.mkSystemFromString hostSystemShortString;
        hostSystemFullString = "${hostSystem.cpu.name}-${hostSystem.vendor.name}-${hostSystem.kernel.name}-${hostSystem.abi.name}";
      in
      # we call the lambda like this to get the host packages
      pkgs-lambda { crossSystemFullString = hostSystemFullString; }
      # and then add the pkgsCross, where we call it for every cross system
      // {
        pkgsCross = {
          aarch64-linux = pkgs-lambda { crossSystemFullString = "aarch64-unknown-linux-gnu"; };
          x86_64-linux = pkgs-lambda { crossSystemFullString = "x86_64-unknown-linux-gnu"; };
        };
      };
    };

  ############ nixosConfigurations ################
    nixosConfigurations = rec {
      "_lsp_dummp" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
    		system = "x86_64-linux";
    		modules = [
          inputs.home-manager.nixosModules.home-manager
          inputs.networkmanager.nixosModules.networkmanager
          inputs.arion.nixosModules.arion
          inputs.disko.nixosModules.disko
          
          # other overlay and home manager module access
          {
            nixpkgs.overlays = [
              # overlay for nix vscode extensions to appear in packages
              #nix-vscode-extensions.overlays.default
            ];
            # a dummy user to expose home-manager modules
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit self;
            };
            users.users._lsp_dummy_user = {
              isNormalUser = true;
              description = "dummy";
            };
            # the user is managed by home-manager
            home-manager.users._lsp_dummy_user = {
              home.username = "_lsp_dummy_user";
              home.homeDirectory = "/home/_lsp_dummy_user";
              home.stateVersion = "24.05";

              # add custom and third party options and configurations
              imports = [
                inputs.lan-mouse.homeManagerModules.default
              ];
            };
          }
        ];
      };
      
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

   		"mac" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/mac.nix
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

      #fesu my second server to fusu
   		"fe" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/fe.nix
      		];
   		};
      
   		"te" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/te.nix
      		];
   		};

   		"ki" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/ki.nix
      		];
   		};

      # my asus tinker board
   		"ti" = nixpkgs.lib.nixosSystem rec {
				specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self unstable nur dataDir system;};
        system = "aarch64-linux";
        modules = [
          ./hosts/ti.nix
        ];
   		};

      # server that hosts stuff
   		"fasu" = nixpkgs.lib.nixosSystem {
				inherit specialArgs;
      		system = "x86_64-linux";
      		modules = [
         		./hosts/fasu.nix
      		];
   		};

      # my server at home
   		"rpi" = inputs.nixpkgs-old.lib.nixosSystem rec {
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

      # lesh... seccond raspi
   		"le" = nixpkgs.lib.nixosSystem rec {
          specialArgs = { inherit inputs confDir workDir secretsDir persistentDir self system; };
      		system = "aarch64-linux";
      		modules = [
         		./hosts/le.nix
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

   		"mosatop" = nixpkgs.lib.nixosSystem {
			  inherit specialArgs;
      	system = "x86_64-linux";
        modules = [
          ./hosts/mosatop.nix
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

  ############ robotnixConfigurations ################
    robotnixConfigurations = rec {
      "phone" = inputs.robotnix.lib.robotnixSystem (import ./hosts/phone/default.nix);
      "phone-emulator" = inputs.robotnix.lib.robotnixSystem {
        # on lineageos wiki (https://wiki.lineageos.org/emulator) they say "sdk_phone_<arch>" 
        # but that's for breakfast and not choosecombo (which robotnix uses), which adds lineage_ to the front
        productName = nixpkgs.legacyPackages.x86_64-linux.lib.mkForce "lineage_sdk_phone_x86_64";
        imports = [
          (import ./hosts/phone/default.nix)
        ];
      };
      "phone-emulator-arm" = inputs.robotnix.lib.robotnixSystem {
        productName = nixpkgs.legacyPackages.x86_64-linux.lib.mkForce "lineage_sdk_phone_arm64";
        imports = [
          (import ./hosts/phone/default.nix)
        ];
      };
      "s9" = inputs.robotnix.lib.robotnixSystem {
        device = "starlte";
        flavor = "lineageos";
      };
      "vanilla" = inputs.robotnix.lib.robotnixSystem {
        device = "x86_64";
        productName = "sdk_x86_64";
        flavor = "vanilla";
      };
    };

  ############ nixOnDroidConfigurations ################
    nixOnDroidConfigurations = rec {
      "phone" = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
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
        pkgs = import nixpkgs { system = "aarch64-linux"; };
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
	};
}
