{ stdenv, fetchgit, libX11 }:

stdenv.mkDerivation {
  name = "saait";

  src = fetchgit {
    url = "git://git.codemadness.org/saait";
    rev = "134ff98c58a8cca78caf918cc6dddc3a24155490";
    sha256 = "0a7i0lsi40551krwxm0maqpnacm1imx8vdx4j3rm67h0ab3ba7bg";
  };

  installPhase = ''
    make install PREFIX=$out
  '';

}
