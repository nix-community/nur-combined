{ lib, buildGoModule, sources }:

buildGoModule rec {
  pname = "odict";
  version = lib.substring 0 7 src.rev;
  src = sources.odict;

  vendorSha256 = "083mvrgpv9hyfmi26sankv940qp0bmyr55jm33dx1ivhd2xhkg78";

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
