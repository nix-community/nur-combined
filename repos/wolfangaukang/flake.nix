{
  description = "wolfangaukang's flakes";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:nixos/nixpkgs/release-24.11";

    # Nix utilities
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nur.url = "github:nix-community/NUR";
    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal projects
    sab = {
      url = "git+https://codeberg.org/wolfangaukang/stream-alert-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apep = {
      url = "git+https://codeberg.org/wolfangaukang/apep";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gorin = {
      url = "git+https://codeberg.org/wolfangaukang/gorin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sarchi = {
      url = "git+ssh://git@github.com/simplerisk/sarchi?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "git+https://codeberg.org/wolfangaukang/dotfiles";
      flake = false;
    };
    multifirefox = {
      url = "git+https://codeberg.org/wolfangaukang/multifirefox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixos, nixpkgs, apep, gorin, sarchi, multifirefox, nur, sab, ... }@inputs:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      local = {
        lib = import ./lib { inherit inputs; inherit (nixpkgs) lib; };
        overlays = import ./overlays { inherit inputs; };
      };

      overlays = [
        apep.overlays.default
        gorin.overlays.default
        multifirefox.overlays.default
        nur.overlay
        sab.overlays.default
        sarchi.overlays.default
      ] ++ (local.overlays);

      forEachSystem = genAttrs systems.flakeExposed;
      pkgsFor = forEachSystem (system: import nixpkgs { inherit overlays system; });

    in
    {
      packages = forEachSystem (system: (import ./pkgs { pkgs = pkgsFor.${system}; }) // {
        multifirefox = pkgsFor.${system}.multifirefox;
        stream-alert-bot = pkgsFor.${system}.stream-alert-bot;
      });
      devShells = forEachSystem (system: import ./shells { pkgs = pkgsFor.${system}; });
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);

      overlays.default = final: prev: { nix-agordoj = self.packages.${final.system}; };
      templates = import ./templates;

      nixosModules = import ./system/modules;
      homeManagerModules = import ./home/modules;

      nixosConfigurations = import ./system/hosts { inherit inputs overlays; localLib = local.lib; };
    };
}
