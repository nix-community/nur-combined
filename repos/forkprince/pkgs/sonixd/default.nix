{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "sonixd";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Full-featured Subsonic/Jellyfin compatible desktop music player";
    homepage = "https://github.com/jeffvli/sonixd";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [onny Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = pname;
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [unzip];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "Sonixd";
      categories = ["AudioVideo" "Music"];
      exec = pname;
    }
