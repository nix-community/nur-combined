{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "json2tsv";
  version = "0.8";

  src = fetchgit {
    url = "git://git.codemadness.org/${pname}";
    rev = version;
    sha256 = "sha256-bpXEVWayFQYJDXDzaJIFuoNJubgbw5URNOpYz3K0DPI=";
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
