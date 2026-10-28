{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-subagents";
  version = "0.83.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PaVfJu2+n7EBtwg3zPk1ImRJXjlm+dtMdJR+e0cJox0=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-tpfe46EtaZsW5rQV8v0h+KgPHaWWyuv/lgBwLJ0VyVk=";

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
