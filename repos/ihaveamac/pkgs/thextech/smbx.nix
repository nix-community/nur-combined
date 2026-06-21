{
  lib,
  fetchzip,
  p7zip,
  thextech,
}:

thextech.wrapGame {
  packId = "smbx";
  gameName = "Super Mario Bros. X";
  gameDir = "smbx13";
  gameSrc = fetchzip {
    url = "https://github.com/TheXTech/TheXTech/releases/download/v${thextech.version}/thextech-smbx13-assets-full-v${thextech.version}.7z";
    hash = "sha256-btaZ28xuh/Rd9epuwck4ton4ctmEpYQi3+EFaQ2bqgQ=";
    nativeBuildInputs = [ p7zip ];
    stripRoot = false;
  };
  desktopGenericName = "SMBX";
  desktopComment = "The Mario fan-game originally created by Andrew Spinks also known as a creator of the Terraria game.";
  meta = with lib; {
    description = "Super Mario Bros. X, on TheXTech engine";
    homepage = "https://wohlsoft.ru/projects/TheXTech/";
    platforms = platforms.all;
    mainProgram = "thextech-smbx";
  };
}
