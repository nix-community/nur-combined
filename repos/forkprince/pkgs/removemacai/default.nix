{
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation {
    pname = "removemacai";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 removemacai $out/bin/removemacai
      install -Dm644 THIRD-PARTY-NOTICES.md $out/share/doc/removemacai/THIRD-PARTY-NOTICES.md
      runHook postInstall
    '';

    meta = {
      description = "Turn off Apple Intelligence on macOS 27 and remove its models";
      homepage = "https://github.com/omlahore/RemoveMacAI";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.mit;
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "removemacai";
    };
  }
