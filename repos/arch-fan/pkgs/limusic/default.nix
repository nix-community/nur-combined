{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "limusic";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-/Z8Kk3mZhmf0kbJkxWcXpeuS+FYtPkHeHMF+9kODp+8=";
  };

  contents = appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      sed -i \
        's|^export GDK_BACKEND=.*$|export GDK_BACKEND="''${GDK_BACKEND:-wayland,x11}"|' \
        $out/apprun-hooks/linuxdeploy-plugin-gtk.sh
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version contents;

  extraInstallCommands = ''
    install -Dm444 \
      ${contents}/limusic.desktop \
      $out/share/applications/limusic.desktop

    substituteInPlace $out/share/applications/limusic.desktop \
      --replace-fail 'Exec=limusic-app' 'Exec=limusic' \
      --replace-fail 'Icon=limusic-app' 'Icon=limusic'

    cp -r ${contents}/usr/share/icons $out/share/
    chmod -R u+w $out/share/icons

    install -Dm444 \
      ${contents}/limusic.png \
      $out/share/icons/hicolor/512x512/apps/limusic.png
  '';

  meta = {
    description = "Native desktop YouTube Music client";
    homepage = "https://github.com/SimoHypers/limusic";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "limusic";
  };
}
