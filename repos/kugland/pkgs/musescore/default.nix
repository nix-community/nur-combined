{ lib
, stdenv
, fetchurl
, appimageTools
}:
let
  sources = {
    x86_64.url = "https://github.com/musescore/MuseScore/releases/download/v4.6.5/MuseScore-Studio-4.6.5.253511702-x86_64.AppImage";
    x86_64.hash = "sha256-GT2qDqGLz6kKRxRahCJ1uAabeyuNFT5WKxX6tf5Q/K8=";
    aarch64.url = "https://github.com/musescore/MuseScore/releases/download/v4.6.5/MuseScore-Studio-4.6.5.253511702-aarch64.AppImage";
    aarch64.hash = "sha256-iPE0Kl7gAz3HbSgdtwPkgqXcQzvsrccNIdWP22Y8ceY=";
  };
in
appimageTools.wrapType2 {
  pname = "musescore";
  version = "4.6.5.253511702";
  src =
    fetchurl
      (
        if stdenv.hostPlatform.isx86_64
        then sources.x86_64
        else if stdenv.hostPlatform.isAarch64
        then sources.aarch64
        else "Unsupported architecture for MuseScore"
      );
  meta = with lib; {
    description = "Free and open-source music notation software for creating, playing and printing sheet music";
    longDescription = ''
      MuseScore is a free and open-source music notation software that allows users to create,
      play and print sheet music. It features a WYSIWYG editor with unlimited score size,
      unlimited number of staves, and support for up to four voices per staff.
    '';
    homepage = "https://musescore.org";
    downloadPage = "https://musescore.org/download";
    changelog = "https://github.com/musescore/MuseScore/releases";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ kugland ];
    mainProgram = "musescore";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
