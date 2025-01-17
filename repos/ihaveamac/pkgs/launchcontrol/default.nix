{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "launchcontrol";
  version = "2.7";

  src = fetchzip {
    url = "https://www.soma-zone.com/download/files/LaunchControl-${version}.tar.xz";
    hash = "sha256-qL9a3SaIs+v2qidw+zSMZUhI8sjVI3SOvyS3HsQqj+A=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/Applications
    cp -R LaunchControl.app $out/Applications/LaunchControl.app
  '';

  meta = with lib; {
    description = "Create, manage and debug launchd(8) services";
    homepage = "https://www.soma-zone.com/LaunchControl/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
  };
}
