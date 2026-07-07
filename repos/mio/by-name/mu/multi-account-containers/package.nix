{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "multi-account-containers";
  version = "8.3.8";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "multi-account-containers";
    tag = finalAttrs.version;
    hash = "sha256-4pi1mVERuM2RQ31qWchJXUwZ/8nEeMVFbL3FYWLhwqI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/multi-account-containers
    cp -r src/. $out/share/multi-account-containers/
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/mozilla/multi-account-containers/releases/tag/${finalAttrs.version}";
    description = "Firefox Multi-Account Containers — keep your identities separate with colored container tabs";
    homepage = "https://github.com/mozilla/multi-account-containers";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
