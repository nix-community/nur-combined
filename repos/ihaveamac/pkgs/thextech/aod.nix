{
  lib,
  fetchzip,
  p7zip,
  thextech,
}:

thextech.wrapGame {
  packId = "aod";
  gameName = "Adventures of Demo";
  gameDir = "aod";
  gameSrc = fetchzip {
    url = "https://github.com/TheXTech/TheXTech/releases/download/v${thextech.version}/thextech-adventure-of-demo-assets-full-v${thextech.version}.7z";
    hash = "sha256-x2Se2k21cumAsQ7BS3gt4GU56McK9CC1YHLWzS1zBxw=";
    nativeBuildInputs = [ p7zip ];
    stripRoot = false;
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
