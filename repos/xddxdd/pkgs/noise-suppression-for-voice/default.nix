{ stdenv
, sources
, lib
, cmake
, ...
}:

stdenv.mkDerivation rec {
  inherit (sources.noise-suppression-for-voice) pname version src;
  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = licenses.gpl3;
  };
}
