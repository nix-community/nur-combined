{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "audio-equalizer-firefox";
  version = "0.2.1";

  extid = "{63d150c4-394c-4275-bc32-c464e76a891c}";

  src = fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/latest/audio-equalizer-wext/audio-equalizer-wext-latest.xpi";
    hash = "sha256-U2gPdtEb3mhUM0W5FMV7PpYqluM80Gf0urWiLch7gxU=";
    name = "audio-equalizer.xpi";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 "$src" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/audio-equalizer.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    description = "Audio Equalizer Firefox add-on (toolbar popup equalizer presets)";
    homepage = "https://addons.mozilla.org/en-US/firefox/addon/audio-equalizer-wext/";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
