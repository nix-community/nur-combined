{
  description = "wolfangaukang's flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:nixos/nixpkgs/release-22.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:guibou/nixGL";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nur.url = "github:nix-community/NUR";
    sab.url = "git+https://codeberg.org/wolfangaukang/stream-alert-bot?ref=main";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";

    # Testing
    ly.url = "github:wolfangaukang/nixpkgs/ly-unstable";
  };

  outputs = { self, nur, home-manager, nixos, nixos-stable, nixpkgs, nixos-hardware, nixos-wsl, nixgl, sab, utils, ly, ... }@inputs:
    let
      inherit (utils.lib) mkFlake exportModules;

      # Local exports
      local-lib = import ./lib { inherit inputs; };
      inherit (local-lib) importAttrset forAllSystems;
      local-modules = exportModules [
        ./modules/nixos/personal
      ];

      # Overlays
      overlays = [
        nixgl.overlay
        nur.overlay
      ] ++ (import ./overlays { inherit inputs; });

      # System settings
      username = "bjorn";

      # Home-Manager settings
      inherit (home-manager.lib) homeManagerConfiguration;
      system = "x86_64-linux";

    in mkFlake {
      inherit self inputs;

      # FUP settings
      supportedSystems = [ "x86_64-linux" ];

      # Need to test this later
      channelsConfig = { allowUnfree = true; };

      sharedOverlays = overlays;

      channels = {
        nixos.input = nixos;
        nixos-stable.input = nixos-stable;
        nixpgks.input = nixpkgs;
      };

      nix = {
        generateRegistryFromInputs = true;
        generateNixPathFromInputs = true;
      };

      hostDefaults = {
        channelName = "nixos";
        modules = [ local-modules.personal ];
      };

      hosts = {
        eyjafjallajokull = (import ./hosts/eyjafjallajokull/nixos-system.nix { inherit username overlays; } inputs);
        holuhraun = (import ./hosts/holuhraun/nixos-system.nix { inherit username overlays; } inputs );
        Katla = (import ./hosts/katla/nixos-system.nix { inherit overlays; username = "nixos"; } inputs );
        vm = (import ./hosts/raudholar/nixos-system.nix { inherit username overlays; } inputs );
      };

      # Common settings
      nixosModules = importAttrset ./modules/nixos;
      packages = forAllSystems (system: import ./pkgs {
        pkgs = import nixpkgs { inherit system; };
      });
      templates = import ./templates;

      # Home-Manager specifics
      hmModules = importAttrset ./modules/home-manager;
      homeConfigurations = {
        wsl = homeManagerConfiguration ( import ./hosts/katla/hm-config.nix { inherit system overlays; username = "nixos"; } inputs );
      };
      wsl = self.homeConfigurations.wsl.activationPackage;

    };
}
