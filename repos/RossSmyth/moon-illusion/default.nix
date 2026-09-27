{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "moon-illusion";
  version = "1.3.2";
  gameName = "Moon Illusion";

  src = fetchItchIo {
    name = "MoonIllusion-${finalAttrs.version}-linux.tar.bz2";
    gameUrl = "https://uraalice.itch.io/moon-illusion";
    upload = "16902469";
    hash = "sha256-aw1Xsdi53Et4i4PlxnkY1kFSschzDaym4Fxu5ZgrjN8=";
  };
})
