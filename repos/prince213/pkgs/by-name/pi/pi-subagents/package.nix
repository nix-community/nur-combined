{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.88.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t/IAZHTbIG1iFF+jq9tBm2jptfIYO2mLvn7WPb1I2Qc=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-d5se9+x5JPpQccyWns7u9CU5AAZF+KE+RrV0nWaciBw=";

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
