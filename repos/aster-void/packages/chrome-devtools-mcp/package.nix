{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}: let
  version = "0.8.1";
in
  buildNpmPackage {
    pname = "chrome-devtools-mcp";
    inherit version;
    src = fetchFromGitHub {
      owner = "ChromeDevTools";
      repo = "chrome-devtools-mcp";
      tag = "chrome-devtools-mcp-v${version}";
      hash = "sha256-ziypJXtcHv66uvDyIiCyUuufzkmJhBtPDidJQJwTgGE=";
    };
    env = {
      PUPPETEER_SKIP_DOWNLOAD = "true";
    };

    buildPhase = ''
      runHook preBuild
      npm run prepare
      npm run build
      runHook postBuild
    '';

    npmDepsHash = "sha256-qR7PbVXXSuZXnOJOKvGeowaLHs88kK7MEPaMdnTpBPc=";

    meta = {
      description = "Chrome DevTools for coding agents";
      homepage = "https://www.npmjs.com/package/chrome-devtools-mcp";
      license = lib.licenses.asl20;
      maintainers = [];
      platforms = lib.platforms.linux ++ lib.platforms.darwin; # haven't tested on darwin
      mainProgram = "chrome-devtools-mcp";
    };
  }
