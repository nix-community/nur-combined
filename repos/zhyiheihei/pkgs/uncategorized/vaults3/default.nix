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
  source = sources."vaults3-linux-${arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vaults3";
  inherit (source) version src;

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D -m 0755 vaults3-linux-${arch} $out/bin/vaults3
    install -D -m 0755 vaults3-cli-linux-${arch} $out/bin/vaults3-cli

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/Kodiqa-Solutions/VaultS3/releases/tag/v${finalAttrs.version}";
    description = "Lightweight S3-compatible object storage with built-in web dashboard";
    homepage = "https://github.com/Kodiqa-Solutions/VaultS3";
    license = lib.licenses.agpl3Only;
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
    mainProgram = "vaults3";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
