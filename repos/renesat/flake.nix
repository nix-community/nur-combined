{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.partitions
      ];

      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      partitionedAttrs = {
        checks = "dev";
        devShells = "dev";
        formatter = "dev";
      };
      partitions.dev = {
        extraInputsFlake = ./flake/dev;
        module = {
          imports = [./flake/dev];
        };
      };

      perSystem = {
        config,
        pkgs,
        lib,
        system,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = import ./overlays.nix;
          config = {
            allowUnfreePredicate = pkg:
              builtins.elem (lib.getName pkg) [
                "1fps"
              ];
          };
        };

        packages = import ./default.nix {
          inherit pkgs;
          inherit system;
        };
      };
    };
}
