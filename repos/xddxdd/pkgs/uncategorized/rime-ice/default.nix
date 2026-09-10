{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-ice";
  version = "0-unstable-2026-09-10";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "859e3b5300e0ea01334a627b15db101e94312a75";
    hash = "sha256-ZPIeDMgbe/syIDLR0gVkKbBKbq4QHaEDlqHp+Voc518=";
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
