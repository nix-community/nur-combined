{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tmustier-pi-usage-extension";
  version = "0.10.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "tmustier";
    repo = "pi-extensions";
    tag = "usage-extension/v${finalAttrs.version}";
    hash = "sha256-tVAS5gD9q3T0Qu0j/jGjErvfmb43+yB5BLY1TETZs6I=";
  };

  sourceRoot = "${finalAttrs.src.name}/usage-extension";

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  meta = {
    description = "Usage statistics dashboard for Pi sessions";
    homepage = "https://github.com/tmustier/pi-extensions/tree/main/usage-extension";
    downloadPage = "https://github.com/tmustier/pi-extensions/releases";
    changelog = "https://github.com/tmustier/pi-extensions/blob/usage-extension/v${finalAttrs.version}/usage-extension/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
