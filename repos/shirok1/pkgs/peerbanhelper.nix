{
  lib,
  stdenv,
  fetchzip,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "peerbanhelper";
  version = "9.5.1";

  src = fetchzip {
    url = "https://github.com/PBH-BTN/PeerBanHelper/releases/download/v${finalAttrs.version}/PeerBanHelper_${finalAttrs.version}.zip";
    hash = "sha256-jnj+m4epEyAfnHdIGfYWVgLFj8m6gjTg3Jh7ZMn8SzU=";
  };

  installPhase = ''
    mkdir -p $out/share/java/libraries

    install -Dm644 $src/libraries/* $out/share/java/libraries
    install -Dm644 $src/PeerBanHelper.jar $out/share/java
  '';

  meta = with lib; {
    description = "Automatically block unwanted, leeches and abnormal BT peers with support for customized and cloud rules.";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
    mainProgram = "peerbanhelper";
  };
})
