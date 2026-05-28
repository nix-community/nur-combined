{
  region ? "cn",
  game ? "gi",
  stdenvNoCC,
  fetchurl,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  type = "${game}-${region}";

  title = lib.strings.toUpper "${game} (${region})";
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "yaagl-${type}";
    inherit (ver) version;

    src = fetchurl (lib.helper.getVariant type ver);

    meta = {
      description = "Yet another anime game launcher for ${title}";
      homepage = "https://github.com/yaagl/yet-another-anime-game-launcher";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
