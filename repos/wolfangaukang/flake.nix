{
  description = "wolfangaukang's flakes";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:nixos/nixpkgs/release-23.05";

    # Nix utilities
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nixgl.url = "github:guibou/nixGL";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    sops.url = "github:Mic92/sops-nix";
    utils.url = "github:numtide/flake-utils";

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

  outputs = { self, nixos, nixpkgs, utils, nixgl, nur, ... }@inputs:
    let
      local = {
        lib = import ./lib { inherit inputs; };
        overlays = import ./overlays { inherit inputs; };
      };

      overlays = [
        nixgl.overlay
        nur.overlay
      ] ++ (local.overlays);

      systems = [ "x86_64-linux" ];

      systemPkgs = nixpkgs.legacyPackages;
      forEachSystem = f: nixos.lib.genAttrs systems (system: f systemPkgs.${system});

    in {
      # Needed to make packages.python3Packages work on nix flake check
      packages = forEachSystem (pkgs: utils.lib.flattenTree (import ./pkgs/top-level { inherit pkgs; }));
      devShells = forEachSystem (pkgs: import ./shells { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosModules = import ./system/modules;
      homeManagerModules = import ./home/modules;

      nixosConfigurations =
        let
          baseUsers = {
            system = [ "root" "bjorn" ];
            hm = [ "bjorn" ];
          };

        in {
          eyjafjallajokull = local.lib.mkNixos {
            inherit inputs overlays;
            users = baseUsers.system;
            hostname = "eyjafjallajokull";
            enable-impermanence = true;
            enable-sops = true;
            enable-hm = true;
            hm-users = baseUsers.hm;
            enable-sops-hm = true;
          };

          holuhraun = local.lib.mkNixos {
            inherit inputs overlays;
            users = baseUsers.system;
            hostname = "holuhraun";
            enable-impermanence = true;
            enable-sops = true;
            enable-hm = true;
            hm-users = baseUsers.hm;
            enable-impermanence-hm = true;
            enable-sops-hm = true;
          };

          torfajokull = local.lib.mkNixos {
            inherit inputs overlays;
            users = baseUsers.system;
            hostname = "torfajokull";
            enable-impermanence = true;
            enable-sops = true;
            enable-hm = true;
            hm-users = baseUsers.hm;
            enable-sops-hm = true;
          };

          Katla =
            let
              users = [ "nixos" ];
            in local.lib.mkNixos {
              inherit inputs overlays users;
              hostname = "katla";
              hm-users = users;
              extra-special-args = { inherit users; };
            };

          vm = local.lib.mkNixos {
            inherit inputs overlays;
            users = [ "root" ];
            hostname = "raudholar";
          };
        };
    };
}
