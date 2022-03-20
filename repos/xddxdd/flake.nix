{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hath-nix.url = github:poscat0x04/hath-nix;
    keycloak-lantian = {
      url = "git+https://git.lantian.pub/lantian/keycloak-lantian.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      lib = nixpkgs.lib;
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in
    {
      inherit forAllSystems lib;

      packages = forAllSystems (system: import ./pkgs {
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

      nixosModules = import ./modules;
    };
}
