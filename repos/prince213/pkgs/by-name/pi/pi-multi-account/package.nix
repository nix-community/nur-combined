{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-multi-account";
  version = "1.28.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Sarrius";
    repo = "pi-multi-account";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3nMVUy1LvlsoXG8+tEbaIohdT1qP9ibN/1/hXeaHUbI=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-gW7HpxcxRjkObS7gJ8zdu4tokWBTBqMoAZyksJvzUNM=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/pi-multi-account/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Automatic multi-account failover and rotation for the Pi coding agent";
    homepage = "https://github.com/Sarrius/pi-multi-account";
    downloadPage = "https://github.com/Sarrius/pi-multi-account/releases";
    changelog = "https://github.com/Sarrius/pi-multi-account/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
