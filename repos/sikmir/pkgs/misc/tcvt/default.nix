{
  lib,
  stdenv,
  fetchgit,
  python3,
}:

stdenv.mkDerivation {
  pname = "tcvt";
  version = "0-unstable-2022-09-28";

  src = fetchgit {
    url = "git://git.subdivi.de/~helmut/tcvt.git";
    rev = "4b6275c0617628c306c42b98b9c7f2107bf64d48";
    hash = "sha256-32oCtTOYFoPKHgJ7RzamcSW5H+Z1WR+iQK02yC/62Sk=";
  };

  buildInputs = [ python3 ];

  postPatch = ''
    patchShebangs tcvt.py
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "ANSI terminal emulator";
    homepage = "https://subdivi.de/~helmut/tcvt/";
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = python3.meta.platforms;
  };
}
