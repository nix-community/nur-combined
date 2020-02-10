{ lib, buildGoModule, mbtileserver }:

buildGoModule rec {
  pname = "mbtileserver";
  version = lib.substring 0 7 src.rev;
  src = mbtileserver;

  modSha256 = "147rpf3dd0md7pm7yfniy139kv3fb3kmyp82slpjrf8xdqgbrpk0";

  meta = with lib; {
    description = mbtileserver.description;
    homepage = mbtileserver.homepage;
    license = licenses.isc;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
