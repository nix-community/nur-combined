{
  description = "Cryolitia's personal NUR repository";
  nixConfig =
    {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        # "https://mirrors.cernet.edu.cn/nix-channels/store"
        # "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cryolitia.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cryolitia.cachix.org-1:/RUeJIs3lEUX4X/oOco/eIcysKZEMxZNjqiMgXVItQ8="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gpd-linuxcontrols = {
      url = "github:Cryolitia/GPD-LinuxControls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };
  outputs = { self, nixpkgs, gpd-linuxcontrols, ... }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"

        "x86_64-darwin"
        "aarch64-darwin"
      ];

      systems-linux = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = (forAllSystems (system: (with {
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      }; import ./default.nix
        {
          inherit pkgs;
        } // gpd-linuxcontrols.legacyPackages.${system} // (
        if (builtins.elem system systems-linux) then
          import ./linux-specific.nix
            {
              inherit pkgs;
            } else { }
      )
      )));

      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

      hydraJobs.build = import ./default.nix {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config = {
            config = {
              allowUnfree = true;
              cudaSupport = true;
              # https://github.com/SomeoneSerge/nixpkgs-cuda-ci/blob/develop/nix/ci/cuda-updates.nix#L18
              cudaCapabilities = [ "8.6" ];
              cudaEnableForwardCompat = false;
            };
          };
        };
      };

      nixosModules = import ./modules;
    };
}
