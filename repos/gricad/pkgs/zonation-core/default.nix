{ lib, stdenv, fetchFromGitHub, cmake, qt4, gdal, boost, fftwFloat, libsForQt5 }:

stdenv.mkDerivation rec {
  version = "4.0.0fmp";
  name = "zonation-core-${version}";

  src = fetchFromGitHub {
    #  owner = "cbig";
    owner = "FedeMPouzols";
    repo = "zonation-core";
    #rev = "${version}";
    rev = "b2a05603d31db6b5e7ced46fc2c0fd517942a6bd";
    #sha256 = "0hz79p4hrccv0595yi85ka5y66ihixqnccjm7dfh9qqh7i0m0c23";
    sha256 = "09zai4pvm6cq4fx3gaiqgv3zn29cr5q5xa8nh6dzr1nbw8w0zhi9";
  };

  patches = [ ./includes.patch ];

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ cmake boost.dev ];
  buildInputs = [ gdal qt4 boost fftwFloat libsForQt5.qwt ];

  meta = {
    description = "Spatial conservation prioritization framework for large-scale conservation planning";
    homepage = https://github.com/cbig/zonation-core;
    maintainers = [ lib.maintainers.bzizou ];
    license = lib.licenses.gpl3;
  };
}
