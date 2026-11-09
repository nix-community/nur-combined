{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.cangjie-nixpkgs.url = "github:NixOS/nixpkgs/50ab793786d9de88ee30ec4e4c24fb4236fc2674";
  outputs =
    {
      self,
      cangjie-nixpkgs,
      nixpkgs,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      pkgsFor = system: import nixpkgs { inherit system; };
      cangjieBuildPkgsFor = system: import cangjie-nixpkgs { inherit system; };

    in
    {
      lib.reaDependencies = pkgs: import ./lib/rea-dependencies.nix { inherit pkgs; };
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          cangjieBuildPkgs = cangjieBuildPkgsFor system;
          pkgs = pkgsFor system;
        }
      );
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          attic-cache-image = pkgs.callPackage ./deploy/attic/image.nix { };
        }
      );
      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          update = pkgs.writeShellApplication {
            name = "nur-packages-update";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.curl
              pkgs.git
              pkgs.jq
              pkgs.nix
              pkgs.nixfmt
              pkgs.nix-update
              pkgs.python3
            ];
            text = ''
              exec ${pkgs.python3}/bin/python3 ${./maintainers/update.py} "''${@}"
            '';
          };
        in
        {
          update = {
            type = "app";
            program = "${update}/bin/nur-packages-update";
            meta.description = "Update pinned NUR packages with nix-update";
          };
        }
      );
      nixosModules = import ./nixos-modules;
      # homeModules = import ./home-modules;
      # darwinModules = import ./darwin-modules;
      # flakeModules = import ./flake-modules;
    };
}
