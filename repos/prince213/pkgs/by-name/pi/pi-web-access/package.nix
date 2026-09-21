{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.30.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B8Ca1AH0OGM8nOKoWLI8Xukx0NNwU8FN84WzADa0v7c=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-Zx5f7wpvREbZND7CxwFMxCdAWbeqGzMMiPgLtmXqQ1c=";

  npmInstallFlags = [ "--omit=peer" ];
  npmPruneFlags = [ "--omit=peer" ];

  postBuild = ''
    node scripts/pi-extensions-dist.js dist
  '';

  postInstall = ''
    cp -r $out/lib/node_modules/pi-web-access/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Web search and content extraction extension for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-web-access";
    downloadPage = "https://github.com/nicobailon/pi-web-access/releases";
    changelog = "https://github.com/nicobailon/pi-web-access/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
