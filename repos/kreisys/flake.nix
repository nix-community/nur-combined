{
  description = "My NUR packages, flaked";

  edition = 201909;

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" "x86_64-darwin" ];

    forAllSystems =
      f: nixpkgs.lib.genAttrs systems (system: f system);

    pkgsFor = system: import nixpkgs {
      inherit system;
    };

  in
  {
    lib = with nixpkgs.lib; rec {};

    packages =
      forAllSystems (system: import ./pkgs {
        sources = import nix/sources.nix;
        pkgs    = pkgsFor system;
      });

    hydraJobs = {
      build = {
        inherit (self.packages) x86_64-linux x86_64-darwin;
      };
    };
  };
}
