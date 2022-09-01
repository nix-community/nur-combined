{ lib, stdenv, fetchgit, python3 }:

stdenv.mkDerivation rec {
  pname = "tcvt";
  version = "2021-01-22";

  src = fetchgit {
    url = "git://git.subdivi.de/~helmut/tcvt.git";
    rev = "2747b2ba0dff190380f9eb7a078c94192dd310f1";
    hash = "sha256-/QT5/NfaIpPKR88Byo7HgS6qs3Zwq06jiMCTRR/tcBU=";
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
