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
      "amd64"
    else
      throw "unsupported system: ${stdenv.hostPlatform.system}";
  source = sources."sublinkpro-linux-${arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sublinkpro";
  inherit (source) version src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D -m 0755 $src $out/bin/sublinkpro

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/ZeroDeng01/sublinkPro/releases/tag/v${finalAttrs.version}";
    description = "Modern proxy subscription management panel with smart tags, speed tests and relay chains";
    homepage = "https://github.com/ZeroDeng01/sublinkPro";
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
    mainProgram = "sublinkpro";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
