{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-agent-browser-native";
  version = "0.9.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-agent-browser-native";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6ocKM+/38qC9+0Q7enAvl6i/TDODmfYNWqRv+2VdTVk=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-QzTEtBKs1zWCBmyyZTfxGhFW9OZQAIbG4mhtPFFB8LE=";

  meta = {
    description = "Pi extension that exposes agent-browser as a native tool for browser automation";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    downloadPage = "https://github.com/fitchmultz/pi-agent-browser-native/releases";
    changelog = "https://github.com/fitchmultz/pi-agent-browser-native/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
