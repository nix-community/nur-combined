{ lib
, stdenv
, fetchFromGitHub
, cmake
, libsForQt5
, fetchpatch
}:

stdenv.mkDerivation rec {
  pname = "xcursor-viewer";
  version = "unstable-2023-02-03";

  src = fetchFromGitHub {
    owner = "drizt";
    repo = "xcursor-viewer";
    rev = "6b8a95a6071d860ee6f9b8e82695cd09d9e6ff31";
    hash = "sha256-65oL1zVNFhKM2ePNvWdSyUIEkHGktNFP5k0/oI+S2j0=";
  };

  patches = [
    (fetchpatch {
      name = "Bump-minimum-required-cmake-version-to-3_10.patch";
      url = "https://github.com/drizt/xcursor-viewer/commit/b91d524829fbf6f7b6d41254fb0e377ed69a2c91.patch";
      hash = "sha256-CzUAEDVj1QQ4nmF1Ym/B3qOIJbWS8K6t/t1fEB1ULi8=";
    })
  ];

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
  ];

  meta = with lib; {
    description = "xcursor viewer";
    homepage = "https://github.com/drizt/xcursor-viewer";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ wineee ];
    mainProgram = "xcursor-viewer";
    platforms = platforms.all;
  };
}
