{ lib, stdenv, fetchFromGitHub, cmake, nettle }:

stdenv.mkDerivation rec {
  pname = "rvthtool";
  version = "dev-2024-01-24";

  src = fetchFromGitHub {
    owner = "GerbilSoft";
    repo = pname;
    rev = "46b533520b4f91ce68357d9845d56e72a347ab22";
    hash = "sha256-Im2MYNu36yEQBLHQVo74uVBGbmuWrP8dWpeK55Y0Tfw=";
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
