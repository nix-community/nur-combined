{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  version = "2.6.3";
  name = "prodigal-${version}";
  src = fetchurl {
    url = "https://github.com/hyattpd/Prodigal/archive/v${version}.tar.gz";
    sha256 = "sha256:17srxkqd3jc77xk15pfbgg1a9xahqg7337w95mrsia7mpza4l2c9";
  };

  makeFlags = [ "INSTALLDIR=$(out)/bin" ];
}
