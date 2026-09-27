{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "ladys-pyre";
  version = "1.0";
  gameName = "Lady's Pyre";

  src = fetchItchIo {
    name = "aladyspyre-pc.zip";
    gameUrl = "https://uraalice.itch.io/ladys-pyre";
    upload = "18310082";
    hash = "sha256-y2bRZfgwoBlx5jN/QeZC4L6ZVaqHt7XTb/bXk4NKH3c=";
  };
})
