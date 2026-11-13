{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  zstd,
  makeWrapper,
  installShellFiles,
  autoPatchelfHook,
  openssl,
  libcap,
  ripgrep,
  python3,
  bubblewrap,
}:
let
  versions = lib.importJSON ./versions.json;
  inherit (versions) version;
  assets = builtins.removeAttrs versions [ "version" ];
  platform = assets.${stdenvNoCC.hostPlatform.system};
  packageManifest = builtins.toFile "codex-package.json" (
    builtins.toJSON {
      layoutVersion = 1;
      inherit version;
      target = lib.removePrefix "codex-" platform.name;
      variant = "codex";
      entrypoint = "bin/codex";
      resourcesDir = "codex-resources";
      pathDir = "codex-path";
    }
  );
in
stdenvNoCC.mkDerivation {
  pname = "codex-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/${platform.name}.zst";
    inherit (platform) hash;
  };
  codeHostSrc = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/${platform.codehost.name}.zst";
    inherit (platform.codehost) hash;
  };

  nativeBuildInputs = [
    zstd
    makeWrapper
    installShellFiles
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    openssl
    libcap
  ];

  unpackPhase = ''
    runHook preUnpack
    zstd -d "$src" -o codex
    zstd -d "$codeHostSrc" -o codex-code-mode-host
    runHook postUnpack
  '';
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  # rg and bwrap already have valid Nix interpreters and RPATHs. Repatching
  # these copied helpers would discard their existing dependency information.
  dontAutoPatchelf = true;
  preFixup = lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    autoPatchelf "$out/libexec/codex/bin"
  '';

  installPhase = ''
    runHook preInstall
    packageDir="$out/libexec/codex"
    mkdir -p "$out/bin" "$packageDir/bin" "$packageDir/codex-path"
    install -m555 codex "$packageDir/bin/codex"
    install -m555 codex-code-mode-host "$packageDir/bin/codex-code-mode-host"
    install -m444 ${packageManifest} "$packageDir/codex-package.json"

    # Daemon installation copies this tree and rejects links outside it.
    install -m555 ${ripgrep}/bin/rg "$packageDir/codex-path/rg"
    ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      mkdir -p "$packageDir/codex-resources"
      install -m555 ${bubblewrap}/bin/bwrap "$packageDir/codex-resources/bwrap"
    ''}

    # The daemon compares the packaged binary with the running executable.
    makeWrapper "$packageDir/bin/codex" "$out/bin/codex" --prefix PATH : ${
      lib.makeBinPath (
        [
          ripgrep
          python3
        ]
        ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ bubblewrap ]
      )
    }
    ln -s ../libexec/codex/bin/codex-code-mode-host "$out/bin/codex-code-mode-host"
    runHook postInstall
  '';
  # Linux binaries must be patched by autoPatchelf before they can be run.
  postFixup = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/codex" --version | grep -F 'codex-cli ${version}'
    test -x "$out/bin/codex-code-mode-host"
    runHook postInstallCheck
  '';

  passthru.updateScript = ./update.sh;
  meta = {
    description = "Lightweight coding agent that runs in your terminal (official binaries)";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "codex";
    platforms = builtins.attrNames assets;
  };
}
