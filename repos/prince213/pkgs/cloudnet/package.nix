{
  lib,
  fetchzip,
  makeBinaryWrapper,
  stdenvNoCC,
  zulu25,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cloudnet";
  version = "4.0.0-RC16";

  src = fetchzip {
    url = "https://github.com/CloudNetService/CloudNet/releases/download/${finalAttrs.version}/CloudNet.zip";
    stripRoot = false;
    hash = "sha256-XRfsTOq3Bw+jsuWt4boIcQfd2Ek++vPwCzpZMcmBI2c=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/cloudnet
    cp -r launcher.jar plugins $out/share/cloudnet

    mkdir -p $out/bin
    makeWrapper ${lib.getExe zulu25} $out/bin/cloudnet \
      --add-flags "-Xms128M -Xmx128M -XX:+UseZGC -XX:+PerfDisableSharedMem" \
      --add-flags "-jar $out/share/cloudnet/launcher.jar"

    runHook postInstall
  '';

  meta = {
    description = "Cloud Network Environment Technology";
    homepage = "https://cloudnetservice.eu/";
    downloadPage = "https://github.com/CloudNetService/CloudNet/releases";
    changelog = "https://github.com/CloudNetService/CloudNet/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
