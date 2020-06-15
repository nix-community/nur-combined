{ stdenv, lib, fetchzip, makeWrapper, pkgconfig, guile, guile-commonmark, guile-reader }:

stdenv.mkDerivation rec {
  pname = "haunt";
  version = "0.2.4";

  src = fetchzip {
    url = "https://files.dthompson.us/haunt/haunt-${version}.tar.gz";
    sha256 = "1l8sjqm9yby92dkzbk0s6gfasmyab1ipq6qlnmyfvbralvmnvchz";
  };

  nativeBuildInputs = [ makeWrapper pkgconfig ];
  buildInputs = [ guile guile-commonmark guile-reader ];

  makeFlags = [
    "moddir=$(out)/share/guile/site"
    "godir=$(out)/share/guile/site/site-ccache"
  ];

  doCheck = true;

  # Not sure this is the right way, shouldn't it be covered by Guile's
  # setup hook?  Anyway, copied it from skribilo and it works.
  postInstall = ''
    wrapProgram $out/bin/haunt \
      --prefix GUILE_LOAD_PATH : "$out/share/guile/site:${guile-reader}/share/guile/site:${guile-commonmark}/share/guile/site" \
      --prefix GUILE_LOAD_COMPILED_PATH : "$out/share/guile/site:${guile-reader}/share/guile/site:${guile-commonmark}/share/guile/site"
  '';

  meta = with lib; {
    description = "Functional static site generator";
    longDescription = ''
      Haunt is a static site generator written in Guile Scheme.
      Haunt features a functional build system and an extensible
      interface for reading articles in any format.
    '';
    homepage = "https://dthompson.us/projects/haunt.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
