{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.35.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GOT/Nym/oWLUHoO6zzvWnEeq+pXiTh/QF4VTY4vbT8s=";
  };

  patches = [ ./no-pi-deps.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-XhZY0IUXnGAcv/TZcuqJ9JqBrgnf3y3RWRkmaPYAV7g=";

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
