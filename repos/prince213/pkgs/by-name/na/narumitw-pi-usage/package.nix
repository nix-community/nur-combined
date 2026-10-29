{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "narumitw-pi-usage";
  version = "0.68.4";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "@narumitw/pi-usage@${finalAttrs.version}";
    hash = "sha256-5ZOeOIQR5IxoofcldGdwV6TEsG7nx8SpUAPfU1gB+I4=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-V+yKcCOQ9f6eB8yXpHo4sgzw8+5gAzar1JjVLnkRmJ0=";

  npmWorkspace = "packages/pi-usage";

  npmBuildFlags = [ "--workspace=packages/pi-tui-kit" ];

  npmInstallFlags = [ "--workspace=${finalAttrs.npmWorkspace}" ];

  preInstall = ''
    kit=$out/lib/node_modules/pi-extensions/node_modules/@narumitw/pi-tui-kit
    mkdir -p $kit/node_modules
    cp -r packages/pi-tui-kit/{dist,package.json} $kit/
    cp -r packages/pi-tui-kit/node_modules/{diff,highlight.js} $kit/node_modules/
    cp -r node_modules/grok-mermaid $kit/node_modules/
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
