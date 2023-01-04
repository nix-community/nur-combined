{ pkgs, lib, callPackage }:

let
  conversions = {
    directory.evaldir = { src, convert, ... }: {
      __cmd = (''
        mkdir $out; cd $out;
      '' + (lib.concatStringsSep "\n" (map (x:
        "ln -s ${callPackage "${src}/${x}" { }} ${lib.removeSuffix ".nix" x}")
        (lib.attrNames (builtins.readDir src)))));
    };
    org.directory = { src, convert, ... }: {
      inherit src;
      nativeBuildInputs = [ pkgs.emacs-nox ];
      __cmd = ''
        mkdir $out/
        emacs --batch $src \
          --eval '(setq default-directory (getenv "out"))' \
          -f org-babel-tangle
      '';
    };
    org.json = { src, ... }: {
      inherit src;
      nativeBuildInputs = [
        (pkgs.emacs-nox.pkgs.withPackages (epkgs: with epkgs; [ org-ref ]))
        pkgs.jq
      ];
      __cmd = ''
        emacs --batch $src --eval '(princ (json-encode (org-export-get-environment)))' | \
          jq --sort-keys > $out
      '';
    };
    org.tex = { src, convert, ... }: rec {
      inherit src;
      nativeBuildInputs =
        [ (pkgs.emacs-nox.pkgs.withPackages (epkgs: with epkgs; [ org-ref ])) ];
      passthru.tangles = convert {
        output = "directory";
        inherit src;
      };
      passthru.etangles = passthru.tangles.evaldir;
      passthru.json = lib.importJSON (convert {
        output = "json";
        inherit src;
      });
      meta.email = passthru.json.email;
      meta.author = builtins.elemAt passthru.json.author 0;
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
        install -Dm444 *.tex $out
      '';
    };
    tex.pdf = { src, convert, ... }: {
      inherit src;
      nativeBuildInputs = [
        (pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-small llncs wrapfig ulem capt-of biblatex latexmk beamer
            pgfgantt svg trimspaces transparent catchfile;
        })
        pkgs.biber
      ];
      __cmd = ''
        runHook preBuild
        ${if src ? tangles then "ln -s ${src.tangles}  tangles" else ""}
        ${if src ? etangles then "ln -s ${src.etangles} etangles" else ""}
        export TMPDIR=/tmp
        export HOME=/tmp
        latexmk -pdf -halt-on-error --shell-escape $src
        install -Dm444 *.pdf $out
        runHook postBuild
      '';
    };
  };
in rec {
  convert = { src, output, ... }@args:
    let
      fileExtension =
        lib.last (lib.splitString "." (src.name or (toString src)));
      fileBase = lib.removeSuffix ".${fileExtension}"
        (builtins.baseNameOf (src.name or (toString src)));
      entry = conversions.${fileExtension}.${output} { inherit convert src; };
      self = pkgs.runCommandLocal "${fileBase}.${output}" (entry // {
        passthru = (src.passthru or { }) // (entry.passthru or { }) // {
          base = src;
          # these should be limited to what is available in converters
          directory = convert {
            src = self;
            output = "directory";
          };
          evaldir = convert {
            src = self;
            output = "evaldir";
          };
          tex = convert {
            src = self;
            output = "tex";
          };
          pdf = convert {
            src = self;
            output = "pdf";
          };
          json = convert {
            src = self;
            output = "json";
          };
        };
        meta = lib.foldr lib.recursiveUpdate { } [
          (src.meta or { })
          (entry.meta or { })
          (args.meta or { })
        ];
      }) entry.__cmd;
    in self;
  wrap = src:
    pkgs.stdenvNoCC.mkDerivation {
      buildCommand = "install -Dm444 ${src} $out";
      # these should be limited to what is available in converters
      passthru.directory = convert {
        inherit src;
        output = "directory";
      };
      passthru.evaldir = convert {
        inherit src;
        output = "evaldir";
      };
      passthru.tex = convert {
        inherit src;
        output = "tex";
      };
      passthru.pdf = convert {
        inherit src;
        output = "pdf";
      };
      passthru.json = convert {
        inherit src;
        output = "json";
      };
    };

  # convenience functions
  convert2dir = src:
    convert {
      inherit src;
      output = "directory";
      name = "output";
    };
  convert2tex = src:
    convert {
      inherit src;
      output = "tex";
    };
  convert2pdf = src:
    convert {
      inherit src;
      output = "pdf";
    };
  convert2json = src:
    convert {
      inherit src;
      output = "json";
    };
}
