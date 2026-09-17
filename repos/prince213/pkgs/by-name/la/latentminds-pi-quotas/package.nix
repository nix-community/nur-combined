{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "latentminds-pi-quotas";
  version = "0.5.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "latentminds-ai";
    repo = "pi-quotas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5Yc93eFWpSBx1V1Q0xT1sEcz07sAyfLsEVaJQInsxu8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src package.json $out

    runHook postInstall
  '';

  meta = {
    description = "Quota monitoring and token usage tracking for the Pi coding agent";
    homepage = "https://github.com/latentminds-ai/pi-quotas";
    downloadPage = "https://github.com/latentminds-ai/pi-quotas/releases";
    changelog = "https://github.com/latentminds-ai/pi-quotas/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
