{
  description = "Example nix flake template for using program-synthesis-nur";

  nixConfig = {
    extra-substituters = ["https://mistzzt.cachix.org"];
    extra-trusted-public-keys = ["mistzzt.cachix.org-1:Ie2vJ/2OCl4D/ifadJLqqd6X3Uj7J2bDqNmw8n1hAJc="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    progsyn = {
      url = "github:mistzzt/program-synthesis-nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    progsyn,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      synPkgs = progsyn.packages.${system};
    in {
      # define your package set here
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      synPkgs = progsyn.packages.${system};
    in {
      default = pkgs.mkShell {
        packages =
          (with pkgs; [cvc5 z3])
          ++ (with synPkgs; [sketch]);
      };
    });
  };
}
