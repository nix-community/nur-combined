{
  lib,
  stdenv,
  bun,
  fetchFromGitHub,
  fetchurl,
  versionCheckHook,
}:

let
  pname = "sentry";
  version = "0.28.1";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "cli";
    rev = version;
    hash = "sha256-J4ozDjMrtGc1nHA3AxYu913Ntb6rgGN4Qbkpl+IkCfI=";
  };

  # @sentry/api version pinned in bun.lock; determines the OpenAPI spec tag
  sentryApiVersion = "0.94.0";

  openapi-spec = fetchurl {
    url = "https://raw.githubusercontent.com/getsentry/sentry-api-schema/${sentryApiVersion}/openapi-derefed.json";
    hash = "sha256-OvCdVV3pPl7JbHLlw+7piKiBVrN1XORzEwaf/gtHpiw=";
  };

  bunDeps = stdenv.mkDerivation {
    name = "${pname}-bun-deps-${version}";
    inherit src;
    nativeBuildInputs = [ bun ];
    dontFixup = true;
    dontConfigure = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    # bun installs platform-specific native deps, so the hash differs per system
    outputHash = {
      x86_64-linux = "sha256-MvXQ0cCXWese3E+rvd8X1suH/N175XysTzxEWoTAAp0=";
      aarch64-darwin = "sha256-UPDgbCA9VWS5OsZ59vUNZ1rd9ZmfRIl8C8r02geMcA8=";
    }.${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");
    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      bun install --frozen-lockfile
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ bun ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR

    # Link pre-fetched dependencies
    cp -r ${bunDeps}/node_modules node_modules
    chmod -R u+w node_modules

    # Generate API schema using pre-fetched OpenAPI spec
    mkdir -p src/generated
    substituteInPlace script/generate-api-schema.ts \
      --replace-fail 'await fetch(openApiUrl)' \
        'await (async () => ({ ok: true, json: async () => JSON.parse(require("fs").readFileSync("${openapi-spec}", "utf-8")) }))()'

    bun run generate:schema
    bun run generate:docs
    bun run generate:sdk

    # Build standalone binary for current platform
    # Public OAuth client ID for sentry.io, baked into official builds
    export SENTRY_CLIENT_ID=1d673b81d60ef84c951359c36296972ca6fd41bd8f45acd2d3a783a3b3c28e41
    bun run script/build.ts --single

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 dist-bin/sentry-* $out/bin/sentry
    runHook postInstall
  '';

  # Bun-compiled binaries embed JS in the ELF; stripping corrupts them
  dontStrip = true;

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
