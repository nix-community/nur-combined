{
  fetchurl,
  lib,
  stdenvNoCC,
}:

let
  version = "0.3.0";
in
stdenvNoCC.mkDerivation {
  pname = "zellij-workspace";
  inherit version;

  src = fetchurl {
    url = "https://github.com/vdbulcke/zellij-workspace/releases/download/v${version}/zellij-workspace.wasm";
    sha256 = "sha256-PR8Epa9JfQUHKg+jBF/9Rs3TDzM/9IYXcdm+kJsJa3M=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zellij/plugins
    cp $src $out/share/zellij/plugins/zellij-workspace.wasm

    runHook postInstall
  '';

  strictDeps = true;

  meta = {
    description = "Zellij plugin for applying layouts to current zellij session";
    homepage = "https://github.com/vdbulcke/zellij-workspace";
    changelog = "https://github.com/vdbulcke/zellij-workspace/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ilkecan ];
    mainProgram = null;
    platforms = lib.platforms.linux;
  };
}
