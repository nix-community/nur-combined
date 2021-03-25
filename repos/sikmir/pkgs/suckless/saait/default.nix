{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "saait";
  version = "2020-12-24";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    rev = "134ff98c58a8cca78caf918cc6dddc3a24155490";
    sha256 = "0a7i0lsi40551krwxm0maqpnacm1imx8vdx4j3rm67h0ab3ba7bg";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "The most boring static page generator";
    homepage = "https://git.codemadness.org/saait/file/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
