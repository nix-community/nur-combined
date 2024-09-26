{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  wrapGAppsHook3,
  autoPatchelfHook,
  openssl_1_1,
  webkitgtk,
  udev,
  libayatana-appindicator,
}:

stdenv.mkDerivation rec {
  pname = "sjtu-canvas-helper";
  version = "1.3.15";
  src = fetchurl {
    url = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper/releases/download/app-v${version}/sjtu-canvas-helper_${version}_amd64.deb";
    hash = "sha256-2O0nqezQ/GcM+aC0tbWpP7W5z3/04cB1+BiZz7szD9E=";
  };

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook3
    autoPatchelfHook
  ];
  
  buildInputs = [
    openssl_1_1
    webkitgtk
    stdenv.cc.cc
  ];

  runtimeDependencies = [
    (lib.getLib udev)
    libayatana-appindicator
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv usr/* $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = licenses.unlicense;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ ];
  };
}
