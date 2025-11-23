{
  pkgs,
  lib ? pkgs.lib,
  callPackage ? pkgs.callPackage,
}:

let
  inherit (lib)
    concatStringsSep
    attrNames
    removeSuffix
    importJSON
    ;
  emacs = pkgs.emacs-nox.pkgs.withPackages (epkgs: [ epkgs.org-ref ]);

  conversions = {
    directory.evaldir =
      { src, ... }:
      {
        __cmd =
          ''
            mkdir $out; cd $out;
          ''
          + (concatStringsSep "\n" (
            map (x: "ln -s ${callPackage "${src}/${x}" { }} ${removeSuffix ".nix" x}") (
              attrNames (builtins.readDir src)
            )
          ));
      };
    org.directory =
      { src, ... }:
      {
        inherit src;
        nativeBuildInputs = [ pkgs.emacs-nox ];
        __cmd = ''
          mkdir $out/
          emacs --batch $src \
            --eval '(setq default-directory (getenv "out"))' \
            -f org-babel-tangle
        '';
      };
    org.json =
      { src, ... }:
      {
        inherit src;
        nativeBuildInputs = [
          emacs
          pkgs.jq
        ];
        __cmd = ''
          emacs --batch $src --eval '(princ (json-encode (org-export-get-environment)))' | \
            jq --sort-keys > $out
        '';
      };
    org.pdf = { src, wrap, ... }: (wrap src).tex.pdf;
    org.tex =
      { src, convert, ... }:
      rec {
        inherit src;
        nativeBuildInputs = [ emacs ];
        passthru.tangles = convert {
          output = "directory";
          inherit src;
        };
        passthru.etangles = passthru.tangles.evaldir;
        passthru.ejson = importJSON (convert {
          output = "json";
          inherit src;
        });
        meta.email = passthru.ejson.email;
        meta.author = lib.head passthru.ejson.author;
        __cmd = ''
          ORGCMD=latex;
          if [[ "$src" == *presentation.org ]] ; then
            ORGCMD=beamer
          fi
          emacs --batch \
                -l org-ref \
                --eval "(setq enable-local-variables :all)" \
                $src \
                --eval '(setq default-directory (getenv "PWD"))' \
                -f org-$ORGCMD-export-to-latex
          install -Dm644 *.tex $out
        '';
      };
    tex.pdf =
      { src, ... }:
      {
        inherit src;
        nativeBuildInputs = [
          (pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-small
              llncs
              wrapfig
              ulem
              capt-of
              biblatex
              latexmk
              beamer
              pgfgantt
              svg
              trimspaces
              transparent
              catchfile
              koma-script
              xpatch
              etoolbox
              mathtools
              kpfonts
              totalcount
              lstaddons
              enumitem
              chngcntr
              subfigure
              floatrow
              csquotes
              algorithm2e
              ifoddpage
              relsize
              tcolorbox
              environ
              tikzfill
              pdfcol
              cleveref
              mathpazo
              lualatex-math
              ;
          })
          pkgs.biber
        ];
        __cmd = ''
          ${if src ? tangles then "ln -s ${src.tangles}  tangles" else ""}
          ${if src ? etangles then "ln -s ${src.etangles} etangles" else ""}
          export TMPDIR=/tmp
          export HOME=/tmp
          latexmk -pdf -halt-on-error --shell-escape $src
          install -Dm644 *.pdf $out
        '';
      };
  };
in
rec {
  convert =
    { src, output, ... }@args:
    let
      fileExtension = lib.last (lib.splitString "." (src.name or (toString src)));
      fileBase = removeSuffix ".${fileExtension}" (builtins.baseNameOf (src.name or (toString src)));
      entry =
        (conversions.${fileExtension}.${output}
          or (throw "No conversion from ${fileExtension} to ${output} found.")
        )
          {
            inherit convert src wrap;
          };
      convertSelf =
        o:
        convert {
          src = self;
          output = o;
        };
      self =
        if lib.isDerivation entry then
          entry
        else
          pkgs.runCommandLocal "${fileBase}.${output}" (
            entry
            // {
              passthru =
                (src.passthru or { })
                // (entry.passthru or { })
                // {
                  base = src;
                  # these should be limited to what is available in converters
                  directory = convertSelf "directory";
                  evaldir = convertSelf "evaldir";
                  tex = convertSelf "tex";
                  pdf = convertSelf "pdf";
                  json = convertSelf "json";
                };
              meta = lib.foldr lib.recursiveUpdate { } [
                (src.meta or { })
                (entry.meta or { })
                (args.meta or { })
              ];
            }
          ) entry.__cmd;
    in
    self;
  wrap =
    src:
    pkgs.stdenvNoCC.mkDerivation {
      name = src.name or builtins.baseNameOf src;
      buildCommand = ''
        install -Dm644 ${src} $out
      '';
      # these should be limited to what is available in converters
      passthru = lib.listToAttrs (
        (map (
          output:
          lib.nameValuePair output (convert {
            inherit src output;
          })
        ))
          [
            "directory"
            "evaldir"
            "tex"
            "pdf"
            "json"
          ]
      );

      preferLocalBuild = true;
      allowSubstitutes = false;
    };
}
