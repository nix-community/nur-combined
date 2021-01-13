{ stdenv, fetchurl, makeDesktopItem, unzip, imagemagick, bash, mono6, mpv }:

let
  pname = "subtitleedit";
  version = "3.5.18";
  files = {
    app = fetchurl {
      url = "https://github.com/SubtitleEdit/subtitleedit/releases/download/${version}/SE" + (builtins.replaceStrings ["."] [""] version) + "Linux.zip";
      sha256 = "003vs5hcs1hp8b0ad7j8dnyb0vjibv99llmjjjig5vf3cw6gbg8y";
    };
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/SubtitleEdit/subtitleedit/${version}/src/Icons/SE.ico";
      sha256 = "1k9llmxmlydnzzgnk1nlv93hp7f8d40mj8grp5fv55rmrvki3lm2";
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
    convert "${files.icon}[6]" $out/share/pixmaps/subtitleedit.png

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

  meta = with stdenv.lib; {
    description = "A subtitle editor";
    homepage = "https://www.nikse.dk/subtitleedit/";
    changelog = "https://github.com/SubtitleEdit/subtitleedit/releases";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
