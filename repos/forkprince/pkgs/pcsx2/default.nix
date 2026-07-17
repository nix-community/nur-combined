{
  stdenvNoCC,
  fetchurl,
  pcsx2,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "pcsx2";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    meta = {
      description = "Playstation 2 emulator (precompiled binary, repacked from official website)";
      homepage = "https://pcsx2.net/";
      maintainers = with lib.maintainers; [Prinky];
      license = with lib.licenses; [gpl3Plus lgpl3Plus];
    };
  })
else pcsx2
