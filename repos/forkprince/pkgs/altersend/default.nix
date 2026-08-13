{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "altersend";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "Send files directly between devices over the internet - no cloud storage, no size limits";
    homepage = "https://altersend.com";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
in
  if stdenvNoCC.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else
    appimageTools.wrapType2 {
      inherit pname version src meta;
    }
