{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  autoPatchelfHook,
  installShellFiles,
  libsecret,
  patchelf,
  source,
  pname,
}:

let
  # Remove once the default patchelf includes https://github.com/NixOS/patchelf/pull/672.
  patchelfForSea = patchelf.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ autoreconfHook ];
    patches = (old.patches or [ ]) ++ [
      (fetchurl {
        url = "https://github.com/NixOS/patchelf/commit/59acc3d98b4961cfddf02090d9426ac735603218.patch";
        hash = "sha256-ONXiByBJKla9r9FzeOx7KgvCEmuySRYE74XGGpEXFKo=";
      })
    ];
  });
in
stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  inherit pname;
  inherit (source) version src;

  strictDeps = true;
  dontBuild = true;
  dontStrip = true;
  nativeBuildInputs = [
    patchelfForSea
    autoPatchelfHook
    installShellFiles
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  # Native keyring modules load libsecret at runtime.
  appendRunpaths = [ (lib.makeLibraryPath [ libsecret ]) ];
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  installPhase = ''
    runHook preInstall

    # The SEA executable locates its web assets and native modules beside itself.
    test -x t3
    test -f client/index.html
    mkdir -p "$out/bin" "$out/libexec/t3code"
    cp -a . "$out/libexec/t3code/"
    ln -s ../libexec/t3code/t3 "$out/bin/t3"

    runHook postInstall
  '';

  preFixup = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # The SEA executable must be patched before it can generate completions.
    postFixupHooks+=(installCompletions)
    installCompletions() (
      export HOME="$(mktemp -d)"
      export T3CODE_HOME="$HOME/.t3"
      export T3CODE_TELEMETRY_ENABLED=false

      for shell in bash fish zsh; do
        "$out/bin/t3" --completions "$shell" > "$TMPDIR/t3.$shell"
        installShellCompletion --cmd t3 --"$shell" "$TMPDIR/t3.$shell"
      done
    )
  '';

  passthru = source;

  meta = {
    description = "Web interface for coding agents";
    homepage = "https://github.com/pingdotgg/t3code";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "t3";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
