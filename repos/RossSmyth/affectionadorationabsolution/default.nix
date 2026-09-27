{
  lib,
  buildRenpyGame,
  fetchItchIo,
}:
buildRenpyGame (finalAttrs: {
  pname = "affectionadorationabsolution";
  version = "1.0";
  gameName = "Affection/Adoration/Absolution";

  src = fetchItchIo {
    name = "affectionadorationabsolution-0.1-pc.zip";
    gameUrl = "https://mismatched-wings.itch.io/affectionadorationabsolution";
    upload = "15247939";
    hash = "sha256-wskb7BgeayQn0H4T5Jei5zAmGsoSjpD1x/jd2IVxc5M=";
  };
})
