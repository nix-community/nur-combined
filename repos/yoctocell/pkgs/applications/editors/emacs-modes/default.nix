{ sources, lib, stdenv, writeText, fetchFromGitHub, emacsPackages, libffi, libtool, python3Packages, emacs, ... }:
let
  inherit (emacsPackages) trivialBuild emacs;
in
lib.recurseIntoAttrs rec {

  org-pretty-table = trivialBuild rec {
    pname = "org-pretty-table";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "Fuco1";
      repo = "org-pretty-table";
      rev = sources.org-pretty-table.rev;
      sha256 = sources.org-pretty-table.sha256;
    };
    packageRequires = with emacsPackages; [
      org
    ];
  };

  matrix-client = trivialBuild rec {
    pname = "matrix-client";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "alphapapa";
      repo = "matrix-client.el";
      rev = sources.matrix-client.rev;
      sha256 = sources.matrix-client.sha256;
    };
    packageRequires = with emacsPackages; [
      ov
      tracking
      dash
      anaphora
      f
      a
      request
      esxml
      ht
      rainbow-identifiers
      frame-purpose
    ];
  };

  ivy-hoogle = trivialBuild rec {
    pname = "ivy-hoogle";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "sjsch";
      repo = "ivy-hoogle";
      rev = sources.ivy-hoogle.rev;
      sha256 = sources.ivy-hoogle.sha256;
    };
    packageRequires = with emacsPackages; [
      ivy
      s
    ];
  };

  org-krita = trivialBuild rec {
    pname = "org-krita";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "lepisma";
      repo = "org-krita";
      rev = sources.org-krita.rev;
      sha256 = sources.org-krita.sha256;
    };
    packageRequires = with emacsPackages; [
      org
      f
    ];
    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/resources
      cp *.el *.elc $out/share/emacs/site-lisp/
      cp resources/template.kra $out/share/emacs/site-lisp/resources
    '';
  };

  tridactyl-mode = trivialBuild rec {
    pname = "tridactyl-mode";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "Fuco1";
      repo = "tridactyl-mode";
      rev = sources.tridactyl-mode.rev;
      sha256 = sources.tridactyl-mode.sha256;
    };
    packageRequires = with emacsPackages; [
      dash
    ];
  };

  awesome-tray = trivialBuild rec {
    pname = "awesome-tray";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "manateelazycat";
      repo = "awesome-tray";
      rev = sources.awesome-tray.rev;
      sha256 = sources.awesome-tray.sha256;
    };
  };

  emacs-application-framework = stdenv.mkDerivation rec {
    pname = "emacs-application-framework";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "manateelazycat";
      repo = "emacs-application-framework";
      rev = sources.emacs-application-framework.rev;
      sha256 = sources.emacs-application-framework.sha256;
    };

    nativeBuildInputs = [ emacs ];
    buildInputs = with python3Packages; [
      pyqt5
      dbus-python
      pyqtwebengine
      pymupdf
    ];

    installPhase = ''
      mkdir -p $out/share/emacs/site-lisp/app/{mindmap,interleave}
      cp *.el $out/share/emacs/site-lisp/
      cp app/mindmap/eaf-mindmap.el $out/share/emacs/site-lisp/app/mindmap/eaf-mindmap.el
      cp app/interleave/eaf-interleave.el $out/share/emacs/site-lisp/app/interleave/eaf-interleave.el
    '';

  };
}
