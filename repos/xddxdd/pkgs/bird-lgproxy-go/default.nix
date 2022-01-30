{ buildGoModule
, sources
, ...
} @ args:

buildGoModule rec {
  pname = "bird-lgproxy-go";
  inherit (sources.bird-lg-go) version src;
  vendorSha256 = "1viqzzz884rasfrlj4wbq0irkvd6s9jp70qgn5218jriiq4mxdpc";

  modRoot = "proxy";
}
