{
  makeDesktopItem,
  appimageTools,
  stdenvNoCC,
  fetchurl,
  _7zz,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "tinywiibackupmanager";
  inherit (ver) version;
  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  meta = {
    description = "A tiny game backup and homebrew app manager for the Wii";
    homepage = "https://github.com/mq1/TinyWiiBackupManager";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "TinyWiiBackupManager";
  };
in
  if stdenvNoCC.hostPlatform.isDarwin
  then
    stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else let
    desktopItem = makeDesktopItem {
      name = "TinyWiiBackupManager";
      desktopName = "TinyWiiBackupManager";
      comment = "A tiny game backup and homebrew app manager for the Wii";
      exec = "TinyWiiBackupManager %U";
      icon = "TinyWiiBackupManager";
      terminal = false;
      categories = ["Game"];
    };
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${desktopItem}/share/applications/*.desktop \
          $out/share/applications/TinyWiiBackupManager.desktop
      '';
    }
