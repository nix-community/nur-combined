{
  appimageTools,
  callPackage,
  lib,
  makeWrapper,
  source ? callPackage ./source.nix { },
}:

let
  pname = "alger-music-player";
  inherit (source) version src;

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    wrapProgram $out/bin/${pname} --add-flags --no-sandbox

    install -Dm444 ${appimageContents}/algermusicplayer.desktop \
      $out/share/applications/algermusicplayer.desktop
    substituteInPlace $out/share/applications/algermusicplayer.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=${pname}'

    install -Dm444 \
      ${appimageContents}/usr/share/icons/hicolor/1084x1084/apps/algermusicplayer.png \
      $out/share/icons/hicolor/1084x1084/apps/algermusicplayer.png
  '';

  meta = {
    description = "Third-party NetEase Cloud Music player";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    changelog = "https://github.com/algerkong/AlgerMusicPlayer/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
