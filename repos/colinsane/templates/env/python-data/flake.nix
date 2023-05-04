{
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
  eachSystem allSystems (system:
    let
      pkgs = import nixpkgs { inherit system; };
      python-packages = pypkg: with pypkg; [
        natsort
        pandas
        plotly
        requests
        scipy
      ];
      python3 = pkgs.python3.withPackages python-packages;
    in {
      devShells.default = with pkgs; mkShell {
        packages = [ python3 ];
      };
    }
  );
}
