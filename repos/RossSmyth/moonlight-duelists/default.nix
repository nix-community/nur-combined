{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "moonlight-duelists";
  version = "1.0.3";
  gameName = "Moonlight Duelists";

  src = fetchItchIo {
    name = "MoonlightDuelists-${finalAttrs.version}-linux.tar.bz2";
    gameUrl = "https://kayinad.itch.io/moonlight-duelists";
    upload = "17011576";
    hash = "sha256-sYniHdVeWIVl7sUMHoPHX0Unp5EoOqXUz6SkrxdkDZQ=";
  };
})
