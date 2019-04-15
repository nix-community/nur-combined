{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}:

with pkgs;
let

  latex = texlive.combine {
    inherit (texlive) scheme-small
    collection-langgerman
    collection-latexextra
    collection-mathscience
    quattrocento ;
    #isodate substr lipsum nonfloat supertabular;
  };



  env-python-packages = packages: [ packages.ipython ] ;
  python = python3.withPackages env-python-packages;

  pandoc-pkgs = [
    python
    librsvg
    pandoc
    haskellPackages.pandoc-citeproc
  ];

  inputs = nixpkgs ++ [latex];

in {
  inherit latex;
  inherit pandoc-pkgs;
}









/*
with (import <nixpkgs> {}).pkgs;
stdenv.mkDerivation {
  name = "haskell-env";
  buildInputs = [ texlive.combined.scheme-full];
} */
