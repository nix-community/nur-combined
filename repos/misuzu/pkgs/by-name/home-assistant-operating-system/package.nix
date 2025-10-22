{
  stdenv,
  lib,
  fetchurl,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./src.json);
  drv = fetchurl (
    sources.platforms.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
  );
in
drv.overrideAttrs {
  pname = "home-assistant-operating-system";
  version = sources.version;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Home Assistant Operating System";
    homepage = "https://github.com/home-assistant/operating-system";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ misuzu ];
    platforms = lib.attrNames sources.platforms;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
