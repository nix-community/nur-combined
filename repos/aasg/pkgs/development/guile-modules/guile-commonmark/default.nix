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

  # Needed for tests.
  LANG = "C.UTF-8";
  postPatch = ''
    # Some tests hardcode a call to setlocale for en_US.UTF-8, but that isn't
    # included in the default build environment.  And other test files that do
    # need a Unicode locale (e.g. tests/inlines/emphasis.scm) don't call
    # setlocale.  Thankfully, Guile automatically loads the locale set in the
    # environment by default (see the GUILE_INSTALL_LOCALE environment
    # variable), so these calls are actually unnecessary as long as the
    # environment is set up properly (which we do in the derivation).
    sed -i '/setlocale/d' tests/inlines/*.scm
  '';

  doCheck = true;

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
