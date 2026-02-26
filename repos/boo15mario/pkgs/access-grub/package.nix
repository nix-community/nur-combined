{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "access-grub";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "Boo15mario";
    repo = "access-grub";
    rev = "main";
    sha256 = "1y6yvkvvak6s22iiyqrbyg60z8r2xh7nqnq83qhfas7y0x7k7ank";
  };

  installPhase = ''
    mkdir -p $out
    cp -r ./red-white-grub/* $out/
  '' ;

  meta = with lib; {
    description = "A red and white high-contrast GRUB theme for accessibility.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
