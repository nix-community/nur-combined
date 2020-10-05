{ sources, lib, writeText, fetchFromGitHub, emacsPackages, libffi, libtool, ... }:
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

  ivy-exwm = trivialBuild rec {
    pname = "ivy-exwm";
    version = builtins.substring 0 7 src.rev;
    src = fetchFromGitHub {
      owner = "pjones";
      repo = "ivy-exwm";
      rev = sources.ivy-exwm.rev;
      sha256 = sources.ivy-exwm.sha256;
    };
    packageRequires = with emacsPackages; [
      ivy
      exwm
      ivy-rich
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
      cp resources/template.kra $out/share/emacs/site-lisp/resources/template.kra
    '';

  };
}
