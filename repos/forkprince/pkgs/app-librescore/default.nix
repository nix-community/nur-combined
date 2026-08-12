{
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenvNoCC.hostPlatform.system;

  pname = "app-librescore";
  src = fetchurl (lib.helper.getPlatform platform ver);

  inherit (ver) version;

  meta = {
    description = "App to download sheet music";
    homepage = "https://github.com/LibreScore/app-librescore";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.mit;
    # platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    # FIXME: Linux version does not work
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
