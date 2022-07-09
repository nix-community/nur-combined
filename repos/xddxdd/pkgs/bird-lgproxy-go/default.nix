{ buildGoModule
, lib
, sources
, ...
} @ args:

buildGoModule rec {
  pname = "bird-lgproxy-go";
  inherit (sources.bird-lg-go) version src;
  vendorSha256 = "sha256-b4Md/LdwNhbKVXdnZ+LO4J/Y0hxBrCcvTW8J1mmysaY=";

  modRoot = "proxy";

  meta = with lib; {
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3;
  };
}
