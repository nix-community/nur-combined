{
  lib,
  buildNpmPackage,
  fetchPnpmDeps,
  makeWrapper,
  nodejs-slim,
  pnpm_11,
  pnpmConfigHook,
  python3,
  versionCheckHook,
  yq-go,

  sources,
  source ? sources.deepseek-harness,
}:

let
  pnpm = pnpm_11;
in
buildNpmPackage (finalAttrs: {
  inherit (source) pname src;
  version = (lib.importJSON source.extract."package.json").version;

  postPatch = ''
    # Upstream verifies npm releases by installing every release-family
    # tarball as a top-level dependency. Reproduce that workspace surface:
    # profile plugins dynamically import peer service packages which are not
    # in the CLI's ordinary production dependency closure.
    workspaceDeps="$TMPDIR/dsh-workspace-dependencies.json"
    workspaceLockDeps="$TMPDIR/dsh-workspace-lock-dependencies.json"
    yq ea -o=json -I=0 \
      '(select(.name | test("^@deepseek-ai/")) | {
        (.name): "workspace:^"
      }) as $item ireduce ({}; . * $item)' \
      vendor/group/package.json packages/*/*/package.json > "$workspaceDeps"
    yq ea -o=json -I=0 \
      '(select(.name | test("^@deepseek-ai/")) | {
        (.name): {
          "specifier": "workspace:^",
          "version": "link:" + (filename | sub("/package.json$", "") | sub("^", "../../"))
        }
      }) as $item ireduce ({}; . * $item)' \
      vendor/group/package.json packages/*/*/package.json > "$workspaceLockDeps"
    DEPS_FILE="$workspaceDeps" yq -i \
      '.dependencies *= load(strenv(DEPS_FILE))' apps/cli/package.json
    DEPS_FILE="$workspaceLockDeps" yq -i \
      '.importers."apps/cli".dependencies *= load(strenv(DEPS_FILE))' pnpm-lock.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      postPatch
      ;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-aySHq0ywTMM5q7YuGHZrV3yQE3bwppgGfWH3wRnHCXk=";
  };

  nativeBuildInputs = [
    makeWrapper
    pnpm
    python3
    yq-go
  ];

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;
  npmBuildScript = "build";

  preInstall = ''
    # Make pnpm copy workspace packages into the deploy output
    pnpm config set --location=project inject-workspace-packages true
    # Its postinstall runs before deploy has assembled node-pty.
    yq -i 'del(.scripts.postinstall)' packages/subprocess/subprocess-local/package.json
  '';

  installPhase = ''
    runHook preInstall

    # A hoisted tree matches the flat npm installation used by upstream's
    # packed-release verification and by dsh's profile module fallback.
    pnpm --filter @deepseek-ai/dsh deploy \
      --prod \
      --config.node-linker=hoisted \
      --config.link-workspace-packages=true \
      $out/lib/deepseek-harness
    # The removed workspace postinstall only makes this helper executable.
    find $out/lib/deepseek-harness/node_modules \
      -path '*/node-pty/*/spawn-helper' \
      -exec chmod +x {} +
    mkdir -p $out/bin
    # dsh installs a Node module loader and intentionally uses internal hooks.
    makeWrapper ${lib.getExe nodejs-slim} $out/bin/dsh \
      --add-flags "--expose-internals" \
      --add-flags "$out/lib/deepseek-harness/lib/bin.js"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # nix-update auto -u
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open-source agent harness developed by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "dsh";
    platforms = lib.platforms.unix;
  };
})
