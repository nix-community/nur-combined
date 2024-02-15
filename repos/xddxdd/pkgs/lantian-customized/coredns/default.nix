{
  sources,
  lib,
  buildGoModule,
  ...
} @ args:
buildGoModule rec {
  inherit (sources.coredns-lantian) pname version src;

  vendorHash = "sha256-NnvFd2V3z3FAmNodyK0yN2r2sYEaJzbs+jIxz0Nj8Ik=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/xddxdd/coredns";
    description = "CoreDNS with Lan Tian's modifications";
    license = licenses.asl20;
  };
}
