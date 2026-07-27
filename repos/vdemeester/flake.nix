{
  description = "System Config";

  outputs = { self, ... } @ inputs:
    let
      wayland = { pkgs, config, ... }: {
        config = {
          nix = {
            settings = {
              # add binary caches
              trusted-public-keys = [
                "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
                "chapeau-rouge.cachix.org-1:r34IG766Ez4Eeanr7Zx+egzXLE2Zgvc+XRspYZPDAn8="
                "vdemeester.cachix.org-1:eZWNOrLR9A9szeMahn9ENaoT9DB3WgOos8va+d2CU44="
              ];
              substituters = [
                "https://nixpkgs-wayland.cachix.org"
                "https://chapeau-rouge.cachix.org"
                "https://vdemeester.cachix.org"
              ];
            };
          };

          nixpkgs.overlays = [ inputs.nixpkgs-wayland.overlay ];
        };
      };
      stableModules = [
        inputs.home-manager-24_05.nixosModules.home-manager
      ];
      unstableModules = [
        inputs.home-manager.nixosModules.home-manager
      ];
      commonModules = [
        {
          config.nixpkgs.overlays = [
            (import ./nix/overlays).tekton
            (import ./nix/overlays/sbr.nix)
            inputs.emacs-overlay.overlay
            # inputs.nur.overlay
            # inputs.devshell.overlays.default
            inputs.chapeau-rouge.overlays.openshift
            inputs.chick-group.overlays.default
            (_: prev: {
              inherit (inputs.devenv.packages.${prev.system}) devenv;
              inherit (inputs.buildkit-tekton.packages.${prev.system}) tkn-local;
	      inherit (inputs.dagger.packages.${prev.system}) dagger;
            })
          ];
        }
        ./systems/modules/core/default.nix
        ./systems/modules/shell/default.nix
        ./systems/modules/desktop/default.nix
        ./systems/modules/dev/default.nix
        ./systems/modules/editors/default.nix
        ./systems/modules/hardware/default.nix
	./systems/modules/profiles/default.nix
        ./systems/modules/virtualisation/default.nix
        ./systems/modules/virtualisation/buildkit.nix
        ./systems/modules/services/default.nix
        inputs.sops-nix.nixosModules.sops
        # inputs.envfs.nixosModules.envfs
        {
          # config.nix.generateRegistryFromInputs = true;
          config.home-manager.useGlobalPkgs = true;
          config.home-manager.useUserPackages = true;
          # Import custom home-manager modules (NixOS)
          config.home-manager.sharedModules = import ./users/modules/modules.nix;
          # Default SopsFile
          config.sops.defaultSopsFile = ./secrets/secrets.yaml;
        }
      ];
    in
    {
      images = {
        athena = (self.nixosConfigurations.athena.extendModules {
          modules = [
            "${inputs.nixpkgs-24_05}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
        }).config.system.build.sdImage;
        demeter = (self.nixosConfigurations.demeter.extendModules {
          modules = [
            "${inputs.nixpkgs-24_05}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
        }).config.system.build.sdImage;
      };
      nixosConfigurations =
        {
          # Work laptop (unstable)
          wakasu = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = commonModules ++ unstableModules ++ [
              wayland
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
              ./systems/hosts/wakasu.nix
            ];
          };
          # Servers (stable)
          aomi = inputs.nixpkgs-24_05.lib.nixosSystem {
            system = "x86_64-linux";
            modules = commonModules ++ stableModules ++ [
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
              inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
              ./systems/hosts/aomi.nix
            ];
          };
          shikoku = inputs.nixpkgs-24_05.lib.nixosSystem {
            system = "x86_64-linux";
            modules = commonModules ++ stableModules ++ [
              ./systems/hosts/shikoku.nix
            ];
          };
          sakhalin = inputs.nixpkgs-24_05.lib.nixosSystem {
            system = "x86_64-linux";
            modules = commonModules ++ stableModules ++ [
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              ./systems/hosts/sakhalin.nix
            ];
          };
          kerkouane = inputs.nixpkgs-24_05.lib.nixosSystem {
            system = "x86_64-linux";
            modules = commonModules ++ stableModules ++ [
              ./systems/modules/services/govanityurl.nix
              ./systems/hosts/kerkouane.nix
            ];
          };
          # Raspberry PI
          # athena
          athena = inputs.nixpkgs-24_05.lib.nixosSystem {
            system = "aarch64-linux";
            modules = commonModules ++ stableModules ++ [
              ./systems/hosts/athena.nix
            ];
          };
          # demeter
          demeter = inputs.nixpkgs-24_05.lib.nixosSystem {
            system = "aarch64-linux";
            modules = commonModules ++ stableModules ++ [
              ./systems/hosts/demeter.nix
            ];
          };
        };

      # TODO: expose some packages ?
      # This is probably not gonna happen, instead I should move any internal package here outside, in their
      # own repository and flake. If they are useful upstream.

      overlays = import ./nix/overlays;

      devShells.x86_64-linux.default =
        let
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        pkgs.mkShell {
          packages = [ pkgs.alejandra pkgs.git pkgs.nodePackages.prettier pkgs.deadnix pkgs.nixfmt-classic pkgs.sops ];
          name = "home";
          DIRENV_LOG_FORMAT = "";
        };
    };

  inputs = {
    # Flake for compatibility with non-flake commands
    flake-compat = { type = "github"; owner = "edolstra"; repo = "flake-compat"; flake = false; };

    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    buildkit-tekton = { url = "github:vdemeester/buildkit-tekton"; inputs.nixpkgs.follows = "nixpkgs"; };


    # nixpkgs
    nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; ref = "nixos-unstable"; };
    nixpkgs-24_05 = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; ref = "nixos-24.05"; };
    # Home Manager
    home-manager = { type = "github"; owner = "nix-community"; repo = "home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager-24_05 = { type = "github"; owner = "nix-community"; repo = "home-manager"; ref = "release-24.05"; inputs.nixpkgs.follows = "nixpkgs-24_05"; };

    impermanence = { type = "github"; owner = "nix-community"; repo = "impermanence"; };

    nixpkgs-wayland = { type = "github"; owner = "nix-community"; repo = "nixpkgs-wayland"; inputs.nixpkgs.follows = "nixpkgs"; };
    dagger = { type = "github"; owner = "dagger"; repo = "nix"; inputs.nixpkgs.follows = "nixpkgs"; };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-24_05";
    };

    sops-nix = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # WSL
    nixos-wsl = { type = "github"; owner = "nix-community"; repo = "NixOS-WSL"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-hardware = { type = "github"; owner = "NixOS"; "repo" = "nixos-hardware"; };

    # Me :D
    chick-group = {
      type = "github";
      owner = "vdemeester";
      repo = "chick-group";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Red Hat
    chapeau-rouge = {
      type = "github";
      owner = "vdemeester";
      repo = "chapeau-rouge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
