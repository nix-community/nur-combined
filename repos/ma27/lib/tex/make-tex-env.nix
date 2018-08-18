{ texlive, stdenv, zathura, pdfpc, writeScriptBin }:
{ name, src, texComponents ? [], buildInputs ? [], ... }@args:

let

  texlive' = if texComponents == []
    then texlive
    else
      let components = lib.unique (texComponents ++ [ "scheme-basic" "scheme-small" ]);
      in texlive.combine (lib.fold (name: attrs: attrs // { "${name}" = texlive."${name}"; }) {} components);

  buildInputs' = [ texlive' ] ++ lib.optional lib.inNixShell [ zathura pdfpc watcher ];

  inherit (stdenv) lib;

  watcher = writeScriptBin "watch-files" ''
    #! ${stdenv.shell}

    FILE=''${1:-}
    if [ -z "$FILE" ]; then
      echo -e "\e[31mNo file to watch was specified. Aborting...\e[0m"
      exit 1
    fi

    if [ ! -f "$FILE" ]; then
      echo -e "\e[31mArgument \`$FILE' is not a valid file. Aborting...\e[0m"
      exit 1
    fi

    echo -e "\e[32mWaiting for changes in \`$FILE'...\e[0m\n"

    chsum=
    compare=

    while [ true ];
    do
      compare=$(md5sum $FILE)
      if [[ $chsum != $compare ]]; then
        echo -e "* \e[32mChange in \`$FILE' detected at $(date '+%H:%m:%S')\e[0m"
        out=$(pdflatex -interaction=nonstopmode $FILE 2>&1)
        if [ $? -eq 0 ]; then
          echo -e "\e[2m  Build sucessful, waiting for changes...\n\e[0m"
        else
          LOG=$(echo $FILE | sed -e 's,\.tex,\.log,')
          echo -e "\e[31m  Build returned non-zero exit status! Please review the log in $LOG.\n\e[0m"
        fi
        chsum=$(md5sum $FILE)
      fi
      sleep 3
    done
  '';

in

stdenv.mkDerivation (lib.recursiveUpdate (builtins.removeAttrs args [ "name" "src" "buildInputs" ]) {
  inherit name src;

  buildInputs = buildInputs';

  shellHook = ''
    echo
    echo -e "-- \e[1;37m${name} / Dev Shell \e[0m--"
    echo
    echo -e "\e[2mwatch-files your-file.tex:\e[0m     Watches your .tex file and builds it on write."
    echo -e "\e[2mzathura your-file.pdf:\e[0m         Opens the generated file with \`zathura'"
    echo -e "\e[2mpdfpc your-file.pdf:\e[0m           To start the presentation"
  '';

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    find . -type f -regex ".*\.tex$" | xargs pdflatex
  '';

  installPhase = ''
    mkdir -p $out/slides
    find . -type f -regex ".*\.pdf$" -exec cp {} $out/slides \;
  '';
})
