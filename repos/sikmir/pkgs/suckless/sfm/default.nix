{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sfm";
  version = "2021-02-18";

  src = fetchFromGitHub {
    owner = "afify";
    repo = "sfm";
    rev = "55ec310062f3e27dd95ac9d5fcb134f25a100ba9";
    sha256 = "1wldb0y2i5jrj427z4q4m4n3v1myfizc0b2wkbmvnms2fvqw05vb";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Simple file manager";
    homepage = src.meta.homepage;
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
  };
}
