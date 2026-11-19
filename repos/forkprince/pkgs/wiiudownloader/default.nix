{
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "wiiudownloader";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "Cross-platform Wii U NUS downloader for Windows, macOS & Linux";
    homepage = "https://github.com/Xpl0itU/WiiUDownloader";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "WiiUDownloader";
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

      desktopId = "WiiUDownloader";
      desktopName = "WiiUDownloader";
      desktopComment = "Cross-platform Wii U NUS downloader";
      exec = "WiiUDownloader %U";
      icon = "WiiUDownloader";
      categories = ["Game"];
    }
