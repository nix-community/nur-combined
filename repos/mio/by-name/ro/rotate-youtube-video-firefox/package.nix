{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rotate-youtube-video-firefox";
  version = "6.2.1.0";

  extid = "{075e8f87-f625-445c-926e-e2411df98fba}";

  src = fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/latest/rotate-youtube-video/rotate-youtube-video-latest.xpi";
    hash = "sha256-8iafw0Vvah/pWFEFAASW2EYpJJhduAYwcFezd1wWTv8=";
    name = "rotate-youtube-video.xpi";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 "$src" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/rotate-youtube-video.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    description = "Rotate YouTube Video Firefox add-on";
    homepage = "https://addons.mozilla.org/en-US/firefox/addon/rotate-youtube-video/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
