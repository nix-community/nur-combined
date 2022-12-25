{
  description = "wolfangaukang's flakes";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:nixos/nixpkgs/release-22.11";

    # Nix utilities
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixgl.url = "github:guibou/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nur.url = "github:nix-community/NUR";
    sops.url = "github:Mic92/sops-nix";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    # Personal projects
    sab.url = "git+https://codeberg.org/wolfangaukang/stream-alert-bot?ref=main";

    # Testing
    ly.url = "github:wolfangaukang/nixpkgs/ly-unstable";
    cloudflare-warp.url = "github:wolfangaukang/nixpkgs/cloudflare-warp-mod";
  };

  outputs = { self, nixos, nixos-stable, nixpkgs, nixos-hardware, nixos-wsl, nixgl, nur, utils, ... }@inputs:
    let
      inherit (utils.lib) mkFlake exportModules;

      # Local exports
      local-modules = exportModules [ ./system/modules/personal ];
      local-lib = import ./lib { inherit inputs; };
      inherit (local-lib) importAttrset forAllSystems mkHome mkSystem;

      # Overlays
      overlays = [
        nixgl.overlay
        nur.overlay
      ] ++ (import ./overlays { inherit inputs; });

      # System settings
      users = [ "bjorn" ];
      # Currently only supporting this system
      system = "x86_64-linux";

    in mkFlake rec {
      inherit self inputs;

      # FUP settings
      supportedSystems = [ system ];

      # Need to test this later
      channelsConfig = { allowUnfree = true; };

      sharedOverlays = overlays;

      channels = {
        nixos.input = nixos;
        nixos-stable.input = nixos-stable;
        nixpkgs.input = nixpkgs;
      };

      nix = {
        generateRegistryFromInputs = true;
        generateNixPathFromInputs = true;
      };

      hostDefaults = {
        channelName = "nixos";
        modules = [ local-modules.personal ];
      };

      hosts =
        let
          usersWithRoot = users ++ [ "root" ];

        in {
          eyjafjallajokull =
            let
              nixosHardware = [ nixos-hardware.nixosModules.lenovo-thinkpad-t430 ];
            in mkSystem {
              inherit inputs overlays;
              users = usersWithRoot;
              hostname = "eyjafjallajokull";
              extra-modules = nixosHardware;
              enable-impermanence = true;
              enable-sops = true;
              enable-hm = true;
              hm-users = users;
            };

          holuhraun =
            let
              nixosHardware = [ nixos-hardware.nixosModules.system76 ];
            in mkSystem {
              inherit inputs overlays;
              users = usersWithRoot;
              hostname = "holuhraun";
              extra-modules = nixosHardware;
              enable-impermanence = true;
              enable-sops = true;
              enable-hm = true;
              hm-users = users;
              enable-impermanence-hm = true;
            };

          Katla =
            let
              users = [ "nixos" ];
              username = builtins.elemAt users 0;
              nixosWSL = [ nixos-wsl.nixosModules.wsl ];
            in mkSystem {
              inherit inputs overlays users;
              hostname = "katla";
              extra-modules = nixosWSL;
              enable-impermanence = false;
              hm-users = users;
            } // { specialArgs = { inherit username; }; };

          vm = mkSystem {
            inherit inputs overlays;
            users = usersWithRoot;
            hostname = "raudholar";
            enable-hm = false;
            enable-impermanence = false;
          } // { channelName = "cloudflare-warp"; };
        };

      outputsBuilder = channels:
        let pkgs = channels.nixpkgs;
        inherit (pkgs) mkShell sops ssh-to-age;
        in {
          devShells."sops-env" = mkShell { buildInputs = [ sops ssh-to-age ]; };
        };

      # Common settings
      nixosModules = importAttrset ./system/modules;
      packages = forAllSystems (system: import ./pkgs {
        pkgs = import nixpkgs { inherit system; };
      });
      templates = import ./templates;

      # Home-Manager specifics
      hmModules = importAttrset ./home/modules;
      homeConfigurations = {
        wsl = mkHome {
          inherit overlays system;
          hostname = "katla";
          username = "nixos";
          channel = inputs.nixpkgs;
        };
      };
      wsl = self.homeConfigurations.wsl.activationPackage;

    };
}
