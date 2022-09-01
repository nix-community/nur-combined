{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "json2tsv";
  version = "0.9";

  src = fetchgit {
    url = "git://git.codemadness.org/json2tsv";
    rev = version;
    hash = "sha256-z0hkFVYwELjGXgnA67TuCELC/P74+42hDLfOHrTE8kA=";
  };

  makeFlags = [ "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "JSON to TSV converter";
    homepage = "https://git.codemadness.org/json2tsv/file/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
