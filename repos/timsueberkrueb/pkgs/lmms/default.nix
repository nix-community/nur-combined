{ lib, fetchFromGitHub, cmake, pkg-config, perl, perl536Packages
, alsa-lib ? null, fftwFloat, fltk13
, fluidsynth ? null, lame ? null, libgig ? null, libjack2 ? null, libpulseaudio ? null
, libsamplerate, libsoundio ? null, libsndfile, libvorbis ? null, portaudio ? null
, qtbase, qtx11extras, qttools, SDL2 ? null, mkDerivation }:

mkDerivation rec {
  pname = "lmms";
  version = "1.3.0-alpha.1";

  src = fetchFromGitHub {
    owner = "LMMS";
    repo = "lmms";
    rev = "v${version}";
    sha256 = "sha256-mLQ3WlppN3Ruu+rdcanGIsWKHv9cRO/zFDb41bR5uvA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake qttools pkg-config perl ];

  buildInputs = [
    alsa-lib
    fftwFloat
    fltk13
    fluidsynth
    lame
    libgig
    libjack2
    libpulseaudio
    libsamplerate
    libsndfile
    libsoundio
    libvorbis
    perl
    perl536Packages.ListMoreUtils
    perl536Packages.XMLParser
    portaudio
    qtbase
    qtx11extras
    SDL2
  ];

  preConfigurePhases = "preConfigure";
  preConfigure = ''
    substituteInPlace plugins/LadspaEffect/swh/ladspa/*.pl \
      --replace '/usr/bin/perl -w' '${perl}/bin/perl'
  '';

  cmakeFlags = [ "-DWANT_QT5=ON" ];

  meta = with lib; {
    description = "DAW similar to FL Studio (music production software)";
    homepage = "https://lmms.io";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ goibhniu yana ];
  };
}
