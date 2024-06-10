{
  description = "A basic go flake with devShell";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          default = pkgs.buildGoModule {
            pname = "name";
            version = "dev";
            src = ./.;
            vendorHash = "";
            doCheck = false;
          };
        };

        devShells.default = pkgs.mkShell {
          hardeningDisable = [ "fortify" ];
          packages = with pkgs; [
            go

            # linters
            gofumpt

            # debugging
            delve
          ];
        };
      }
    );
}