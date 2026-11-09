{
  lib,
  stdenv,
  sources,
}:
let
  arch =
    if stdenv.hostPlatform.isAarch64 then
      "arm64"
    else if stdenv.hostPlatform.isx86_64 then
      "x64"
    else
      throw "unsupported system: ${stdenv.hostPlatform.system}";
  source = sources."nexttodo-linux-${arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nexttodo";
  inherit (source) version src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D -m 0755 ${finalAttrs.src} $out/bin/nexttodo

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/JunieXD/NextTodo/releases/tag/v${finalAttrs.version}";
    description = "Dependency-aware todo client: shows what can be done right now";
    homepage = "https://github.com/JunieXD/NextTodo";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "nexttodo";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
