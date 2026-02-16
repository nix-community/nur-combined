{
  stdenvNoCC,
  lmstudio,
  fetchurl,
  undmg,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;

  src = fetchurl (lib.helper.getSingle ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "lmstudio";

    inherit version src;

    nativeBuildInputs = [undmg];

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      app=$(find . -maxdepth 2 -name "*.app" -type d | head -n1)
      cp -R "$app" $out/Applications/
      runHook postInstall
    '';

    postFixup = ''
      sed -i 's|_0x345c2d && !_0x44174f\.startsWith(_0x4ce401(0x1185)) && \(|false && \(|g' "$out/Applications/LM Studio.app/Contents/Resources/app/.webpack/main/index.js"
    '';

    meta = {
      description = "LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models (LLMs)";
      homepage = "https://lmstudio.ai/";
      license = lib.licenses.unfree;
      mainProgram = "lm-studio";
      maintainers = ["Prinky"];
      platforms = ["aarch64-darwin"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else lmstudio
