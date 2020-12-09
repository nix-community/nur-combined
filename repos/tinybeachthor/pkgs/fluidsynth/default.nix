{ stdenv, lib, fetchFromGitHub
, pkgconfig, cmake
, glib, libsndfile, libpulseaudio, libjack2, portaudio
, alsaLib
, AudioUnit, CoreAudio, CoreMIDI, CoreServices
}:

stdenv.mkDerivation rec {
  pname = "fluidsynth";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "FluidSynth";
    repo = "fluidsynth";
    rev = "v${version}";
    sha256 =  "sha256-48AF8FfRSBKVofc3/u/mFoNUIB0vmDSeHeUFGC7BlzE=";
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ glib libsndfile libpulseaudio libjack2 portaudio ]
    ++ lib.optionals stdenv.isLinux [ alsaLib ]
    ++ lib.optionals stdenv.isDarwin [ AudioUnit CoreAudio CoreMIDI CoreServices ];

  cmakeFlags = [
    "-Denable-framework=off"
    "-Denable-portaudio=on"
  ];

  meta = with lib; {
    description = "Real-time software synthesizer based on the SoundFont 2 specifications";
    homepage    = "http://www.fluidsynth.org";
    license     = licenses.lgpl21Plus;
    platforms   = platforms.unix;
  };
}
