{
  lib,
  stdenv,
  nodejs,
  darwin,
  fetchFromGitHub,
  fetchPnpmDeps,
  fetchurl,
  pnpm_10,
  pnpmConfigHook,
  versionCheckHook,
}:

let
  pname = "sentry";
  version = "0.37.0";
  pnpm = pnpm_10;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "cli";
    rev = version;
    hash = "sha256-wTVDqtd2+T2KhTYnkqTvC0dabAJRfjfuZfhGViJlaxw=";
  };

  # @sentry/api version pinned in pnpm-lock.yaml; determines the OpenAPI spec tag
  sentryApiVersion = "0.141.0";

  openapi-spec = fetchurl {
    url = "https://raw.githubusercontent.com/getsentry/sentry-api-schema/${sentryApiVersion}/openapi-derefed.json";
    hash = "sha256-GjGMWxTRVora4p2EwizEpvdcKbIbXHpn1/+fyKeCO+4=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src pnpm;
    fetcherVersion = 3;
    hash = "sha256-v3yaiYGcPKROBLooHUyW19FyIXg7A1Dy4TQFWqAQMkY=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  inherit pnpmDeps;

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  buildPhase = ''
    runHook preBuild

    # Generate API schema using pre-fetched OpenAPI spec
    mkdir -p src/generated
    substituteInPlace script/generate-api-schema.ts \
      --replace-fail 'await fetch(openApiUrl)' \
        'await (async () => ({ ok: true, json: async () => JSON.parse(require("fs").readFileSync("${openapi-spec}", "utf-8")) }))()'
    substituteInPlace script/build.ts \
      --replace-fail 'const NODE_VERSION = "lts";' \
        'const NODE_VERSION = "${nodejs.version}";'

    # Fossilize resolves Node via its own cache and otherwise fetches it from nodejs.org.
    # Seed the cache with nixpkgs' Node binary to keep the build offline and reproducible.
    export FOSSILIZE_CACHE_DIR="$TMPDIR/fossilize-cache"
    fossilizePlatform="$(node -e 'process.stdout.write((process.platform === "win32" ? "win" : process.platform) + "-" + process.arch)')"
    mkdir -p "$FOSSILIZE_CACHE_DIR"
    cp ${nodejs}/bin/node "$FOSSILIZE_CACHE_DIR/node-v${nodejs.version}-$fossilizePlatform"
    chmod u+wx "$FOSSILIZE_CACHE_DIR/node-v${nodejs.version}-$fossilizePlatform"

    # Public OAuth client ID for sentry.io, baked into official builds
    export SENTRY_CLIENT_ID=1d673b81d60ef84c951359c36296972ca6fd41bd8f45acd2d3a783a3b3c28e41
    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 dist-bin/sentry-* $out/bin/sentry
    runHook postInstall
  '';

  # Fossilize strips before SEA injection; Nix stripping after injection corrupts the executable
  dontStrip = true;

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    codesign --force --sign - "$out/bin/sentry"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  # sentry creates ~/.sentry/ config dir on startup; needs a writable HOME
  versionCheckKeepEnvironment = "HOME";
  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    runHook preInstallCheck
    runHook postInstallCheck
  '';

  meta = {
    description = "A command-line interface for Sentry";
    homepage = "https://cli.sentry.dev/";
    changelog = "https://github.com/getsentry/cli/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ congee ];
    mainProgram = "sentry";
  };
}
