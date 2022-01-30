{ buildGoModule
, sources
, ...
} @ args:

buildGoModule rec {
  pname = "bird-lg-go";
  inherit (sources.bird-lg-go) version src;
  vendorSha256 = "101z8afd3wd9ax3ln2jx1hsmkarps5jfzyng4xmvdr4m4hd9basq";

  modRoot = "frontend";
}
