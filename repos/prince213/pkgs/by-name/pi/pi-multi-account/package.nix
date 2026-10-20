{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-multi-account";
  version = "1.26.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Sarrius";
    repo = "pi-multi-account";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VPe35uUjbZ9NxFx3Bhg/YWsAAv/Ye2DwrDt1dz1euBM=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-huvV6/6+8bZOVXWI90iPgt2sT96pgZlJf+VWpaNv6yw=";

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
