{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "u8strings";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "jwilk";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-wnv/qDn7Ke+dygRj+GFsRGtGDNsccYbXFe3gPSDAxAk=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "strings(1) with UTF-8 support";
    homepage = "https://jwilk.net/software/u8strings";
    license = licenses.mit;
    platforms = platforms.all;
  };

}
