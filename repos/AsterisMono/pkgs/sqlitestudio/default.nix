{ stdenv, lib, fetchFromGitHub, qtbase, qtsvg, qttools, readline, tcl, wrapQtAppsHook, copyDesktopItems, makeDesktopItem }:
stdenv.mkDerivation rec {
  name = "sqlitestudio";
  version = "3.4.4";

  src = fetchFromGitHub {
    owner = "pawelsalawa";
    repo = "sqlitestudio";
    rev = "${version}";
    sha256 = "5oBYv8WxyfVvvqr15XApvn6P/lBxR8b6E+2acRkvX0U=";
  };

  nativeBuildInputs = [
    wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    qtbase
    qtsvg
    qttools
    readline
    tcl
  ];

  desktopItems = [
    (makeDesktopItem {
      inherit name;
      desktopName = "Sqlitestudio";
      exec = "sqlitestudio";
      icon = name;
      comment = "Database manager for SQLite";
      terminal = false;
      startupNotify = false;
      categories = [ "Development" ];
    })
  ];

  configurePhase = ''
    mkdir -p output/build
    cd output/build
    qmake LIBDIR=$out/lib BINDIR=$out/bin ../../SQLiteStudio3
  '';

  postInstall = ''
    install -Dm755 \
      ../../SQLiteStudio3/guiSQLiteStudio/img/sqlitestudio.svg \
      $out/share/pixmaps/sqlitestudio.svg
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Database manager for SQLite";
    homepage = "https://sqlitestudio.pl/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
