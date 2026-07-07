{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "wayback-machine-extension";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "wayback-machine-webextension";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lEcKEpchqfvPWH+VMz/qnD4I89XBPyj/DgvOLe/8ygM=";
  };

  npmDepsHash = "sha256-CQS3B03w3N3Nd67Q4Yvnsy/J5bCdgJC7jAeVYeCNEnI=";

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/wayback-machine-extension
    cp -r webextension/* $out/share/wayback-machine-extension/
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    changelog = "https://github.com/internetarchive/wayback-machine-webextension/releases/tag/v${finalAttrs.version}";
    description = "Official Wayback Machine browser extension by the Internet Archive";
    homepage = "https://github.com/internetarchive/wayback-machine-webextension";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
