{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  bubblewrap,
  chromium,
  makeWrapper,
  runCommand,
}: let
  tag = "chrome-devtools-mcp-v0.9.0";
  unwrapped = buildNpmPackage {
    pname = "chrome-devtools-mcp-unwrapped";
    version = tag;
    src = fetchFromGitHub {
      owner = "ChromeDevTools";
      repo = "chrome-devtools-mcp";
      inherit tag;
      hash = "sha256-VHKyQFZGoINdiZjb+4VKu0cOp0Klgg/1Tnc9b1jH5Z4=";
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

    npmDepsHash = "sha256-fUnjN6xSVndJ2O9u8Suc2sogPwTEL8JFgp0HfzvcHjs=";

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
    ["--symlink" "${lib.getExe chromium}" "opt/google/chrome/chrome"]
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
