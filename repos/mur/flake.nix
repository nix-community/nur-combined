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
              default = list-repo;
            };

            devShells.default = pkgs.mkShell {
              buildInputs = [
                # Package that creates env with all packages. Pretty self-explanatory.
                pkgs.buildEnv
                {
                  name = "mur";
                  paths = (builtins.attrValues packages) ++
                    [ list-repo ];
                }
              ];
            };
          };
      };
}

