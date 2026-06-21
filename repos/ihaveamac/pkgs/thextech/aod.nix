{
  lib,
  fetchurl,
  thextech,
}:

thextech.wrapGame {
  packId = "aod";
  gameName = "Adventures of Demo";
  gameDir = "aod";
  gameSrc = fetchurl {
    url = "https://github.com/TheXTech/TheXTech/releases/download/v${thextech.version}/thextech-adventure-of-demo-assets-full-v${thextech.version}.7z";
    hash = "sha256-ekQqnHoPP9W9/G9b5/SpMycRi+i3v8QwHMEpe4N9jkQ=";
  };
  desktopGenericName = "AOD";
  desktopComment = "This is a small game based on the TheXTech engine with the A2XT content pack made by the Talkhaus community (visit their forum here https://talkhaus.raocow.com). It's a remix of old SMBX episodes such as \"The Invasion 1\", brought to the A2XT universe!";
  meta = with lib; {
    description = "Adventures of Demo, on TheXTech engine";
    homepage = "https://wohlsoft.ru/projects/TheXTech/";
    platforms = platforms.all;
    mainProgram = "thextech-aod";
  };
}
