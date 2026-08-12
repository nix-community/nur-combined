{
  fetchurl,
  lib,
  stdenvNoCC,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zellij-workspace";
  version = "0.3.2";

  src = fetchurl {
    url = "https://github.com/vdbulcke/zellij-workspace/releases/download/v${finalAttrs.version}/zellij-workspace.wasm";
    sha256 = "sha256-nbaxG8POfsRd3lyZ4bI+SJOy78slkboG4cESdnJxD14=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zellij/plugins
    cp $src $out/share/zellij/plugins/zellij-workspace.wasm

    runHook postInstall
  '';

  __structuredAttrs = true;
  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zellij plugin for applying layouts to current zellij session";
    homepage = "https://github.com/vdbulcke/zellij-workspace";
    changelog = "https://github.com/vdbulcke/zellij-workspace/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
  };
})
