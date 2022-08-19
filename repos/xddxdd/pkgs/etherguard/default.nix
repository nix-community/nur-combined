{ buildGoModule
, lib
, sources
, ...
} @ args:

buildGoModule rec {
  pname = "etherguard";
  inherit (sources.etherguard) version src;
  vendorSha256 = "sha256-9+zpQ/AhprMMfC4Om64GfQLgms6eluTOB6DdnSTNOlk=";
}
