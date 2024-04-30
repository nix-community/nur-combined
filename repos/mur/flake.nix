{
  description = "Myxa's (nix) User Repository";

  nixConfig = {
    extra-substituters = "https://mur.cachix.org";
    extra-trusted-public-keys = "mur.cachix.org-1:VncNRWnvAh+Pl71texI+mPOiwTB5267t029meC4HBC0=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    let
      overlays = final: prev: import ./overlay.nix final prev;
    in
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        flake = {
          overlays.default = overlays;
        };

        systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
        perSystem = { config, self', inputs', pkgs, system, lib, ... }:
          let
            mur = import ./default.nix { inherit pkgs; };
            packages = lib.filterAttrs (_: v: lib.isDerivation v) mur;
            list-repo = pkgs.callPackage ./list-repo.nix { inherit pkgs packages overlays; }; # the binary is called "mur"
          in
          {
            legacyPackages = mur;
            packages = packages // {
              # Default package that creates env with all packages. Pretty self-explanatory.
              default = pkgs.buildEnv {
                name = "mur";
                paths = (builtins.attrValues packages) ++
                  # We are adding the list-repo package (with bin called "mur")
                  # to the default environment in order to provide default binary
                  # for "nix run". It's not included in self'.packages because it
                  # makes no sense.
                  [ list-repo ];
              };
            };

            devShells.default = pkgs.mkShell {
              buildInputs = [ self'.packages.default ];
            };
          };
      };
}

