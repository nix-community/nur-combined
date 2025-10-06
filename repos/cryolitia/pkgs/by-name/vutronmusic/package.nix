{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "vutronmusic";
  version = "2.6.0";

  src = fetchurl {
    url = "https://github.com/stark81/VutronMusic/releases/download/v${version}/VutronMusic-${version}_linux_x86_64.AppImage";
    sha256 = "sha256-SkVN2xXQrJsPeoim3OyghqDi5NwnwiZk7lpDEEZNbFI=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src;
  unshareIpc = false;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/vutron.desktop $out/share/applications/vutron.desktop
    install -m 444 -D ${appimageContents}/vutron.png \
       $out/share/icons/hicolor/512x512/apps/vutron.png
    substituteInPlace $out/share/applications/vutron.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=vutron'
  '';

  meta = with lib; {
    description = "高颜值的第三方网易云播放器";
    mainProgram = "vutronmusic";
    homepage = "https://github.com/stark81/VutronMusic";
    license = licenses.mit;
    maintainers = with maintainers; [ Cryolitia ];
    platforms = [ "x86_64-linux" ];
  };
}
