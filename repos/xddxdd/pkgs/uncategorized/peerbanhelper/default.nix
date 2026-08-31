{
  fetchurl,
  nix-update-script,
  stdenv,
  lib,
  jdk25_headless,
  makeWrapper,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "peerbanhelper";
  version = "9.5.0";
  src = fetchurl {
    url = "https://github.com/Ghost-chu/PeerBanHelper/releases/download/v${finalAttrs.version}/PeerBanHelper_${finalAttrs.version}.zip";
    hash = "sha256-wMb6ZSb+TcTR9LEacpHr9ts3vUH9vmZ+xJYbGwElzLQ=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/Ghost-chu/PeerBanHelper/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Automatically bans unwanted, leeching, and anomalous BT clients, with support for custom rules for qBittorrent and Transmission";
    homepage = "https://github.com/Ghost-chu/PeerBanHelper";
    license = lib.licenses.gpl3Only;
    mainProgram = "peerbanhelper";
  };
})
