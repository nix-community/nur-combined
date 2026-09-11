{
  autoPatchelfHook,
  callPackage,
  lib,
  source ? callPackage ./source.nix { },
  stdenv,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cargo-pretty";
  inherit (source) version src;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 cargo-pretty "$out/bin/cargo-pretty"

    runHook postInstall
  '';

  meta = {
    description = "Cargo wrapper with a live status view for build, run and test";
    homepage = "https://github.com/romancitodev/cargo-pretty";
    changelog = "https://github.com/romancitodev/cargo-pretty/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cargo-pretty";
  };
})
