{ lib, stdenv, fetchurl, makeDesktopItem, unzip, imagemagick, bash, mono6, mpv }:

let
  pname = "subtitleedit";
  version = "3.6.0";
  files = {
    app = fetchurl {
      url = "https://github.com/SubtitleEdit/subtitleedit/releases/download/${version}/SE" + (builtins.replaceStrings ["."] [""] version) + ".zip";
      sha256 = "0yzh6ivhcfk0fsxcmqphhzmfn66i3cjxyvjgwqvmxhwrnnc5wjyp";
    };
    icon = fetchurl {
      url = "https://github.com/SubtitleEdit/subtitleedit/raw/${version}/src/ui/SE.ico";
      sha256 = "0mwlzjs2xv7najk3azqxm8aapxqa3i1s2h97fjrzajg93qs7mz3y";
    };
  };
  launcher = makeDesktopItem {
    name = "subtitleedit";
    desktopName = "Subtitle Edit";
    comment = "A subtitle editor";
    exec = "subtitleedit %F";
    icon = "subtitleedit";
    categories = "Video;AudioVideo;AudioVideoEditing;";
  };
in
stdenv.mkDerivation rec {
  inherit pname version;

  dontUnpack = true;

  # TODO: tesseract (OCR)
  buildInputs = [ bash mono6 mpv ];
  nativeBuildInputs = [ unzip imagemagick ];

  installPhase = ''
    install -d $out/share/subtitleedit
    unzip ${files.app} -d $out/share/subtitleedit
    touch $out/share/subtitleedit/.PACKAGE-MANAGER

    install -d $out/share/pixmaps
    convert "${files.icon}[9]" $out/share/pixmaps/subtitleedit.png

    install -d $out/share/applications
    ln -s ${launcher}/share/applications/* $out/share/applications/

    install -d $out/bin
    cat > $out/bin/subtitleedit <<EOF
    #!${bash}/bin/sh
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
