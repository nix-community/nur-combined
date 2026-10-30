{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  callPackage,
}:

let
  # The version is the one `npx freebuff` installs, i.e. the `latest` dist-tag
  # of the npm package. CodebuffAI/freebuff's own tags do not track it (they
  # stop at v1.0.679 while the npm wrapper is on 0.2.x), but the source snapshot
  # of a release is the commit that sets freebuff/cli/release/package.json to
  # that version. `update.py` resolves that commit from npm and keeps these in
  # sync; the build below passes the version through to the binary.
  version = "0.2.35";

  src = fetchFromGitHub {
    owner = "CodebuffAI";
    repo = "freebuff";
    rev = "7f99e218b792bea12ca3573caa198ecb3c2de9eb";
    hash = "sha256-5Y02a0X+c81g9GO22arYOyoKpXVLF38HQVTmUIVuRNA=";
  };

  # The CLI validates its client environment at startup (common/src/env.ts) and
  # cli/scripts/build-binary.ts bakes the NEXT_PUBLIC_* variables that are set
  # during the build into the binary with `--define`. A binary built without
  # them stops with "Environment validation failed" before it can run a turn.
  #
  # These are the public production values found in the official npm release
  # binary (Publishable/ingestion keys — the client halves of PostHog and
  # Stripe, not secrets). CODEBUFF_APP_URL can still be overridden at runtime.
  #
  # The API host must be `www.codebuff.com`: the bare `codebuff.com` 301s to it,
  # and Bun's fetch drops the Authorization header on that cross-host redirect,
  # so every bearer-authenticated call (/api/v1/me, completions, agent runs)
  # came back 401 and the CLI reported the stored key as invalid.
  clientEnv = {
    NEXT_PUBLIC_CB_ENVIRONMENT = "prod";
    NEXT_PUBLIC_CODEBUFF_APP_URL = "https://www.codebuff.com";
    NEXT_PUBLIC_FREEBUFF_APP_URL = "https://freebuff.com";
    NEXT_PUBLIC_SUPPORT_EMAIL = "support@codebuff.com";
    NEXT_PUBLIC_POSTHOG_API_KEY = "phc_tug7g8yc10qNestK14QV8WyKwjfEl6vwzIbJkBdqeHS";
    NEXT_PUBLIC_POSTHOG_HOST_URL = "https://us.i.posthog.com";
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY = "pk_live_51Q0SA5KrNS6SjmqWMgRE0ar5v6cMvtizkyY3mXjYaZsU6AG9ctpNPKZMVf6xFK2ngqwkt8rHNIQgNiCFSbRdGb9Z00QEo13rfx";
    NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL = "https://billing.stripe.com/p/login/cN22bea8W6Ra2is144";
    # Optional in env-schema.ts and therefore not set by our build unless given
    # here; the official 0.2.35 binary bakes the public Prelude web SDK key.
    NEXT_PUBLIC_PRELUDE_WEB_SDK_KEY = "sdk_1xLWzByLeEenx4AgNLhwbLqEqAp0YuTogKIO";
    NEXT_PUBLIC_WEB_PORT = "3000";
  };

  # The Bun workspace dependencies (including the OpenTUI native bundles for
  # both glibc and musl) come from the registry, so they are fetched once in a
  # fixed-output derivation and the real build runs offline. Upstream pins Bun
  # 1.3.14 in .bun-version; nixpkgs' Bun builds the same tree with the same
  # output, so no second Bun is carried around.
  #
  # `bun install` resolves the platform-specific payloads (the OpenTUI native
  # bundles, ripgrep, ...), so every target has its own hash.
  workspaceDepsHashes = {
    x86_64-linux = "sha256-BMxWm9Jo/SwsAjSEToK8vvZ9rJ15OJJcB3FBz9jI07I=";
    aarch64-darwin = "sha256-u5jfsEfqRi8obOe4S36lXfg2v3jX+6TD780LVg7Xdoc=";
  };

  workspaceDeps = stdenvNoCC.mkDerivation {
    pname = "freebuff-workspace-deps";
    inherit version src;

    nativeBuildInputs = [ bun ];

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash =
      workspaceDepsHashes.${stdenvNoCC.hostPlatform.system}
        or (throw "freebuff: no workspace dependency hash for ${stdenvNoCC.hostPlatform.system}");

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      export HOME=$TMPDIR/home
      mkdir -p "$HOME"

      bun install --frozen-lockfile --ignore-scripts

      # Two packages the CLI needs are missing from the public snapshot's
      # lockfile (the private tree the release is cut from has them):
      #  - @opentelemetry/api is the optional peer of posthog-node, which
      #    common/ imports; bundling fails to resolve the dynamic import inside
      #    posthog-node without it.
      #  - picocolors is imported by cli/src but not declared anywhere.
      # `--no-save` keeps bun.lock untouched, so this stays a pure addition to
      # the lockfile pins above.
      bun install --ignore-scripts --no-save \
        '@opentelemetry/api@1.10.0' \
        'picocolors@1.1.1'

      # Workspace packages are linked as ../../<workspace>; those links resolve
      # once this tree is copied back to the root of the source.
      mkdir -p $out
      cp -a node_modules/. $out/

      runHook postInstall
    '';
  };
in
stdenvNoCC.mkDerivation {
  pname = "freebuff";
  inherit version src;

  nativeBuildInputs = [ bun ];

  env = clientEnv;

  postPatch = ''
    # The version must describe the source we build: the npm release version is
    # recorded in this file, so detect a mismatch before the long build.
    grep -qF '"version": "${version}"' freebuff/cli/release/package.json

    # The SDK's .d.ts bundle type-checks the whole workspace and currently
    # fails on unrelated @ai-sdk provider type mismatches in this snapshot. The
    # CLI only consumes sdk/dist/index.mjs, so skip the declaration bundle.
    substituteInPlace cli/scripts/build-binary.ts \
      --replace-fail "'run', '--cwd', '../sdk', 'build'" \
        "'run', '--cwd', '../sdk', 'build', '--no-types'"

    # Upstream re-installs the OpenTUI native packages with a nested
    # `bun install` before compiling. Both the glibc and the musl variant are
    # already in the lockfile-installed node_modules, and the sandbox has no
    # network, so use those instead.
    substituteInPlace cli/scripts/build-binary.ts \
      --replace-fail "  prepareOpenTuiNativeBundle(targetInfo)" \
        "  // prepareOpenTuiNativeBundle(targetInfo)"
  '';

  buildPhase = ''
    runHook preBuild

    # Writable copy: the build generates files in the tree and in node_modules.
    cp -a ${workspaceDeps} ./node_modules

    export HOME=$TMPDIR/home
    mkdir -p "$HOME"

    bun freebuff/cli/build.ts ${version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 cli/bin/freebuff $out/bin/freebuff
    # The CLI loads tree-sitter.wasm from the directory of process.execPath.
    install -Dm644 cli/bin/tree-sitter.wasm $out/bin/tree-sitter.wasm

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    export HOME=$TMPDIR/home
    mkdir -p "$HOME"
    $out/bin/freebuff --version | grep -Fqx '${version}'

    runHook postInstallCheck
  '';

  passthru.updateScript = callPackage ./update.nix {
    attrPath = "freebuff";
  };

  meta = {
    description = "Free AI coding agent CLI (Freebuff)";
    homepage = "https://freebuff.com";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "freebuff";
    # The dependency hashes above pin the targets that have been built; a new
    # platform needs its own `workspaceDeps` hash.
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
