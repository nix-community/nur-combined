{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, libsndfile, volk
}:

stdenv.mkDerivation rec {
  pname = "sigutils";
  version = "2021-07-17";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = pname;
    rev = "0b0be80d1c76803a1f463bb68a470d81afcc5101";
    hash = "sha256-ImeyR6iDIfgu2Pp4JcCzp+pJXVMmPLUps4kHsjsqsxM=";
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
