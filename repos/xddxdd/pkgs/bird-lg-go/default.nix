{ buildGoModule
, lib
, sources
, ...
} @ args:

buildGoModule rec {
  pname = "bird-lg-go";
  inherit (sources.bird-lg-go) version src;
  vendorSha256 = "sha256-p1qwhxLXKcVOT2pspuN2aV2juvHRO17QqY3QnXeWDZc=";

  modRoot = "frontend";

  meta = with lib; {
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3;
  };
}
