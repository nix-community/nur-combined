{ stdenv, lib, makeWrapper, appimageTools, fetchurl, copyDesktopItems, makeDesktopItem }:
let
  pkgname = "shotcut";
  pkgver = "24.11.17";
  shotcut-src = appimageTools.wrapType2 {
    pname = "${pkgname}";
    version = "${pkgver}";

    src = fetchurl {
      url = "https://zenlayer.dl.sourceforge.net/project/shotcut/v${pkgver}/shotcut-linux-x86_64-241117.AppImage";
      hash = "sha256-TQiRW7RERL7kGsQwEgyNRGh1CUSQSSTp0uVRuMs+qo0=";
    };
  };
in
stdenv.mkDerivation {
  pname = "${pkgname}";
  version = "${pkgver}";
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall
    makeWrapper ${shotcut-src}/bin/${pkgname} $out/bin/${pkgname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Shotcut";
      desktopName = "Shotcut";
      exec = "${pkgname}";
      terminal = false;
      icon = "org.shotcut.Shotcut";
      comment = "Shotcut is a free, open source, cross-platform video editor.";
      categories = [ "AudioVideo" "Video" "AudioVideoEditing" ];
      keywords = [
        "video"
        "audio"
        "editing"
        "shotcut"
      ];
    })
  ];

  meta = with lib; {
    description = "Shotcut is a free, open source, cross-platform video editor.";
    homepage = "https://shotcut.org/";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = with licenses; [ gpl3Plus ];
  };
}
