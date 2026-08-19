{
  callPackage,
  lib,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "flutter-rust-bridge-codegen";
  inherit (source) version src;

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 flutter_rust_bridge_codegen "$out/bin/flutter_rust_bridge_codegen"

    runHook postInstall
  '';

  meta = {
    description = "Code generator for Flutter/Dart and Rust bindings";
    homepage = "https://github.com/fzyzcjy/flutter_rust_bridge";
    changelog = "https://github.com/fzyzcjy/flutter_rust_bridge/releases/tag/v${source.version}";
    license = lib.licenses.mit;
    mainProgram = "flutter_rust_bridge_codegen";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
