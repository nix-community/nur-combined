{
  description = "Bash project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { nixpkgs, ... }: 
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = forEachSystem (system: import nixpkgs { inherit system; });

    in {
      #packages = forEachSystem (system: {
        #default = pkgsFor.${system}.callPackage ./package.nix { };
      #});
      # apps = forEachSystem (system: {
      #   default = { type = "app"; program = pkgsFor.${system}.lib.getExe self.outputs.packages.${system}.default; };
      # });
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
      devShells = forEachSystem (system: 
        let
          pkgs = pkgsFor.${system};
          defaultPkgs = with pkgs; [
            dprint
            gnumake
            marksman
            nil
            pre-commit
          ];
          langPkgs = with pkgs; [
            bash-language-server
            shellcheck
          ];

        in {
          default = pkgs.mkShell { packages = defaultPkgs ++ langPkgs; };
        });
    };
}
