{
  autoPatchelfHook,
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "freebuff";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [autoPatchelfHook];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      install -Dm755 freebuff $out/bin/freebuff
      install -Dm644 tree-sitter.wasm $out/bin/tree-sitter.wasm

      runHook postInstall
    '';

    meta = {
      description = "The 100% free coding agent (terminal)";
      longDescription = ''
        Freebuff is a free coding agent funded by ads instead of a subscription.
        Threads live in the cloud, so a task can be started in the terminal and continued from the desktop, phone or browser.
      '';
      homepage = "https://freebuff.com/";
      changelog = "https://github.com/CodebuffAI/codebuff-community/releases/tag/freebuff-v${ver.version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "freebuff";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
