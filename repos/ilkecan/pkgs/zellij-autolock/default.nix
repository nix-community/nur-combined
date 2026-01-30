{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.2.2";
in
stdenvNoCC.mkDerivation {
  pname = "zellij-autolock";
  inherit version;

  src = fetchurl {
    url = "https://github.com/fresh2dev/zellij-autolock/releases/download/${version}/zellij-autolock.wasm";
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

  strictDeps = true;

  meta = {
    description = "Autolock Zellij when certain processes open";
    homepage = "https://github.com/fresh2dev/zellij-autolock";
    changelog = "https://github.com/fresh2dev/zellij-autolock/releases/tag/${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ilkecan ];
    mainProgram = null;
    platforms = lib.platforms.linux;
  };
}
