{
  lib,
  fetchurl,
  makePakeApp,
}:

makePakeApp {
  pname = "apple-music";
  appName = "Apple Music";
  url = "https://music.apple.com/";
  icon = fetchurl {
    url = "https://web.archive.org/web/20260114093215if_/https://store-images.s-microsoft.com/image/apps.62962.14205055896346606.c235e3d6-fbce-45bb-9051-4be6c2ecba8f.28d7c3cb-0c64-40dc-9f24-53326f80a6dd?h=307";
    hash = "sha256-SP81Sin+zMalZxwj8zwDSxdsCLDa7D3IeOz3Li80DNk=";
  };
  meta = {
    description = "Desktop application for Apple Music (packaged via Pake)";
    homepage = "https://music.apple.com/";
    license = lib.licenses.unfree;
    mainProgram = "apple-music";
  };
}
