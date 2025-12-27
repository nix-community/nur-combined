{ lib, pkgs, stdenv, appimageTools, fetchurl, ... }:

let
  version = "5.0.0";
  pname = "algermusicplayer";

  algerSrc = {
    "x86_64-linux" = fetchurl {
      url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/AlgerMusicPlayer-${version}-linux-x86_64.AppImage";
      sha256 = "c1e20734937d0a678c222023c1dddee911b97696f996127d1f0b444da2e83649";
    };
    "aarch64-linux" = fetchurl {
      url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/AlgerMusicPlayer-${version}-linux-arm64.AppImage";
      sha256 = "9db0e0ef821d7a64c8245c965ccd7a92e165dd3ccc08e02e2b2dbb5f88849917";
    };
  };

  src = algerSrc.${stdenv.hostPlatform.system} or
    (throw "${pname} does not support system ${stdenv.hostPlatform.system}");
in

appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands =
    let
      appimageContents = appimageTools.extract { inherit pname version src; };
    in
    ''
      install -D ${appimageContents}/algermusicplayer.desktop $out/share/applications/algermusicplayer.desktop
      substituteInPlace $out/share/applications/algermusicplayer.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=algermusicplayer'

      mkdir -p $out/share/pixmaps

      cp -L ${appimageContents}/algermusicplayer.png $out/share/pixmaps/algermusicplayer.png
    '';

  meta = {
    description = "Third-party music player for Netease Cloud Music";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ "cinqwqeggs" ];
    mainProgram = "algermusicplayer";
    platforms = builtins.attrNames algerSrc;
  };
}
