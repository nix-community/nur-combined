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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixos-stable";
      };
    };

    # Personal projects
    sab = {
      url = "git+https://codeberg.org/wolfangaukang/stream-alert-bot";
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

  outputs = { self, nixos, nixpkgs, multifirefox, nur, sab, ... }@inputs:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      local = {
        lib = import ./lib { inherit inputs; inherit (nixpkgs) lib; };
        overlays = import ./overlays { inherit inputs; };
      };

      overlays = [
        multifirefox.overlays.default
        nur.overlay
        sab.overlays.default
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
