{ lib, buildGoModule, sources }:
let
  pname = "odict";
  date = lib.substring 0 10 sources.odict.date;
  version = "unstable-" + date;
in
buildGoModule {
  inherit pname version;
  src = sources.odict;

  vendorSha256 = "083mvrgpv9hyfmi26sankv940qp0bmyr55jm33dx1ivhd2xhkg78";

  meta = with lib; {
    inherit (sources.odict) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
