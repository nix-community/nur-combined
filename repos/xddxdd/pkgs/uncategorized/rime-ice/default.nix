{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-ice";
  version = "0-unstable-2026-11-11";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "927e1cf1d3eeb9bf4be85e3f684dba4dd485b6f6";
    hash = "sha256-laZ7u29e+F+2slf5td+rKbJuoFHCxUI928nJ+JimVNs=";
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
