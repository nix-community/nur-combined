{
  fetchurl,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zellij-autolock";
  version = "0.2.2";

  src = fetchurl {
    url = "https://github.com/fresh2dev/zellij-autolock/releases/download/${finalAttrs.version}/zellij-autolock.wasm";
    sha256 = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zellij/plugins
    cp $src $out/share/zellij/plugins/zellij-autolock.wasm

    runHook postInstall
  '';

  __structuredAttrs = true;
  strictDeps = true;

  meta = {
    description = "Autolock Zellij when certain processes open";
    homepage = "https://github.com/fresh2dev/zellij-autolock";
    changelog = "https://github.com/fresh2dev/zellij-autolock/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
  };
})
