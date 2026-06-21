{
  lib,
  fetchurl,
  thextech,
}:

thextech.wrapGame {
  packId = "smbx";
  gameName = "Super Mario Bros. X";
  gameDir = "smbx13";
  gameSrc = fetchurl {
    url = "https://github.com/TheXTech/TheXTech/releases/download/v${thextech.version}/thextech-smbx13-assets-full-v${thextech.version}.7z";
    hash = "sha256-SwPW0uq1RBUJxNknCpQA+1MfqEBzuA9he90n3Kx9mNE=";
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
