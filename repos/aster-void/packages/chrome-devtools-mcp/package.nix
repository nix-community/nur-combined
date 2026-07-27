{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  bubblewrap,
  chromium,
  makeWrapper,
  runCommand,
}: let
  tag = "chrome-devtools-mcp-v0.12.1";
  unwrapped = buildNpmPackage {
    pname = "chrome-devtools-mcp-unwrapped";
    version = tag;
    src = fetchFromGitHub {
      owner = "ChromeDevTools";
      repo = "chrome-devtools-mcp";
      inherit tag;
      hash = "sha256-kLIZ3IpeAAY0sycwhoYoBLI96Vh2ATSS8VpFRBptTNw=";
    };
    env = {
      PUPPETEER_SKIP_DOWNLOAD = "true";
    };

    buildPhase = ''
      runHook preBuild
      npm run bundle
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/chrome-devtools-mcp
      cp -r build $out/lib/node_modules/chrome-devtools-mcp/
      cp package.json $out/lib/node_modules/chrome-devtools-mcp/
      chmod +x $out/lib/node_modules/chrome-devtools-mcp/build/src/index.js
      mkdir -p $out/bin
      ln -s $out/lib/node_modules/chrome-devtools-mcp/build/src/index.js $out/bin/chrome-devtools-mcp
      runHook postInstall
    '';

    npmDepsHash = "sha256-WPRVYEYOUjRWYKNRbd6+mZeRZLtHfoTlst3vZMt8sxE=";

    meta = {
      description = "Chrome DevTools for coding agents";
      homepage = "https://www.npmjs.com/package/chrome-devtools-mcp";
      license = lib.licenses.asl20;
      maintainers = [];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "chrome-devtools-mcp";
    };
  };
  bwrapFlags = lib.lists.flatten [
    ["--ro-bind" "/" "/"]
    ["--dev-bind" "/dev" "/dev"]
    ["--proc" "/proc"]
    ["--bind" "/tmp" "/tmp"]
    ["--bind" "$HOME" "$HOME"]
    ["--tmpfs" "/opt"]
    ["--dir" "/opt/google/chrome"]
    ["--symlink" "${lib.getExe chromium}" "/opt/google/chrome/chrome"]
    ["--"]
    (lib.getExe unwrapped)
  ];
in
  runCommand "${tag}" {
    nativeBuildInputs = [makeWrapper];
    passthru = {inherit unwrapped;};
    meta =
      unwrapped.meta
      // {
        mainProgram = "chrome-devtools-mcp";
      };
  } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe bubblewrap} $out/bin/chrome-devtools-mcp --add-flags ${
      lib.escapeShellArg
      (lib.concatStringsSep " " bwrapFlags)
    }
  ''
