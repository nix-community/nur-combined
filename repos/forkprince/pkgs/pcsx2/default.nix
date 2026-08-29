{
  stdenvNoCC,
  fetchurl,
  pcsx2,
  lib,
  ...
}:
if stdenvNoCC.hostPlatform.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "pcsx2";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    unpackPhase = ''
      runHook preUnpack
      tar xf $src
      for d in ./*; do [ -d "$d" ] && mv "$d" PCSX2.app && break; done
      runHook postUnpack
    '';

    meta = {
      description = "Playstation 2 emulator (precompiled binary, repacked from official website)";
      homepage = "https://pcsx2.net/";
      maintainers = with lib.maintainers; [Prinky];
      license = with lib.licenses; [gpl3Plus lgpl3Plus];
    };
  })
else pcsx2
