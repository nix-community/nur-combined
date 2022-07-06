{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, volk
}:

stdenv.mkDerivation rec {
  pname = "sigutils";
  version = "2022-07-05";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = pname;
    rev = "1d7559d427aadd253dd825eef26bf15e54860c5f";
    hash = "sha256-wvd6sixwGmR9R4x+swLVqXre4Dqnj10jZIXUfaJcmBw=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ fftwFloat libsndfile volk ];

  meta = with lib; {
    description = "Small signal processing utility library";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
