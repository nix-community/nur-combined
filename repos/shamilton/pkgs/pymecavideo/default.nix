{ lib
, python3Packages
, fetchFromGitLab
, inkscape
, qttools
, wrapQtAppsHook
, qtbase
, opencv2
, makeDesktopItem
}:

python3Packages.buildPythonApplication rec {
  pname = "pymecavideo";
  version = "8.0rc10";

  src = fetchFromGitLab {
    owner = "oppl";
    repo = "pymecavideo";
    rev = "v8.0_rc10";
    sha256 = "sha256-uc2GDjWVKGDPSZBLUb4+KE+uYm0g4vU++McvzH4xySQ=";
  };

  nativeBuildInputs = [ inkscape qttools wrapQtAppsHook python3Packages.pyqt6 ];

  patches = [ ./setup-fix.patch ];

  preBuild = ''
    cd src
    make LRELEASE="lrelease" RCC="${qtbase.dev}/bin/rcc"
    cd ..
  '';

  postPatch = ''
    substituteInPlace src/version.py \
      --replace "~" "_"
  '';

  postInstall = ''
    install -Dm644 "${desktopItem}/share/applications/"* \
      -t $out/share/applications/
    install -Dm 644 data/icones/pymecavideo-16.png $out/share/icons/hicolor/16x16/apps/pymecavideo.png
    install -Dm 644 data/icones/pymecavideo-32.png $out/share/icons/hicolor/32x32/apps/pymecavideo.png
    install -Dm 644 data/icones/pymecavideo-48.png $out/share/icons/hicolor/48x48/apps/pymecavideo.png
    install -Dm 644 data/icones/pymecavideo.svg $out/share/icons/hicolor/scalable/apps/pymecavideo.svg
  '';

  propagatedBuildInputs = with python3Packages; [
    pyqt6
    numpy
    magic
    opencv4
    pyqtgraph
  ];

  desktopItem = makeDesktopItem {
    name = "PyMecaVideo";
    desktopName = "PyMecaVideo";
    type = "Application";
    exec = "pymecavideo";
    terminal = false;
    icon = "pymecavideo";
    comment = "Interactive tool to track moving points in video framesets";
    categories = [ "GNOME" "Application" "Video" "Education" "Science" ];
  };

  doCheck = false;

  meta = with lib; {
    description = ''GUI automation Python module for human beings'';
    homepage = "https://github.com/asweigart/pyautogui";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
