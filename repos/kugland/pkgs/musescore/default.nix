{ pkgs
, lib
, appimageTools
}:
let
  sources = {
    x86_64.url = "https://github.com/musescore/MuseScore/releases/download/v4.5.2/MuseScore-Studio-4.5.2.251141401-x86_64.AppImage";
    x86_64.hash = "sha256-0BC2Rkx4tNojB3608Jb5Sa5ousTICaiwCKDPv0jiYKU=";
    aarch64.url = "https://github.com/musescore/MuseScore/releases/download/v4.5.2/MuseScore-Studio-4.5.2.251150648-aarch64.AppImage";
    aarch64.hash = "sha256-4a0OIF3AVr5Pwjyyi6+pW7kb5YyaIVODvpPXvtTRdgU=";
    armv7l.url = "https://github.com/musescore/MuseScore/releases/download/v4.5.2/MuseScore-Studio-4.5.2.251150648-armv7l.AppImage";
    armv7l.hash = "sha256-wAiW4ABwnOn5QEj2u8fyAFKYlBddSH/XstdvwojUHh8=";
  };
in
appimageTools.wrapType2 {
  pname = "musescore";
  version = "Studio-4.5.2.251141401";
  src =
    pkgs.fetchurl
      (
        if pkgs.stdenv.hostPlatform.isx86_64
        then sources.x86_64
        else if pkgs.stdenv.hostPlatform.isAarch64
        then sources.aarch64
        else if pkgs.stdenv.hostPlatform.isArmv7
        then sources.armv7l
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
