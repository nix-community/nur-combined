{ lib, stdenv, mkDerivation, fetchFromGitHub, qmake, pkg-config
, fftwFloat, sigutils, suscan, suwidgets, volk
, fftw, libsndfile, soapysdr
}:

mkDerivation rec {
  pname = "sigdigger";
  version = "0.2.0-rc1";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = "SigDigger";
    rev = "v${version}";
    hash = "sha256-OWFPf1iIDhzgV7+pANp7lxzEBhxND0tIhB0VGNOeCak=";
  };

  nativeBuildInputs = [ qmake pkg-config ];

  buildInputs = [
    fftwFloat sigutils suscan suwidgets volk
    fftw libsndfile soapysdr
  ];

  qmakeFlags = [ "SUWIDGETS_PREFIX=${suwidgets}" "SigDigger.pro" ];

  installPhase = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "Qt-based digital signal analyzer, using Suscan core and Sigutils DSP library";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
