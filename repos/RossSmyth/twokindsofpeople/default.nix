{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "two-kinds-of-people";
  version = "1.0";
  gameName = "Two Kinds of People";

  src = fetchItchIo {
    name = "tkop-${finalAttrs.version}-pc.zip";
    gameUrl = "https://lacunova.itch.io/tkop";
    upload = "18254531";
    hash = "sha256-y0to2H0kXzQsOjI97IYz8sOzJBa8KQlbvN6wh6l+PtA=";
  };
})
