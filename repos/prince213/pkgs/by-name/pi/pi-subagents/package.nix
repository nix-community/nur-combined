{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.82.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BGR3oEsb0Ir05DFX3WhFQn4SjiMC9L8kihJWT18b93g=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-fVIO8aD0mm1gx2t1fwKefJCSBkVgYQpdH9ZsLfyX8B0=";

  npmBuildScript = "build:pkg";

  preInstall = ''
    cd dist-pkg
    mv ../node_modules .
  '';

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
