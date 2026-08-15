{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.50.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2lv3e6s+AVXL5Da/+PhSzG4b5Hc62+2MY0mjqSPBoVo=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-61WhRXAS+JUDXQurNwdtc0ATi/gqrEcYnctvwDOa2B4=";

  dontNpmBuild = true;

  postInstall = ''
    rm -rf $out/bin
    cp -r $out/lib/node_modules/pi-subagents/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extension for async subagent delegation with truncation, artifacts, and session sharing";
    homepage = "https://github.com/nicobailon/pi-subagents";
    downloadPage = "https://github.com/nicobailon/pi-subagents/releases";
    changelog = "https://github.com/nicobailon/pi-subagents/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
