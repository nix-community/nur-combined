{
  fetchedSrc,
  lib,
  stdenv,
  appimageTools,
}:
let
  algerSrc = {
    "x86_64-linux" = fetchedSrc.algermusicplayer-x86;
    "aarch64-linux" = fetchedSrc.algermusicplayer-arm;
  };
  sources = algerSrc.${stdenv.hostPlatform.system};
in
appimageTools.wrapAppImage (finalAttrs: {
  pname = "algermusicplayer";
  inherit (sources) version;
  src = appimageTools.extract {
    inherit (finalAttrs) pname version;
    inherit (sources) src;
  };

  extraInstallCommands = ''
    install -D ${finalAttrs.src}/algermusicplayer.desktop $out/share/applications/algermusicplayer.desktop
    substituteInPlace $out/share/applications/algermusicplayer.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=algermusicplayer'

    mkdir -p $out/share/pixmaps

    cp -L ${finalAttrs.src}/algermusicplayer.png $out/share/pixmaps/algermusicplayer.png
  '';

  meta = {
    description = "Third-party music player for Netease Cloud Music";
    homepage = "https://github.com/algerkong/AlgerMusicPlayer";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "algermusicplayer";
    platforms = builtins.attrNames algerSrc;
  };
})
