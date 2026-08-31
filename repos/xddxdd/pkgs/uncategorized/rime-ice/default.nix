{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-ice";
  version = "0-unstable-2026-08-31";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "fbb516b2786e4d5444383706d13c31c2e4d10c08";
    hash = "sha256-SvWajOoaruuFAqmkz4odIzVR1wvG0KVlohQv0mJX2lY=";
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
