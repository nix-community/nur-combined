{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  zstd,
  makeWrapper,
  installShellFiles,
  versionCheckHook,
  patchelf,
  jq,
  ps,
  python3,
  installShellCompletions ? stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform,
}:
let
  versions = lib.importJSON ./versions.json;
  inherit (versions) version;
  assets = builtins.removeAttrs versions [ "version" ];
  platform = assets.${stdenvNoCC.hostPlatform.system};
  isLinux = stdenvNoCC.hostPlatform.isLinux;
in
stdenvNoCC.mkDerivation {
  pname = "codex-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-package-${platform.target}.tar.zst";
    inherit (platform) hash;
  };

  nativeBuildInputs = [
    zstd
    makeWrapper
    installShellFiles
  ]
  ++ lib.optionals isLinux [
    patchelf
    jq
  ];

  unpackPhase = ''
    runHook preUnpack
    mkdir codex-package
    tar --zstd -xf "$src" -C codex-package
    runHook postUnpack
  '';
  sourceRoot = "codex-package";
  dontConfigure = true;
  dontBuild = true;
  # Preserve upstream signatures, package checksums and the voice runtime's origin-relative RUNPATHs.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    packageDir="$out/libexec/codex"
    mkdir -p "$out/bin" "$packageDir"
    cp -a . "$packageDir/"

    ${lib.optionalString isLinux ''
      # The CLI and its other helpers are static musl binaries. Only the voice host uses glibc.
      voiceHost=codex-resources/voice/bin/codex-voice-host
      voiceManifest="$packageDir/codex-resources/voice/manifest.json"
      patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$packageDir/$voiceHost"
      voiceHash=$(sha256sum "$packageDir/$voiceHost" | cut -d ' ' -f 1)
      jq --arg path "$voiceHost" --arg hash "$voiceHash" '.sha256[$path] = $hash' \
        "$voiceManifest" > voice-manifest.json
      install -m444 voice-manifest.json "$voiceManifest"
    ''}

    # Keep the entrypoint inside the package so the daemon can stage it verbatim.
    makeWrapper "$packageDir/bin/codex" "$out/bin/codex" \
      --prefix PATH : "$packageDir/codex-path${lib.optionalString isLinux ":$packageDir/codex-resources"}:${
        lib.makeBinPath [
          ps
          python3
        ]
      }"
    ln -s ../libexec/codex/bin/codex-code-mode-host "$out/bin/codex-code-mode-host"
    runHook postInstall
  '';
  postInstall = lib.optionalString installShellCompletions ''
    for shell in bash fish zsh; do
      "$out/bin/codex" completion "$shell" > "codex.$shell"
      installShellCompletion --cmd codex "--$shell" "codex.$shell"
    done
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/codex";
  postInstallCheck = ''
    test -x "$out/bin/codex-code-mode-host"
    "$out/libexec/codex/bin/codex-exec-server" --help > /dev/null
    "$out/libexec/codex/codex-resources/voice/bin/codex-voice-host" --build-commit > /dev/null
  '';

  passthru.updateScript = ./update.sh;
  meta = {
    description = "Lightweight coding agent that runs in your terminal (official binaries)";
    homepage = "https://github.com/openai/codex";
    changelog = "https://github.com/openai/codex/releases/tag/rust-v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "codex";
    platforms = builtins.attrNames assets;
  };
}
