{
  lib,
  stdenvNoCC,
  callPackage,
  autoPatchelfHook,
  ncurses,
  installShellFiles,
  versionCheckHook,
  zstd,
  source ? callPackage ./source.nix { },
  githubReleaseUpdater ? callPackage ../../lib/github-release-updater.nix { },
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "codex-bin";
  inherit (source) version src;

  sourceRoot = ".";
  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    installShellFiles
    zstd
  ];
  # The bundled zsh and voice runtime are dynamically linked, unlike Codex itself.
  buildInputs = [ ncurses ];

  installPhase = ''
    runHook preInstall

    # Daemon bootstrap requires the complete upstream package layout.
    mkdir -p "$out"
    cp -a bin codex-package.json codex-path codex-resources "$out/"

    installShellCompletion --cmd codex \
      --bash <("$out/bin/codex" completion bash) \
      --fish <("$out/bin/codex" completion fish) \
      --zsh <("$out/bin/codex" completion zsh)

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = source // {
    updateScript = [
      (lib.getExe githubReleaseUpdater)
      "--owner"
      "openai"
      "--repo"
      "codex"
      "--attribute"
      "codex-bin"
      "--tag-pattern"
      "rust-v(\\d+\\.\\d+\\.\\d+)"
    ];
  };

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://github.com/openai/codex/releases/tag/rust-v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
