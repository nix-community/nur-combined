{ config, pkgs, girara
# zathura_pdf_mupdf fails to load _opj_create_decompress at runtime on Darwin (https://github.com/NixOS/nixpkgs/pull/61295#issue-277982980)
, useMupdf ? config.zathura.useMupdf or (!pkgs.stdenv.isDarwin) }:

let
  callPackage = pkgs.newScope self;

  self = rec {
    gtk = pkgs.gtk3;

    zathura_core = callPackage ./core { inherit girara; };

    zathura_pdf_poppler = callPackage ./pdf-poppler { inherit girara; };

    zathura_pdf_mupdf = callPackage ./pdf-mupdf { inherit girara; };

    zathura_djvu = callPackage ./djvu { inherit girara; };

    zathura_ps = callPackage ./ps { inherit girara; };

    zathura_cb = callPackage ./cb { inherit girara; };

    zathuraWrapper = callPackage ./wrapper.nix {
      plugins = [
        zathura_djvu
        zathura_ps
        zathura_cb
        (if useMupdf then zathura_pdf_mupdf else zathura_pdf_poppler)
      ];
    };
  };

in self.zathuraWrapper
