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

    # Builders
    builders = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
    in {
      dnd = pkgs.callPackage ./builders/dnd {
        selfLib = self.lib;
      };
      minecraft = pkgs.callPackage ./builders/minecraft {};
    });

    # Library items
    lib = import ./lib { inherit (nixpkgs) lib; };

    # NixOS modules
    nixosModules = mapImport (import ./modules);

    devShell = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
    in pkgs.mkShell {
      # Things to be put in $PATH
      nativeBuildInputs = with pkgs; [
        jq
      ];
    });

    # Home-manager modules
    hmModules = mapImport (import ./hm-modules);
  };
}
