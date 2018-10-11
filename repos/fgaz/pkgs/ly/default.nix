{ stdenv, fetchFromGitHub, ncurses, linux-pam, libX11, termbox }:

stdenv.mkDerivation rec {
  name = "ly";
  version = "0.2.1";
  src = fetchFromGitHub {
    owner = "cylgom";
    repo = "ly";
    rev = "${version}";
    sha256 = "16gjcrd4a6i4x8q8iwlgdildm7cpdsja8z22pf2izdm6rwfki97d";
    fetchSubmodules = true;
  };
  buildInputs = [ ncurses linux-pam libX11 termbox ];
  makeFlags = [ "FLAGS=-Wno-error" "DESTDIR=$(out)" ];
  postInstall = ''
    mv $out/usr/* $out/
    rmdir $out/usr
  '';
}

