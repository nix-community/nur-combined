{
  appimageTools,
  fetchurl,
  lib,
}:

appimageTools.wrapType2 (finalAttrs: {
  pname = "limusic";
  version = "1.4.1";

  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${finalAttrs.version}/limusic_${finalAttrs.version}_amd64.AppImage";
    hash = "sha256-sN96kSnmSNsEH395ovKMybORSQPwYqBwU/z8r0FS/DA=";
  };

  # The bundled libgcrypt needs it; appimageTools stopped providing it.
  extraPkgs = pkgs: [ pkgs.libgpg-error ];

  extraInstallCommands = ''
    install -Dm444 \
      ${finalAttrs.contents}/limusic.desktop \
      $out/share/applications/limusic-app.desktop

    substituteInPlace $out/share/applications/limusic-app.desktop \
      --replace-fail 'Exec=limusic-app' 'Exec=limusic' \
      --replace-fail 'Categories=' 'Categories=AudioVideo;Audio;Player;Music;'

    cp -r ${finalAttrs.contents}/usr/share/icons $out/share/
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
})
