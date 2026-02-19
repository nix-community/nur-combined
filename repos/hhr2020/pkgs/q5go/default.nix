{
  copyDesktopItems,
  fetchFromGitHub,
  fetchpatch,
  imagemagick,
  lib,
  makeDesktopItem,
  pandoc,
  pkg-config,
  qt6,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "q5go";
  version = "2.1.3-unstable-2023-05-01";

  src = fetchFromGitHub {
    owner = "bernds";
    repo = finalAttrs.pname;
    rev = "e5a003daabae58e18a1705757be25a7a086a591b";
    hash = "sha256-MsXi0rI+U7xfLZjcctIODEVqfii63fZpmW9iuSJHbBw=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/bernds/q5Go/commit/db74074e025685ed8c56d0420ae7602e6fc22ff7.patch";
      hash = "sha256-GWOa4HFMhvgyDUtLhTyAjOv+wp+uJCFJS268paFXaas=";
    })
  ];

  buildInputs = builtins.attrValues {
    inherit (qt6) qtbase qtmultimedia qtsvg qt5compat;
  };

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    pandoc
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  preConfigure = ''
    mkdir build && cd build
  '';

  qmakeFlags = [
    "../src/q5go.pro"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "q5go";
      desktopName = "q5Go";
      genericName = "Go";
      exec = "q5go";
      icon = "q5go";
      mimeTypes = [
        "text/plain"
        "text/sfg"
      ];
      categories = [
        "Qt"
        "KDE"
        "Game"
        "BoardGame"
      ];
      comment = finalAttrs.meta.description;
    })
  ];

  postInstall = ''
    magick ../src/images/Bowl.ico -transparent black ../src/images/Bowl.png
    install -D ../src/images/Bowl.png $out/share/icons/hicolor/32x32/apps/q5go.png
  '';

  meta = {
    description = "A tool for Go players";
    homepage = "https://github.com/bernds/q5Go";
    mainProgram = "q5go";
    license = lib.licenses.gpl2Plus;
  };
})
