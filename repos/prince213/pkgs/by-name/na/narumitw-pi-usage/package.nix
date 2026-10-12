{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "narumitw-pi-usage";
  version = "0.65.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "@narumitw/pi-usage@${finalAttrs.version}";
    hash = "sha256-qqEMKCbEpPbpPoq/q/6f5E6tQZERw3QgW3NCGD9z2bo=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-gJDc4oTetLCDqq5NBCljns0el7ix0qQ1NC/YRWtx7tQ=";

  npmWorkspace = "packages/pi-usage";

  npmInstallFlags = [ "--workspace=${finalAttrs.npmWorkspace}" ];

  preInstall = ''
    mkdir -p $out/lib/node_modules/pi-extensions
    cp -r ${finalAttrs.npmWorkspace}/node_modules $out/lib/node_modules/pi-extensions/
  '';

  postInstall = ''
    cp -r $out/lib/node_modules/pi-extensions/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extension that shows current-account usage and DeepSeek API balance for supported providers";
    homepage = "https://github.com/narumiruna/pi-extensions/tree/main/packages/pi-usage";
    downloadPage = "https://github.com/narumiruna/pi-extensions/releases";
    changelog = "https://github.com/narumiruna/pi-extensions/blob/@narumitw/pi-usage@${finalAttrs.version}/packages/pi-usage/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
