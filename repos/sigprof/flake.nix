{
  description = "Personal NUR repository of @sigprof";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    devshell,
  }:
    {
      lib = import ./lib inputs;
      nixosModules = import ./modules {inherit self inputs;};
      nixosConfigurations = import ./hosts {inherit self inputs;};
      overlays.default = import ./overlay.nix;
    }
    // (
      flake-utils.lib.eachDefaultSystem (system: let
        inherit (flake-utils.lib) filterPackages flattenTree;
        pkgs = nixpkgs.legacyPackages.${system};
        legacyPackages = (pkgs.callPackage ./pkgs {inherit inputs;}).packages;
        packages = filterPackages system (flattenTree legacyPackages);
      in {
        inherit packages legacyPackages;
      })
    )
    // (
      let
        checkedSystems = with flake-utils.lib.system; [
          x86_64-linux
          x86_64-darwin
          aarch64-linux
          aarch64-darwin
          # No `i686-linux` because `pre-commit-hooks` does not evaluate
        ];
      in
        flake-utils.lib.eachSystem checkedSystems (system: {
          checks = {
            pre-commit = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                alejandra.enable = true;
              };
            };
          };

          devShells.default = devshell.legacyPackages.${system}.mkShell {
            name = "sigprof/nur-packages";
            motd = "{6}🔨 Welcome to {bold}sigprof/nur-packages{reset}";
            packages = [
              pre-commit-hooks.packages.${system}.alejandra
            ];
            devshell.startup.pre-commit-hooks.text = self.checks.${system}.pre-commit.shellHook;
          };
        })
    );
}
