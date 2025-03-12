{ lib, stdenv, fetchFromGitHub, cmake, qt5, gdal, boost, fftwFloat, libsForQt5 }:

stdenv.mkDerivation rec {
  version = "4.0.0-678505c";
  name = "zonation-core-${version}";

  src = fetchFromGitHub {
    owner = "cbig";
    #owner = "FedeMPouzols";
    repo = "zonation-core";
    #rev = "${version}";
    rev = "678505c05f6b2263c3af0254c3ce9eb51a9af538";
    sha256 = "0zhjhbikasxdpgmr7yp5yjm3r4gwcr4qw0vcj661y3wrnjfc57ay";
  };

  patches = [ ./includes.patch ];

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ cmake boost.dev qt5.wrapQtAppsHook ];
  buildInputs = [ gdal qt5.qtbase boost fftwFloat libsForQt5.qwt ];

  meta = {
    description = "Spatial conservation prioritization framework for large-scale conservation planning";
    homepage = https://github.com/cbig/zonation-core;
    maintainers = [ lib.maintainers.bzizou ];
    license = lib.licenses.gpl3;
  };
}
