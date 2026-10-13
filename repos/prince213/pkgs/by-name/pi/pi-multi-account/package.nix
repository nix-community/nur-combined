{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-multi-account";
  version = "1.24.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Sarrius";
    repo = "pi-multi-account";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Fnq5nabLP9TEpHhlenJ25vlDrMAosnGk4BVRHSA47IY=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-oRIY/r22izCKHn/y+E1XH+RNHP3mHuVOL5SdIVXOsFM=";

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
