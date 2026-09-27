{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "melt";
  version = "1.2";
  gameName = "Melt";

  src = fetchItchIo {
    name = "Melt-${finalAttrs.version}-pc.zip";
    gameUrl = "https://remidie.itch.io/melt";
    upload = "14290312";
    hash = "sha256-r10cvqgltD+bHn7gpU4j//0O10fWQkjJoHxCeeQEWUs=";
  };
})
