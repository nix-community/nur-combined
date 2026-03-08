{
  home-manager,
  nix-darwin,
  nixpkgs-stable,
  nixpkgs-unstable,
  self,
  ...
}@inputs:
let
  homelab = import ../homelab.nix;
  lib = nixpkgs-unstable.lib;

  mkSpecialArgs =
    system:
    let
      unstablePkgs = self.lib.import_nixpkgs system nixpkgs-unstable;
      stablePkgs = self.lib.import_nixpkgs system nixpkgs-stable;
    in
    {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };

  # Auto-discover all system directories (each must have a default.nix with metadata)
  systemDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
  systemConfigs = lib.mapAttrs (name: _: import ./${name}) systemDirs;

  byType = type: lib.filterAttrs (_: cfg: cfg.type == type) systemConfigs;
in
{
  nixosConfigurations = lib.listToAttrs (
    lib.mapAttrsToList (
      name: cfg:
      let
        args = mkSpecialArgs cfg.system;
      in
      lib.nameValuePair (cfg.configName or name) (
        lib.nixosSystem {
          inherit (cfg) system;
          pkgs = args.unstablePkgs;
          specialArgs = args;
          modules = [ ./${name}/configuration.nix ];
        }
      )
    ) (byType "nixos")
  );

  darwinConfigurations = lib.listToAttrs (
    lib.mapAttrsToList (
      name: cfg:
      let
        args = mkSpecialArgs cfg.system;
      in
      lib.nameValuePair (cfg.configName or name) (
        nix-darwin.lib.darwinSystem {
          pkgs = args.unstablePkgs;
          specialArgs = args;
          modules = [ ./${name}/configuration.nix ];
        }
      )
    ) (byType "darwin")
  );

  homeConfigurations = lib.listToAttrs (
    lib.mapAttrsToList (
      name: cfg:
      let
        args = mkSpecialArgs cfg.system;
      in
      lib.nameValuePair (cfg.configName or name) (
        home-manager.lib.homeManagerConfiguration {
          pkgs = args.stablePkgs;
          extraSpecialArgs = args;
          modules = [ ./${name}/home.nix ];
        }
      )
    ) (byType "home")
  );
}
