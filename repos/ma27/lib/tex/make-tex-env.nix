{ texlive, stdenv, zathura, pdfpc, writeScriptBin, substituteAll, bash }:
{ name, src, texComponents ? [], buildInputs ? [], ... }@args:

let

  texlive' = texlive.combine (lib.fold (name: attrs: attrs // { ${name} = texlive.${name}; }) {} (lib.unique (
    texComponents ++ [ "scheme-basic" "scheme-small" ]
  )));

  buildInputs' = [ texlive' ]
    ++ buildInputs
    ++ lib.optional lib.inNixShell [ zathura pdfpc watcher ];

  inherit (stdenv) lib;

  watcher = writeScriptBin "watch-tex" (builtins.readFile (substituteAll {
    src = ./watch-tex.bash;
    bash = "${bash}/bin/bash";
  }));

  build = "find . -type f -regex \".*\.tex$\" | xargs pdflatex -interaction=nonstopmode";

in

stdenv.mkDerivation (lib.recursiveUpdate (builtins.removeAttrs args [ "name" "src" "buildInputs" ]) {
  inherit name src;

  buildInputs = buildInputs';

  shellHook = ''
    echo
    echo -e "-- \e[1;37m${name} / Dev Shell \e[0m--"
    echo
    echo -e "\e[2mwatch-tex your-file.tex:\e[0m       Watches your .tex file and builds it on write."
    echo -e "\e[2mzathura your-file.pdf:\e[0m         Opens the generated file with \`zathura'"
    echo -e "\e[2mpdfpc your-file.pdf:\e[0m           To start the presentation"
  '';

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    ${build}

    aux=$(find . -type f -regex ".*\.aux$")
    if [ ! -z $aux ]; then
      echo $aux | xargs bibtex
      ${build} # rebuild once when building bibtex
    fi
  '';

  installPhase = ''
    mkdir -p $out/docs
    find . -type f -regex ".*\.pdf$" -exec cp {} $out/docs \;
  '';
})
