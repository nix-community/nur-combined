{
  description = "My NUR packages";

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" ];
    mapImport = nixpkgs.lib.mapAttrs (_: value: import value);
  in {
    # Packages
    # packages = forAllSystems (system: let
    #   pkgs = nixpkgs.legacyPackages."${system}";
    # in {
    # });

    nixosConfigurations.cubik-studio = import ./containers/cubik-studio.nix nixpkgs "x86_64-linux";

    # Builders
    builders = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
    in {
      minecraft = pkgs.callPackage ./builders/minecraft {};
    });

    # Library items
    lib = import ./lib { inherit (nixpkgs) lib; };

    # NixOS modules
    nixosModules = mapImport (import ./modules);

    # Home-manager modules
    hmModules = mapImport (import ./hm-modules);
  };
}
