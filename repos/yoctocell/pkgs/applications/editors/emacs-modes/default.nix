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
    pname = "exwm-ivy";
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
}
