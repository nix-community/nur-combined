{ lib, buildGoModule, sources }:

buildGoModule rec {
  pname = "mbtileserver";
  version = lib.substring 0 7 src.rev;
  src = sources.mbtileserver;

  modSha256 = "1brhj1pczaz7p1d3r3bzkbd3d14zqcbr96r1s8z134lq6axqhb7q";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
