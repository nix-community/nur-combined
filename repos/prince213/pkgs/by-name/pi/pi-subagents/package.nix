{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.83.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n2VQpu7LnEmiprtyIL4H7AxNSkplBLPEjbYhFA6njlY=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-Kzp7Q+EkZupXJexODN5XQpvAQDk5BmQkVtDS5ucBxuk=";

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
