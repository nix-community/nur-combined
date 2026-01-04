{
  description = "Personal NUR repository of @sigprof";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    git-hooks-nix,
    devshell,
    ...
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
          # No `i686-linux` because `git-hooks-nix` does not evaluate
        ];
      in
        flake-utils.lib.eachSystem checkedSystems (system: let
          nixos-unstable = inputs.nixos-unstable.legacyPackages.${system};
          alejandra = nixos-unstable.alejandra;
        in {
          checks =
            {
              pre-commit = git-hooks-nix.lib.${system}.run {
                src = ./.;
                hooks = {
                  alejandra.enable = true;
                };
                tools.alejandra = alejandra;
              };
            }
            // (
              let
                inherit (nixpkgs.lib) filterAttrs mapAttrs mapAttrs' nameValuePair pipe;
                inherit (self.legacyPackages.${system}.lib) forceCached;
              in
                pipe self.nixosConfigurations [
                  (mapAttrs' (name: host: (nameValuePair ("host/" + name) host.config.system.build.toplevel)))
                  (filterAttrs (_: drv: drv.system == system))
                  (mapAttrs (_: drv: forceCached drv))
                ]
            );

          devShells.default = devshell.legacyPackages.${system}.mkShell {
            name = "sigprof/nur-packages";
            motd = "{6}🔨 Welcome to {bold}sigprof/nur-packages{reset}";
            packages = [
              alejandra
            ];
            devshell.startup.git-hooks-nix.text = self.checks.${system}.pre-commit.shellHook;
          };
        })
    );
}
