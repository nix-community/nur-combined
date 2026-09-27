{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "oblivion2666demo";
  # Versions are not labled, so just the date.
  version = "1.0-2026-09-13";
  gameName = "Oblivion 2666 - Demo Disc";

  src = fetchItchIo {
    name = "oblivion2666demo-win-linux.zip";
    gameUrl = "https://solarautomata.itch.io/oblivion2666demo";
    upload = "19222206";
    hash = "sha256-QEcP2I4D6VieQkMshaeRN1KzK4uLH6a0IZj/wVF1cGI=";
  };
})
