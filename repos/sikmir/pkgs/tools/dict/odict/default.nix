{ lib, buildGoModule, sources }:

buildGoModule {
  pname = "odict-unstable";
  version = lib.substring 0 10 sources.odict.date;

  src = sources.odict;

  vendorSha256 = "083mvrgpv9hyfmi26sankv940qp0bmyr55jm33dx1ivhd2xhkg78";

  meta = with lib; {
    inherit (sources.odict) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
