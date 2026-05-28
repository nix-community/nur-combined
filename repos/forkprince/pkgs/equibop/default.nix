{
  stdenvNoCC,
  fetchurl,
  equibop,
  unzip,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "equibop";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Custom Discord App aiming to give you better performance and improve linux support";
      homepage = "https://github.com/Equicord/Equibop";
      changelog = "https://github.com/Equicord/Equibop/releases/tag/v${ver.version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [Prinky];
    };
  })
else equibop
