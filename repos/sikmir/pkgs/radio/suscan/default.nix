{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, libxml2, sigutils, soapysdr, volk
}:

stdenv.mkDerivation rec {
  pname = "suscan";
  version = "2021-07-17";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = pname;
    rev = "09fd8cf1f220ae707a877107163515114d9eb671";
    hash = "sha256-KU3JaGIL65LWJWc6Iw/eyKdUMnVQ85g0MtmuSPGdp44=";
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
