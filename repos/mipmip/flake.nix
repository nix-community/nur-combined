{

  inputs = {

    ## MAIN NIXPKGS
    nixpkgs-2211.url = "github:NixOS/nixpkgs/nixos-22.11";       # GNOME 43.2
    #nixpkgs-2305.url = "github:NixOS/nixpkgs/nixos-23.05";  # GNOME 44.2?
    nixpkgs-2311.url = "github:NixOS/nixpkgs/nixos-23.11";  # GNOME 45.2
    #nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";  # GNOME 46


    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    #nixpkgs-inkscape13.url = "github:leiserfg/nixpkgs?ref=staging";

    ## HOME MANAGER
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    ## OTHER
    agenix.url = "github:ryantm/agenix";

    nixified-ai = { url = "github:nixified-ai/flake"; };

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";

    bmc.url = "github:wearetechnative/bmc";
    race.url = "github:wearetechnative/race";

    jsonify-aws-dotfiles.url = "github:mipmip/jsonify-aws-dotfiles";
    myhotkeys.url = "github:mipmip/gnome-hotkeys.cr/0.2.7";
    shellstuff.url = "github:mipmip/nix-shellstuff";
    dirtygit.url = "github:mipmip/dirtygit";
    skull.url = "github:mipmip/skull";

    nixpkgs-pine64.url = "nixpkgs/dfd82985c273aac6eced03625f454b334daae2e8";
    mobile-nixos = {
      url = "github:nixos/mobile-nixos/efbe2c3c5409c868309ae0770852638e623690b5";
      flake = false;
    };
    home-manager-pine64.url = "github:nix-community/home-manager/release-22.05";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };


  };

  outputs = inputs@{
    self,
    home-manager,
    nixpkgs,
    nixpkgs-2211,
    nixpkgs-2311,
    alacritty-theme,
    unstable,
    #    nixpkgs-inkscape13,
    agenix,
    nixos-hardware,

    nixified-ai,

    jsonify-aws-dotfiles, dirtygit, bmc, race, shellstuff, skull, myhotkeys,

    nixpkgs-pine64, mobile-nixos, home-manager-pine64,

   nix-on-droid
    } :

    let

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          (import ./overlays)
          alacritty-theme.overlays.default
        ];
        inherit system;
        config.allowUnfree = true;
      };

      #    nixpkgs-inkscape13ForSystem = system: import nixpkgs-inkscape13 {
      #      inherit system;
      #      config.allowUnfree = true;
      #    };

      unstableForSystem = system: import unstable {
        inherit system;
        config.allowUnfree = true;
      };

      importFromChannelForSystem = system: channel: import channel {
        inherit system;
        config.allowUnfree = true;
      };

      #for grannyos
      nixpkgs-unstable = unstableForSystem "x86_64-linux";

      defaultSystem = "x86_64-linux";
      extraPkgs = {
        environment.systemPackages = [
          agenix.packages."${defaultSystem}".default
          bmc.packages."${defaultSystem}".bmc
          jsonify-aws-dotfiles.packages."${defaultSystem}".jsonify-aws-dotfiles
          race.packages."${defaultSystem}".race
          dirtygit.packages."${defaultSystem}".dirtygit
          myhotkeys.packages."${defaultSystem}".myhotkeys
          shellstuff.packages."${defaultSystem}".shellstuff
          skull.packages."${defaultSystem}".skull
        ];
      };

    in
      rec {
       formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;

       homeConfigurations."pim@passieflora" = home-manager.lib.homeManagerConfiguration {
        modules = [
          (import ./home/pim/home-machine-passieflora.nix)
        ];

        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          username = "pim";
          homedir = "/home/pim";
          withLinny = false;
          isDesktop = false;
          tmuxPrefix = "b";
          unstable = unstableForSystem "x86_64-linux";
          bmc = bmc;
          race = race;
          dirtygit = dirtygit;
          inherit shellstuff;
          jsonify-aws-dotfiles = jsonify-aws-dotfiles;

        };
      };


      homeConfigurations."pim@tn-nixhost" = home-manager.lib.homeManagerConfiguration {
        modules = [
          (import ./home/pim/home-machine-tn-nixhost.nix)
        ];

        pkgs = pkgsForSystem "x86_64-linux";
        extraSpecialArgs = {
          username = "pim";
          homedir = "/home/pim";
          withLinny = false;
          isDesktop = false;
          tmuxPrefix = "b";
          unstable = unstableForSystem "x86_64-linux";
          bmc = bmc;
          race = race;
          dirtygit = dirtygit;
          inherit shellstuff;
          jsonify-aws-dotfiles = jsonify-aws-dotfiles;

        };
      };

      homeConfigurations."pim@rodin" = home-manager.lib.homeManagerConfiguration (import ./rodinHomeConf.nix ({
        pkgsForSystem = pkgsForSystem;
        inherit unstableForSystem;
        inherit jsonify-aws-dotfiles;
        inherit extraPkgs;
        isDesktop = true;
      }));

      homeConfigurations = {

        "pim@lego1" = home-manager.lib.homeManagerConfiguration {
          modules = [ (import ./home/pim/home-machine-lego1.nix) ];
          pkgs = pkgsForSystem "x86_64-linux";
          extraSpecialArgs = {
            username = "pim";
            homedir = "/home/pim";
            withLinny = true;
            isDesktop = true;
            tmuxPrefix = "a";
            unstable = unstableForSystem "x86_64-linux";
            jsonify-aws-dotfiles = jsonify-aws-dotfiles;
          };
        };

        "pim@ojs" = home-manager.lib.homeManagerConfiguration {
          modules = [ (import ./home/pim/home-machine-ojs.nix) ];

          pkgs = pkgsForSystem "x86_64-linux";
          extraSpecialArgs = {
            username = "pim";
            homedir = "/home/pim";
            withLinny = true;
            isDesktop = true;
            tmuxPrefix = "a";
            unstable = unstableForSystem "x86_64-linux";
          };
        };
      };

      nixosConfigurations.rodin = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";

        modules =
          let
            system = "x86_64-linux";

            defaults = { pkgs, ... }: {
              nixpkgs.overlays = [(import ./overlays)];
              _module.args.unstable = importFromChannelForSystem system unstable;
              _module.args.pkgs-2211 = importFromChannelForSystem system nixpkgs-2211;
            };


          in [
            ./hosts/rodin/configuration.nix
            defaults
            agenix.nixosModules.default
            extraPkgs

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
            }

            ##          {
            ##              imports = [
            ##                nixified-ai.nixosModules.invokeai
            ##              ];
            ##
            ##              environment.systemPackages = [
            ##                nixified-ai.packages.${system}.invokeai-nvidia
            ##              ];
            ##
            ##  #            services.invokeai = {
            ##  #              enable = false;
            ##  #              host = "0.0.0.0";
            ##  #              nsfwChecker = false;
            ##  #              package = nixified-ai.packages.${system}.invokeai-nvidia;
            ##  #            };
            ##
            ##            }


          ];
      };

      nixosConfigurations.lego1 = nixpkgs.lib.nixosSystem {

        modules =
          let
            system = "x86_64-linux";
            defaults = { pkgs, ... }: {
              nixpkgs.overlays = [(import ./overlays)];
              _module.args.unstable = importFromChannelForSystem system unstable;
              _module.args.pkgs-2211 = importFromChannelForSystem system nixpkgs-2211;
              _module.args.pkgs-2311 = importFromChannelForSystem system nixpkgs-2311;
              #_module.args.pkgs-inkscape13 = importFromChannelForSystem system nixpkgs-inkscape13;
            };


          in [
            defaults
            nixos-hardware.nixosModules.framework-12th-gen-intel
            ./hosts/lego1/configuration.nix

            agenix.nixosModules.default
            extraPkgs
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
            }
          ];
      };

      nixosConfigurations.ojs = nixpkgs.lib.nixosSystem {

        modules =
          let
            system = "x86_64-linux";
            defaults = { pkgs, ... }: {
              _module.args.unstable = unstableForSystem "x86_64-linux";
              #_module.args.nixpkgs-inkscape13 = nixpkgs-inkscape13ForSystem "x86_64-linux";
            };
          in [
            defaults
            ./hosts/ojs/configuration.nix

            extraPkgs
            agenix.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
            }
          ];
      };

      nixosConfigurations.gnome45 = nixpkgs-2311.lib.nixosSystem {
        modules =
          let
            system = "x86_64-linux";
          in
            [
            {
              nixpkgs.config.pkgs = import nixpkgs-2311 { inherit system; };
            }
            ./hosts/gnome-45/configuration.nix
          ];
      };

      nixosConfigurations.grannyos = nixpkgs-2311.lib.nixosSystem {
        modules =
          let
            system = "x86_64-linux";
          in
            [
            {
              nixpkgs.config.pkgs = import nixpkgs-2311 { inherit system; };
            }
            ./hosts/grannyos/configuration.nix
          ];
      };

      nixosConfigurations.billquick = nixpkgs.lib.nixosSystem {

        modules =
          let
            defaults = { pkgs, ... }: {
              _module.args.unstable = unstableForSystem "x86_64-linux";
            };
          in [
            defaults
            ./hosts/billquick/configuration.nix
            .home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
            }
          ];

      };

      nixosConfigurations.pinephone = (nixpkgs-pine64.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { home-manager = home-manager-pine64; };
        modules = [
          (import "${mobile-nixos}/lib/configuration.nix" {
            device = "pine64-pinephone";
          })
          ./hosts/pesto/default.nix
        ];
      });
      pinephone-img = nixosConfigurations.pinephone.config.mobile.outputs.u-boot.disk-image;

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [ ./hosts/nix-on-droid/configuration.nix ];
      };

      nixosConfigurations.passieflora = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
        ./hosts/passieflora/configuration.nix
        ./hosts/passieflora/nix/substituter.nix
        nixos-hardware.nixosModules.apple-t2

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
        }

        ];
      };

      nixosConfigurations.passieflora-no = nixpkgs.lib.nixosSystem {

        modules =
          let
            system = "x86_64-linux";
            defaults = { pkgs, ... }: {
              nixpkgs.overlays = [(import ./overlays)];
              _module.args.unstable = importFromChannelForSystem system unstable;
              _module.args.pkgs-2211 = importFromChannelForSystem system nixpkgs-2211;
              _module.args.pkgs-2311 = importFromChannelForSystem system nixpkgs-2311;
            };


          in [
            defaults
            ./hosts/passieflora/configuration.nix

            agenix.nixosModules.default
            extraPkgs
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
            }
          ];
      };



    };

}
