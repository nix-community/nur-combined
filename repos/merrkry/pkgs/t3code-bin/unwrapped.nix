{
  lib,
  stdenv,
  autoPatchelfHook,
  libsecret,
  source,
  pname,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  inherit pname;
  inherit (source) version src;

  strictDeps = true;
  dontBuild = true;
  dontStrip = true;
  nativeBuildInputs = [ autoPatchelfHook ];
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
