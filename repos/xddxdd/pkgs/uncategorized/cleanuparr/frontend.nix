{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nodejs_26,
}:
buildNpmPackage (finalAttrs: {
  pname = "cleanuparr-frontend";
  version = "2.10.5";

  src = fetchFromGitHub {
    owner = "Cleanuparr";
    repo = "Cleanuparr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jaBAT3DWbsE5upQD4rERUVW/sb5Hu8pyuY7RdvhVDMs=";
  };
  sourceRoot = "source/code/frontend";

  nodejs = nodejs_26;
  npmDepsHash = "sha256-HVA869ahw3PS9/a9JLhHS8KieioHAdRYjp2U47WcmVU=";

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/wwwroot
    cp -r dist/ui/browser/. $out/wwwroot/

    runHook postInstall
  '';

  meta = {
    description = "Angular web frontend for Cleanuparr (build artifact)";
    homepage = "https://github.com/Cleanuparr/Cleanuparr";
    license = lib.licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
