{
  retroarch-full,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "retroarch";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Multi-platform emulator frontend for libretro cores";
      homepage = "https://libretro.com";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Plus;
    };
  })
else retroarch-full
