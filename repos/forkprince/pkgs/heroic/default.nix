{
  stdenvNoCC,
  fetchurl,
  heroic,
  unzip,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  src = fetchurl (lib.helper.getPlatform platform ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "heroic";

    inherit version src;

    nativeBuildInputs = [unzip];

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
      description = "Native GOG, Epic, and Amazon Games Launcher for Linux, Windows and Mac";
      homepage = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher";
      changelog = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/tag/v${version}";
      license = lib.licenses.gpl3Only;
      maintainers = ["Prinky"];
      platforms = lib.platforms.darwin;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else heroic
