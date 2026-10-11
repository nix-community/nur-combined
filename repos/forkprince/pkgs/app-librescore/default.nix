{
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
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "app-librescore";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else
    lib.helper.mkAppImage {
      inherit pname version src meta;

      desktopName = "LibreScore";
      categories = ["AudioVideo" "Music"];
    }
