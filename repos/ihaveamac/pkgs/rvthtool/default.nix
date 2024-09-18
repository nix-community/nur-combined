{ lib, stdenv, fetchFromGitHub, cmake, nettle }:

stdenv.mkDerivation rec {
  pname = "rvthtool";
  version = "dev-2024-05-17";

  src = fetchFromGitHub {
    owner = "GerbilSoft";
    repo = pname;
    rev = "2029a71346198fc1fc946d5853c11f44e6d5b922";
    hash = "sha256-1/crr2dpZjexWAQ/yWd4pZG56cKcbbOwF51LOARKiF8=";
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
