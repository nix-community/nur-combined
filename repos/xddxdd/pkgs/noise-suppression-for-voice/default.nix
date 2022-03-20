{ stdenv
, sources
, cmake
, ...
}:

stdenv.mkDerivation rec {
  inherit (sources.noise-suppression-for-voice) pname version src;
  nativeBuildInputs = [ cmake ];
}
