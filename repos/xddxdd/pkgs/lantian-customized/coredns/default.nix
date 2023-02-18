{ sources
, lib
, buildGoModule
, ...
} @ args:

buildGoModule rec {
  inherit (sources.coredns-lantian) pname version src;

  vendorSha256 = "sha256-PzwFE6xTHjzD3SiTbajQ9IBrlpjKgYD8ipbyfQIfrCk=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/xddxdd/coredns";
    description = "CoreDNS with Lan Tian's modifications";
    license = licenses.asl20;
  };
}
