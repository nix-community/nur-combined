{
  lib,
  stdenvNoCC,
  fetchurl,
  zstd,
  sources,
  source ? sources.aliasmode,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "aliasmode-chromium-bin";
  version = finalAttrs.passthru.runtime.version;
  src = fetchurl {
    inherit (finalAttrs.passthru.runtime) url;
    sha256 = finalAttrs.passthru.runtime.archiveSha256;
  };
  sourceRoot = finalAttrs.passthru.runtime.archiveRoot;
  nativeBuildInputs = [ zstd ];
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    # Upstream shares components only beside version-named runtime directories.
    mkdir -p $out/lib/aliasmode-chromium
    cp -R . $out/lib/aliasmode-chromium/
    runHook postInstall
  '';
  # AliasMode verifies the upstream executable before launch.
  dontFixup = true;
  passthru.runtime = (lib.importJSON source.artifacts."browser-runtime.json").chromium;
  passthru.executable = "${finalAttrs.finalPackage}/lib/aliasmode-chromium/${finalAttrs.passthru.runtime.executable}";
  meta = {
    description = "Pinned Chromium engine resources for AliasMode";
    homepage = "https://github.com/aliasmode/aliasmode-chromium";
    license = with lib.licenses; [
      gpl3Only
      bsd3
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = [ "x86_64-linux" ];
  };
})
