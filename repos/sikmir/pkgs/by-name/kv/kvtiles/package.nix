{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "kvtiles";
  version = "0-unstable-2024-01-24";

  src = fetchFromGitHub {
    owner = "akhenakh";
    repo = "kvtiles";
    rev = "fa777c1f1874779101dfcd7f0d8ae925d0acaf21";
    hash = "sha256-PQUKHnn3Yb1mgbW32ftQrOYcOWFDpaJK6jsirAz39mk=";
  };

  vendorHash = "sha256-dGhoGKddIsH82qKYWvh9aaRtZB0wa65+wIwOYjz5Hvw=";

  meta = {
    description = "Self hosted maps, PMTiles, MBTiles key value storage and server";
    homepage = "https://github.com/akhenakh/kvtiles";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "kvtilesd";
  };
})
