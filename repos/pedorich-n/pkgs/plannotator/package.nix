{
  lib,
  stdenv,
  bun,
  fetchFromGitHub,
  jj,
  git,
  gh,
  glab,
  makeWrapper,
  nix-update-script,
  nodejs,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plannotator";
  version = "0.28.47";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7rZr524w3AZvYHaLK6ProngipakMMXpcsvdlSkvs7Zs=";
  };

  nodeModules = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-node-modules";
    inherit (finalAttrs) version src;

    __structuredAttrs = true;
    strictDeps = true;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

      bun install \
        --backend=copyfile \
        --cpu='*' \
        --frozen-lockfile \
        --ignore-scripts \
        --libc='*' \
        --linker=hoisted \
        --no-progress \
        --os='*'

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontFixup = true;

    outputHashMode = "recursive";
    outputHash = "sha256-Q9OiXdlyvcU93iq6VE6lLAdbyrIDfg49GWAg+z7n6Wg=";
  };

  nativeBuildInputs = [
    bun
    nodejs
    makeWrapper
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R "$nodeModules"/. .

    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

    bun apps/guides-show/build/sync-manifest.ts --if-missing
    bun scripts/require-bun.ts

    bun run build:review
    bun run build:hook

    bun build apps/hook/server/index.ts \
      --target bun \
      --compile \
      --no-compile-autoload-bunfig \
      --define "__CLI_VERSION__=\"${finalAttrs.version}\"" \
      --outfile plannotator

    bun scripts/check-bun-runtime-trust.ts plannotator

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 plannotator $out/bin/plannotator

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/plannotator \
      --suffix PATH : ${
        lib.makeBinPath [
          jj
          git
          gh
          glab
        ]
      }
  '';

  dontStrip = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--subpackage"
      "nodeModules"
    ];
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Interactive plan and code review surface for AI coding agents";
    homepage = "https://plannotator.ai";
    changelog = "https://github.com/backnotprop/plannotator/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];
    mainProgram = "plannotator";
    broken = lib.versionOlder (lib.getVersion bun) "1.4.4";
  };
})
