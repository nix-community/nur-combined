{
  lib,
  stdenvNoCC,
  fetchurl,
  gitUpdater,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-lmdg";
  version = "0-unstable-2026-08-20";

  src = fetchurl {
    url = "https://github.com/jetcookies/RIME-LMDG-tracker/releases/download/${finalAttrs.version}/wanxiang-lts-zh-hans.gram";
    hash = "sha256-xfynz0OvcxTHbIApA2eet2Qokuu4zc+LdRAKqa4N7sw=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    install -Dm755 $src $out/share/rime-data/wanxiang-lts-zh-hans.gram

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/jetcookies/RIME-LMDG-tracker.git";
  };

  meta = {
    description = "Language, Model, Dictionary, Grammar";
    homepage = "https://github.com/amzxyz/RIME-LMDG";
    downloadPage = "https://github.com/amzxyz/RIME-LMDG/releases/tag/LTS";
    license = lib.licenses.cc-by-40;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
