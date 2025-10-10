{ lib, pkgs, appimageTools, fetchurl, ... }:

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

  src = algerSrc.${pkgs.stdenv.hostPlatform.system} or (
    throw "${pname} does not support system ${pkgs.stdenv.hostPlatform.system}"
  );

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    libglvnd
    ffmpeg
    qt5.qtbase
  ];

  meta = {
    description = "Third-party music player for Netease Cloud Music";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ "cinqwqeggs" ];
    mainProgram = "algermusicplayer";
    platforms = builtins.attrNames algerSrc;
  };
}
