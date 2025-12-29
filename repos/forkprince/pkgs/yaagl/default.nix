{
  region ? "cn",
  game ? "gi",
  stdenvNoCC,
  fetchurl,
  lib,
  ...
}: let
  ver = lib.helper.read ./version.json;
  type = "${game}-${region}";

  title = lib.strings.toUpper "${game} (${region})";
in
  stdenvNoCC.mkDerivation {
    pname = "yaagl-${type}";
    inherit (ver) version;

    src = fetchurl (lib.helper.getVariant type ver);

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

    meta = {
      description = "Yet another anime game launcher for ${title}";
      homepage = "https://github.com/yaagl/yet-another-anime-game-launcher";
      license = lib.licenses.mit;
      maintainers = ["Prinky"];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
