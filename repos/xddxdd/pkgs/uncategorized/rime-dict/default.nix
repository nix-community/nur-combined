{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rime-dict";
  version = "0-unstable-2026-10-28";
  src = fetchFromGitHub {
    owner = "Iorest";
    repo = "rime-dict";
    rev = "a559581be1b3c61c9da7d0beee192ec73b193de1";
    hash = "sha256-5E/cDJ7jx2flxQZgoaNslN+uWSrqzbqdBYlQ9qOtXiY=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/rime-data
    find $src -name "*.dict.yaml" -exec cp {} $out/share/rime-data/ \;

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/Iorest/rime-dict";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "RIME 词库增强";
    homepage = "https://github.com/Iorest/rime-dict";
    license = with lib.licenses; [ unfree ];
  };
})
