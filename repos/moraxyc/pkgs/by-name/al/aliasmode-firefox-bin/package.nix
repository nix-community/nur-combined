{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  sources,
  source ? sources.aliasmode,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "aliasmode-firefox-bin";
  version = finalAttrs.passthru.runtime.version;
  src = fetchurl {
    inherit (finalAttrs.passthru.runtime) url;
    sha256 = finalAttrs.passthru.runtime.archiveSha256;
  };
  nativeBuildInputs = [ unzip ];
  unpackPhase = ''
    runHook preUnpack
    mkdir firefox
    unzip -q "$src" -d firefox
    runHook postUnpack
  '';
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/aliasmode-firefox
    cp -R firefox/. $out/lib/aliasmode-firefox/
    runHook postInstall
  '';
  # Preserve the original executable bytes for AliasMode's integrity checks.
  dontFixup = true;
  passthru.runtime = (lib.importJSON source.artifacts."browser-runtime.json").firefox;
  meta = {
    description = "Pinned Firefox engine resources for AliasMode";
    homepage = "https://github.com/aliasmode/aliasmode-firefox";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = [ "x86_64-linux" ];
  };
})
