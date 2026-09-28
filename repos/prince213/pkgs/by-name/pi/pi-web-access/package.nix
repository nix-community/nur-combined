{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.32.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UAjyFczuWxnK2p/PG6RrZMTlJOpwu1OB93KvFaMRTBE=";
  };

  patches = [ ./no-pi-deps.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-Jeo9rUqTyT1sjVEqt8KuVuP/vb1p1kX3i1x6NK3XJyE=";

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
