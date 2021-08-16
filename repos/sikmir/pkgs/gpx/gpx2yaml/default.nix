{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "gpx2yaml";
  version = "2021-08-16";

  src = fetchgit {
    url = "git://git.sikmir.ru/${pname}";
    rev = "c3fc569023c5b3414bc6711a6a12249435d98af5";
    sha256 = "sha256-kpAi9vuQ5fZreAZpNf2Fz7robQHyHjBDyIKYUC3SAfE=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "GPX to YAML converter";
    homepage = "https://git.sikmir.ru/gpx2yaml/file/README.md.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
