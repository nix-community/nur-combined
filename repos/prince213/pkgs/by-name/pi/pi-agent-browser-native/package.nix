{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-agent-browser-native";
  version = "0.9.9";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-agent-browser-native";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1RoSotKHQXEmYaivkDW3zBteoQsUbL0bX1LdzPDSiWI=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-5itW1CmGWVP4Kx/hvCF7P+CE8BTJbR2oMSV7Y8QhmEw=";

  meta = {
    description = "Pi extension that exposes agent-browser as a native tool for browser automation";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    downloadPage = "https://github.com/fitchmultz/pi-agent-browser-native/releases";
    changelog = "https://github.com/fitchmultz/pi-agent-browser-native/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
