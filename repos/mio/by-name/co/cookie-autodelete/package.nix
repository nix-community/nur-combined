{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "cookie-autodelete";
  version = "3.8.2";

  src = fetchFromGitHub {
    owner = "Cookie-AutoDelete";
    repo = "Cookie-AutoDelete";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l1OCXWxAtAIgihQRhMVzMTILdCYiBqW6Y++hSBtA8Lg=";
  };

  npmDepsHash = "sha256-IVj/jQB5kGgTKbzIT86eeUa9jQCXre6fPAlRVOs4nZU=";

  buildPhase = ''
    runHook preBuild
    npm run compile
    node ./tools/buildFilesDev.js
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/cookie-autodelete
    cp -r extension/. $out/share/cookie-autodelete/
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    changelog = "https://github.com/Cookie-AutoDelete/Cookie-AutoDelete/releases/tag/v${finalAttrs.version}";
    description = "Automatically remove cookies when a tab is closed";
    homepage = "https://github.com/Cookie-AutoDelete/Cookie-AutoDelete";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
