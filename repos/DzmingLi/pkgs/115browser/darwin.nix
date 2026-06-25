{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "_115browser";
  version = "7.2.5.15";

  src = fetchurl {
    url = "https://down.115.com/client/mac/115br_v${finalAttrs.version}.dmg";
    hash = "sha256-lJzAhwq1ha5szpFkhfbUdRgxxFQ/HeDMV863VXpiQI4=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a *.app $out/Applications/
    runHook postInstall
  '';

  meta = {
    description = "115浏览器 - 115 Browser";
    homepage = "https://pc.115.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
  };
})
