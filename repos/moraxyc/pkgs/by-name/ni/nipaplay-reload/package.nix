{
  lib,
  sources,
  stdenvNoCC,
  callPackage,
}:
let
  inherit (stdenvNoCC.hostPlatform) system isDarwin;
  source =
    sources."nipaplay-reload-${if isDarwin then "darwin" else system}"
      or (throw "Unsupported system: ${system}");
in
callPackage (if isDarwin then ./darwin.nix else ./linux.nix) {
  inherit (source) version src;
  pname = "nipaplay-reload";

  meta = {
    description = "Modern, cross-platform local video player that supports bullet comments and multiple subtitle formats.";
    homepage = "https://github.com/MCDFsteve/NipaPlay-Reload";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "nipaplay-reload";
  };
}
