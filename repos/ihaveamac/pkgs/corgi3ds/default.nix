{
  stdenv,
  lib,
  pkgs,
  qtbase,
  wrapQtAppsHook,
  qmake,
  qtmultimedia,
  makeDesktopItem,
}:

let
  # putting this in desktopItems doesn't seem to actually work?
  desktopItem = makeDesktopItem {
    name = "corgi3ds";
    exec = "Corgi3DS";
    desktopName = "Corgi3DS";
    comment = "Low level 3DS emulator";
    startupWMClass = ".Corgi3DS-wrapped";
  };
in
stdenv.mkDerivation rec {
  pname = "Corgi3DS";
  version = "2020-07-15";

  src = pkgs.fetchFromGitHub {
    owner = "PSI-Rockin";
    repo = pname;
    rev = "master";
    sha256 = "sha256-CwF/4Am5+rw3XELjZTx9LtebAdoeMALhX42vopIgzU4=";
  };

  patches = [
    ./include-cstdint.patch
    ./include-cstdio.patch
    ./stub-missing-register-or-something.patch
    ./remove-usr-local-stuff.patch
  ];

  buildInputs = [
    qtbase
    qtmultimedia
    pkgs.gmp
  ];

  nativeBuildInputs = [
    qmake
    wrapQtAppsHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp Corgi3DS $out/bin
    ${
      if stdenv.isDarwin then
        ''
          APPDIR=$out/Applications/Corgi3DS.app/Contents
          mkdir -p $APPDIR/MacOS
          ln -s $out/bin/Corgi3DS $APPDIR/MacOS/Corgi3DS
          cp ${./Info.plist} $APPDIR/Info.plist
        ''
      else
        ''
          mkdir -p $out/share/applications
          cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
        ''
    }
    runHook postInstall
  '';

  meta = with lib; {
    description = "An LLE dog-themed 3DS emulator";
    homepage = "https://github.com/PSI-Rockin/Corgi3DS";
    license = licenses.gpl3;
    platforms = platforms.unix;
    mainProgram = "Corgi3DS";
  };
}
