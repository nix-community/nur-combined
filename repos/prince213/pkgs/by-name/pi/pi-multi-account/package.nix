{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-multi-account";
  version = "1.29.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Sarrius";
    repo = "pi-multi-account";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/h0sCwBpzgdJ1h5dOIARod6dSMszcvzJqRM0ktfsHq8=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-l5JnIRSl5u5hEFIWTtSS+OIThOBN7au3SLEU4vARGOY=";

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
