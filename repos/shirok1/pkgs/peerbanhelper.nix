{
  lib,
  stdenv,
  pkgs,
  ...
}:

stdenv.mkDerivation rec {
  pname = "peerbanhelper";
  version = "9.3.9";

  src = pkgs.fetchzip {
    url = "https://github.com/PBH-BTN/PeerBanHelper/releases/download/v${version}/PeerBanHelper_${version}.zip";
    hash = "sha256-ieZxZVrzbY2YckapKDWD5YNFjygibEabG+v4nVbCZvI=";
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
    mainProgram = pname;
  };
}
