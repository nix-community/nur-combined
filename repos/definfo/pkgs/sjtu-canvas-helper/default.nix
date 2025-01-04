{
  source,
  lib,
  stdenv,
  dpkg,
  wrapGAppsHook3,
  autoPatchelfHook,
  openssl_1_1,
  webkitgtk,
  udev,
  libayatana-appindicator,
}:

stdenv.mkDerivation {
  inherit (source) pname src version;

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook3
    autoPatchelfHook
  ];

  buildInputs = [
    openssl_1_1 # ! insecure
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

  meta = {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = lib.licenses.unlicense;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ definfo ];
  };
}
