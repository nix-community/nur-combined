{ buildGoModule
, lib
, sources
, ...
} @ args:

buildGoModule rec {
  pname = "etherguard";
  inherit (sources.etherguard) version src;
  vendorSha256 = "sha256-9+zpQ/AhprMMfC4Om64GfQLgms6eluTOB6DdnSTNOlk=";

  meta = with lib; {
    description = "Layer2 version of wireguard with Floyd Warshall implement in go";
    homepage = "https://github.com/KusakabeShi/EtherGuard-VPN";
    license = licenses.mit;
  };
}
