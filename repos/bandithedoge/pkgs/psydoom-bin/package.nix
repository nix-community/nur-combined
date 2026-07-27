{
  sources,

  appimageTools,
  lib,
  stdenv,
}:
let
  sourceMap = with sources; {
    x86_64-linux = psydoom-bin-x86_64;
    aarch64-linux = psydoom-bin-aarch64;
    armv6l-linux = psydoom-bin-armhf;
    armv7a-linux = psydoom-bin-armhf;
    armv7l-linux = psydoom-bin-armhf;
  };

  source = sourceMap.${stdenv.system} or sourceMap.x86_64-linux;
in
appimageTools.wrapType2 {
  pname = "psydoom-bin";
  inherit (source) version src;

  extraInstallCommands = ''
    mv $out/bin/psydoom-bin $out/bin/psydoom
  '';

  meta = {
    description = "A backport of PSX Doom to PC";
    homepage = "https://github.com/BodbDearg/PsyDoom";
    license = lib.licenses.gpl3Plus;
    platforms = builtins.attrNames sourceMap;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "psydoom";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
