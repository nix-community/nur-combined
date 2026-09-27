{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "lessons-in-love";
  version = "0.61.0";
  gameName = "Lessons in Love";

  src = fetchItchIo {
    name = "lessons-in-love-windows.zip";
    gameUrl = "https://djnostyle.itch.io/lessons-in-love";
    upload = "6262900";
    hash = "sha256-Thw+wRWnt/c7275GmiYjBNlv0t0gZGbFUhxPRbakQDw=";
  };
})
