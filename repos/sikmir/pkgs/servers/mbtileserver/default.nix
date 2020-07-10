{ lib, buildGoModule, sources }:
let
  pname = "mbtileserver";
  date = lib.substring 0 10 sources.mbtileserver.date;
  version = "unstable-" + date;
in
buildGoModule {
  inherit pname version;
  src = sources.mbtileserver;

  vendorSha256 = null;

  meta = with lib; {
    inherit (sources.mbtileserver) description homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
