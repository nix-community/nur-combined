{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "superpowers";
  version = "6.3.0";

  src = fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EsGNO0dULWf5Bx6bGrCv2kI2Z8aKH0kRvGiuN23wChQ=";
  };

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  meta = {
    description = "Software development methodology for your coding agents";
    homepage = "https://github.com/obra/superpowers";
    downloadPage = "https://github.com/obra/superpowers/releases";
    changelog = "https://github.com/obra/superpowers/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
