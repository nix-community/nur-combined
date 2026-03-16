{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "archon";
  version = "9.0.17";

  src = fetchurl {
    url = "https://github.com/RPGLogs/Uploaders-archon/releases/download/v${version}/archon-v${version}.AppImage";
    hash = "sha256-wey4qGQUTFVTdyYA3MOW0lp/DnhMK1FDAjzG6BvyZ6s=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/"Archon App.desktop" \
      $out/share/applications/${pname}.desktop

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec="${pname}"'

    if [ -d ${appimageContents}/usr/share/icons ]; then
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = with lib; {
    description = "The complete toolkit for mastering endgame content";
    homepage = "https://www.archon.gg/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "archon";
    broken = false;
  };
}
