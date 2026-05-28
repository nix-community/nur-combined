{
  stdenvNoCC,
  fetchurl,
  heroic,
  unzip,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "heroic";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Native GOG, Epic, and Amazon Games Launcher for Linux, Windows and Mac";
      homepage = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher";
      changelog = "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/tag/v${ver.version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
else heroic
