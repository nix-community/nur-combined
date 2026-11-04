{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-agent-browser-native";
  version = "0.9.16";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-agent-browser-native";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tKGHX/VFewN4fE55Kq0jNPt0hScFyE/3/g/YKo2x0Dg=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-TUIk+qJkqhzP/w1DmsBXHXn3MdxPyWgaU6FdaxsDpOk=";

  meta = {
    description = "Pi extension that exposes agent-browser as a native tool for browser automation";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    downloadPage = "https://github.com/fitchmultz/pi-agent-browser-native/releases";
    changelog = "https://github.com/fitchmultz/pi-agent-browser-native/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
