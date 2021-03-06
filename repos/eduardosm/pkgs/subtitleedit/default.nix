{ lib, stdenv, fetchurl, makeDesktopItem, unzip, imagemagick, bash, mono6, mpv, tesseract4 }:

stdenv.mkDerivation rec {
  pname = "subtitleedit";
  version = "3.6.1";

  src = fetchurl {
    url = "https://github.com/SubtitleEdit/subtitleedit/releases/download/${version}/SE" + (builtins.replaceStrings ["."] [""] version) + ".zip";
    sha256 = "1phz4yn309xhny3yhblmkmfd27bj0w1mlrm9qmjkxik6p3ig0x1q";
  };
  icon = fetchurl {
    url = "https://github.com/SubtitleEdit/subtitleedit/raw/${version}/src/ui/Icons/SE.ico";
    sha256 = "0mwlzjs2xv7najk3azqxm8aapxqa3i1s2h97fjrzajg93qs7mz3y";
  };

  launcher = makeDesktopItem {
    name = "subtitleedit";
    desktopName = "Subtitle Edit";
    comment = "A subtitle editor";
    exec = "subtitleedit %F";
    icon = "subtitleedit";
    categories = "Video;AudioVideo;AudioVideoEditing;";
  };

  dontUnpack = true;

  buildInputs = [ bash mono6 mpv tesseract4 ];
  nativeBuildInputs = [ unzip imagemagick ];

  installPhase = ''
    install -d $out/share/subtitleedit
    unzip ${src} -d $out/share/subtitleedit

    rm -r $out/share/subtitleedit/Tesseract302
    rm $out/share/subtitleedit/Hunspell{x86,x64}.dll

    touch $out/share/subtitleedit/.PACKAGE-MANAGER

    install -d $out/share/pixmaps
    convert "${icon}[9]" $out/share/pixmaps/subtitleedit.png

    install -d $out/share/applications
    ln -s ${launcher}/share/applications/* $out/share/applications/

    install -d $out/bin
    cat > $out/bin/subtitleedit <<EOF
    #!${bash}/bin/sh
    export PATH="${tesseract4}/bin\''${PATH:+:}\$PATH"
    export LD_LIBRARY_PATH="${mpv}/lib\''${LD_LIBRARY_PATH:+:}\$LD_LIBRARY_PATH"
    ${mono6}/bin/mono $out/share/subtitleedit/SubtitleEdit.exe "\$@"
    EOF
    chmod +x $out/bin/subtitleedit
  '';

  meta = with lib; {
    description = "A subtitle editor";
    homepage = "https://www.nikse.dk/subtitleedit/";
    changelog = "https://github.com/SubtitleEdit/subtitleedit/releases";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
