{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}:

with pkgs;
let

  latexWithExtraPackages = {...}@pkgs: texlive.combine ({
    inherit (texlive) scheme-small
    collection-langgerman
    collection-latexextra
    collection-mathscience
    quattrocento
    tracklang;
    #isodate substr lipsum nonfloat supertabular;
  } // builtins.trace pkgs pkgs);

  latex = latexWithExtraPackages {};



  pandocWithFilters =
    { name ? "pandoc", filters ? [], extraPackages ? [], pythonExtra ? (_: [])}:
    let
      pythonDefault = packages: [ packages.ipython packages.pandocfilters packages.pygraphviz ];
      python = python3.withPackages (p: (pythonDefault p) ++ (pythonExtra p));
      pandocPackages = [
        librsvg
        haskellPackages.pandoc-citeproc
      ];
      buildInputs = [ makeWrapper python ] ++ pandocPackages ++ extraPackages;

    in
    runCommand name  {
      inherit buildInputs;
    } ''
        for file in ${ lib.concatStringsSep " " filters }
        do
          [ -f "$file" ] || (printf "File Not Found or not a File %s" "$file"; exit 1)
        done

        makeWrapper ${pandoc}/bin/pandoc $out/bin/pandoc \
          ${ lib.concatMapStringsSep " " (filter: "--add-flags \"-F ${filter}\"") filters} \
          --prefix PATH : "${lib.makeBinPath buildInputs}"
      '';



  inputs = nixpkgs ++ [latex];

in {
  inherit latex;
  inherit latexWithExtraPackages;
  inherit pandoc-pkgs;
  inherit pandocWithFilters;
  pandoc = pandocWithFilters {};
}
