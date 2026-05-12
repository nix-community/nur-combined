{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        # "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { config.allowUnfree = true; inherit system; };
      });
      checks = forAllSystems (system: self.packages.${system});
      devShells = forAllSystems (system: rec {
        pkgs = import nixpkgs { config.allowUnfree = true; inherit system; };
        default = pkgs.mkShell rec{
          buildInputs =
            with pkgs;[
              stdenv.cc.libc
              stdenv
              glibc
              libgcc
              pkg-config
              gfortran
              gcc.cc
              mkl
            ];
          shellHook = ''
            unset LD_PRELOAD
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib/:${pkgs.lib.makeLibraryPath buildInputs}:$NIX_LD_LIBRARY_PATH"
            echo ${pkgs.mkl}
          '';
        };

      });
    };
}
