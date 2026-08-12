{
  obs-studio,
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
    pname = "obs-studio";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

    nativeBuildInputs = [_7zz];

    meta = {
      description = "Free and open source software for video recording and live streaming";
      longDescription = ''
        This project is a rewrite of what was formerly known as "Open Broadcaster
        Software", software originally designed for recording and streaming live
        video content, efficiently
      '';
      homepage = "https://obsproject.com";
      maintainers = with lib.maintainers; [Prinky];
      license = [lib.licenses.gpl2Plus];
    };
  })
else obs-studio
