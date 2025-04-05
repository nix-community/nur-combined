{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      # Run `nix fmt [FILE_OR_DIR]...` to execute formatters configured in treefmt.nix.
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      legacyPackages = eachSystem (pkgs: import ./default.nix { inherit pkgs; });

      packages = eachSystem (
        pkgs: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${pkgs.system}
      );

      nixosModules = import ./modules { inherit self; } // {
        default = {
          imports = nixpkgs.lib.attrValues self.nixosModules;
        };
      };

      checks = eachSystem (
        pkgs:
        self.legacyPackages.${pkgs.system}.tests
        // {
          formatting = treefmtEval.${pkgs.system}.config.build.check self;
        }
      );
    };
}
