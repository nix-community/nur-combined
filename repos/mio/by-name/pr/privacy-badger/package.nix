{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "privacy-badger";
  version = "2026.6.16";

  src = fetchFromGitHub {
    owner = "EFForg";
    repo = "privacybadger";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-yWYtc++yKhbW9nt4qsAc8164aKvcf1wj/fIOFk2hEqc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/privacy-badger
    cp -r src/. $out/share/privacy-badger/
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/EFForg/privacybadger/releases/tag/release-${finalAttrs.version}";
    description = "Privacy Badger — automatically learns to block trackers (by EFF)";
    homepage = "https://privacybadger.org";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
