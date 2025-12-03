{ pkgs
, lib
, appimageTools
}:
let
  sources = {
    x86_64.url = "https://github.com/musescore/MuseScore/releases/download/v4.6.3/MuseScore-Studio-4.6.3.252940956-x86_64.AppImage";
    x86_64.hash = "sha256-YWdQhWgslsYZCkxnlB4JpMNX5CGNUiCIhrJzmtpJuwA=";
    aarch64.url = "https://github.com/musescore/MuseScore/releases/download/v4.6.3/MuseScore-Studio-4.6.3.252940956-aarch64.AppImage";
    aarch64.hash = "sha256-YaEMWpQMWIk/wqPR1BU0E05U5QOSP9ouXqazxUki8K8=";
  };
in
appimageTools.wrapType2 {
  pname = "musescore";
  version = "4.6.3.252940956";
  src =
    pkgs.fetchurl
      (
        if pkgs.stdenv.hostPlatform.isx86_64
        then sources.x86_64
        else if pkgs.stdenv.hostPlatform.isAarch64
        then sources.aarch64
        else "Unsupported architecture for MuseScore"
      );
  meta = {
    description = "Free and open-source music notation software for creating, playing and printing sheet music";
    longDescription = ''
      MuseScore is a free and open-source music notation software that allows users to create,
      play and print sheet music. It features a WYSIWYG editor with unlimited score size,
      unlimited number of staves, and support for up to four voices per staff.
    '';
    homepage = "https://musescore.org";
    downloadPage = "https://musescore.org/download";
    changelog = "https://github.com/musescore/MuseScore/releases";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" "aarch64-linux" "armv7l-linux" ];
    maintainers = [ lib.maintainers.kugland ];
    mainProgram = "musescore";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
