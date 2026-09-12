{
  appimageTools,
  fetchurl,
  lib,
}:

appimageTools.wrapType2 rec {
  pname = "limusic";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-/Z8Kk3mZhmf0kbJkxWcXpeuS+FYtPkHeHMF+9kODp+8=";
  };

  extraInstallCommands =
    let
      contents = appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    ''
      install -Dm444 ${contents}/limusic.desktop \
        $out/share/applications/limusic.desktop

      substituteInPlace $out/share/applications/limusic.desktop \
        --replace-fail 'Exec=limusic-app' 'Exec=limusic'

      cp -r ${contents}/usr/share/icons $out/share/
    '';

  meta = {
    description = "Native desktop YouTube Music client";
    homepage = "https://github.com/SimoHypers/limusic";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "limusic";
  };
}
