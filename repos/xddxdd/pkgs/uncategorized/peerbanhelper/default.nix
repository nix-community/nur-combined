{
  sources,
  stdenvNoCC,
  lib,
  jdk25_headless,
  makeWrapper,
  unzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.peerbanhelper) pname version src;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp PeerBanHelper.jar $out/opt/peerbanhelper.jar
    cp -r libraries $out/opt/libraries

    makeWrapper ${jdk25_headless}/bin/java $out/bin/peerbanhelper \
      --add-flags "-jar" \
      --add-flags "$out/opt/peerbanhelper.jar"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/Ghost-chu/PeerBanHelper/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Automatically bans unwanted, leeching, and anomalous BT clients, with support for custom rules for qBittorrent and Transmission";
    homepage = "https://github.com/Ghost-chu/PeerBanHelper";
    license = lib.licenses.gpl3Only;
    mainProgram = "peerbanhelper";
  };
})
