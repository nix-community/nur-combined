{ stdenv, lib, fetchFromGitHub, callPackage, pkgconfig, libdatrie, libthai }:
stdenv.mkDerivation rec {
  name = "thpronun-${version}";
  rev = "v${version}";
  version = "0.1.0";

  # TODO doesn't work right now
  src = fetchFromGitHub {
   # only the release tarball is hosted on my profile
    owner = "JohnAZoidberg";
    repo = "thpronun";
    inherit rev;
    sha256 = "1rjphabnf7khskwh2qawjqv29qgww47a4z8ialj1wal9x9k5kqp1";
  };

  buildInputs = [ pkgconfig libdatrie libthai ];

  meta = with lib; {
    description = "A program for analyzing pronunciation of Thai words";
    license = licenses.gpl3;
    homepage = https://github.com/tlwg/thpronun;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;

    broken = true;
  };
}

