{ lib, stdenv, fetchFromGitHub, cmake, nettle }:

stdenv.mkDerivation rec {
  pname = "rvthtool";
  version = "dev-2024-12-15";

  src = fetchFromGitHub {
    owner = "GerbilSoft";
    repo = pname;
    rev = "4f9761837a2de721488f5a7f10ce9dc8f4e5795e";
    hash = "sha256-cVUjlNGKFbi4jw5GtpfHJNH+56329U3NGDgh32ZyQ9E=";
  };

  buildInputs = [ nettle ];
  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Open-source tool for managing RVT-H Reader consoles";
    homepage = "https://github.com/GerbilSoft/rvthtool";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    mainProgram = "rvthtool";
  };
}
