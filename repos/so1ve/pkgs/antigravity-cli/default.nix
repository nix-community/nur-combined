{
  autoPatchelfHook,
  callPackage,
  lib,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation {
  pname = "antigravity-cli";
  inherit (source) version src;

  strictDeps = true;

  sourceRoot = ".";
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 antigravity $out/bin/agy

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Google's Go-based terminal user interface (TUI) agent client";
    homepage = "https://antigravity.google";
    changelog = "https://antigravity.google/docs/changelog";
    license = lib.licenses.unfree;
    mainProgram = "agy";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
