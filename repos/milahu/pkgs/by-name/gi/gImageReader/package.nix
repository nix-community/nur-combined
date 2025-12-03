{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libuuid,
  sane-backends,
  podofo_0_10,
  libjpeg,
  djvulibre,
  libxmlxx3,
  libzip,
  tesseract,
  intltool,
  poppler,
  json-glib,
  ninja,
  python3,
  doxygen,
  enchant,

  # Gtk deps
  # upstream gImagereader supports Qt too
  gobject-introspection,
  wrapGAppsHook3,
  gtkmm3,
  gtksourceview3,
  gtksourceviewmm,
  gtkspell3,
  gtkspellmm,
  cairomm,
  kdePackages,
  qt6Packages,
  withQt6 ? false,
  wrapQtAppsHook ? null,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [ pygobject3 ]);
in
stdenv.mkDerivation rec {
  pname = "gImageReader";
  version = "c05e8c8c22e73b5f502f1f1df669aed1433c9a36"; # 2025-08-19

  src = fetchFromGitHub {
    owner = "manisandro";
    repo = "gImageReader";
    rev = "${version}";
    sha256 = "sha256-5BHW3JSAnbm0XKxfDqKZBEQWpavvDVrB/e8sKM8SNnI=";
  };

  postPatch =
  if (builtins.stringLength version == 40) then
  ''
    sed -i 's/^EXECUTE_PROCESS(COMMAND git rev-parse HEAD OUTPUT_VARIABLE PACKAGE_REVISION.*/SET(PACKAGE_REVISION "${version}")/' CMakeLists.txt
  ''
  else ""
  ;

  nativeBuildInputs = [
    cmake
    ninja
    intltool
    pkg-config
    pythonEnv
    enchant
    gobject-introspection
    wrapGAppsHook3
  ]
  ++ lib.optionals withQt6 [ qt6Packages.wrapQtAppsHook ];

  buildInputs = [
    libxmlxx3
    libzip
    libuuid
    sane-backends
    podofo_0_10
    libjpeg
    djvulibre
    tesseract
    poppler
    doxygen
    cairomm
    gtkmm3
    gtksourceview3
    gtksourceviewmm
    gtkspell3
    gtkspellmm
    json-glib
  ]
  ++ lib.optionals withQt6 (
    with qt6Packages;
    [
      kdePackages.poppler
      qtbase
      qtspell
      qttools
      quazip
    ]
  );

  # interface type can be where <type> is either gtk, qt6
  cmakeFlags = [
    "-DINTERFACE_TYPE=gtk"
  ]
  ++ lib.optionals withQt6 [ "-DINTERFACE_TYPE=qt6 -DQT_VER=6" ];

  meta = with lib; {
    description = "Simple Gtk/Qt front-end to tesseract-ocr";
    mainProgram = if withQt6 then "gImageReader-qt6" else "gImageReader";
    homepage = "https://github.com/manisandro/gImageReader";
    changelog = "https://github.com/manisandro/gImageReader/blob/${version}/NEWS";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ teto ];
    platforms = platforms.linux;
  };
}
