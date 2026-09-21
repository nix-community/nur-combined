{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "superpowers";
  version = "6.4.1";

  src = fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rgeJhjQyABYlhlyFRmgyhbZmmmIPPNkch4CXyTkGEyM=";
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
