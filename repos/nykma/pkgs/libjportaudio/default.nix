# Copied from https://github.com/CrackTC/nur-packages
{ stdenv
, fetchFromGitHub
, jdk
, libsamplerate
, libcap
, libjack2
, alsa-lib
, cmake
, portaudio
}:

let
  version = "0.1.0";
  pname = "libjportaudio";
in
stdenv.mkDerivation rec {
  inherit version pname;
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "philburk";
    repo = "portaudio-java";
    rev = "2ec5cc47d6f8abe85ddb09c34e69342bfe72c60b";
    sha256 = "t+Pqtgstd1uJjvD4GKomZHMeSECNLeQJOrz97o+lV2Q=";
  };

  buildInputs = [ portaudio libcap libsamplerate libjack2 alsa-lib ];
  nativeBuildInputs = [ cmake ];

  JAVA_HOME = "${jdk}";
  cmakeFlags = ["-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];

  buildPhase = ''
    make jportaudio_0_1_0
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libjportaudio_0_1_0.so $out/lib/libjportaudio.so
  '';
}
