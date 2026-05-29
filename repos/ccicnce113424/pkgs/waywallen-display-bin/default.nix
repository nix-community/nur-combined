{
  sources,
  version,
  lib,
  stdenv,
  unzip,
  autoPatchelfHook,
  qt6,
}:
stdenv.mkDerivation {
  pname = "waywallen-display";
  inherit (sources) src;
  inherit version;

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];

  strictDeps = true;
  __structuredAttrs = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/wallpapers/org.waywallen.kde
    cp -r * $out/share/plasma/wallpapers/org.waywallen.kde
    runHook postInstall
  '';

  meta = {
    description = "desktop integration for waywallen";
    homepage = "https://github.com/waywallen/waywallen-display";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
