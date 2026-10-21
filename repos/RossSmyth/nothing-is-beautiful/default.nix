{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "nothing-is-beautiful";
  version = "1.0";
  gameName = "Nothing is Beautiful Demo";

  src = fetchItchIo {
    name = "Nothing is Beautiful Demo (PC).zip";
    gameUrl = "https://djnostyle.itch.io/nothing-is-beautiful";
    upload = "1708231";
    hash = "sha256-5t5heDvqUYmB9yg1ayOcekhdOgHlZWy3Ot5myJ8lltc=";
  };
})
