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
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nixgl.url = "github:guibou/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nur.url = "github:nix-community/NUR";
    sops.url = "github:Mic92/sops-nix";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    # Personal projects
    sab.url = "git+https://codeberg.org/wolfangaukang/stream-alert-bot?ref=main";
    dotfiles = {
      url = "git+https://codeberg.org/wolfangaukang/dotfiles?ref=main";
      flake = false;
    };

    # Temporary
    # Remove this one after PR 3675 from home-manager is merged
    hm-firejail.url = "github:VAWVAW/home-manager/firejail";
  };

  outputs = { self, nixos, nixos-stable, nixpkgs, nixos-hardware, nixos-wsl, nixgl, nur, utils, ... }@inputs:
    let
      inherit (utils.lib) mkFlake exportModules flattenTree;

      pkgs = import nixpkgs { inherit system; };

      # Local exports
      local = {
        modules = exportModules [ ./system/modules/personal ];
        overlays = import ./overlays { inherit inputs; };
        lib = import ./lib { inherit inputs; };
        pkgs = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
      };
      inherit (local.lib) importAttrset forAllSystems mkHome mkSystem;

      # Overlays
      overlays = [
        nixgl.overlay
        nur.overlay
      ] ++ (local.overlays);

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
        modules = [ local.modules.personal ];
      };

      hosts =
        let
          usersWithRoot = users ++ [ "root" ];
          kernels = pkgs.linuxKernel.packages;
          system76Hardware = [ nixos-hardware.nixosModules.system76 ];

        in {
          eyjafjallajokull = mkSystem {
            inherit inputs overlays;
            users = usersWithRoot;
            hostname = "eyjafjallajokull";
            # Can't upgrade because of vboxnet
            kernel = kernels.linux_6_1;
            extra-modules = system76Hardware;
            enable-impermanence = true;
            enable-sops = true;
            enable-hm = true;
            hm-users = users;
          };

          holuhraun = mkSystem {
            inherit inputs overlays;
            users = usersWithRoot;
            hostname = "holuhraun";
            # Can't upgraade because of ZFS
            kernel = kernels.linux_6_2;
            extra-modules = system76Hardware;
            enable-impermanence = true;
            enable-sops = true;
            enable-hm = true;
            hm-users = users;
            enable-impermanence-hm = true;
          };

          torfajokull = mkSystem {
            inherit inputs overlays;
            users = usersWithRoot;
            hostname = "torfajokull";
            kernel = kernels.linux_6_3;
            extra-modules = [ nixos-hardware.nixosModules.lenovo-thinkpad-t430 ];
            enable-impermanence = true;
            enable-sops = true;
            enable-hm = true;
            hm-users = users;
          };

          Katla =
            let
              users = [ "nixos" ];
              username = builtins.elemAt users 0;
            in mkSystem {
              inherit inputs overlays users;
              hostname = "katla";
              extra-modules = [ nixos-wsl.nixosModules.wsl ];
              hm-users = users;
            } // { specialArgs = { inherit username; }; };

          vm = mkSystem {
            inherit inputs overlays;
            users = [ "root" ];
            hostname = "raudholar";
            extra-modules = [ nixosModules.cloudflare-warp ];
          } // { channelName = "nixpkgs"; };
        };

      outputsBuilder = channels:
        let pkgs = channels.nixpkgs;
        inherit (pkgs) mkShell flac flacon shntool sops ssh-to-age;
        in {
          devShells = {
            flac = mkShell { buildInputs = [ flacon flac shntool ]; };
            sops-env = mkShell { buildInputs = [ sops ssh-to-age ]; };
          };
        };

      # Common settings
      nixosModules = importAttrset ./system/modules;
      packages = forAllSystems (system: flattenTree local.pkgs);
      templates = import ./templates;

      # Home-Manager specifics
      hmModules = importAttrset ./home/modules;
      homeConfigurations = {
        wsl = mkHome {
          inherit inputs overlays system;
          hostname = "katla";
          username = "nixos";
          channel = inputs.nixpkgs;
        };
      };
      wsl = self.homeConfigurations.wsl.activationPackage;

    };
}
