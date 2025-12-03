{
  description = "A project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    gorin = {
      url = "git+https://codeberg.org/wolfangaukang/gorin";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ inputs.gorin.overlays.default ];
        }
      );

    in
    {
      #packages = forEachSystem (system: {
      #default = pkgsFor.${system}.callPackage ./package.nix { };
      #});
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
      devShells = forEachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          defaultPkgs = with pkgs; [
            dprint
            gorin
            gnumake
            marksman
            nil
            pre-commit
          ];
          langPkgs = [ ];

        in
        {
          default = pkgs.mkShell { packages = defaultPkgs ++ langPkgs; };
        }
      );
    };
}
