{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "limusic";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-GMYF+hHi4EeN2DbJ13rK+49sPwN8AuQerGS9Moe5XX8=";
  };

  contents = appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      substituteInPlace $out/apprun-hooks/linuxdeploy-plugin-gtk.sh \
        --replace-fail 'export GDK_BACKEND=x11' \
          'export GDK_BACKEND="''${GDK_BACKEND:-wayland,x11}"'
    '';
  };
in
appimageTools.wrapAppImage {
  # Keep `src` (fetchurl) on the final derivation so nix-update can find
  # `pkg.src.url`; `contents` is what actually runs.
  inherit
    pname
    version
    src
    contents
    ;

  extraInstallCommands = ''
    install -Dm444 \
      ${contents}/limusic.desktop \
      $out/share/applications/limusic-app.desktop

    substituteInPlace $out/share/applications/limusic-app.desktop \
      --replace-fail 'Exec=limusic-app' 'Exec=limusic' \
      --replace-fail 'Categories=' 'Categories=AudioVideo;Audio;Player;Music;'

    cp -r ${contents}/usr/share/icons $out/share/
    chmod -R u+w $out/share/icons
    # Upstream ships empty 16x16, 256x256 and scalable dirs; don't ship them.
    find $out/share/icons -type d -empty -delete
  '';

  meta = {
    description = "Native desktop YouTube Music client";
    homepage = "https://github.com/SimoHypers/limusic";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "limusic";
  };
}
