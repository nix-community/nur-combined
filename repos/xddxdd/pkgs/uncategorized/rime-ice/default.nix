{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-ice";
  version = "0-unstable-2026-09-18";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "158d8a218b974383336d4e2e7c919affc570d410";
    hash = "sha256-Cr5pwfPrXDZA/fMM40CyK38sZre4kkD5x3LvKsTkgxQ=";
  };
  buildPhase = ''
    runHook preBuild

    mv default.yaml rime_ice_suggestion.yaml

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    cp -r * $out/share/rime-data/

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/iDvel/rime-ice";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rime 配置：雾凇拼音 | 长期维护的简体词库";
    homepage = "https://dvel.me/posts/rime-ice/";
    license = lib.licenses.gpl3Only;
  };
})
