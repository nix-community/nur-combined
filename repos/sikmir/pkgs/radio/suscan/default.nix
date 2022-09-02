{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, libxml2, sigutils, soapysdr, volk
}:

stdenv.mkDerivation rec {
  pname = "suscan";
  version = "2022-07-05";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = "suscan";
    rev = "37dad542b97aff24654f0bb80fb8e85af7cb84ab";
    hash = "sha256-h1ogtYjkqiHb1/NAJfJ0HQIvGnZM2K/PSP5nqLXUf9M=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ fftwFloat libsndfile libxml2 sigutils soapysdr volk ];

  meta = with lib; {
    description = "Channel scanner based on sigutils library";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
