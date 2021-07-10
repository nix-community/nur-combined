{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, libusb }:

stdenv.mkDerivation rec {
  pname = "airspyhf";
  version = "1.6.8";

  src = fetchFromGitHub {
    owner = "airspy";
    repo = pname;
    rev = version;
    hash = "sha256-RKTMEDPeKcerJZtXTn8eAShxDcZUMgeQg/+7pEpMyVg=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libusb ];

  meta = with lib; {
    description = "User mode driver for Airspy HF+";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
