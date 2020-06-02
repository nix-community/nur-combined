{ lib, buildGoModule, sources }:

buildGoModule rec {
  pname = "mbtileserver";
  version = lib.substring 0 7 src.rev;
  src = sources.mbtileserver;

  vendorSha256 = null;

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
