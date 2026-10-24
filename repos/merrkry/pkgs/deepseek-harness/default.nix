{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm,
  pnpm_11,
  pnpmConfigHook,
  nodejs_24,
  bashInteractive,
  bubblewrap,
  makeWrapper,
  autoPatchelfHook,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  # Only disables session OpenTelemetry upload.
  # Session Log API uploads follow the user's session-log-deepseek.enabled setting.
  disableTelemetry ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  strictDeps = true;

  pname = "deepseek-harness";
  version = "0.2.1-rc.3";

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    tag = "dsh-v${finalAttrs.version}";
    # Keep the commit needed by the frontend without nondeterministic Git packs.
    leaveDotGit = true;
    postFetch = ''
      git -C "$out" rev-parse HEAD > "$out/.git-revision"
      rm -rf "$out/.git"
    '';
    hash = "sha256-3qZOezUYuvMOQvJI8sRPq5SOfurTKM06E39Zxar7KdI=";
  };

  # Match upstream's pnpm major for the lockfile and workspace deployment.
  # The launcher uses nixpkgs' default pnpm for runtime plugin installation.
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-C9Aw9AS4r7zubaEuT6mLXQ+AhhMVlTxPZRKTpzRUkcU=";
  };

  # Keep account diagnostics off ACP and SDK protocol stdout.
  patches = [ ./account-logs-stderr.patch ];

  nativeBuildInputs = [
    nodejs_24
    pnpm_11
    pnpmConfigHook
    makeWrapper
    autoPatchelfHook
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  env = {
    CI = "true";
    DSH_TELEMETRY_DISABLED = "1";
  };

  postPatch = ''
    # Inspector workers replace the parent's execArgv instead of inheriting it.
    substituteInPlace packages/experimental/inspector/src/host/bridge/controller.ts \
      --replace-fail 'execArgv: []' 'execArgv: ["--expose-internals"]'

    # The tests also use the shared accessor, including inside Vitest workers.
    substituteInPlace vitest.shared.ts \
      --replace-fail "? ['--no-webstorage'] : []" \
        "? ['--no-webstorage', '--expose-internals'] : ['--expose-internals']"

    # Source-launch tests invoke bare Node without our launcher's flags.
    substituteInPlace vitest.config.ts \
      --replace-fail 'const platformUnsupportedTests = [...windowsUnsupportedTests, ...nonLinuxWebWorkerTests]' \
        "const platformUnsupportedTests = [...windowsUnsupportedTests, ...nonLinuxWebWorkerTests, 'apps/cli/tests/source-launch.compat.spec.ts']"
  '';

  buildPhase = ''
    runHook preBuild

    export DSH_CLIENT_COMMIT_HASH=$(cat .git-revision)

    # nixpkgs' Node has different V8 machine code from the builds recognized
    # by the native accessor. --expose-internals provides these modules directly.
    # Patch the shared accessor for both the host and worker bootstrap.
    # HMR's internalBinding accessor is available through Node's test binding.
    # https://github.com/numtide/llm-agents.nix/pull/10832
    substituteInPlace node_modules/.pnpm/node-addon-require-builtin@*/node_modules/node-addon-require-builtin/lib/index.js \
      --replace-fail 'return api.requireBuiltin(moduleId);' \
        "if (moduleId === 'internal/bootstrap/realm') {
          return require('internal/test/binding');
        }
        return require(moduleId);"

    pnpm run build:official

    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    pnpm exec vitest run apps/cli/tests packages/boot/app-boot/tests packages/boot/hmr/tests

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    # Upstream's executable closure also includes the runtime peer dependencies.
    pnpm --offline --ignore-scripts --filter dsh-python-runtime-closure --prod \
      --config.inject-workspace-packages=true --config.allow-unused-patches=true \
      deploy "$out/lib/deepseek-harness"

    # Deploy can restore registry dependencies from the unpatched pnpm store.
    cliDirectory=$(realpath "$out/lib/deepseek-harness/node_modules/@deepseek-ai/dsh")
    accessorEntry=$(node -p \
      'require.resolve("node-addon-require-builtin", { paths: [process.argv[1]] })' \
      "$cliDirectory")
    install -m644 node_modules/.pnpm/node-addon-require-builtin@*/node_modules/node-addon-require-builtin/lib/index.js \
      "$accessorEntry"

    # Match the executable release's cleanup while preserving runtime assets,
    # including Markdown instructions owned by skills.
    find "$out/lib/deepseek-harness/node_modules" -type f \
      ! -path '*/assets/*' \
      \( -name 'README*.md' -o -name 'CHANGELOG*.md' -o -name 'HISTORY*.md' \
         -o -name '*.map' -o -name '*.d.ts' -o -name '*.d.mts' -o -name '*.d.cts' \) \
      -delete

    # node-pty ships other targets and Windows ConPTY debugging symbols.
    find "$out/lib/deepseek-harness/node_modules" -type d \
      \( \( -regex '.*/node-pty/prebuilds/[^/]+' ! -name linux-x64 \) \
         -o -path '*/node-pty/third_party/conpty' \) \
      -prune -exec rm -r {} +

    # Koffi bundles both libc variants in the same platform package.
    find "$out/lib/deepseek-harness/node_modules" \
      -path '*/@koromix/koffi-linux-x64/musl_x64' -type d -prune -exec rm -r {} +

    substituteInPlace \
      "$out/lib/deepseek-harness/node_modules/@deepseek-ai/dsh-terminal-bash/lib/index.js" \
      --replace-fail '"/bin/bash"' '"${lib.getExe bashInteractive}"'

    makeWrapper ${lib.getExe nodejs_24} "$out/bin/dsh" \
      --argv0 dsh \
      ${lib.optionalString disableTelemetry "--set DSH_TELEMETRY_DISABLED 1"} \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          pnpm
        ]
      } \
      --add-flags --expose-internals \
      --add-flags "$out/lib/deepseek-harness/node_modules/@deepseek-ai/dsh/lib/bin.js"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  postInstallCheck = ''
    DSH_TEST_PACKAGE="$out" node --test ${./tests.mjs}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=unstable"
      "--version-regex=dsh-v(.*)"
    ];
  };

  meta = {
    description = "Agent harness with an everything-is-a-plugin architecture";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    changelog = "https://github.com/deepseek-ai/deepseek-harness/releases/tag/dsh-v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "dsh";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
