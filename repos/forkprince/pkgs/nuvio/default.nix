{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "nuvio";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Watch your library, anywhere";
    homepage = "https://nuvio.tv/";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3;
    platforms = lib.platforms.darwin ++ ["x86_64-linux"];
    mainProgram = "nuvio";
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

      desktopName = "Nuvio";
      categories = ["AudioVideo" "Video"];
    }
