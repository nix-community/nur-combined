{ stdenv, lib, fetchFromGitHub, autoreconfHook, pkgconfig, guile }:

stdenv.mkDerivation rec {
  pname = "guile-commonmark";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "OrangeShark";
    repo = "guile-commonmark";
    rev = "v${version}";
    sha256 = "1jn4idjlksq2vl4fgxgicgzz3hrcpdyr67v7jqyfaa4v4cidr059";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ guile ];

  makeFlags = [
    "moddir=$(out)/share/guile/site"
    "godir=$(out)/share/guile/site/site-ccache"
  ];

  meta = with lib; {
    description = "CommonMark parser for Guile";
    longDescription = ''
      guile-commonmark is a library for parsing CommonMark, a fully
      specified variant of Markdown.  The library is written in Guile
      Scheme and is designed to transform a CommonMark document to
      SXML.  guile-commonmark tries to closely follow the CommonMark
      spec, the main difference is no support for parsing block and
      inline level HTML.
    '';
    homepage = "https://github.com/OrangeShark/guile-commonmark";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
