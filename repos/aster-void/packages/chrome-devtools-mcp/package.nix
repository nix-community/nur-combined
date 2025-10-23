{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  bubblewrap,
  chromium,
  makeWrapper,
  runCommand,
}: let
  version = "0.8.1";
  unwrapped = buildNpmPackage {
    pname = "chrome-devtools-mcp-unwrapped";
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
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  };
in
  runCommand "chrome-devtools-mcp-${version}" {
    nativeBuildInputs = [makeWrapper];
    passthru = {inherit unwrapped;};
    meta =
      unwrapped.meta
      // {
        mainProgram = "chrome-devtools-mcp";
      };
  } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe bubblewrap} $out/bin/chrome-devtools-mcp \
      --add-flags "--ro-bind / /" \
      --add-flags "--dev-bind /dev /dev" \
      --add-flags "--proc /proc" \
      --add-flags "--bind /tmp /tmp" \
      --add-flags "--bind \$HOME \$HOME" \
      --add-flags "--tmpfs /opt" \
      --add-flags "--dir /opt/google/chrome" \
      --add-flags "--symlink ${lib.getExe chromium} /opt/google/chrome/chrome" \
      --add-flags "--" \
      --add-flags "${lib.getExe' unwrapped "chrome-devtools-mcp"}"
  ''
