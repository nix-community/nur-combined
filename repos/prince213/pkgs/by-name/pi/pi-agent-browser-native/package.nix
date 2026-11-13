{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-agent-browser-native";
  version = "0.9.23";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-agent-browser-native";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l4FIf/n8JVBde31K8L5ZpX0sc2BeKo+jZdPUjVQSW4o=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-qlmKTWDQUpxYQ6QBEw5a9zTiWXNGvwtXXXqPbMdVNFQ=";

  meta = {
    description = "Pi extension that exposes agent-browser as a native tool for browser automation";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    downloadPage = "https://github.com/fitchmultz/pi-agent-browser-native/releases";
    changelog = "https://github.com/fitchmultz/pi-agent-browser-native/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
