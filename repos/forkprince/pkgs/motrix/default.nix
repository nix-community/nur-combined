{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "motrix";
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);
  inherit (ver) version;

  meta = {
    description = "A full-featured download manager";
    homepage = "https://motrix.app/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "motrix";
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

      desktopName = "Motrix";
      startupWMClass = "Motrix";
      categories = ["Network" "Utility"];
      extraDesktopItem = {
        mimeTypes = [
          "application/x-bittorrent"
          "x-scheme-handler/magnet"
          "x-scheme-handler/motrix"
        ];
      };
    }
