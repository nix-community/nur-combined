{ stdenv, lib, fetchFromGitHub, wrapQtAppsHook, cmake, qt5 }:

stdenv.mkDerivation {
  pname = "clight-gui";
  version = "2021-02-26";

  src = fetchFromGitHub {
    owner = "nullobsi";
    repo = "clight-gui";
    rev = "4258f297ac4c993a769743ecc2184d0c76d1dae4";
    sha256 = "sha256-dutwHZd6ymwQcpngfkDeopnQVwK6x+nar5Toksbn3w8=";
  };

  sourceRoot = "source/src";

  buildInputs = [ qt5.qtbase qt5.qtcharts ];
  nativeBuildInputs = [ cmake wrapQtAppsHook ];

  meta = with lib; {
    description = "Qt GUI for clight";
    homepage = "https://github.com/nullobsi/clight-gui";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
