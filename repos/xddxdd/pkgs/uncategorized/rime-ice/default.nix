{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-ice";
  version = "0-unstable-2026-10-31";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "99662ba01e3affa6a0f009174ca530b887bac3b6";
    hash = "sha256-FDvoNdhXiPANkb1cjGjDg9KzpfXI5mwOesKp0rC6l2U=";
  };
  __structuredAttrs = true;
  strictDeps = true;
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
