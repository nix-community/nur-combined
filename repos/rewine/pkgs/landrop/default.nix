{ lib
, stdenv
, fetchFromGitHub
, libsForQt515
, pkg-config
, libsodium
}:
let 
  qmake = libsForQt515.qmake;
  wrapQtAppsHook = libsForQt515.qt5.wrapQtAppsHook;
in stdenv.mkDerivation {
  pname = "LANDrop";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "LANDrop";
    repo = "LANDrop";
    rev = "v0.4.0";
    hash = "sha256-IwtphjMSa0e2mO5C4zHId48SUpT99sXziZzApnSmvrU=";
  };

  nativeBuildInputs = [ qmake wrapQtAppsHook pkg-config ];
  buildInputs = [ libsodium.dev ];

  dontConfigure = true;

  buildPhase = ''
    cd LANDrop
    qmake PREFIX=$out LANDrop.pro
    make -j$(nproc)
  '';

  installPhase = ''
    install -D LANDrop $out/bin/landrop
    install -D icons/app.svg  $out/share/icons/hicolor/scalable/apps/landrop.svg
    sed -i s/Exec=LANDrop/Exec=landrop/g ../misc/LANDrop.desktop
    sed -i s/Icon=LANDrop/Icon=landrop/g ../misc/LANDrop.desktop
    install -D ../misc/LANDrop.desktop $out/share/applications/LANDrop.desktop
  '';

  meta = with lib; {
    description = "Drop any files to any devices on your LAN";
    homepage = "https://landrop.app";
    license = licenses.bsd3;
  };
}

