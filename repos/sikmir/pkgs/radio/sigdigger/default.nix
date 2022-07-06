{ lib, stdenv, fetchFromGitHub, pkg-config, qmake, wrapQtAppsHook
, curl, fftw, fftwFloat, libsndfile, portaudio
, sigutils, soapysdr, suscan, suwidgets, volk
}:

stdenv.mkDerivation rec {
  pname = "sigdigger";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = "SigDigger";
    rev = "v${version}";
    hash = "sha256-dS+Fc0iQz7GIlGaR556Ur/EQh3Uzhqm9uBW42IuEqoE=";
  };

  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];

  buildInputs = [
    curl
    fftw
    fftwFloat
    libsndfile
    portaudio
    sigutils
    soapysdr
    suscan
    suwidgets
    volk
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
