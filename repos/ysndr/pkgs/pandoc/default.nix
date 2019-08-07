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




 
  


  pandocWithFilters = 
    { name ? "pandoc", filters ? [], extraPackages ? [], pythonExtra ? (_: [])}: 
    let 
      pythonDefault = packages: [ packages.ipython packages.pandocfilters packages.pygraphviz ];
      python = python3.withPackages (p: (pythonDefault p) ++ (pythonExtra p));
      pandocPackages = [
        librsvg
        haskellPackages.pandoc-citeproc
      ];
    in
    runCommand name {
      buildInputs = [ makeWrapper pandocPackages python ] ++ extraPackages;
    } ''
        for file in ${ lib.concatStringsSep " " filters }
        do
          [ -f "$file" ] || (printf "File Not Found or not a File %s" "$file"; exit 1)
        done

        makeWrapper ${pandoc}/bin/pandoc $out/bin/pandoc \
          ${ lib.concatMapStringsSep " " (filter: "--add-flags \"-F ${filter}\"") filters} \
          --prefix PATH : "${python}/bin"
          
      '';
  


  inputs = nixpkgs ++ [latex];

in {
  inherit latex;
  inherit pandoc-pkgs;
  inherit pandocWithFilters;
}









/*
with (import <nixpkgs> {}).pkgs;
stdenv.mkDerivation {
  name = "haskell-env";
  buildInputs = [ texlive.combined.scheme-full];
} */
