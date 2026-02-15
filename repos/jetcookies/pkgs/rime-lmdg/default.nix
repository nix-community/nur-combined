{
  lib,
  stdenvNoCC,
  fetchurl,
  unstableGitUpdater,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-lmdg";
  version = "0-unstable-2026-02-13";

  src = fetchurl {
    url = "https://github.com/jetcookies/RIME-LMDG-tracker/releases/download/${finalAttrs.version}/wanxiang-lts-zh-hans.gram";
    hash = "sha256-9LgUCgZoI/T1nYxBs3mubyYCMzMqjvQZ40pr7MitXMk=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    install -Dm755 $src $out/share/rime-data/wanxiang-lts-zh-hans.gram

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "github:jetcookies/RIME-LMDG-tracker";
    branch = "master";
    hardcodeZeroVersion = true;
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