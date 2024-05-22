{
  buildGoModule,
  lib,
  sources,
  ...
}:
buildGoModule rec {
  pname = "bird-lgproxy-go";
  inherit (sources.bird-lg-go) version src;
  vendorHash = "sha256-nBTLQUX68f98D0RTlyX0gnvhQ+bu8d3Vv67J/YoXJxs=";

  modRoot = "proxy";

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3Only;
  };
}
