{
  appimageTools,
  fetchurl,
  lib,
}:

appimageTools.wrapType2 (finalAttrs: {
  pname = "chat-on-steroids";
  version = "2.1.48";

  src = fetchurl {
    url = "https://github.com/totec448-spec/chat-on-steroids/releases/download/v${finalAttrs.version}/Chat-On-Steroids-Linux-x64.AppImage";
    hash = "sha256-0VL+1CKoZPB0+AhMVB3W9GYLIsB7abHXryvpq3kQAUE=";
  };

  # The bundled libappindicator3 (tray icon) links against it.
  extraPkgs = pkgs: [ pkgs.libdbusmenu-gtk3 ];

  extraInstallCommands = ''
    install -Dm444 \
      ${finalAttrs.contents}/com.chatonsteroids.app.desktop \
      $out/share/applications/com.chatonsteroids.app.desktop

    substituteInPlace $out/share/applications/com.chatonsteroids.app.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=chat-on-steroids'

    cp -r ${finalAttrs.contents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Local coding bridge for ChatGPT over MCP, with native desktop control and approved-folder capability limits";
    homepage = "https://github.com/totec448-spec/chat-on-steroids";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chat-on-steroids";
  };
})
