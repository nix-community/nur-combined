{ sources
, lib
, buildGoModule
, ...
} @ args:

buildGoModule rec {
  inherit (sources.coredns-lantian) pname version src;

  vendorSha256 = "sha256-F53X6yowczNzls9Kle/zDDbzWnkQNsVSX4pVRMxCrKM=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/xddxdd/coredns";
    description = "CoreDNS with Lan Tian's modifications";
    license = licenses.asl20;
  };
}
