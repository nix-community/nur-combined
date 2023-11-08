{
  buildGoModule,
  lib,
  sources,
  ...
} @ args:
buildGoModule rec {
  pname = "bird-lgproxy-go";
  inherit (sources.bird-lg-go) version src;
  vendorSha256 = "sha256-nOXRbnPFVrejNTAlvAQPoOt2Mm4pQ8D/n7ovDmLf9cM=";

  modRoot = "proxy";

  meta = with lib; {
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3;
  };
}
