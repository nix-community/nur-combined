{ lib, pkgs, stdenv, appimageTools, fetchurl, ... }:

let
  version = "4.9.0";
  pname = "algermusicplayer";

  algerSrc = {
    "x86_64-linux" = fetchurl {
      url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/AlgerMusicPlayer-${version}-linux-x86_64.AppImage";
      sha256 = "7d8f25a1bb118369c310d60363747cd73276c7416bdbdbc971cade95b7608268";
    };
    "aarch64-linux" = fetchurl {
      url = "https://github.com/algerkong/AlgerMusicPlayer/releases/download/v${version}/AlgerMusicPlayer-${version}-linux-arm64.AppImage";
      sha256 = "12fba1e87421b9b0385ab425568b7e0420f66afaeaa496b1cff2f7f8007bb117";
    };
  };

  src = algerSrc.${stdenv.hostPlatform.system} or
    (throw "${pname} does not support system ${stdenv.hostPlatform.system}");
in

appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    libglvnd
    ffmpeg
    qt5.qtbase
  ];

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
