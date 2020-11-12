{pkgs, ...}:
let
  appimage = pkgs.appimageTools.extractType2 {
    name = "ytmd-appimage";
    src = builtins.fetchurl {
        url = "https://github.com/ytmdesktop/ytmdesktop/releases/download/v1.13.0/YouTube-Music-Desktop-App-1.13.0.AppImage";
        sha256 = "0f5l7hra3m3q9zd0ngc9dj4mh1lk0rgicvh9idpd27wr808vy28v";
    };
  };
  drv = pkgs.stdenv.mkDerivation {
    name = "ytmdesktop";
    src = appimage;
    installPhase = ''
      mkdir -p $out/usr/share/ytmd
      cp $src/resources/app.asar $out/usr/share/ytmd
      cp $src/youtube-music-desktop-app.png $out/usr/share/ytmd
    '';
    meta = {
      homepage = "https://ytmdesktop.app/";
      description = "Youtube Music";
      # license = stdenv.licences.proprietary;
      platforms = pkgs.stdenv.lib.platforms.unix;
    };
  };
in pkgs.makeDesktopItem {
    name = "ytmd";
    desktopName = "Youtube Music";
    type = "Application";
    icon = "${drv}/usr/share/ytmd/youtube-music-desktop-app.png";
    exec = "${pkgs.electron}/bin/electron ${drv}/usr/share/ytmd/app.asar $*";
}
