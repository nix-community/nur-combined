{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    keycloak-lantian = {
      url = "git+https://git.lantian.pub/lantian/keycloak-lantian.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      lib = nixpkgs.lib;
      eachSystem = flake-utils.lib.eachSystemMap flake-utils.lib.allSystems;
    in
    {
      inherit eachSystem lib;

      packages = eachSystem (system: import ./pkgs {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        inherit inputs;
      });

      # Following line doesn't work for infinite recursion
      # overlay = self: super: packages."${super.system}";
      overlay = self: super: import ./pkgs {
        pkgs = import nixpkgs {
          inherit (super) system;
          config.allowUnfree = true;
        };
        inherit inputs;
      };

      apps = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          nvfetcher = pkgs.writeShellScriptBin "nvfetcher" ''
            ${pkgs.nvfetcher}/bin/nvfetcher -c nvfetcher.toml -o _sources
          '';
        });

      nixosModules = import ./modules;
    };
}
